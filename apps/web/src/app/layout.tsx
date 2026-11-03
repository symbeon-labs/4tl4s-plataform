import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "4TL4S PLATFORM",
  description: "Coordenação, governança e execução de iniciativas.",
  icons: { icon: "/atlas-mark.svg" },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="pt-BR"><body>{children}</body></html>;
}
