import { useAppKit } from "@reown/appkit/react";
import { Eye, RefreshCw } from "lucide-react";
import { useEffect, useState } from "react";
import { ArcIcon, UsdcToken } from "@/components/brand";
import { NavLink, SiteHeader } from "@/components/site-header";
import { SiteFooter } from "@/components/site-footer";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { DEPLOYED, IS_MAINNET, NETWORK, short } from "@/lib/chain";
import { usd } from "@/lib/vault";
import { Employee } from "./Employee";
import { Employer } from "./Employer";
import { useDashboard, useViewer } from "./hooks";

type Tab = "employer" | "employee";
const tabFromHash = (): Tab => (location.hash === "#employee" ? "employee" : "employer");

export function Dashboard() {
  const { open } = useAppKit();
  const { account, connected, readOnly } = useViewer();
  const q = useDashboard(account);
  const [tab, setTab] = useState<Tab>(tabFromHash);
  useEffect(() => {
    const on = () => setTab(tabFromHash());
    addEventListener("hashchange", on);
    return () => removeEventListener("hashchange", on);
  }, []);
  const offers = q.data?.inbox.filter((o) => o.status === 1).length ?? 0;

  return (
    <div className="flex min-h-screen flex-col">
      <SiteHeader
        home="../"
        links={
          <>
            <NavLink href="../#how">How it works</NavLink>
            <NavLink href="../#roadmap">Roadmap</NavLink>
          </>
        }
      >
        <span className="hidden items-center gap-2 rounded-full border px-3 py-1.5 text-xs text-muted-foreground sm:flex">
          <ArcIcon className="h-3" />
          {NETWORK}
          {!IS_MAINNET && <span className="size-1.5 rounded-full bg-warning" />}
        </span>
        {q.data && (
          <span className="hidden items-center gap-1.5 rounded-full border px-3 py-1.5 font-mono text-xs md:flex">
            <UsdcToken className="size-3.5" />
            {usd(q.data.wallet)}
          </span>
        )}
        <Button size="sm" variant={connected ? "outline" : "default"} onClick={() => open()}>
          {connected && account ? <span className="font-mono">{short(account)}</span> : "Connect wallet"}
        </Button>
      </SiteHeader>

      <main className="relative min-w-0 flex-1">
        <div className="bg-grid pointer-events-none absolute inset-x-0 top-0 h-72 [mask-image:linear-gradient(black,transparent)]" />
        <div className="relative mx-auto max-w-6xl px-4 py-10 sm:px-6">
          <div className="flex flex-wrap items-end justify-between gap-6">
            <div>
              <p className="font-mono text-xs tracking-[0.2em] text-primary uppercase">Payroll</p>
              <h1 className="mt-3 text-4xl font-semibold">{tab === "employer" ? "Run payroll" : "Your pay"}</h1>
              <p className="mt-2 text-muted-foreground">
                {tab === "employer" ? "Fund the pool, hire, and manage every stream." : "Watch it tick up. Withdraw whenever you like."}
              </p>
            </div>
            <Tabs value={tab} onValueChange={(v) => (location.hash = v)}>
              <TabsList>
                <TabsTrigger value="employer">Employer</TabsTrigger>
                <TabsTrigger value="employee">
                  Employee
                  {offers > 0 && <span className="ml-1.5 rounded-full bg-primary px-1.5 font-mono text-[10px] text-primary-foreground">{offers}</span>}
                </TabsTrigger>
              </TabsList>
            </Tabs>
          </div>

          {readOnly && account && (
            <p className="mt-6 flex items-center gap-2 rounded-xl border bg-card px-4 py-3 text-sm text-muted-foreground">
              <Eye className="size-4" /> Viewing <span className="font-mono text-foreground">{short(account)}</span> read-only.
            </p>
          )}

          <div className="mt-8">
            {!DEPLOYED ? (
              <Notice title="PayrollVault isn't deployed on this network yet">
                Run <code className="font-mono text-foreground">./deploy-arc.sh</code> or add <code className="font-mono text-foreground">?payroll=0x…</code> to the URL.
              </Notice>
            ) : !account ? (
              <Notice title="Connect a wallet to get started">
                Employers fund payroll and send offers. Employees accept offers and withdraw their pay.
                <Button className="mt-6" size="lg" onClick={() => open()}>
                  Connect wallet
                </Button>
              </Notice>
            ) : q.isError ? (
              <Notice title="Couldn't load from Arc">
                {(q.error as Error).message}
                <Button className="mt-6" variant="outline" onClick={() => q.refetch()}>
                  <RefreshCw /> Try again
                </Button>
              </Notice>
            ) : !q.data ? (
              <div className="space-y-6">
                <Skeleton className="h-28 rounded-2xl" />
                <div className="grid gap-6 lg:grid-cols-2">
                  <Skeleton className="h-64 rounded-2xl" />
                  <Skeleton className="h-64 rounded-2xl" />
                </div>
              </div>
            ) : tab === "employer" ? (
              <Employer d={q.data} account={account} readOnly={readOnly} />
            ) : (
              <Employee d={q.data} account={account} readOnly={readOnly} />
            )}
          </div>
        </div>
      </main>
      <SiteFooter root="../" />
    </div>
  );
}

function Notice({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="flex flex-col items-center rounded-2xl border bg-card px-6 py-20 text-center">
      <h2 className="text-2xl font-semibold">{title}</h2>
      <div className="mt-3 flex max-w-md flex-col items-center text-muted-foreground">{children}</div>
    </div>
  );
}
