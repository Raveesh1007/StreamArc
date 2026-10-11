import { Check, Lock } from "lucide-react";
import { useEffect, useRef, type ReactNode } from "react";
import { UsdcToken } from "@/components/brand";
import { LiveAmount } from "@/components/live-amount";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import { toRate } from "@/lib/vault";

export function Tile({
  title,
  desc,
  badge,
  className,
  delay = 0,
  children,
}: {
  title: string;
  desc: string;
  badge?: string;
  className?: string;
  delay?: number;
  children: ReactNode;
}) {
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    const el = ref.current!;
    const io = new IntersectionObserver(([e]) => e.isIntersecting && (el.dataset.in = "", io.disconnect()), { threshold: 0.2 });
    io.observe(el);
    return () => io.disconnect();
  }, []);
  return (
    <div
      ref={ref}
      style={{ animationDelay: `${delay}ms` }}
      onPointerMove={(e) => {
        const r = e.currentTarget.getBoundingClientRect();
        e.currentTarget.style.setProperty("--x", `${e.clientX - r.left}px`);
        e.currentTarget.style.setProperty("--y", `${e.clientY - r.top}px`);
      }}
      className={cn(
        "reveal spotlight group relative flex flex-col overflow-hidden rounded-2xl border bg-card transition-colors hover:border-primary/40",
        className,
      )}
    >
      <div className="relative flex min-h-44 flex-1 items-center justify-center overflow-hidden px-6 pt-6">{children}</div>
      <div className="relative flex items-end justify-between gap-4 p-6">
        <div>
          <h3 className="text-lg font-semibold">{title}</h3>
          <p className="mt-1.5 max-w-md text-sm text-muted-foreground">{desc}</p>
        </div>
        {badge && (
          <Badge variant="outline" className="shrink-0 font-mono text-[10px] tracking-wide text-muted-foreground uppercase">
            {badge}
          </Badge>
        )}
      </div>
    </div>
  );
}

const SALARY = toRate("4200");

export function EarningsVisual() {
  return (
    <div className="flex w-full items-end justify-between gap-8">
      <div>
        <p className="font-mono text-[11px] tracking-widest text-muted-foreground uppercase">Earned today</p>
        <LiveAmount base={161_000000n} rate={SALARY} digits={4} className="mt-1 block text-4xl sm:text-5xl" />
        <p className="mt-2 font-mono text-xs text-primary">+$0.00162 / s</p>
      </div>
      <div className="flex h-28 flex-1 items-end gap-1.5 sm:max-w-xs">
        {Array.from({ length: 14 }, (_, i) => (
          <span
            key={i}
            style={{ height: `${30 + i * 5}%`, animationDelay: `${i * -170}ms` }}
            className="animate-bar flex-1 origin-bottom rounded-t-sm bg-primary/25 group-hover:bg-primary/40 last:bg-primary"
          />
        ))}
      </div>
    </div>
  );
}

export function ScheduleVisual() {
  return (
    <div className="w-full space-y-4 font-mono text-[11px] text-muted-foreground">
      <div>
        <p>EVERY SECOND</p>
        <div className="mt-1.5 h-2 overflow-hidden rounded-full bg-muted">
          <div className="animate-fill h-full origin-left rounded-full bg-primary" />
        </div>
      </div>
      <div>
        <p>WEEKLY</p>
        <div className="mt-1.5 flex gap-1">
          {[0, 1, 2, 3].map((i) => (
            <span key={i} style={{ animationDelay: `${i * 750}ms` }} className="animate-step h-2 flex-1 rounded-full bg-primary" />
          ))}
        </div>
      </div>
      <div>
        <p>EVERY 30 DAYS</p>
        <div className="mt-1.5 h-2 rounded-full bg-muted">
          <span className="animate-step block h-full rounded-full bg-primary [animation-delay:2250ms]" />
        </div>
      </div>
    </div>
  );
}

export function RunwayVisual() {
  return (
    <div className="relative grid size-36 place-items-center">
      <svg viewBox="0 0 100 100" className="absolute inset-0 -rotate-90">
        <circle cx="50" cy="50" r="42" fill="none" stroke="var(--muted)" strokeWidth="7" />
        <circle
          cx="50"
          cy="50"
          r="42"
          fill="none"
          stroke="var(--primary)"
          strokeWidth="7"
          strokeLinecap="round"
          pathLength={1}
          strokeDasharray="0.72 1"
          className="transition-[stroke-dasharray] duration-700 group-hover:[stroke-dasharray:0.9_1]"
        />
      </svg>
      <div className="text-center">
        <p className="font-mono text-3xl">42</p>
        <p className="text-xs text-muted-foreground">days left</p>
      </div>
    </div>
  );
}

export function DebtVisual() {
  return (
    <div className="w-full space-y-3 text-xs">
      <div className="flex h-10 overflow-hidden rounded-lg border">
        <div className="animate-stripes stripes flex w-[62%] items-center gap-1.5 px-3 text-warning">
          <Lock className="size-3.5" /> Owed
        </div>
        <div className="flex flex-1 items-center bg-primary/15 px-3 text-primary">Free</div>
      </div>
      <div className="flex justify-between font-mono text-muted-foreground">
        <span>$12,400 locked for the team</span>
        <span>$7,600</span>
      </div>
    </div>
  );
}

export function ConsentVisual() {
  return (
    <div className="w-full space-y-2.5 text-sm">
      <div className="flex items-center justify-between rounded-lg border bg-background px-3 py-2.5">
        <span>
          Raise <span className="font-mono text-primary">+$500</span>
        </span>
        <span className="flex items-center gap-1 text-xs text-primary">
          <Check className="size-3.5" /> Applied
        </span>
      </div>
      <div className="relative h-11">
        <div className="animate-cycle absolute inset-0 flex items-center justify-between rounded-lg border bg-background px-3">
          <span>
            Pay cut <span className="font-mono text-warning">−$200</span>
          </span>
          <span className="flex items-center gap-1.5 text-xs text-warning">
            <span className="animate-pulse-dot size-1.5 rounded-full bg-warning" /> Needs consent
          </span>
        </div>
        <div className="animate-cycle absolute inset-0 flex items-center justify-between rounded-lg border bg-background px-3 opacity-0 [animation-delay:3s]">
          <span>New schedule: weekly</span>
          <span className="flex items-center gap-1 text-xs text-primary">
            <Check className="size-3.5" /> Accepted
          </span>
        </div>
      </div>
    </div>
  );
}

export function BulkVisual() {
  const rows = ["0x8d2b…2b76, 3000, continuous", "0x551f…df90, 4500, weekly", "0x3a9c…71e2, 5200, monthly"];
  return (
    <div className="flex w-full items-center gap-4">
      <div className="flex-1 space-y-1.5 rounded-lg border bg-background p-3 font-mono text-[11px] text-muted-foreground">
        {rows.map((r, i) => (
          <p key={r} style={{ animationDelay: `${i * 400}ms` }} className="animate-row truncate">
            {r}
          </p>
        ))}
      </div>
      <div className="shrink-0 text-center">
        <p className="font-mono text-2xl text-primary">1 tx</p>
        <p className="text-xs text-muted-foreground">3 offers</p>
      </div>
    </div>
  );
}

export function GasVisual() {
  return (
    <div className="flex items-center gap-4">
      {[0, 1, 2].map((i) => (
        <span
          key={i}
          style={{ animationDelay: `${i * -2.3}s` }}
          className={cn("animate-tilt grid place-items-center rounded-full border bg-background", i === 1 ? "size-20" : "size-12")}
        >
          <UsdcToken className={i === 1 ? "size-12" : "size-7"} />
        </span>
      ))}
    </div>
  );
}

export function VestingVisual() {
  return (
    <svg viewBox="0 0 320 120" className="h-36 w-full max-w-lg overflow-visible">
      {[30, 60, 90].map((y) => (
        <line key={y} x1="0" x2="320" y1={y} y2={y} stroke="var(--border)" strokeDasharray="2 4" />
      ))}
      <line x1="80" x2="80" y1="10" y2="115" stroke="var(--border)" />
      <text x="84" y="20" className="fill-muted-foreground font-mono text-[9px]">
        CLIFF
      </text>
      <path
        d="M0 115 H80 V88 L300 12"
        fill="none"
        stroke="var(--primary)"
        strokeWidth="2.5"
        strokeLinejoin="round"
        pathLength={1}
        strokeDasharray="1 1"
        className="animate-draw"
      />
      <circle cx="80" cy="88" r="4" fill="var(--primary)" />
      <text x="90" y="100" className="fill-primary font-mono text-[9px]">
        25% at cliff
      </text>
    </svg>
  );
}

export function FlowVisual() {
  return (
    <svg viewBox="0 0 200 80" className="h-28 w-full">
      {[20, 40, 60].map((y, i) => (
        <path
          key={y}
          d={`M0 ${y} C60 ${y - 14} 140 ${y + 14} 200 ${y}`}
          fill="none"
          stroke="var(--primary)"
          strokeOpacity={0.35 + i * 0.25}
          strokeWidth="2"
          strokeDasharray="3 9"
          className="animate-flow"
          style={{ animationDuration: `${1.2 + i * 0.5}s` }}
        />
      ))}
    </svg>
  );
}

export function MerkleVisual() {
  const nodes: [number, number][] = [[100, 14], [55, 44], [145, 44], [30, 74], [80, 74], [120, 74], [170, 74]];
  const edges = [[0, 1], [0, 2], [1, 3], [1, 4], [2, 5], [2, 6]];
  return (
    <svg viewBox="0 0 200 90" className="h-28 w-full">
      {edges.map(([a, b]) => (
        <line key={`${a}${b}`} x1={nodes[a][0]} y1={nodes[a][1]} x2={nodes[b][0]} y2={nodes[b][1]} stroke="var(--border)" strokeWidth="1.5" />
      ))}
      {nodes.map(([x, y], i) => (
        <circle key={i} cx={x} cy={y} r="8" strokeWidth="1.5" className="animate-node" style={{ animationDelay: `${(6 - i) * 0.25}s` }} />
      ))}
    </svg>
  );
}

export function AdvanceVisual() {
  return (
    <div className="flex items-center gap-8">
      <div className="animate-tilt w-48 rounded-xl border bg-background p-4 shadow-xl shadow-black/10">
        <div className="flex items-center justify-between">
          <span className="font-mono text-[10px] text-muted-foreground">STREAM #128</span>
          <UsdcToken className="size-4" />
        </div>
        <LiveAmount base={2_400_000000n} rate={SALARY} digits={2} className="mt-6 block text-2xl" />
        <p className="mt-1 text-[11px] text-muted-foreground">future pay, as an NFT</p>
      </div>
      <div className="hidden text-sm sm:block">
        <p className="text-muted-foreground">Borrow up to</p>
        <p className="font-mono text-2xl text-primary">$1,800</p>
      </div>
    </div>
  );
}
