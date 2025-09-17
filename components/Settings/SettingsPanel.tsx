'use client';

import { useState, useEffect } from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/swiftcn-ui/card';
import { Label } from '@/components/swiftcn-ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/swiftcn-ui/select';
import { Switch } from '@/components/swiftcn-ui/switch';
import { Button } from '@/components/swiftcn-ui/button';
import { Input } from '@/components/swiftcn-ui/input';
import { useLanguage } from '@/hooks/useLanguage';

export function SettingsPanel() {
  const { language: currentLanguage, setLanguage, t } = useLanguage();
  const [theme, setTheme] = useState<'light' | 'dark' | 'system'>('system');
  const [animationsEnabled, setAnimationsEnabled] = useState(true);
  const [animationSpeed, setAnimationSpeed] = useState(1);

  // Load settings from localStorage on mount
  useEffect(() => {
    const savedTheme = localStorage.getItem('theme') as 'light' | 'dark' | 'system' | null;
    const savedAnimations = localStorage.getItem('animationsEnabled');
    const savedAnimationSpeed = localStorage.getItem('animationSpeed');

    if (savedTheme) setTheme(savedTheme);
    if (savedAnimations) setAnimationsEnabled(savedAnimations === 'true');
    if (savedAnimationSpeed) setAnimationSpeed(parseFloat(savedAnimationSpeed));
  }, []);

  // Apply theme changes to the document
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

  // Save other settings to localStorage
  useEffect(() => {
    localStorage.setItem('animationsEnabled', animationsEnabled.toString());
    localStorage.setItem('animationSpeed', animationSpeed.toString());
  }, [animationsEnabled, animationSpeed]);

  const handleResetSettings = () => {
    setTheme('system');
    setLanguage('en');
    setAnimationsEnabled(true);
    setAnimationSpeed(1);
  };

  return (
    <div className="space-y-6">
      {/* Display Settings */}
      <Card>
        <CardHeader>
          <CardTitle>{t('display')}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="space-y-2">
            <Label htmlFor="theme">{t('theme')}</Label>
            <Select value={theme} onValueChange={(value: 'light' | 'dark' | 'system') => setTheme(value)}>
              <SelectTrigger id="theme">
                <SelectValue placeholder={t('theme')} />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="system">{t('system')}</SelectItem>
                <SelectItem value="light">{t('light')}</SelectItem>
                <SelectItem value="dark">{t('dark')}</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-2">
            <Label htmlFor="language">{t('language')}</Label>
            <Select value={currentLanguage} onValueChange={(value: 'en' | 'zh') => setLanguage(value)}>
              <SelectTrigger id="language">
                <SelectValue placeholder={t('language')} />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="en">{t('english')}</SelectItem>
                <SelectItem value="zh">{t('chinese')}</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div className="flex items-center justify-between">
            <div className="space-y-1">
              <Label>{t('themePreview')}</Label>
              <p className="text-sm text-muted-foreground">
                {t('currentTheme')}: {theme === 'system' ? t('systemPreference') : t(theme)}
              </p>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-10 h-10 rounded bg-primary flex items-center justify-center text-primary-foreground text-xs">
                Aa
              </div>
              <div className="w-10 h-10 rounded bg-secondary flex items-center justify-center text-secondary-foreground text-xs">
                Aa
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Animation Settings */}
      <Card>
        <CardHeader>
          <CardTitle>{t('animations')}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="flex items-center justify-between">
            <div className="space-y-1">
              <Label>{t('enableAnimations')}</Label>
              <p className="text-sm text-muted-foreground">
                {t('toggleAllUIAnimations')}
              </p>
            </div>
            <Switch
              checked={animationsEnabled}
              onCheckedChange={setAnimationsEnabled}
            />
          </div>

          <div className="space-y-3">
            <div className="flex justify-between">
              <Label>{t('animationSpeed')}</Label>
              <span className="text-sm font-mono bg-muted px-2 py-1 rounded">
                {animationSpeed.toFixed(1)}x
              </span>
            </div>
            <Input
              type="range"
              min="0.1"
              max="3"
              step="0.1"
              value={animationSpeed}
              onChange={(e) => setAnimationSpeed(parseFloat(e.target.value))}
              className="w-full"
            />
            <div className="flex justify-between text-xs text-muted-foreground">
              <span>{t('slower')}</span>
              <span>{t('faster')}</span>
            </div>
          </div>

          <div className="pt-4 border-t">
            <Label className="mb-3 block">{t('animationPreview')}</Label>
            <div className="flex items-center gap-4">
              <div
                className={`h-12 w-12 rounded-lg bg-primary ${animationsEnabled ? 'animate-pulse' : ''}`}
                style={{
                  animationDuration: animationsEnabled ? `${1 / animationSpeed}s` : undefined
                }}
              />
              <div className="text-sm">
                <p className="font-medium">{t('animationPreview')}</p>
                <p className="text-muted-foreground">
                  {animationsEnabled
                    ? `${t('animationSpeed')}: ${animationSpeed.toFixed(1)}x`
                    : t('animationsDisabled')}
                </p>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Reset Settings */}
      <div className="flex justify-end">
        <Button variant="outline" onClick={handleResetSettings}>
          {t('resetToDefaults')}
        </Button>
      </div>
    </div>
  );
}