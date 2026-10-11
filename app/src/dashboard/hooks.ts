import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useCallback } from "react";
import { toast } from "sonner";
import type { Abi, Address } from "viem";
import { useAccount, useSwitchChain, useWalletClient } from "wagmi";
import { chain, DEPLOYED, explorerUrl, pub, VAULT, VIEW_AS } from "@/lib/chain";
import { ERRORS, loadDashboard, vaultAbi } from "@/lib/vault";

export function useViewer() {
  const { address } = useAccount();
  const account = VIEW_AS ?? address;
  return { account, connected: !!address, readOnly: !!VIEW_AS && VIEW_AS !== address };
}

export function useDashboard(account?: Address) {
  return useQuery({
    queryKey: ["dashboard", account],
    queryFn: () => loadDashboard(account!),
    enabled: !!account && DEPLOYED,
    refetchInterval: 30_000,
  });
}

const errorText = (e: unknown) => {
  const err = e as { walk?: (f: (c: unknown) => boolean) => { data?: { errorName?: string } }; shortMessage?: string; message?: string };
  const name = err.walk?.((c) => !!(c as { data?: { errorName?: string } }).data?.errorName)?.data?.errorName;
  return (name && ERRORS[name]) || err.shortMessage || err.message || "Something went wrong";
};

type Call = { functionName: string; args: unknown[]; address?: Address; abi?: Abi };

export function useTx() {
  const { data: wallet } = useWalletClient();
  const { switchChainAsync } = useSwitchChain();
  const qc = useQueryClient();
  return useCallback(
    async (label: string, call: Call) => {
      if (!wallet) return toast.error("Connect a wallet first"), false;
      const id = toast.loading(`${label}`, { description: "Confirm in your wallet" });
      try {
        if (wallet.chain.id !== chain.id) await switchChainAsync({ chainId: chain.id });
        const req = { address: VAULT, abi: vaultAbi, account: wallet.account, chain, ...call } as never;
        const gas = await pub.estimateContractGas(req);
        const hash = await wallet.writeContract({ ...(req as object), gas: (gas * 6n) / 5n } as never);
        const view = { label: "View", onClick: () => open(explorerUrl("tx", hash), "_blank") };
        toast.loading(label, { id, description: "Confirming on Arc…", action: view });
        const r = await pub.waitForTransactionReceipt({ hash });
        if (r.status !== "success") throw new Error("Transaction reverted");
        toast.success(`${label} confirmed`, { id, description: undefined, action: view });
        await qc.invalidateQueries({ queryKey: ["dashboard"] });
        return true;
      } catch (e) {
        toast.error(`${label} failed`, { id, description: errorText(e), action: undefined });
        return false;
      }
    },
    [wallet, switchChainAsync, qc],
  );
}
