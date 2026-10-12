import { useEffect, useRef, type ComponentProps } from "react";
import { cn } from "@/lib/utils";

export function HoloCard({ className, children, ...props }: ComponentProps<"div">) {
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    const el = ref.current!;
    const io = new IntersectionObserver(
      ([e]) => {
        if (e.isIntersecting) el.dataset.in = "";
        el.toggleAttribute("data-view", e.isIntersecting);
      },
      { threshold: 0.2 },
    );
    io.observe(el);
    return () => io.disconnect();
  }, []);
  return (
    <div
      {...props}
      ref={ref}
      onPointerMove={(e) => {
        if (e.pointerType !== "mouse") return;
        const r = e.currentTarget.getBoundingClientRect();
        const x = (e.clientX - r.left) / r.width;
        const y = (e.clientY - r.top) / r.height;
        const s = e.currentTarget.style;
        s.setProperty("--px", `${x}`);
        s.setProperty("--py", `${y}`);
        s.setProperty("--rx", `${(0.5 - y) * 7}deg`);
        s.setProperty("--ry", `${(x - 0.5) * 7}deg`);
      }}
      onPointerLeave={(e) => {
        e.currentTarget.style.setProperty("--rx", "0deg");
        e.currentTarget.style.setProperty("--ry", "0deg");
      }}
      className={cn("holo relative overflow-hidden rounded-2xl border bg-card", className)}
    >
      {children}
      <div aria-hidden className="holo-foil" />
      <div aria-hidden className="holo-glare" />
    </div>
  );
}
