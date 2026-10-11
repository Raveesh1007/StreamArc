import { useEffect, useRef } from "react";
import { cn } from "@/lib/utils";
import type { Logo } from "./ascii-coin-scene";

export function AsciiCoin({ logos, className }: { logos: Logo[]; className?: string }) {
  const ref = useRef<HTMLDivElement>(null);
  const key = logos.join();
  useEffect(() => {
    let dispose: (() => void) | undefined;
    let dead = false;
    import("./ascii-coin-scene").then((m) => {
      if (!dead && ref.current) dispose = m.mount(ref.current, key.split(",") as Logo[]);
    });
    return () => {
      dead = true;
      dispose?.();
    };
  }, [key]);
  return <div ref={ref} aria-hidden className={cn("pointer-events-none overflow-hidden text-ascii select-none", className)} />;
}
