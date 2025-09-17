// app/layout.tsx
import './globals.css';
import type { Metadata } from 'next';
import { ThemeToggle } from '@/components/ThemeToggle';

export const metadata: Metadata = {
  title: 'Interactive UI Components',
  description: 'InteractiveFeedbackView and AnimationControlPanel components demo',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>
        <div className="absolute top-4 right-4">
          <ThemeToggle />
        </div>
        {children}
      </body>
    </html>
  );
}