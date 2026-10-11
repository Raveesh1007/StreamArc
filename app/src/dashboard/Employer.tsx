import { CircleSlash, Pause, Play, SendHorizontal, SlidersHorizontal, TrendingUp, TriangleAlert, Users } from "lucide-react";
import { useState, type FormEvent, type ReactNode } from "react";
import { toast } from "sonner";
import { getAddress, isAddress, maxUint256, parseUnits } from "viem";
import { LiveAmount } from "@/components/live-amount";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Textarea } from "@/components/ui/textarea";
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip";
import { pub, USDC, VAULT } from "@/lib/chain";
import { erc20Abi, parseSchedule, perMonth, schedule, toRate, toUsd, usd, when, type Dashboard, type Stream } from "@/lib/vault";
import { useTx } from "./hooks";
import { Addr, Empty, OfferBadge, Panel, ScheduleSelect, Stat, StreamBadge } from "./parts";

type Tx = ReturnType<typeof useTx>;
const field = (e: FormEvent<HTMLFormElement>) => {
  e.preventDefault();
  const f = e.currentTarget;
  return { f, get: (k: string) => String(new FormData(f).get(k) ?? "") };
};

export function Employer({ d, account, readOnly }: { d: Dashboard; account: `0x${string}`; readOnly: boolean }) {
  const tx = useTx();
  const [dialog, setDialog] = useState<{ mode: Mode; s: Stream }>();
  const runwayDays = d.runway === maxUint256 ? undefined : Number(d.runway) / 86400;

  return (
    <div className="space-y-6">
      {runwayDays !== undefined && runwayDays < 7 && (
        <div className="flex items-center gap-3 rounded-xl border border-warning/30 bg-warning/10 px-4 py-3 text-sm text-warning">
          <TriangleAlert className="size-4 shrink-0" />
          Less than a week of payroll left in the pool. Top up so your team keeps getting paid.
        </div>
      )}

      <div className="grid grid-cols-2 gap-px overflow-hidden rounded-2xl border bg-border lg:grid-cols-5 [&>:last-child]:col-span-2 lg:[&>:last-child]:col-span-1">
        <Stat label="Pool balance" value={usd(d.pool.balance)} />
        <Stat label="Owed to team" value={usd(d.owed)} />
        <Stat label="Free to withdraw" value={usd(d.free)} />
        <Stat label="Payroll / month" value={usd(perMonth(d.pool.totalRate))} hint={`${d.team.filter((s) => s.status === 1).length} active`} />
        <Stat
          label="Runway"
          value={runwayDays === undefined ? "—" : `${runwayDays.toFixed(1)} days`}
          hint={runwayDays === undefined ? "No active pay" : undefined}
          tone={runwayDays !== undefined && runwayDays < 7 ? "warn" : undefined}
        />
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <Fund d={d} account={account} tx={tx} disabled={readOnly} />
        <Hire tx={tx} disabled={readOnly} />
      </div>

      <Panel title="Team">
        {d.team.length ? (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="pl-5">Employee</TableHead>
                <TableHead>Salary / mo</TableHead>
                <TableHead>Paid</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Earned</TableHead>
                <TableHead>Next payday</TableHead>
                <TableHead className="pr-5 text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {d.team.map((s) => (
                <TableRow key={String(s.id)}>
                  <TableCell className="pl-5">
                    <Addr a={s.employee} />
                    <span className="ml-2 font-mono text-xs text-muted-foreground">#{String(s.id)}</span>
                  </TableCell>
                  <TableCell className="font-mono">{usd(perMonth(s.rate))}</TableCell>
                  <TableCell className="text-muted-foreground">{schedule(s.period)}</TableCell>
                  <TableCell>
                    <div className="flex items-center gap-1.5">
                      <StreamBadge status={s.status} />
                      {s.change[2] && <span className="text-xs text-warning">change pending</span>}
                    </div>
                  </TableCell>
                  <TableCell>
                    <LiveAmount base={s.earned} rate={s.status === 1 ? s.rate : 0n} />
                  </TableCell>
                  <TableCell className="text-muted-foreground">{s.period && s.status !== 3 ? when(s.nextPayday) : "—"}</TableCell>
                  <TableCell className="pr-5">
                    {s.status !== 3 && !readOnly && (
                      <div className="flex justify-end gap-1">
                        <Act
                          label={s.status === 1 ? "Pause" : "Resume"}
                          onClick={() => tx(s.status === 1 ? "Pause" : "Resume", { functionName: s.status === 1 ? "pause" : "resume", args: [s.id] })}
                        >
                          {s.status === 1 ? <Pause /> : <Play />}
                        </Act>
                        <Act label="Raise" onClick={() => setDialog({ mode: "raise", s })}>
                          <TrendingUp />
                        </Act>
                        <Act label="Change terms" onClick={() => setDialog({ mode: "change", s })}>
                          <SlidersHorizontal />
                        </Act>
                        <Act label="End stream" danger onClick={() => setDialog({ mode: "cancel", s })}>
                          <CircleSlash />
                        </Act>
                      </div>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        ) : (
          <Empty icon={Users} title="No one on payroll yet">
            Send an offer above. Pay starts streaming the moment it's accepted.
          </Empty>
        )}
      </Panel>

      <Panel title="Offers sent">
        {d.sent.length ? (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="pl-5">Employee</TableHead>
                <TableHead>Salary / mo</TableHead>
                <TableHead>Paid</TableHead>
                <TableHead>Expires</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="pr-5" />
              </TableRow>
            </TableHeader>
            <TableBody>
              {d.sent.map((o) => (
                <TableRow key={String(o.id)}>
                  <TableCell className="pl-5">
                    <Addr a={o.employee} />
                  </TableCell>
                  <TableCell className="font-mono">{usd(perMonth(o.rate))}</TableCell>
                  <TableCell className="text-muted-foreground">{schedule(o.period)}</TableCell>
                  <TableCell className="text-muted-foreground">{o.expiresAt ? when(o.expiresAt) : "Never"}</TableCell>
                  <TableCell>
                    <OfferBadge status={o.status} />
                  </TableCell>
                  <TableCell className="pr-5 text-right">
                    {o.status === 1 && !readOnly && (
                      <Button variant="ghost" size="sm" onClick={() => tx("Revoke offer", { functionName: "revokeOffer", args: [o.id] })}>
                        Revoke
                      </Button>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        ) : (
          <Empty icon={SendHorizontal} title="No offers sent" />
        )}
      </Panel>

      {dialog && <StreamDialog {...dialog} tx={tx} onClose={() => setDialog(undefined)} />}
    </div>
  );
}

function Act({ label, onClick, danger, children }: { label: string; onClick: () => void; danger?: boolean; children: ReactNode }) {
  return (
    <Tooltip>
      <TooltipTrigger asChild>
        <Button variant="ghost" size="icon" aria-label={label} onClick={onClick} className={danger ? "hover:text-destructive" : undefined}>
          {children}
        </Button>
      </TooltipTrigger>
      <TooltipContent>{label}</TooltipContent>
    </Tooltip>
  );
}

function Fund({ d, account, tx, disabled }: { d: Dashboard; account: `0x${string}`; tx: Tx; disabled: boolean }) {
  const deposit = async (e: FormEvent<HTMLFormElement>) => {
    const { f, get } = field(e);
    const amount = parseUnits(get("amount"), 6);
    const allowance = await pub.readContract({ address: USDC, abi: erc20Abi, functionName: "allowance", args: [account, VAULT] });
    if (allowance < amount && !(await tx("Approve USDC", { address: USDC, abi: erc20Abi, functionName: "approve", args: [VAULT, amount] }))) return;
    if (await tx("Deposit", { functionName: "deposit", args: [amount] })) f.reset();
  };
  const withdraw = async (e: FormEvent<HTMLFormElement>) => {
    const { f, get } = field(e);
    if (await tx("Withdraw unused funds", { functionName: "withdrawExcess", args: [parseUnits(get("amount"), 6), account] })) f.reset();
  };
  return (
    <Panel title="Fund payroll">
      <Tabs defaultValue="deposit" className="p-5">
        <TabsList>
          <TabsTrigger value="deposit">Deposit</TabsTrigger>
          <TabsTrigger value="withdraw">Withdraw</TabsTrigger>
        </TabsList>
        <TabsContent value="deposit">
          <AmountForm onSubmit={deposit} cta="Deposit USDC" hint={`Wallet: ${usd(d.wallet)}`} max={toUsd(d.wallet)} disabled={disabled} />
        </TabsContent>
        <TabsContent value="withdraw">
          <AmountForm
            onSubmit={withdraw}
            cta="Withdraw"
            hint={`Free to withdraw: ${usd(d.free)}. Money owed to your team stays locked.`}
            max={toUsd(d.free)}
            disabled={disabled}
          />
        </TabsContent>
      </Tabs>
    </Panel>
  );
}

function AmountForm({ onSubmit, cta, hint, max, disabled }: { onSubmit: (e: FormEvent<HTMLFormElement>) => void; cta: string; hint: string; max: number; disabled: boolean }) {
  return (
    <form onSubmit={onSubmit} className="mt-4 space-y-3">
      <Label htmlFor={cta}>Amount (USDC)</Label>
      <div className="flex gap-2">
        <div className="relative flex-1">
          <Input id={cta} name="amount" type="number" min="0.000001" step="any" required placeholder="10,000" className="pr-14 font-mono" />
          <button
            type="button"
            onClick={(e) => ((e.currentTarget.previousElementSibling as HTMLInputElement).value = String(max))}
            className="absolute top-1/2 right-2 -translate-y-1/2 rounded px-1.5 py-0.5 font-mono text-[11px] text-primary hover:bg-primary/10"
          >
            MAX
          </button>
        </div>
        <Button disabled={disabled}>{cta}</Button>
      </div>
      <p className="text-xs text-muted-foreground">{hint}</p>
    </form>
  );
}

function Hire({ tx, disabled }: { tx: Tx; disabled: boolean }) {
  const single = async (e: FormEvent<HTMLFormElement>) => {
    const { f, get } = field(e);
    if (!isAddress(get("employee"), { strict: false })) return toast.error("Enter a valid employee address");
    const days = Number(get("expires") || 0);
    const expiresAt = days ? (await pub.getBlock()).timestamp + BigInt(Math.round(days * 86400)) : 0n;
    const ok = await tx("Send offer", {
      functionName: "propose",
      args: [getAddress(get("employee")), toRate(get("monthly")), BigInt(get("period")), expiresAt],
    });
    if (ok) f.reset();
  };
  const bulk = async (e: FormEvent<HTMLFormElement>) => {
    const { f, get } = field(e);
    try {
      const rows = get("csv")
        .split("\n")
        .map((l) => l.trim())
        .filter((l) => l && !l.startsWith("#"))
        .map((l, i) => {
          const [a, m, p = "continuous"] = l.split(",");
          if (!isAddress(a.trim(), { strict: false })) throw new Error(`Line ${i + 1}: invalid address`);
          return [getAddress(a.trim()), toRate(m), parseSchedule(p)] as const;
        });
      if (!rows.length) return toast.error("Add at least one line");
      const ok = await tx(`Send ${rows.length} offers`, {
        functionName: "batchPropose",
        args: [rows.map((r) => r[0]), rows.map((r) => r[1]), rows.map((r) => r[2]), rows.map(() => 0n)],
      });
      if (ok) f.reset();
    } catch (err) {
      toast.error((err as Error).message);
    }
  };
  return (
    <Panel title="Hire">
      <Tabs defaultValue="single" className="p-5">
        <TabsList>
          <TabsTrigger value="single">Single offer</TabsTrigger>
          <TabsTrigger value="bulk">Bulk</TabsTrigger>
        </TabsList>
        <TabsContent value="single">
          <form onSubmit={single} className="mt-4 grid gap-4 sm:grid-cols-2">
            <div className="space-y-2 sm:col-span-2">
              <Label htmlFor="employee">Employee wallet</Label>
              <Input id="employee" name="employee" required placeholder="0x…" className="font-mono" />
            </div>
            <div className="space-y-2">
              <Label htmlFor="monthly">Monthly salary (USDC)</Label>
              <Input id="monthly" name="monthly" type="number" min="0.000001" step="any" required placeholder="3,000" className="font-mono" />
            </div>
            <div className="space-y-2">
              <Label>Paid</Label>
              <ScheduleSelect />
            </div>
            <div className="space-y-2">
              <Label htmlFor="expires">Offer expires in (days)</Label>
              <Input id="expires" name="expires" type="number" min="0" defaultValue="7" className="font-mono" />
            </div>
            <div className="flex items-end">
              <Button className="w-full" disabled={disabled}>
                Send offer
              </Button>
            </div>
          </form>
        </TabsContent>
        <TabsContent value="bulk">
          <form onSubmit={bulk} className="mt-4 space-y-3">
            <Label htmlFor="csv">One per line: address, monthly USDC, schedule</Label>
            <Textarea
              id="csv"
              name="csv"
              rows={5}
              className="font-mono text-xs"
              placeholder={"0xabc…, 3000, continuous\n0xdef…, 4500, weekly\n0x123…, 5200, monthly"}
            />
            <div className="flex items-center justify-between gap-4">
              <p className="text-xs text-muted-foreground">Everyone gets an offer in one transaction.</p>
              <Button disabled={disabled}>Send all</Button>
            </div>
          </form>
        </TabsContent>
      </Tabs>
    </Panel>
  );
}

type Mode = "raise" | "change" | "cancel";
const COPY: Record<Mode, [string, string, string]> = {
  raise: ["Give a raise", "Raises apply instantly. The new rate starts streaming right away.", "Apply raise"],
  change: ["Change terms", "Pay cuts and schedule changes only take effect if the employee accepts.", "Propose change"],
  cancel: ["End this stream", "Pay stops now. Everything earned so far, including a partial period, stays withdrawable.", "End stream"],
};

function StreamDialog({ mode, s, tx, onClose }: { mode: Mode; s: Stream; tx: Tx; onClose: () => void }) {
  const [title, desc, cta] = COPY[mode];
  const submit = async (e: FormEvent<HTMLFormElement>) => {
    const { get } = field(e);
    const ok =
      mode === "cancel"
        ? await tx("End stream", { functionName: "cancel", args: [s.id] })
        : mode === "raise"
          ? await tx("Raise", { functionName: "raise", args: [s.id, toRate(get("monthly"))] })
          : await tx("Propose new terms", { functionName: "proposeChange", args: [s.id, toRate(get("monthly")), BigInt(get("period"))] });
    if (ok) onClose();
  };
  return (
    <Dialog open onOpenChange={(o) => !o && onClose()}>
      <DialogContent>
        <form onSubmit={submit} className="space-y-5">
          <DialogHeader>
            <DialogTitle>{title}</DialogTitle>
            <DialogDescription>{desc}</DialogDescription>
          </DialogHeader>
          <div className="rounded-lg border bg-muted/50 px-4 py-3 text-sm">
            <Addr a={s.employee} /> <span className="text-muted-foreground">· now {usd(perMonth(s.rate))} / mo, {schedule(s.period).toLowerCase()}</span>
          </div>
          {mode !== "cancel" && (
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="d-monthly">New monthly salary (USDC)</Label>
                <Input id="d-monthly" name="monthly" type="number" min="0.000001" step="any" required autoFocus className="font-mono" />
              </div>
              {mode === "change" && (
                <div className="space-y-2">
                  <Label>Paid</Label>
                  <ScheduleSelect defaultValue={String(s.period)} />
                </div>
              )}
            </div>
          )}
          <DialogFooter>
            <Button type="button" variant="ghost" onClick={onClose}>
              Cancel
            </Button>
            <Button variant={mode === "cancel" ? "destructive" : "default"}>{cta}</Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
