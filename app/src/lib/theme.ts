import { useSyncExternalStore } from "react";

export type Theme = "light" | "dark";

const subs = new Set<() => void>();
export const getTheme = (): Theme => (document.documentElement.classList.contains("dark") ? "dark" : "light");
export const onTheme = (cb: () => void) => (subs.add(cb), () => void subs.delete(cb));

export function setTheme(t: Theme) {
  document.documentElement.classList.toggle("dark", t === "dark");
  try {
    localStorage.setItem("theme", t);
  } catch {}
  subs.forEach((f) => f());
}

export const useTheme = () => useSyncExternalStore(onTheme, getTheme);
