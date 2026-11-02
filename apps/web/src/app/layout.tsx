import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "4TL4S — Operational Intelligence",
  description: "A governed operating layer for projects, evidence and execution.",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="pt-BR"><body>{children}</body></html>;
}
