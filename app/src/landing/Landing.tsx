import { ArrowRight, ArrowUpRight } from "lucide-react";
import { useState } from "react";
import { AsciiCoin } from "@/components/ascii-coin";
import { AsciiSky } from "@/components/ascii-sky";
import { HoloCard } from "@/components/holo-card";
import { ArcIcon, ArcLogo, UsdcLockup, UsdcToken } from "@/components/brand";
import { LiveAmount } from "@/components/live-amount";
import { NavLink, SiteHeader } from "@/components/site-header";
import { SiteFooter } from "@/components/site-footer";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { toRate } from "@/lib/vault";
import {
  AdvanceVisual,
  BulkVisual,
  ConsentVisual,
  DebtVisual,
  EarningsVisual,
  FlowVisual,
  GasVisual,
  hue,
  type Hue,
  MerkleVisual,
  RunwayVisual,
  ScheduleVisual,
  Tile,
  VestingVisual,
} from "./bento";

const REPO = "https://github.com/Raveesh1007/StreamArc";
const SALARY = toRate("3000");

export function Landing() {
  return (
    <>
      <SiteHeader
        links={
          <>
            <NavLink href="#how">How it works</NavLink>
            <NavLink href="#features">Features</NavLink>
            <NavLink href="#developers">Developers</NavLink>
            <NavLink href="#roadmap">Roadmap</NavLink>
          </>
        }
      >
        <Button variant="ghost" size="sm" asChild className="hidden rounded-full text-foreground/60 sm:inline-flex">
          <a href={REPO}>GitHub</a>
        </Button>
        <Button size="sm" asChild className="rounded-full bg-foreground text-background hover:bg-foreground/85">
          <a href="./app/">
            Start <ArrowRight />
          </a>
        </Button>
      </SiteHeader>
      <main>
        <Hero />
        <BuiltOn />
        <HowItWorks />
        <Features />
        <Developers />
        <Roadmap />
        <Cta />
      </main>
      <SiteFooter />
    </>
  );
}

function Section({
  id,
  eyebrow,
  title,
  intro,
  glow = "violet",
  children,
}: {
  id?: string;
  eyebrow: string;
  title: string;
  intro?: string;
  glow?: Hue;
  children: React.ReactNode;
}) {
  return (
    <section id={id} style={hue(glow)} className="relative scroll-mt-16 overflow-hidden border-t">
      <div className="pointer-events-none absolute -top-40 left-1/2 h-80 w-[70rem] -translate-x-1/2 rounded-full bg-primary/10 blur-3xl" />
      <div className="pointer-events-none absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-primary/60 to-transparent" />
      <div className="relative mx-auto max-w-6xl px-4 py-24 sm:px-6">
        <p className="font-mono text-xs tracking-[0.2em] text-primary uppercase">{eyebrow}</p>
        <h2 className="mt-4 max-w-2xl text-4xl font-semibold sm:text-5xl">{title}</h2>
        {intro && <p className="mt-4 max-w-xl text-lg text-muted-foreground">{intro}</p>}
        <div className="mt-14">{children}</div>
      </div>
    </section>
  );
}

function Hero() {
  return (
    <section className="bg-sky relative overflow-hidden">
      <AsciiSky className="[mask-image:linear-gradient(black_40%,transparent)]" />
      <div className="beams animate-beam pointer-events-none absolute -top-10 left-1/2 h-[46rem] w-[90rem] -translate-x-1/2" />
      <div className="horizon pointer-events-none absolute -bottom-[25rem] left-1/2 h-[36rem] w-[150%] -translate-x-1/2 max-lg:hidden" />
      <div className="relative mx-auto grid max-w-6xl items-center gap-16 px-4 pt-24 pb-20 sm:px-6 lg:grid-cols-[1.1fr_0.9fr] lg:pt-32 [&>*]:min-w-0">
        <div>
          <a
            href="https://docs.arc.io"
            className="animate-rise inline-flex items-center gap-2 rounded-full border bg-card/60 py-1 pr-3 pl-1.5 text-xs text-muted-foreground backdrop-blur hover:text-foreground"
          >
            <span className="flex items-center gap-1.5 rounded-full bg-secondary px-2 py-0.5 text-foreground">
              <ArcIcon className="h-3" /> Live on Arc
            </span>
            Settled in USDC, gas paid in USDC
            <ArrowUpRight className="size-3" />
          </a>
          <h1 className="animate-rise mt-7 text-[2.6rem] leading-[0.95] font-semibold [animation-delay:80ms] sm:text-7xl">
            Payroll that pays
            <br />
            <span className="text-glow text-primary">every second.</span>
          </h1>
          <p className="animate-rise mt-7 max-w-lg text-lg text-muted-foreground [animation-delay:160ms]">
            Fund one USDC pool. Your team earns by the second and withdraws whenever they want, to any wallet. No
            payday waits, no bank rails, no second token for gas.
          </p>
          <div className="animate-rise mt-9 flex flex-wrap gap-3 [animation-delay:240ms]">
            <Button size="lg" asChild>
              <a href="./app/">
                Launch app <ArrowRight />
              </a>
            </Button>
            <Button size="lg" variant="outline" asChild>
              <a href="#how">See how it works</a>
            </Button>
          </div>
        </div>
        <div className="relative pt-36 sm:pt-52 lg:pr-16">
          <AsciiCoin
            logos={["arc", "usdc"]}
            className="text-aurora animate-aurora opacity-60 dark:opacity-80 absolute -top-28 -right-28 size-[42rem] [mask-image:radial-gradient(circle,black_50%,transparent_70%)] max-sm:-top-8 max-sm:-right-32 max-sm:size-[26rem]"
          />
          <Payslip />
        </div>
      </div>
      <div className="relative border-t bg-card/50 backdrop-blur-md">
        <dl className="mx-auto grid max-w-6xl grid-cols-2 px-4 sm:px-6 lg:grid-cols-4">
          {[
            ["$0.001157", "earned per second on a $3k salary"],
            ["< 1 s", "finality on Arc"],
            ["~$0.01", "gas per transaction, paid in USDC"],
            ["0%", "protocol fees"],
          ].map(([v, k], i) => (
            <div key={k} style={hue(STAT_HUES[i])} className={cn("py-7 pr-4", i > 0 && "lg:border-l lg:pl-8", i % 2 === 1 && "border-l pl-6")}>
              <dt className="font-mono text-2xl text-primary">{v}</dt>
              <dd className="mt-1 text-sm text-muted-foreground">{k}</dd>
            </div>
          ))}
        </dl>
      </div>
    </section>
  );
}

const STAT_HUES: Hue[] = ["primary", "cyan", "usdc-bright", "violet"];

function Payslip() {
  return (
    <div className="animate-rise relative [animation-delay:320ms]">
      <HoloCard className="bg-card/90 p-6 shadow-2xl shadow-black/20 backdrop-blur-md dark:shadow-black/60">
        <div className="flex items-center justify-between">
          <span className="font-mono text-xs tracking-widest text-muted-foreground uppercase">Live payslip</span>
          <span className="flex items-center gap-2 text-xs text-primary">
            <span className="animate-pulse-dot size-1.5 rounded-full bg-primary" /> Streaming
          </span>
        </div>
        <div className="mt-6 flex items-center gap-3">
          <Party label="Acme pool" sub="Employer" />
          <svg viewBox="0 0 100 8" preserveAspectRatio="none" className="h-2 flex-1" aria-hidden>
            <line x1="0" y1="4" x2="100" y2="4" stroke="var(--border)" strokeWidth="2" />
            <defs>
              <linearGradient id="payslip-flow">
                <stop offset="0" stopColor="var(--primary)" />
                <stop offset="0.5" stopColor="var(--usdc-bright)" />
                <stop offset="1" stopColor="var(--violet)" />
              </linearGradient>
            </defs>
            <line
              x1="0"
              y1="4"
              x2="100"
              y2="4"
              stroke="url(#payslip-flow)"
              strokeWidth="2"
              strokeDasharray="4 8"
              className="animate-flow"
            />
          </svg>
          <Party label="alice.eth" sub="Employee" />
        </div>
        <div className="mt-8">
          <p className="text-sm text-muted-foreground">Earned since you opened this page</p>
          <LiveAmount base={0n} rate={SALARY} className="mt-1 block text-4xl text-foreground sm:text-5xl" />
        </div>
        <dl className="mt-8 grid grid-cols-2 gap-px overflow-hidden rounded-xl border bg-border text-sm">
          {[
            ["Salary", "$3,000.00 / mo"],
            ["Rate", "$0.001157 / s"],
            ["Paid", "Every second"],
            ["Withdraw", "Any time"],
          ].map(([k, v]) => (
            <div key={k} className="bg-card px-4 py-3">
              <dt className="text-xs text-muted-foreground">{k}</dt>
              <dd className="mt-0.5 font-mono">{v}</dd>
            </div>
          ))}
        </dl>
      </HoloCard>
    </div>
  );
}

function Party({ label, sub }: { label: string; sub: string }) {
  return (
    <div className="flex items-center gap-2.5">
      <span className="grid size-10 place-items-center rounded-full border bg-secondary">
        <UsdcToken />
      </span>
      <div className="leading-tight">
        <p className="text-sm font-medium">{label}</p>
        <p className="text-xs text-muted-foreground">{sub}</p>
      </div>
    </div>
  );
}

function BuiltOn() {
  return (
    <section className="border-t">
      <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-8 px-4 py-12 sm:px-6 md:flex-row">
        <p className="max-w-sm text-sm text-muted-foreground">
          Built on Arc, Circle's stablecoin-native chain. Salaries are USDC from deposit to withdrawal.
        </p>
        <div className="flex flex-wrap items-center justify-center gap-6 sm:gap-10">
          <div className="flex items-center gap-3">
            <span className="font-mono text-xs text-muted-foreground uppercase">Built on</span>
            <ArcLogo className="h-7" />
          </div>
          <div className="hidden h-8 w-px bg-border sm:block" />
          <div className="flex items-center gap-3">
            <span className="font-mono text-xs text-muted-foreground uppercase">Paid in</span>
            <UsdcLockup className="h-7" />
          </div>
        </div>
      </div>
    </section>
  );
}

const STEP_HUES: Hue[] = ["primary", "usdc-bright", "violet"];

function HowItWorks() {
  const steps = [
    ["Fund the pool", "Deposit USDC once. It sits in the PayrollVault contract, not with us."],
    ["Send offers", "Pick a salary and a schedule: every second, weekly or every 30 days. The employee accepts on-chain."],
    ["Pay streams", "Earnings accrue every second. Employees withdraw whatever has unlocked, to any address."],
  ];
  return (
    <Section id="how" eyebrow="How it works" title="Three steps from wallet to payroll." glow="usdc-bright">
      <ol className="grid gap-4 md:grid-cols-3">
        {steps.map(([t, d], i) => (
          <li key={t} style={hue(STEP_HUES[i])}>
            <HoloCard className="h-full p-8">
              <span className="font-mono text-sm text-primary">0{i + 1}</span>
              <h3 className="mt-10 text-2xl font-semibold">{t}</h3>
              <p className="mt-3 text-muted-foreground">{d}</p>
            </HoloCard>
          </li>
        ))}
      </ol>
    </Section>
  );
}

function Features() {
  return (
    <Section
      id="features"
      eyebrow="Features"
      title="Fair to the team. Simple for the employer."
      intro="Everything runs in one open-source contract on Arc. No custody, no middleman."
      glow="primary"
    >
      <div className="grid gap-4 md:grid-cols-6">
        <Tile className="md:col-span-4" title="Paid by the second" desc="Earnings accrue continuously. Nobody waits two weeks for money they've already earned.">
          <EarningsVisual />
        </Tile>
        <Tile className="md:col-span-2" delay={80} tone="cyan" title="Payday schedules" desc="Every second, weekly or every 30 days. Ending early pays the partial period pro rata.">
          <ScheduleVisual />
        </Tile>
        <Tile className="md:col-span-2" delay={0} tone="usdc-bright" title="Runway at a glance" desc="What's owed, what's free, monthly burn and how long the pool lasts.">
          <RunwayVisual />
        </Tile>
        <Tile className="md:col-span-2" delay={80} tone="arc-gold" title="Debt stays on record" desc="Employers can only withdraw what isn't owed. Back pay is settled first on top-up.">
          <DebtVisual />
        </Tile>
        <Tile className="md:col-span-2" delay={160} tone="violet" title="Consent built in" desc="Raises apply instantly. Cuts and schedule changes wait for the employee.">
          <ConsentVisual />
        </Tile>
        <Tile className="md:col-span-3" delay={0} tone="arc-coral" title="Bulk offers" desc="Paste wallets and salaries. Everyone gets an offer in a single transaction.">
          <BulkVisual />
        </Tile>
        <Tile className="md:col-span-3" delay={80} tone="usdc-bright" title="Gas in USDC" desc="Arc charges gas in USDC, so employees never need a second token to get paid.">
          <GasVisual />
        </Tile>
      </div>
    </Section>
  );
}

const SNIPPETS = {
  Employer: `const vault = getContract({ address: PAYROLL, abi, client })

await vault.write.deposit([parseUnits("30000", 6)])

await vault.write.propose([
  alice,
  await vault.read.monthlyToRate([3000_000000n]),
  604800n,
  0n,
])`,
  Employee: `await vault.write.acceptOffer([offerId])

const ready = await vault.read.withdrawable([streamId])

await vault.write.withdraw([streamId, ready, myWallet])`,
};

const highlight = (code: string) =>
  code.split(/("[^"]*"|\b(?:await|const)\b|\b\d[\d_]*n?\b|\.\w+(?=\())/g).map((t, i) =>
    i % 2 === 0 ? (
      t
    ) : (
      <span
        key={i}
        className={
          t.startsWith('"')
            ? "text-arc-gold"
            : /^\d/.test(t)
              ? "text-usdc-bright"
              : t.startsWith(".")
                ? "text-primary"
                : "text-violet"
        }
      >
        {t}
      </span>
    ),
  );

function Developers() {
  const [tab, setTab] = useState<keyof typeof SNIPPETS>("Employer");
  return (
    <Section
      id="developers"
      eyebrow="Developers"
      title="One contract. A handful of calls."
      intro="PayrollVault is plain Solidity on Arc. Integrate payroll into your own product with viem in a few lines."
      glow="cyan"
    >
      <div className="grid gap-10 lg:grid-cols-[1fr_1.3fr]">
        <ul className="space-y-6 text-muted-foreground">
          {[
            ["deposit", "Fund the employer pool in USDC."],
            ["propose / batchPropose", "Send one offer or hundreds."],
            ["raise / proposeChange", "Instant raises, consent-based cuts."],
            ["withdraw", "Employees pull unlocked pay to any address."],
          ].map(([f, d]) => (
            <li key={f} className="border-l-2 border-border pl-4 transition-colors hover:border-primary">
              <code className="font-mono text-sm text-foreground">{f}</code>
              <p className="mt-1 text-sm">{d}</p>
            </li>
          ))}
          <Button variant="outline" asChild>
            <a href={`${REPO}/blob/main/payroll/src/PayrollVault.sol`}>
              Read the contract <ArrowUpRight />
            </a>
          </Button>
        </ul>
        <HoloCard>
          <div className="flex items-center gap-1 border-b px-3">
            {(Object.keys(SNIPPETS) as (keyof typeof SNIPPETS)[]).map((k) => (
              <button
                key={k}
                onClick={() => setTab(k)}
                className={cn(
                  "-mb-px border-b-2 px-3 py-3 font-mono text-xs transition-colors",
                  tab === k ? "border-primary text-foreground" : "border-transparent text-muted-foreground hover:text-foreground",
                )}
              >
                {k.toLowerCase()}.ts
              </button>
            ))}
          </div>
          <pre className="overflow-x-auto p-6 font-mono text-[13px] leading-6 text-foreground/90">
            <code>{highlight(SNIPPETS[tab])}</code>
          </pre>
        </HoloCard>
      </div>
    </Section>
  );
}

function Roadmap() {
  return (
    <Section id="roadmap" eyebrow="Roadmap" title="Payroll is the first stream." intro="The same streaming engine powers what comes next." glow="arc-coral">
      <div className="grid gap-4 md:grid-cols-6">
        <Tile className="md:col-span-4" badge="Contracts ready" tone="violet" title="Vesting grants" desc="USDC and token grants with cliffs, cliff unlocks and linear vesting.">
          <VestingVisual />
        </Tile>
        <Tile className="md:col-span-2" delay={80} badge="Contracts ready" tone="cyan" title="Open-ended streams" desc="Retainers and subscriptions with top-ups, pauses and refunds.">
          <FlowVisual />
        </Tile>
        <Tile className="md:col-span-2" delay={0} badge="Contracts ready" tone="arc-coral" title="Vesting airdrops" desc="Distribute to thousands of wallets from a Merkle list, vesting over time.">
          <MerkleVisual />
        </Tile>
        <Tile className="md:col-span-4" delay={80} badge="Exploring" tone="arc-gold" title="Salary advances" desc="Every stream is an NFT. Borrow against future pay, transparently on-chain.">
          <AdvanceVisual />
        </Tile>
      </div>
    </Section>
  );
}

function Cta() {
  return (
    <section className="bg-sky relative overflow-hidden border-t">
      <AsciiSky density={0.8} className="[mask-image:radial-gradient(ellipse_at_center,black_30%,transparent_75%)]" />
      <div className="beams animate-beam pointer-events-none absolute -top-10 left-1/2 h-[40rem] w-[80rem] -translate-x-1/2" />
      <div className="horizon pointer-events-none absolute -bottom-[28rem] left-1/2 h-[34rem] w-[140%] -translate-x-1/2" />
      <AsciiCoin
        logos={["arc", "usdc"]}
        className="text-aurora animate-aurora absolute top-1/2 left-1/2 size-[40rem] -translate-x-1/2 -translate-y-1/2 opacity-30 dark:opacity-40 [mask-image:radial-gradient(circle,black_35%,transparent_70%)]"
      />
      <div className="relative mx-auto max-w-6xl px-4 py-36 text-center sm:px-6">
        <h2 className="mx-auto max-w-4xl text-5xl font-semibold text-balance sm:text-6xl">
          Run your next payroll <span className="whitespace-nowrap text-primary">on Arc.</span>
        </h2>
        <p className="mx-auto mt-5 max-w-md text-lg text-muted-foreground">
          Connect a wallet, fund the pool and send your first offer in under a minute.
        </p>
        <div className="mt-9 flex justify-center gap-3">
          <Button size="lg" asChild>
            <a href="./app/">
              Launch app <ArrowRight />
            </a>
          </Button>
          <Button size="lg" variant="outline" asChild>
            <a href={REPO}>View source</a>
          </Button>
        </div>
      </div>
    </section>
  );
}
