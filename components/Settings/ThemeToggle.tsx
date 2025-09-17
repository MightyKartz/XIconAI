'use client';

import { useState, useEffect } from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/swiftcn-ui/card';
import { Label } from '@/components/swiftcn-ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/swiftcn-ui/select';
import { Button } from '@/components/swiftcn-ui/button';

export function ThemeToggle() {
  const [theme, setTheme] = useState<'light' | 'dark' | 'system'>('system');

  useEffect(() => {
    const savedTheme = localStorage.getItem('theme') as 'light' | 'dark' | 'system' | null;
    if (savedTheme) {
      setTheme(savedTheme);
    }
  }, []);

  useEffect(() => {
    const root = document.documentElement;

    if (theme === 'system') {
      const systemTheme = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
      root.classList.toggle('dark', systemTheme === 'dark');
    } else {
      root.classList.toggle('dark', theme === 'dark');
    }

    localStorage.setItem('theme', theme);
  }, [theme]);

  const handleResetTheme = () => {
    setTheme('system');
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>Appearance</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="space-y-2">
          <Label htmlFor="theme">Theme</Label>
          <Select value={theme} onValueChange={(value: 'light' | 'dark' | 'system') => setTheme(value)}>
            <SelectTrigger id="theme">
              <SelectValue placeholder="Select theme" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="system">System</SelectItem>
              <SelectItem value="light">Light</SelectItem>
              <SelectItem value="dark">Dark</SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div className="flex items-center justify-between pt-4">
          <div className="space-y-1">
            <Label>Theme Preview</Label>
            <p className="text-sm text-muted-foreground">
              Current theme: {theme === 'system' ? 'System preference' : theme.charAt(0).toUpperCase() + theme.slice(1)}
            </p>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded bg-primary flex items-center justify-center text-primary-foreground text-xs">
              Aa
            </div>
            <div className="w-8 h-8 rounded bg-secondary flex items-center justify-center text-secondary-foreground text-xs">
              Aa
            </div>
          </div>
        </div>

        <div className="pt-4">
          <Button variant="outline" onClick={handleResetTheme} className="w-full">
            Reset to System Theme
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}