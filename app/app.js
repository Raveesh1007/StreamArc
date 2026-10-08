import {
  createPublicClient,
  createWalletClient,
  custom,
  http,
  parseAbi,
  formatUnits,
  parseUnits,
  isAddress,
  getAddress,
  maxUint256,
  zeroAddress,
} from "https://esm.sh/viem@2.21.55";
import cfg from "./config.js";

const q = new URLSearchParams(location.search);
const RPC = q.get("rpc") || cfg.rpc;
const VAULT = q.get("payroll") || cfg.payroll;
const MONTH = 2592000n;
const WEEK = 604800n;
const SCALE = 10n ** 18n;

const chain = {
  id: cfg.chainId,
  name: cfg.name,
  nativeCurrency: { name: "USDC", symbol: "USDC", decimals: 18 },
  rpcUrls: { default: { http: [RPC] } },
  blockExplorers: { default: { name: "Arc Explorer", url: cfg.explorer } },
};

const vaultAbi = parseAbi([
  "function employers(address) view returns (uint256, uint256, uint256, uint256)",
  "function streams(uint256) view returns (address, address, uint256, uint256, uint256, uint256, uint8, uint256, uint256, uint256)",
  "function offers(uint256) view returns (address, address, uint256, uint256, uint256, uint8, uint256)",
  "function pendingChange(uint256) view returns (uint256, uint256, bool)",
  "function earned(uint256) view returns (uint256)",
  "function withdrawable(uint256) view returns (uint256)",
  "function nextPayday(uint256) view returns (uint256)",
  "function totalOwed(address) view returns (uint256)",
  "function freeBalance(address) view returns (uint256)",
  "function runway(address) view returns (uint256)",
  "function streamsOfEmployer(address) view returns (uint256[])",
  "function streamsOfEmployee(address) view returns (uint256[])",
  "function offersOfEmployer(address) view returns (uint256[])",
  "function offersOfEmployee(address) view returns (uint256[])",
  "function deposit(uint256)",
  "function withdrawExcess(uint256, address)",
  "function propose(address, uint256, uint256, uint256) returns (uint256)",
  "function batchPropose(address[], uint256[], uint256[], uint256[]) returns (uint256[])",
  "function revokeOffer(uint256)",
  "function raise(uint256, uint256)",
  "function proposeChange(uint256, uint256, uint256)",
  "function pause(uint256)",
  "function resume(uint256)",
  "function cancel(uint256)",
  "function acceptOffer(uint256) returns (uint256)",
  "function rejectOffer(uint256)",
  "function acceptChange(uint256)",
  "function rejectChange(uint256)",
  "function withdraw(uint256, uint256, address)",
  ...[
    "NotEmployer",
    "NotEmployee",
    "InvalidAmount",
    "InvalidAddress",
    "InvalidRate",
    "InvalidPeriod",
    "InvalidExpiry",
    "InvalidStatus",
    "OfferExpired",
    "NoPendingChange",
    "NoChange",
    "NotARaise",
    "LengthMismatch",
    "InsufficientFreeBalance",
    "InsufficientPoolBalance",
    "TransferFailed",
  ].map((e) => `error ${e}()`),
]);
const erc20Abi = parseAbi([
  "function balanceOf(address) view returns (uint256)",
  "function allowance(address, address) view returns (uint256)",
  "function approve(address, uint256) returns (bool)",
]);

const pub = createPublicClient({ chain, transport: http(RPC) });
let wallet;
let account = q.get("as") && isAddress(q.get("as"), { strict: false }) ? getAddress(q.get("as")) : undefined;
let ticks = {};

const $ = (s) => document.querySelector(s);
const read = (functionName, args) => pub.readContract({ address: VAULT, abi: vaultAbi, functionName, args });
const usd = (v) => Number(formatUnits(v, 6)).toLocaleString("en-US", { style: "currency", currency: "USD" });
const monthly = (rate) => usd((rate * MONTH) / SCALE);
const toRate = (m) => (parseUnits(String(m), 6) * SCALE) / MONTH;
const short = (a) => `${a.slice(0, 6)}…${a.slice(-4)}`;
const addrLink = (a) => `<a href="${cfg.explorer}/address/${a}" target="_blank" rel="noopener">${short(a)}</a>`;
const when = (t) => (t ? new Date(Number(t) * 1000).toLocaleString() : "—");
const STATUS = ["—", "Active", "Paused", "Canceled"];
const OFFER = ["—", "Open", "Accepted", "Rejected", "Revoked"];
const schedule = (p) =>
  p === 0n ? "Every second" : p === WEEK ? "Weekly" : p === MONTH ? "Every 30 days" : `Every ${Number(p) / 86400} days`;
const parseSchedule = (s) =>
  ({ continuous: 0n, weekly: WEEK, monthly: MONTH })[s.trim().toLowerCase()] ?? BigInt(s.trim());

function toast(msg, hash, bad) {
  const el = $("#toast");
  el.className = bad ? "show bad" : "show";
  el.innerHTML = msg + (hash ? ` <a href="${cfg.explorer}/tx/${hash}" target="_blank" rel="noopener">view tx</a>` : "");
  clearTimeout(toast.t);
  toast.t = setTimeout(() => (el.className = ""), bad ? 8000 : 5000);
}

async function tx(label, functionName, args, address = VAULT, abi = vaultAbi) {
  if (!wallet) return toast("Connect a wallet first", null, true);
  toast(`${label}: confirm in your wallet…`);
  try {
    const req = { address, abi, functionName, args, account, chain };
    const gas = await pub.estimateContractGas(req);
    const hash = await wallet.writeContract({ ...req, gas: (gas * 6n) / 5n });
    toast(`${label}: waiting for Arc…`, hash);
    const r = await pub.waitForTransactionReceipt({ hash });
    if (r.status !== "success") throw new Error("Transaction reverted");
    toast(`${label}: done`, hash);
    await refresh();
    return true;
  } catch (e) {
    toast(
      `${label} failed: ${e.walk?.((c) => c.data?.errorName)?.data?.errorName || e.shortMessage || e.message}`,
      null,
      true,
    );
  }
}

async function connect() {
  const eth = window.ethereum;
  if (!eth) return toast("No wallet found. Install MetaMask or Rabby.", null, true);
  [account] = await eth.request({ method: "eth_requestAccounts" });
  account = getAddress(account);
  const chainId = `0x${cfg.chainId.toString(16)}`;
  try {
    await eth.request({ method: "wallet_switchEthereumChain", params: [{ chainId }] });
  } catch (e) {
    if (e.code !== 4902) throw e;
    await eth.request({
      method: "wallet_addEthereumChain",
      params: [
        {
          chainId,
          chainName: chain.name,
          nativeCurrency: chain.nativeCurrency,
          rpcUrls: [cfg.rpc],
          blockExplorerUrls: [cfg.explorer],
        },
      ],
    });
  }
  wallet = createWalletClient({ chain, transport: custom(eth) });
  eth.on?.("accountsChanged", ([a]) => {
    account = a && getAddress(a);
    refresh();
  });
  await refresh();
}

async function loadStream(id) {
  const [s, earned, withdrawable, nextPayday, change] = await Promise.all([
    read("streams", [id]),
    read("earned", [id]),
    read("withdrawable", [id]),
    read("nextPayday", [id]),
    read("pendingChange", [id]),
  ]);
  const [employer, employee, rate, , , period, status] = s;
  return { id, employer, employee, rate, period, status, earned, withdrawable, nextPayday, change };
}

async function loadOffer(id) {
  const [employer, employee, rate, period, expiresAt, status, streamId] = await read("offers", [id]);
  return { id, employer, employee, rate, period, expiresAt, status, streamId };
}

function tickable(s) {
  ticks[s.id] = { base: s.earned, rate: s.status === 1 ? s.rate : 0n, at: Date.now() };
  return `<span class="tick" data-tick="${s.id}">${usd(s.earned)}</span>`;
}

function renderEmployer({ pool, owed, free, runway, streams, offers }) {
  const [balance, , totalRate] = pool;
  const days = runway === maxUint256 ? "No active pay" : `${(Number(runway) / 86400).toFixed(1)} days`;
  $("#stats").innerHTML = [
    ["Pool balance", usd(balance)],
    ["Owed to team", usd(owed)],
    ["Free to withdraw", usd(free)],
    ["Payroll / month", monthly(totalRate)],
    ["Runway", days],
  ]
    .map(([k, v]) => `<div class="stat"><span>${k}</span><b>${v}</b></div>`)
    .join("");
  $("#runway-warn").hidden = !(runway !== maxUint256 && runway < 7n * 86400n);

  $("#team").innerHTML = streams.length
    ? streams
        .map(
          (s) => `<tr>
      <td>#${s.id}</td><td>${addrLink(s.employee)}</td><td>${monthly(s.rate)}</td><td>${schedule(s.period)}</td>
      <td><span class="pill s${s.status}">${STATUS[s.status]}</span>${s.change[2] ? ' <span class="pill">Change pending</span>' : ""}</td>
      <td>${tickable(s)}</td><td>${s.period && s.status !== 3 ? when(s.nextPayday) : "—"}</td>
      <td class="actions">${
        s.status === 3
          ? ""
          : `<button data-act="${s.status === 1 ? "pause" : "resume"}" data-id="${s.id}">${s.status === 1 ? "Pause" : "Resume"}</button>
         <button data-act="raise" data-id="${s.id}">Raise</button>
         <button data-act="change" data-id="${s.id}">Change terms</button>
         <button data-act="cancel" data-id="${s.id}" class="danger">End</button>`
      }</td></tr>`,
        )
        .join("")
    : `<tr><td colspan="8" class="empty">No one on payroll yet. Send an offer above.</td></tr>`;

  $("#sent").innerHTML = offers.length
    ? offers
        .map(
          (
            o,
          ) => `<tr><td>#${o.id}</td><td>${addrLink(o.employee)}</td><td>${monthly(o.rate)}</td><td>${schedule(o.period)}</td>
      <td>${o.expiresAt ? when(o.expiresAt) : "Never"}</td><td><span class="pill o${o.status}">${OFFER[o.status]}</span></td>
      <td class="actions">${o.status === 1 ? `<button data-act="revoke" data-id="${o.id}">Revoke</button>` : ""}</td></tr>`,
        )
        .join("")
    : `<tr><td colspan="7" class="empty">No offers sent.</td></tr>`;
}

function renderEmployee({ streams, offers }) {
  const open = offers.filter((o) => o.status === 1);
  $("#inbox").innerHTML = open.length
    ? open
        .map(
          (o) => `<div class="card offer"><div><b>${monthly(o.rate)}</b> / month from ${addrLink(o.employer)}</div>
      <div class="muted">${schedule(o.period)} · expires ${o.expiresAt ? when(o.expiresAt) : "never"}</div>
      <div class="actions"><button class="primary" data-act="accept" data-id="${o.id}">Accept offer</button>
      <button data-act="reject" data-id="${o.id}">Decline</button></div></div>`,
        )
        .join("")
    : `<p class="empty">No open offers.</p>`;

  $("#pay").innerHTML = streams.length
    ? streams
        .map(
          (s) => `<div class="card pay">
      <div class="row"><span class="muted">From ${addrLink(s.employer)} · #${s.id}</span><span class="pill s${s.status}">${STATUS[s.status]}</span></div>
      <div class="big">${tickable(s)}</div><div class="muted">earned so far · ${monthly(s.rate)} / month · paid ${schedule(s.period).toLowerCase()}</div>
      <div class="row"><div><span class="muted">Ready to withdraw</span><br><b>${usd(s.withdrawable)}</b></div>
      ${s.period && s.status !== 3 ? `<div><span class="muted">Next payday</span><br><b>${when(s.nextPayday)}</b></div>` : ""}
      <button class="primary" data-act="withdraw" data-id="${s.id}" ${s.withdrawable ? "" : "disabled"}>Withdraw</button></div>
      ${
        s.change[2]
          ? `<div class="notice">Your employer proposed new terms: <b>${monthly(s.change[0])}</b> / month, paid ${schedule(s.change[1]).toLowerCase()}.
        <button data-act="acceptChange" data-id="${s.id}">Accept</button> <button data-act="rejectChange" data-id="${s.id}">Decline</button></div>`
          : ""
      }</div>`,
        )
        .join("")
    : `<p class="empty">No pay streams yet. Accept an offer to start getting paid every second.</p>`;
}

async function refresh() {
  $("#who").textContent = account ? short(account) : "";
  $("#connect").textContent = wallet ? "Connected" : "Connect wallet";
  if (VAULT === zeroAddress) return ($("#not-deployed").hidden = false);
  if (!account)
    return ($("#stats").innerHTML = `<p class="muted">Connect a wallet to run payroll or collect your pay.</p>`);
  try {
    const [bal, pool, owed, free, runway, sIds, oIds, eIds, eoIds] = await Promise.all([
      pub
        .readContract({ address: cfg.usdc, abi: erc20Abi, functionName: "balanceOf", args: [account] })
        .catch(() => 0n),
      read("employers", [account]),
      read("totalOwed", [account]),
      read("freeBalance", [account]),
      read("runway", [account]),
      read("streamsOfEmployer", [account]),
      read("offersOfEmployer", [account]),
      read("streamsOfEmployee", [account]),
      read("offersOfEmployee", [account]),
    ]);
    ticks = {};
    $("#balance").textContent = `${usd(bal)} USDC`;
    const [streams, offers, myStreams, myOffers] = await Promise.all([
      Promise.all([...sIds].reverse().map(loadStream)),
      Promise.all([...oIds].reverse().map(loadOffer)),
      Promise.all([...eIds].reverse().map(loadStream)),
      Promise.all([...eoIds].reverse().map(loadOffer)),
    ]);
    renderEmployer({ pool, owed, free, runway, streams, offers });
    renderEmployee({ streams: myStreams, offers: myOffers });
  } catch (e) {
    toast(`Could not load from Arc: ${e.shortMessage || e.message}`, null, true);
  }
}

setInterval(() => {
  const now = Date.now();
  for (const el of document.querySelectorAll("[data-tick]")) {
    const t = ticks[el.dataset.tick];
    if (!t) continue;
    const v = Number(t.base) / 1e6 + (Number(t.rate) / 1e24) * ((now - t.at) / 1000);
    el.textContent = `$${v.toLocaleString("en-US", { minimumFractionDigits: 6, maximumFractionDigits: 6 })}`;
  }
}, 100);
setInterval(() => account && refresh(), 30000);

const actions = {
  pause: (id) => tx("Pause", "pause", [id]),
  resume: (id) => tx("Resume", "resume", [id]),
  cancel: (id) =>
    confirm("End this pay stream? Everything earned so far stays withdrawable.") && tx("End stream", "cancel", [id]),
  revoke: (id) => tx("Revoke offer", "revokeOffer", [id]),
  accept: (id) => tx("Accept offer", "acceptOffer", [id]),
  reject: (id) => tx("Decline offer", "rejectOffer", [id]),
  acceptChange: (id) => tx("Accept new terms", "acceptChange", [id]),
  rejectChange: (id) => tx("Decline new terms", "rejectChange", [id]),
  withdraw: (id) => tx("Withdraw", "withdraw", [id, maxUint256, account]),
  raise: (id) => {
    const m = prompt("New monthly salary in USDC (raises apply instantly):");
    if (m) tx("Raise", "raise", [id, toRate(m)]);
  },
  change: (id) => {
    const m = prompt("New monthly salary in USDC (the employee must accept):");
    if (!m) return;
    const p = prompt("Pay schedule: continuous, weekly or monthly", "continuous");
    if (p) tx("Propose new terms", "proposeChange", [id, toRate(m), parseSchedule(p)]);
  },
};

document.addEventListener("click", (e) => {
  const b = e.target.closest("[data-act]");
  if (b) actions[b.dataset.act](BigInt(b.dataset.id));
});

$("#connect").onclick = () => connect().catch((e) => toast(e.shortMessage || e.message, null, true));

for (const t of document.querySelectorAll("nav button")) {
  t.onclick = () => (location.hash = t.dataset.tab);
}
const showTab = () => {
  const tab = location.hash === "#employee" ? "employee" : "employer";
  for (const t of document.querySelectorAll("nav button")) t.classList.toggle("on", t.dataset.tab === tab);
  for (const s of document.querySelectorAll("main > section")) s.hidden = s.id !== tab;
};
addEventListener("hashchange", showTab);
showTab();

$("#deposit-form").onsubmit = async (e) => {
  e.preventDefault();
  if (!wallet) return toast("Connect a wallet first", null, true);
  const amount = parseUnits(e.target.amount.value, 6);
  const allowance = await pub.readContract({
    address: cfg.usdc,
    abi: erc20Abi,
    functionName: "allowance",
    args: [account, VAULT],
  });
  if (allowance < amount && !(await tx("Approve USDC", "approve", [VAULT, amount], cfg.usdc, erc20Abi))) return;
  if (await tx("Deposit", "deposit", [amount])) e.target.reset();
};

$("#withdraw-form").onsubmit = async (e) => {
  e.preventDefault();
  if (await tx("Withdraw excess", "withdrawExcess", [parseUnits(e.target.amount.value, 6), account])) e.target.reset();
};

$("#offer-form").onsubmit = async (e) => {
  e.preventDefault();
  const f = e.target;
  if (!isAddress(f.employee.value, { strict: false })) return toast("Enter a valid employee address", null, true);
  const days = Number(f.expires.value || 0);
  const expiresAt = days ? (await pub.getBlock()).timestamp + BigInt(Math.round(days * 86400)) : 0n;
  if (
    await tx("Send offer", "propose", [
      getAddress(f.employee.value),
      toRate(f.monthly.value),
      BigInt(f.period.value),
      expiresAt,
    ])
  )
    f.reset();
};

$("#bulk-form").onsubmit = async (e) => {
  e.preventDefault();
  const rows = e.target.csv.value
    .split("\n")
    .map((l) => l.trim())
    .filter((l) => l && !l.startsWith("#"));
  try {
    const parsed = rows.map((l, i) => {
      const [a, m, p = "continuous"] = l.split(",");
      if (!isAddress(a.trim(), { strict: false })) throw new Error(`Line ${i + 1}: bad address`);
      return [getAddress(a.trim()), toRate(m.trim()), parseSchedule(p)];
    });
    if (!parsed.length) return toast("Paste at least one line", null, true);
    const ok = await tx(`Send ${parsed.length} offers`, "batchPropose", [
      parsed.map((r) => r[0]),
      parsed.map((r) => r[1]),
      parsed.map((r) => r[2]),
      parsed.map(() => 0n),
    ]);
    if (ok) e.target.reset();
  } catch (err) {
    toast(err.message, null, true);
  }
};

$("#contract").innerHTML = VAULT === zeroAddress ? "not deployed" : addrLink(VAULT);
$("#net").textContent = cfg.name;
refresh();
