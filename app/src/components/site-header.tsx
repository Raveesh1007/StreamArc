import { Menu, Moon, Sun } from "lucide-react";
import type { ReactNode } from "react";
import { Wordmark } from "@/components/brand";
import { Button } from "@/components/ui/button";
import { setTheme, useTheme } from "@/lib/theme";

export function SiteHeader({ home = "./", links, children }: { home?: string; links?: ReactNode; children?: ReactNode }) {
  const theme = useTheme();
  return (
    <header className="sticky top-0 z-40 flex h-0 justify-center">
      <div className="notch flex h-13 max-w-[calc(100%-2.5rem)] items-center gap-6 pr-2.5 pl-3.5 text-foreground">
        <a href={home} aria-label="StreamArc home" className="shrink-0">
          <Wordmark className="text-base" />
        </a>
        <nav className="hidden items-center gap-5 text-sm font-medium text-foreground/60 md:flex">{links}</nav>
        <div className="ml-auto flex items-center gap-1.5">
          <Button
            variant="ghost"
            size="icon"
            className="size-8 rounded-full"
            aria-label={`Switch to ${theme === "dark" ? "light" : "dark"} mode`}
            onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
          >
            {theme === "dark" ? <Sun /> : <Moon />}
          </Button>
          {children}
          {links && (
            <details className="group relative md:hidden">
              <summary className="grid size-8 list-none place-items-center rounded-full hover:bg-accent [&::-webkit-details-marker]:hidden" aria-label="Menu">
                <Menu className="size-4" />
              </summary>
              <nav
                onClick={(e) => e.currentTarget.closest("details")!.removeAttribute("open")}
                className="absolute top-11 right-0 flex w-48 flex-col gap-1 rounded-2xl border bg-background/95 p-2 text-sm text-foreground/70 shadow-2xl [&>a]:rounded-lg [&>a]:px-3 [&>a]:py-2 [&>a:hover]:bg-accent"
              >
                {links}
              </nav>
            </details>
          )}
        </div>
      </div>
    </header>
  );
}

export const NavLink = ({ href, children }: { href: string; children: ReactNode }) => (
  <a href={href} className="transition-colors hover:text-foreground">
    {children}
  </a>
);
