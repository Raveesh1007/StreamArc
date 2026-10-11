import { Moon, Sun } from "lucide-react";
import type { ReactNode } from "react";
import { Wordmark } from "@/components/brand";
import { Button } from "@/components/ui/button";
import { setTheme, useTheme } from "@/lib/theme";

export function SiteHeader({ home = "./", links, children }: { home?: string; links?: ReactNode; children?: ReactNode }) {
  const theme = useTheme();
  return (
    <header className="sticky top-0 z-40 border-b bg-background/75 backdrop-blur-xl">
      <div className="mx-auto flex h-16 max-w-6xl items-center gap-8 px-4 sm:px-6">
        <a href={home} aria-label="StreamArc home">
          <Wordmark />
        </a>
        <nav className="hidden items-center gap-6 text-sm text-muted-foreground md:flex">{links}</nav>
        <div className="ml-auto flex items-center gap-2">
          <Button
            variant="ghost"
            size="icon"
            aria-label={`Switch to ${theme === "dark" ? "light" : "dark"} mode`}
            onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
          >
            {theme === "dark" ? <Sun /> : <Moon />}
          </Button>
          {children}
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
