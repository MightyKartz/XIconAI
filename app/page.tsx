// app/page.tsx
import React from 'react';

export default function Home() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-background p-8">
      <div className="max-w-2xl text-center space-y-6">
        <h1 className="text-4xl font-bold">Interactive UI Components</h1>
        <p className="text-lg text-muted-foreground">
          This demo showcases the InteractiveFeedbackView and AnimationControlPanel components
          built with SwiftCN-UI and Tailwind CSS.
        </p>
        <div className="pt-4">
          <a
            href="/demo"
            className="inline-block px-6 py-3 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 transition-colors"
          >
            View Component Demo
          </a>
        </div>
      </div>
    </div>
  );
}