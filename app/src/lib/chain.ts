import { createPublicClient, defineChain, getAddress, http, isAddress, zeroAddress, type Address } from "viem";
import config from "../../config.json";

export type Net = keyof typeof config.networks;

const q = new URLSearchParams(location.search);
const as = q.get("as");
const valid = (k: string | null): Net | undefined => (k && Object.hasOwn(config.networks, k) ? (k as Net) : undefined);
const saved = (() => {
  try {
    return localStorage.getItem("network");
  } catch {
    return null;
  }
})();

export const NET: Net =
  valid(q.get("network")) ?? valid(saved) ?? (config.networks.mainnet.payroll !== zeroAddress ? "mainnet" : "testnet");

const save = (n: Net) => {
  try {
    localStorage.setItem("network", n);
  } catch {}
};
if (valid(q.get("network"))) save(NET);

export function setNetwork(n: Net) {
  save(n);
  const url = new URL(location.href);
  url.searchParams.delete("network");
  history.replaceState(null, "", url);
  location.reload();
}

const cfg = config.networks[NET];

export const RPC = q.get("rpc") || cfg.rpc;
export const VAULT = (q.get("payroll") || cfg.payroll) as Address;
export const USDC = cfg.usdc as Address;
export const EXPLORER = cfg.explorer;
export const NETWORK = cfg.name;
export const IS_MAINNET = cfg.chainId === 5042;
export const DEPLOYED = VAULT !== zeroAddress;
export const VIEW_AS = as && isAddress(as, { strict: false }) ? getAddress(as) : undefined;

export const chain = defineChain({
  id: cfg.chainId,
  name: cfg.name,
  nativeCurrency: { name: "USDC", symbol: "USDC", decimals: 18 },
  rpcUrls: { default: { http: [RPC] } },
  blockExplorers: { default: { name: "Arc Explorer", url: cfg.explorer } },
});

export const pub = createPublicClient({ chain, transport: http(RPC) });

export const explorerUrl = (kind: "address" | "tx", id: string) => `${EXPLORER}/${kind}/${id}`;
export const short = (a: string) => `${a.slice(0, 6)}…${a.slice(-4)}`;
