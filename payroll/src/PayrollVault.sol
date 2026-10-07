// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.29;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract PayrollVault {
    enum Status {
        None,
        Active,
        Paused,
        Canceled
    }

    enum OfferStatus {
        None,
        Open,
        Accepted,
        Rejected,
        Revoked
    }

    struct Employer {
        uint256 balance;
        uint256 debt;
        uint256 totalRate;
        uint256 lastUpdate;
    }

    struct Stream {
        address employer;
        address employee;
        uint256 ratePerSec;
        uint256 lastUpdate;
        uint256 anchor;
        uint256 period;
        Status status;
        uint256 earnedCum;
        uint256 unlockedCum;
        uint256 withdrawnCum;
    }

    struct Offer {
        address employer;
        address employee;
        uint256 ratePerSec;
        uint256 period;
        uint256 expiresAt;
        OfferStatus status;
        uint256 streamId;
    }

    struct Change {
        uint256 ratePerSec;
        uint256 period;
        bool pending;
    }

    error NotEmployer();
    error NotEmployee();
    error InvalidAmount();
    error InvalidAddress();
    error InvalidRate();
    error InvalidPeriod();
    error InvalidExpiry();
    error InvalidStatus();
    error OfferExpired();
    error NoPendingChange();
    error NoChange();
    error NotARaise();
    error LengthMismatch();
    error InsufficientFreeBalance();
    error InsufficientPoolBalance();
    error TransferFailed();

    event Deposited(address indexed employer, uint256 amount);
    event ExcessWithdrawn(address indexed employer, address to, uint256 amount);
    event OfferProposed(
        uint256 indexed offerId,
        address indexed employer,
        address indexed employee,
        uint256 ratePerSec,
        uint256 period,
        uint256 expiresAt
    );
    event OfferAccepted(uint256 indexed offerId, uint256 indexed streamId);
    event OfferRejected(uint256 indexed offerId);
    event OfferRevoked(uint256 indexed offerId);
    event Raised(uint256 indexed streamId, uint256 oldRate, uint256 newRate);
    event ChangeProposed(uint256 indexed streamId, uint256 ratePerSec, uint256 period);
    event ChangeAccepted(uint256 indexed streamId, uint256 ratePerSec, uint256 period);
    event ChangeRejected(uint256 indexed streamId);
    event Paused(uint256 indexed streamId);
    event Resumed(uint256 indexed streamId);
    event Canceled(uint256 indexed streamId);
    event Withdrawn(uint256 indexed streamId, address to, uint256 amount);

    uint256 internal constant SCALE = 1e18;
    uint256 public constant MONTH = 30 days;
    uint256 public constant MAX_PERIOD = 365 days;

    IERC20 public immutable token;

    mapping(address => Employer) public employers;
    mapping(uint256 => Stream) public streams;
    mapping(uint256 => Offer) public offers;
    mapping(uint256 => Change) public pendingChange;

    uint256 public nextStreamId = 1;
    uint256 public nextOfferId = 1;

    mapping(address => uint256[]) internal _streamsOfEmployer;
    mapping(address => uint256[]) internal _streamsOfEmployee;
    mapping(address => uint256[]) internal _offersOfEmployer;
    mapping(address => uint256[]) internal _offersOfEmployee;

    constructor(IERC20 token_) {
        token = token_;
    }

    function deposit(uint256 amount) external {
        if (amount == 0) revert InvalidAmount();
        _syncEmployer(msg.sender);
        employers[msg.sender].balance += amount;
        emit Deposited(msg.sender, amount);
        _pull(msg.sender, amount);
    }

    function withdrawExcess(uint256 amount, address to) external {
        if (to == address(0)) revert InvalidAddress();
        _syncEmployer(msg.sender);
        Employer storage e = employers[msg.sender];
        if (amount == 0 || amount > _free(e.balance, e.debt)) revert InsufficientFreeBalance();
        e.balance -= amount;
        emit ExcessWithdrawn(msg.sender, to, amount);
        _push(to, amount);
    }

    function propose(address employee, uint256 ratePerSec, uint256 period, uint256 expiresAt)
        public
        returns (uint256 offerId)
    {
        if (employee == address(0)) revert InvalidAddress();
        if (ratePerSec == 0) revert InvalidRate();
        _checkPeriod(period);
        if (expiresAt != 0 && expiresAt <= block.timestamp) revert InvalidExpiry();

        offerId = nextOfferId++;
        offers[offerId] = Offer(msg.sender, employee, ratePerSec, period, expiresAt, OfferStatus.Open, 0);
        _offersOfEmployer[msg.sender].push(offerId);
        _offersOfEmployee[employee].push(offerId);
        emit OfferProposed(offerId, msg.sender, employee, ratePerSec, period, expiresAt);
    }

    function batchPropose(
        address[] calldata employees,
        uint256[] calldata rates,
        uint256[] calldata periods,
        uint256[] calldata expiries
    ) external returns (uint256[] memory offerIds) {
        uint256 n = employees.length;
        if (rates.length != n || periods.length != n || expiries.length != n) revert LengthMismatch();
        offerIds = new uint256[](n);
        for (uint256 i; i < n; ++i) {
            offerIds[i] = propose(employees[i], rates[i], periods[i], expiries[i]);
        }
    }

    function revokeOffer(uint256 offerId) external {
        Offer storage o = offers[offerId];
        if (o.employer != msg.sender) revert NotEmployer();
        if (o.status != OfferStatus.Open) revert InvalidStatus();
        o.status = OfferStatus.Revoked;
        emit OfferRevoked(offerId);
    }

    function raise(uint256 streamId, uint256 newRate) external {
        Stream storage s = _employerStream(streamId);
        if (newRate <= s.ratePerSec) revert NotARaise();
        _sync(s);
        if (s.status == Status.Active) employers[s.employer].totalRate += newRate - s.ratePerSec;
        emit Raised(streamId, s.ratePerSec, newRate);
        s.ratePerSec = newRate;
    }

    function proposeChange(uint256 streamId, uint256 newRate, uint256 newPeriod) external {
        Stream storage s = _employerStream(streamId);
        if (newRate == 0) revert InvalidRate();
        _checkPeriod(newPeriod);
        if (newRate == s.ratePerSec && newPeriod == s.period) revert NoChange();
        pendingChange[streamId] = Change(newRate, newPeriod, true);
        emit ChangeProposed(streamId, newRate, newPeriod);
    }

    function pause(uint256 streamId) external {
        Stream storage s = _employerStream(streamId);
        if (s.status != Status.Active) revert InvalidStatus();
        _sync(s);
        employers[s.employer].totalRate -= s.ratePerSec;
        s.status = Status.Paused;
        emit Paused(streamId);
    }

    function resume(uint256 streamId) external {
        Stream storage s = _employerStream(streamId);
        if (s.status != Status.Paused) revert InvalidStatus();
        _sync(s);
        employers[s.employer].totalRate += s.ratePerSec;
        s.status = Status.Active;
        emit Resumed(streamId);
    }

    function cancel(uint256 streamId) external {
        Stream storage s = _employerStream(streamId);
        _sync(s);
        if (s.status == Status.Active) employers[s.employer].totalRate -= s.ratePerSec;
        s.status = Status.Canceled;
        s.unlockedCum = s.earnedCum;
        delete pendingChange[streamId];
        emit Canceled(streamId);
    }

    function acceptOffer(uint256 offerId) external returns (uint256 streamId) {
        Offer storage o = offers[offerId];
        if (o.employee != msg.sender) revert NotEmployee();
        if (o.status != OfferStatus.Open) revert InvalidStatus();
        if (o.expiresAt != 0 && block.timestamp > o.expiresAt) revert OfferExpired();

        _syncEmployer(o.employer);
        employers[o.employer].totalRate += o.ratePerSec;

        streamId = nextStreamId++;
        streams[streamId] = Stream({
            employer: o.employer,
            employee: msg.sender,
            ratePerSec: o.ratePerSec,
            lastUpdate: block.timestamp,
            anchor: block.timestamp,
            period: o.period,
            status: Status.Active,
            earnedCum: 0,
            unlockedCum: 0,
            withdrawnCum: 0
        });
        _streamsOfEmployer[o.employer].push(streamId);
        _streamsOfEmployee[msg.sender].push(streamId);
        o.status = OfferStatus.Accepted;
        o.streamId = streamId;
        emit OfferAccepted(offerId, streamId);
    }

    function rejectOffer(uint256 offerId) external {
        Offer storage o = offers[offerId];
        if (o.employee != msg.sender) revert NotEmployee();
        if (o.status != OfferStatus.Open) revert InvalidStatus();
        o.status = OfferStatus.Rejected;
        emit OfferRejected(offerId);
    }

    function acceptChange(uint256 streamId) external {
        Stream storage s = _employeeStream(streamId);
        Change memory c = pendingChange[streamId];
        if (!c.pending) revert NoPendingChange();
        if (s.status == Status.Canceled) revert InvalidStatus();
        _sync(s);

        Employer storage e = employers[s.employer];
        if (s.status == Status.Active) e.totalRate = e.totalRate - s.ratePerSec + c.ratePerSec;
        s.ratePerSec = c.ratePerSec;
        if (c.period != s.period) {
            s.unlockedCum = s.earnedCum;
            s.anchor = block.timestamp;
            s.period = c.period;
        }
        delete pendingChange[streamId];
        emit ChangeAccepted(streamId, c.ratePerSec, c.period);
    }

    function rejectChange(uint256 streamId) external {
        _employeeStream(streamId);
        if (!pendingChange[streamId].pending) revert NoPendingChange();
        delete pendingChange[streamId];
        emit ChangeRejected(streamId);
    }

    function withdraw(uint256 streamId, uint256 amount, address to) external {
        if (to == address(0)) revert InvalidAddress();
        Stream storage s = _employeeStream(streamId);
        _sync(s);

        Employer storage e = employers[s.employer];
        uint256 available = (s.unlockedCum - s.withdrawnCum) / SCALE;
        if (amount == type(uint256).max) amount = available < e.balance ? available : e.balance;
        if (amount == 0 || amount > available) revert InvalidAmount();
        if (amount > e.balance) revert InsufficientPoolBalance();

        s.withdrawnCum += amount * SCALE;
        e.debt -= amount * SCALE;
        e.balance -= amount;
        emit Withdrawn(streamId, to, amount);
        _push(to, amount);
    }

    function monthlyToRate(uint256 monthly) public pure returns (uint256) {
        return monthly * SCALE / MONTH;
    }

    function earned(uint256 streamId) external view returns (uint256) {
        (uint256 e,) = _accrue(streams[streamId]);
        return e / SCALE;
    }

    function unlocked(uint256 streamId) external view returns (uint256) {
        (, uint256 u) = _accrue(streams[streamId]);
        return u / SCALE;
    }

    function withdrawable(uint256 streamId) external view returns (uint256) {
        Stream storage s = streams[streamId];
        (, uint256 u) = _accrue(s);
        uint256 available = (u - s.withdrawnCum) / SCALE;
        uint256 bal = employers[s.employer].balance;
        return available < bal ? available : bal;
    }

    function nextPayday(uint256 streamId) external view returns (uint256) {
        Stream storage s = streams[streamId];
        if (s.period == 0 || s.status == Status.Canceled || s.status == Status.None) return 0;
        return s.anchor + ((block.timestamp - s.anchor) / s.period + 1) * s.period;
    }

    function totalOwed(address employer) public view returns (uint256) {
        return _ceil(_debtNow(employers[employer]));
    }

    function freeBalance(address employer) public view returns (uint256) {
        Employer storage e = employers[employer];
        return _free(e.balance, _debtNow(e));
    }

    function runway(address employer) external view returns (uint256) {
        Employer storage e = employers[employer];
        if (e.totalRate == 0) return type(uint256).max;
        uint256 debt = _debtNow(e);
        uint256 funds = e.balance * SCALE;
        return funds > debt ? (funds - debt) / e.totalRate : 0;
    }

    function streamsOfEmployer(address employer) external view returns (uint256[] memory) {
        return _streamsOfEmployer[employer];
    }

    function streamsOfEmployee(address employee) external view returns (uint256[] memory) {
        return _streamsOfEmployee[employee];
    }

    function offersOfEmployer(address employer) external view returns (uint256[] memory) {
        return _offersOfEmployer[employer];
    }

    function offersOfEmployee(address employee) external view returns (uint256[] memory) {
        return _offersOfEmployee[employee];
    }

    function _accrue(Stream storage s) internal view returns (uint256 earnedNow, uint256 unlockedNow) {
        uint256 rate = s.status == Status.Active ? s.ratePerSec : 0;
        uint256 last = s.lastUpdate;
        earnedNow = s.earnedCum + rate * (block.timestamp - last);
        if (s.period == 0) return (earnedNow, earnedNow);

        uint256 payday = s.anchor + ((block.timestamp - s.anchor) / s.period) * s.period;
        unlockedNow = payday > last ? s.earnedCum + rate * (payday - last) : s.unlockedCum;
    }

    function _sync(Stream storage s) internal {
        _syncEmployer(s.employer);
        (s.earnedCum, s.unlockedCum) = _accrue(s);
        s.lastUpdate = block.timestamp;
    }

    function _syncEmployer(address employer) internal {
        Employer storage e = employers[employer];
        e.debt = _debtNow(e);
        e.lastUpdate = block.timestamp;
    }

    function _debtNow(Employer storage e) internal view returns (uint256) {
        return e.debt + e.totalRate * (block.timestamp - e.lastUpdate);
    }

    function _free(uint256 balance, uint256 debt) internal pure returns (uint256) {
        uint256 owed = _ceil(debt);
        return balance > owed ? balance - owed : 0;
    }

    function _ceil(uint256 scaled) internal pure returns (uint256) {
        return (scaled + SCALE - 1) / SCALE;
    }

    function _checkPeriod(uint256 period) internal pure {
        if (period > MAX_PERIOD) revert InvalidPeriod();
    }

    function _employerStream(uint256 streamId) internal view returns (Stream storage s) {
        s = streams[streamId];
        if (s.employer != msg.sender) revert NotEmployer();
        if (s.status != Status.Active && s.status != Status.Paused) revert InvalidStatus();
    }

    function _employeeStream(uint256 streamId) internal view returns (Stream storage s) {
        s = streams[streamId];
        if (s.employee != msg.sender) revert NotEmployee();
    }

    function _pull(address from, uint256 amount) internal {
        if (!token.transferFrom(from, address(this), amount)) revert TransferFailed();
    }

    function _push(address to, uint256 amount) internal {
        if (!token.transfer(to, amount)) revert TransferFailed();
    }
}
