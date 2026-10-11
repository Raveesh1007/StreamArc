import { useEffect, useRef } from "react";
import { cn } from "@/lib/utils";

const fmt = (v: number, digits: number) =>
  `$${v.toLocaleString("en-US", { minimumFractionDigits: digits, maximumFractionDigits: digits })}`;

export function LiveAmount({
  base,
  rate,
  digits = 6,
  className,
}: {
  base: bigint;
  rate: bigint;
  digits?: number;
  className?: string;
}) {
  const ref = useRef<HTMLSpanElement>(null);
  useEffect(() => {
    const start = performance.now();
    const b = Number(base) / 1e6;
    const r = Number(rate) / 1e24;
    const id = setInterval(() => {
      if (ref.current) ref.current.textContent = fmt(b + (r * (performance.now() - start)) / 1000, digits);
    }, 50);
    return () => clearInterval(id);
  }, [base, rate, digits]);
  return (
    <span ref={ref} className={cn("font-mono tabular", className)}>
      {fmt(Number(base) / 1e6, digits)}
    </span>
  );
}
