import { formatUnits, parseAbi, parseUnits, type Address } from "viem";
import { pub, USDC, VAULT } from "./chain";

export const MONTH = 2592000n;
export const WEEK = 604800n;
export const SCALE = 10n ** 18n;

export const SCHEDULES = [
  { value: "0", label: "Every second", key: "continuous" },
  { value: String(WEEK), label: "Weekly", key: "weekly" },
  { value: String(MONTH), label: "Every 30 days", key: "monthly" },
] as const;

export const vaultAbi = parseAbi([
  "function employers(address) view returns (uint256, uint256, uint256, uint256)",
  "function streams(uint256) view returns (address, address, uint256, uint256, uint256, uint256, uint8, uint256, uint256, uint256)",
  "function offers(uint256) view returns (address, address, uint256, uint256, uint256, uint8, uint256)",
  "function pendingChange(uint256) view returns (uint256, uint256, bool)",
  "function earned(uint256) view returns (uint256)",
  "function withdrawable(uint256) view returns (uint256)",
  "function unlocked(uint256) view returns (uint256)",
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
  "error NotEmployer()",
  "error NotEmployee()",
  "error InvalidAmount()",
  "error InvalidAddress()",
  "error InvalidRate()",
  "error InvalidPeriod()",
  "error InvalidExpiry()",
  "error InvalidStatus()",
  "error OfferExpired()",
  "error NoPendingChange()",
  "error NoChange()",
  "error NotARaise()",
  "error LengthMismatch()",
  "error InsufficientFreeBalance()",
  "error InsufficientPoolBalance()",
  "error TransferFailed()",
]);

export const erc20Abi = parseAbi([
  "function balanceOf(address) view returns (uint256)",
  "function allowance(address, address) view returns (uint256)",
  "function approve(address, uint256) returns (bool)",
]);

export const ERRORS: Record<string, string> = {
  NotEmployer: "Only the employer can do that.",
  NotEmployee: "Only the employee can do that.",
  InvalidAmount: "Enter an amount above zero.",
  InvalidAddress: "That address isn't valid.",
  InvalidRate: "Enter a salary above zero.",
  InvalidPeriod: "That pay schedule isn't supported.",
  InvalidExpiry: "The expiry must be in the future.",
  InvalidStatus: "This stream or offer can't do that right now.",
  OfferExpired: "This offer has expired.",
  NoPendingChange: "There's no pending change.",
  NoChange: "Those are the current terms.",
  NotARaise: "Raises must be higher than the current salary. Use “Change terms” for a cut.",
  LengthMismatch: "Each row needs an address, salary and schedule.",
  InsufficientFreeBalance: "That's more than the free balance. Funds owed to your team are locked.",
  InsufficientPoolBalance: "The pool doesn't hold enough USDC.",
  TransferFailed: "The USDC transfer failed.",
};

export const STATUS = ["—", "Active", "Paused", "Ended"] as const;
export const OFFER = ["—", "Open", "Accepted", "Declined", "Revoked"] as const;

export const toUsd = (v: bigint) => Number(formatUnits(v, 6));
export const usd = (v: bigint, digits = 2) =>
  toUsd(v).toLocaleString("en-US", { style: "currency", currency: "USD", minimumFractionDigits: digits });
export const perMonth = (rate: bigint) => (rate * MONTH) / SCALE;
export const toRate = (monthly: string) => (parseUnits(monthly.trim(), 6) * SCALE) / MONTH;
export const when = (t: bigint) => (t ? new Date(Number(t) * 1000).toLocaleString() : "—");
const UNITS = [
  [86400, "day"],
  [3600, "hour"],
  [60, "minute"],
  [1, "second"],
] as const;

export function schedule(p: bigint) {
  if (p === 0n) return "Every second";
  if (p === WEEK) return "Weekly";
  if (p === MONTH) return "Every 30 days";
  const [size, unit] = UNITS.find(([s]) => Number(p) >= s)!;
  const n = +(Number(p) / size).toFixed(1);
  return n === 1 ? `Every ${unit}` : `Every ${n} ${unit}s`;
}
export const parseSchedule = (s: string) =>
  BigInt(SCHEDULES.find((x) => x.key === s.trim().toLowerCase())?.value ?? s.trim());

const read = <T>(functionName: string, args: unknown[], blockNumber?: bigint) =>
  pub.readContract({ address: VAULT, abi: vaultAbi, functionName, args, blockNumber } as never) as Promise<T>;

export type Stream = Awaited<ReturnType<typeof loadStream>>;
export type Offer = Awaited<ReturnType<typeof loadOffer>>;
export type Dashboard = Awaited<ReturnType<typeof loadDashboard>>;

async function loadStream(id: bigint, blockNumber: bigint) {
  const [s, earned, unlocked, withdrawable, nextPayday, change] = await Promise.all([
    read<readonly [Address, Address, bigint, bigint, bigint, bigint, number, bigint, bigint, bigint]>("streams", [id], blockNumber),
    read<bigint>("earned", [id], blockNumber),
    read<bigint>("unlocked", [id], blockNumber),
    read<bigint>("withdrawable", [id], blockNumber),
    read<bigint>("nextPayday", [id], blockNumber),
    read<readonly [bigint, bigint, boolean]>("pendingChange", [id], blockNumber),
  ]);
  const [employer, employee, rate, , , period, status, , , withdrawnCum] = s;
  const unpaid = unlocked - withdrawnCum / SCALE - withdrawable;
  return { id, employer, employee, rate, period, status, earned, withdrawable, unpaid, nextPayday, change };
}

async function loadOffer(id: bigint, blockNumber: bigint) {
  const [employer, employee, rate, period, expiresAt, status, streamId] = await read<
    readonly [Address, Address, bigint, bigint, bigint, number, bigint]
  >("offers", [id], blockNumber);
  return { id, employer, employee, rate, period, expiresAt, status, streamId };
}

export async function loadDashboard(account: Address) {
  const block = await pub.getBlock();
  const n = block.number;
  const [wallet, pool, owed, free, runway, sIds, oIds, eIds, eoIds] = await Promise.all([
    pub.readContract({ address: USDC, abi: erc20Abi, functionName: "balanceOf", args: [account], blockNumber: n }).catch(() => 0n),
    read<readonly [bigint, bigint, bigint, bigint]>("employers", [account], n),
    read<bigint>("totalOwed", [account], n),
    read<bigint>("freeBalance", [account], n),
    read<bigint>("runway", [account], n),
    read<readonly bigint[]>("streamsOfEmployer", [account], n),
    read<readonly bigint[]>("offersOfEmployer", [account], n),
    read<readonly bigint[]>("streamsOfEmployee", [account], n),
    read<readonly bigint[]>("offersOfEmployee", [account], n),
  ]);
  const all = <T>(ids: readonly bigint[], load: (id: bigint, b: bigint) => Promise<T>) =>
    Promise.all([...ids].reverse().map((id) => load(id, n)));
  const [team, sent, pay, inbox] = await Promise.all([
    all(sIds, loadStream),
    all(oIds, loadOffer),
    all(eIds, loadStream),
    all(eoIds, loadOffer),
  ]);
  return {
    at: Number(block.timestamp),
    wallet,
    pool: { balance: pool[0], debt: pool[1], totalRate: pool[2] },
    owed,
    free,
    runway,
    team,
    sent,
    pay,
    inbox,
  };
}
