import { Inbox, Wallet } from "lucide-react";
import { maxUint256 } from "viem";
import { LiveAmount } from "@/components/live-amount";
import { Button } from "@/components/ui/button";
import { perMonth, schedule, usd, when, type Dashboard } from "@/lib/vault";
import { useTx } from "./hooks";
import { Addr, Empty, Panel, StreamBadge } from "./parts";

export function Employee({ d, account, readOnly }: { d: Dashboard; account: `0x${string}`; readOnly: boolean }) {
  const tx = useTx();
  const open = d.inbox.filter((o) => o.status === 1);

  return (
    <div className="space-y-6">
      {open.length > 0 && (
        <div className="grid gap-4 md:grid-cols-2">
          {open.map((o) => (
            <div key={String(o.id)} className="relative overflow-hidden rounded-2xl border border-primary/30 bg-card p-6">
              <div className="pointer-events-none absolute -top-16 -right-16 size-48 rounded-full bg-primary/10 blur-3xl" />
              <p className="font-mono text-xs tracking-widest text-primary uppercase">New offer</p>
              <p className="mt-4 font-mono text-3xl">
                {usd(perMonth(o.rate))}
                <span className="text-base text-muted-foreground"> / month</span>
              </p>
              <p className="mt-2 text-sm text-muted-foreground">
                From <Addr a={o.employer} /> · paid {schedule(o.period).toLowerCase()} · {o.expiresAt ? `expires ${when(o.expiresAt)}` : "no expiry"}
              </p>
              {!readOnly && (
                <div className="mt-6 flex gap-2">
                  <Button onClick={() => tx("Accept offer", { functionName: "acceptOffer", args: [o.id] })}>Accept offer</Button>
                  <Button variant="ghost" onClick={() => tx("Decline offer", { functionName: "rejectOffer", args: [o.id] })}>
                    Decline
                  </Button>
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      {d.pay.length ? (
        <div className="grid gap-6 lg:grid-cols-2">
          {d.pay.map((s) => (
            <section key={String(s.id)} className="rounded-2xl border bg-card">
              <div className="flex items-center justify-between border-b px-6 py-4 text-sm">
                <span className="text-muted-foreground">
                  From <Addr a={s.employer} /> <span className="font-mono text-xs">#{String(s.id)}</span>
                </span>
                <StreamBadge status={s.status} />
              </div>
              <div className="px-6 pt-7 pb-6">
                <p className="text-sm text-muted-foreground">Earned so far</p>
                <LiveAmount base={s.earned} rate={s.status === 1 ? s.rate : 0n} className="mt-1 block text-4xl sm:text-5xl" />
                <p className="mt-2 text-sm text-muted-foreground">
                  {usd(perMonth(s.rate))} / month · paid {schedule(s.period).toLowerCase()}
                </p>
              </div>
              <div className="grid grid-cols-2 gap-px border-y bg-border">
                <div className="bg-card px-6 py-4">
                  <p className="text-xs text-muted-foreground">Ready to withdraw</p>
                  <p className="mt-1 font-mono text-lg text-primary">{usd(s.withdrawable)}</p>
                </div>
                <div className="bg-card px-6 py-4">
                  <p className="text-xs text-muted-foreground">Next payday</p>
                  <p className="mt-1 text-sm">{s.status === 3 ? "Stream ended" : s.period ? when(s.nextPayday) : "Unlocks every second"}</p>
                </div>
              </div>
              <div className="space-y-3 px-6 py-5">
                {s.unpaid > 0n && (
                  <p className="rounded-lg border border-warning/30 bg-warning/10 px-3 py-2 text-sm text-warning">
                    {usd(s.unpaid)} is owed but your employer's pool is empty. It's paid first when they top up.
                  </p>
                )}
                {s.change[2] && (
                  <div className="rounded-lg border bg-muted/50 px-3 py-3 text-sm">
                    New terms proposed: <b className="font-mono">{usd(perMonth(s.change[0]))}</b> / month, paid {schedule(s.change[1]).toLowerCase()}.
                    {!readOnly && (
                      <div className="mt-3 flex gap-2">
                        <Button size="sm" onClick={() => tx("Accept new terms", { functionName: "acceptChange", args: [s.id] })}>
                          Accept
                        </Button>
                        <Button size="sm" variant="ghost" onClick={() => tx("Decline new terms", { functionName: "rejectChange", args: [s.id] })}>
                          Decline
                        </Button>
                      </div>
                    )}
                  </div>
                )}
                <Button
                  className="w-full"
                  size="lg"
                  disabled={readOnly || !s.withdrawable}
                  onClick={() => tx("Withdraw", { functionName: "withdraw", args: [s.id, maxUint256, account] })}
                >
                  <Wallet /> Withdraw {usd(s.withdrawable)}
                </Button>
              </div>
            </section>
          ))}
        </div>
      ) : (
        !open.length && (
          <Panel title="Your pay">
            <Empty icon={Inbox} title="No pay streams yet">
              When an employer sends you an offer it shows up here. Accept it and you start earning every second.
            </Empty>
          </Panel>
        )
      )}
    </div>
  );
}
