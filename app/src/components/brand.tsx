import arcIconBlack from "@/assets/brand/arc-icon-black.svg";
import arcIconWhite from "@/assets/brand/arc-icon-white.svg";
import arcLogoBlack from "@/assets/brand/arc-logo-black.svg";
import arcLogoWhite from "@/assets/brand/arc-logo-white.svg";
import usdcLockupInverse from "@/assets/brand/usdc-lockup-inverse.svg";
import usdcLockup from "@/assets/brand/usdc-lockup.svg";
import usdcToken from "@/assets/brand/usdc-token.svg";
import { useId } from "react";
import { cn } from "@/lib/utils";

export function Mark({ className }: { className?: string }) {
  const id = useId();
  return (
    <svg viewBox="0 0 32 32" className={cn("size-7", className)} aria-hidden>
      <defs>
        <linearGradient id={id} x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor="var(--primary)" />
          <stop offset="0.55" stopColor="var(--cyan)" />
          <stop offset="1" stopColor="var(--usdc-bright)" />
        </linearGradient>
      </defs>
      <rect width="32" height="32" rx="8" fill={`url(#${id})`} />
      <path
        d="M7 12.5c3-3.2 6 3.2 9 0s6-3.2 9 0M7 19.5c3-3.2 6 3.2 9 0s6-3.2 9 0"
        fill="none"
        stroke="var(--primary-foreground)"
        strokeWidth="2.6"
        strokeLinecap="round"
      />
    </svg>
  );
}

export function Wordmark({ className }: { className?: string }) {
  return (
    <span className={cn("flex items-center gap-2.5 font-display text-lg font-semibold tracking-tight", className)}>
      <Mark />
      StreamArc
    </span>
  );
}

type Img = { className?: string };
const Themed = ({ light, dark, alt, className }: { light: string; dark: string; alt: string; className?: string }) => (
  <>
    <img src={light} alt={alt} className={cn("w-auto dark:hidden", className)} />
    <img src={dark} alt={alt} className={cn("hidden w-auto dark:block", className)} />
  </>
);

export const ArcLogo = ({ className }: Img) => <Themed light={arcLogoBlack} dark={arcLogoWhite} alt="Arc" className={cn("h-6", className)} />;
export const ArcIcon = ({ className }: Img) => <Themed light={arcIconBlack} dark={arcIconWhite} alt="Arc" className={cn("h-4", className)} />;
export const UsdcLockup = ({ className }: Img) => (
  <Themed light={usdcLockup} dark={usdcLockupInverse} alt="USDC" className={cn("h-6", className)} />
);
export const UsdcToken = ({ className }: Img) => <img src={usdcToken} alt="USDC" className={cn("size-5", className)} />;
