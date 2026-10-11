import { WagmiAdapter } from "@reown/appkit-adapter-wagmi";
import { defineChain } from "@reown/appkit/networks";
import { createAppKit } from "@reown/appkit/react";
import { http } from "viem";
import { chain, RPC } from "./chain";
import { getTheme, onTheme } from "./theme";

const projectId = "746d2d57f2fb312056ab775a9262a0af";
const network = defineChain({ ...chain, caipNetworkId: `eip155:${chain.id}`, chainNamespace: "eip155" });

export const wagmiAdapter = new WagmiAdapter({ projectId, networks: [network], transports: { [chain.id]: http(RPC) } });

const accent = () => getComputedStyle(document.documentElement).getPropertyValue("--primary").trim();

const appKit = createAppKit({
  adapters: [wagmiAdapter],
  networks: [network],
  projectId,
  metadata: {
    name: "StreamArc",
    description: "Payroll that pays every second, in USDC",
    url: location.origin,
    icons: [new URL("../favicon.svg", location.href).href],
  },
  features: { analytics: false, email: false, socials: false },
  themeMode: getTheme(),
  themeVariables: {
    "--w3m-accent": accent(),
    "--w3m-font-family": "Instrument Sans Variable, sans-serif",
    "--w3m-border-radius-master": "2px",
  },
});

onTheme(() => {
  appKit.setThemeMode(getTheme());
  appKit.setThemeVariables({ "--w3m-accent": accent() });
});
