import { ArcLogo, UsdcLockup, Wordmark } from "@/components/brand";
import { DEPLOYED, explorerUrl, NETWORK, short, VAULT } from "@/lib/chain";

const REPO = "https://github.com/Raveesh1007/StreamArc";

export function SiteFooter({ root = "./" }: { root?: string }) {
  const cols = [
    {
      title: "Product",
      links: [
        ["Launch app", `${root}app/`],
        ["How it works", `${root}#how`],
        ["Roadmap", `${root}#roadmap`],
      ],
    },
    {
      title: "Developers",
      links: [
        ["Source code", REPO],
        ["PayrollVault", `${REPO}/blob/main/payroll/src/PayrollVault.sol`],
        ["Arc docs", "https://docs.arc.io"],
      ],
    },
  ];
  return (
    <footer className="border-t">
      <div className="mx-auto grid max-w-6xl gap-10 px-4 py-14 sm:px-6 md:grid-cols-[1.4fr_1fr_1fr_1.2fr]">
        <div className="space-y-3">
          <Wordmark />
          <p className="max-w-xs text-sm text-muted-foreground">Payroll that pays every second, in USDC.</p>
        </div>
        {cols.map((c) => (
          <div key={c.title} className="space-y-3 text-sm">
            <p className="font-mono text-xs tracking-widest text-muted-foreground uppercase">{c.title}</p>
            {c.links.map(([label, href]) => (
              <a key={label} href={href} className="block text-foreground/80 transition-colors hover:text-primary">
                {label}
              </a>
            ))}
          </div>
        ))}
        <div className="space-y-4 text-sm">
          <p className="font-mono text-xs tracking-widest text-muted-foreground uppercase">Built on</p>
          <div className="flex items-center gap-5 opacity-80">
            <ArcLogo className="h-5" />
            <UsdcLockup className="h-5" />
          </div>
          {DEPLOYED && (
            <a href={explorerUrl("address", VAULT)} className="block font-mono text-xs text-muted-foreground hover:text-primary">
              {NETWORK} · {short(VAULT)}
            </a>
          )}
        </div>
      </div>
      <div className="border-t">
        <p className="mx-auto max-w-6xl px-4 py-5 text-xs text-muted-foreground sm:px-6">
          © 2026 StreamArc · Open source under GPL-3.0
        </p>
      </div>
    </footer>
  );
}
