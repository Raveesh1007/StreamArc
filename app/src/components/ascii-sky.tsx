import { useEffect, useRef } from "react";
import { onTheme } from "@/lib/theme";
import { cn } from "@/lib/utils";

const GLYPHS = "..··:+*✦";
const HUES = ["--foreground", "--foreground", "--cyan", "--usdc-bright", "--violet", "--arc-gold", "--primary"];

type Star = { x: number; y: number; g: string; c: number; p: number; s: number };
type Meteor = { x: number; y: number; t: number };

export function AsciiSky({ className, density = 1 }: { className?: string; density?: number }) {
  const ref = useRef<HTMLCanvasElement>(null);
  useEffect(() => {
    const cv = ref.current!;
    const ctx = cv.getContext("2d")!;
    const still = matchMedia("(prefers-reduced-motion: reduce)").matches;
    let w = 0, h = 0, stars: Star[] = [], colors: string[] = [], dark = false, meteor: Meteor | null = null;
    let raf = 0, visible = true, next = 3000;

    const readColors = () => {
      const cs = getComputedStyle(cv);
      colors = HUES.map((v) => cs.getPropertyValue(v).trim());
      dark = document.documentElement.classList.contains("dark");
    };
    const resize = () => {
      const dpr = Math.min(devicePixelRatio, 2);
      w = cv.clientWidth;
      h = cv.clientHeight;
      cv.width = w * dpr;
      cv.height = h * dpr;
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      stars = Array.from({ length: Math.round(((w * h) / 2600) * density) }, () => ({
        x: Math.random() * w,
        y: Math.random() * h,
        g: GLYPHS[(Math.random() ** 2.2 * GLYPHS.length) | 0],
        c: (Math.random() * HUES.length) | 0,
        p: Math.random() * 6.28,
        s: 0.4 + Math.random() * 1.6,
      }));
    };
    const draw = (t: number) => {
      ctx.clearRect(0, 0, w, h);
      ctx.font = '12px "JetBrains Mono Variable", monospace';
      const base = dark ? 0.75 : 0.5;
      for (const st of stars) {
        ctx.globalAlpha = base * (still ? 0.7 : 0.35 + 0.65 * Math.abs(Math.sin(t / 1000 * st.s + st.p)));
        ctx.fillStyle = colors[st.c];
        ctx.fillText(st.g, st.x, st.y);
      }
      if (meteor) {
        const age = (t - meteor.t) / 1100;
        if (age > 1) meteor = null;
        else
          for (let i = 0; i < 14; i++) {
            const k = age * 1.4 - i * 0.025;
            if (k < 0) continue;
            ctx.globalAlpha = (1 - i / 14) * (1 - age) * base * 1.3;
            ctx.fillStyle = colors[i < 3 ? 0 : 2];
            ctx.fillText(i < 2 ? "*" : "·", meteor.x + k * 380, meteor.y + k * 150);
          }
      }
      ctx.globalAlpha = 1;
    };
    const loop = (t: number) => {
      if (!meteor && t > next) {
        meteor = { x: Math.random() * w * 0.7, y: Math.random() * h * 0.4, t };
        next = t + 4000 + Math.random() * 6000;
      }
      draw(t);
      raf = visible ? requestAnimationFrame(loop) : 0;
    };

    readColors();
    resize();
    const ro = new ResizeObserver(() => (resize(), still && draw(0)));
    ro.observe(cv);
    const io = new IntersectionObserver(([e]) => {
      visible = e.isIntersecting;
      if (visible && !raf && !still) raf = requestAnimationFrame(loop);
    });
    io.observe(cv);
    const off = onTheme(() => (readColors(), still && draw(0)));
    if (still) draw(0);
    return () => (cancelAnimationFrame(raf), ro.disconnect(), io.disconnect(), off());
  }, [density]);
  return <canvas ref={ref} aria-hidden className={cn("pointer-events-none absolute inset-0 size-full", className)} />;
}
