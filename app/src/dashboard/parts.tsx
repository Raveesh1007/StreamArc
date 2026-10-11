import { ArrowUpRight, type LucideIcon } from "lucide-react";
import type { ReactNode } from "react";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { explorerUrl, short } from "@/lib/chain";
import { cn } from "@/lib/utils";
import { OFFER, SCHEDULES, STATUS } from "@/lib/vault";

export function Stat({ label, value, hint, tone }: { label: string; value: ReactNode; hint?: string; tone?: "warn" }) {
  return (
    <div className="bg-card px-5 py-5">
      <p className="text-xs text-muted-foreground">{label}</p>
      <p className={cn("mt-2 font-mono text-2xl tabular", tone === "warn" && "text-warning")}>{value}</p>
      {hint && <p className="mt-1 text-xs text-muted-foreground">{hint}</p>}
    </div>
  );
}

export function Addr({ a }: { a: string }) {
  return (
    <a
      href={explorerUrl("address", a)}
      target="_blank"
      rel="noopener"
      className="inline-flex items-center gap-1 font-mono text-sm hover:text-primary"
    >
      {short(a)}
      <ArrowUpRight className="size-3 opacity-50" />
    </a>
  );
}

const STATUS_STYLE = ["", "border-primary/30 bg-primary/10 text-primary", "border-warning/30 bg-warning/10 text-warning", "text-muted-foreground"];
const OFFER_STYLE = ["", "border-warning/30 bg-warning/10 text-warning", "border-primary/30 bg-primary/10 text-primary", "text-muted-foreground", "text-muted-foreground"];

export const StreamBadge = ({ status }: { status: number }) => (
  <Badge variant="outline" className={STATUS_STYLE[status]}>
    {status === 1 && <span className="animate-pulse-dot size-1.5 rounded-full bg-primary" />}
    {STATUS[status]}
  </Badge>
);

export const OfferBadge = ({ status }: { status: number }) => (
  <Badge variant="outline" className={OFFER_STYLE[status]}>
    {OFFER[status]}
  </Badge>
);

export function ScheduleSelect({ name = "period", defaultValue = "0" }: { name?: string; defaultValue?: string }) {
  return (
    <Select name={name} defaultValue={defaultValue}>
      <SelectTrigger className="w-full">
        <SelectValue />
      </SelectTrigger>
      <SelectContent>
        {SCHEDULES.map((s) => (
          <SelectItem key={s.value} value={s.value}>
            {s.label}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  );
}

export function Empty({ icon: Icon, title, children }: { icon: LucideIcon; title: string; children?: ReactNode }) {
  return (
    <div className="flex flex-col items-center gap-3 px-6 py-14 text-center">
      <span className="grid size-11 place-items-center rounded-full border bg-secondary">
        <Icon className="size-5 text-muted-foreground" />
      </span>
      <p className="font-medium">{title}</p>
      {children && <div className="max-w-sm text-sm text-muted-foreground">{children}</div>}
    </div>
  );
}

export function Panel({ title, action, children, className }: { title: string; action?: ReactNode; children: ReactNode; className?: string }) {
  return (
    <section className={cn("overflow-hidden rounded-2xl border bg-card", className)}>
      <div className="flex items-center justify-between gap-4 border-b px-5 py-4">
        <h2 className="text-base font-semibold">{title}</h2>
        {action}
      </div>
      {children}
    </section>
  );
}
