// components/ComponentSettingsPanel.tsx
'use client';

import { useState } from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/swiftcn-ui/card';
import { Label } from '@/components/swiftcn-ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/swiftcn-ui/select';
import { Switch } from '@/components/swiftcn-ui/switch';
import { Input } from '@/components/swiftcn-ui/input';
import { Button } from '@/components/swiftcn-ui/button';
import { Slider } from '@/components/swiftcn-ui/slider';
import { useLanguage } from '@/hooks/useLanguage';

export function ComponentSettingsPanel() {
  const { t } = useLanguage();

  // 按钮设置
  const [buttonSettings, setButtonSettings] = useState({
    variant: 'default',
    size: 'default',
    borderRadius: '0.5rem',
    animationEnabled: true,
  });

  // 卡片设置
  const [cardSettings, setCardSettings] = useState({
    shadow: 'sm',
    borderRadius: '0.5rem',
    borderColor: 'default',
  });

  // 输入框设置
  const [inputSettings, setInputSettings] = useState({
    variant: 'default',
    borderRadius: '0.5rem',
    focusRing: true,
  });

  // 保存设置到localStorage
  const saveSettings = () => {
    localStorage.setItem('componentSettings', JSON.stringify({
      button: buttonSettings,
      card: cardSettings,
      input: inputSettings,
    }));
  };

  // 加载设置
  const loadSettings = () => {
    const saved = localStorage.getItem('componentSettings');
    if (saved) {
      const settings = JSON.parse(saved);
      setButtonSettings(settings.button);
      setCardSettings(settings.card);
      setInputSettings(settings.input);
    }
  };

  return (
    <div className="space-y-6">
      {/* 按钮设置 */}
      <Card>
        <CardHeader>
          <CardTitle>{t('buttonSettings')}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label>{t('variant')}</Label>
            <Select
              value={buttonSettings.variant}
              onValueChange={(value) => setButtonSettings({...buttonSettings, variant: value})}
            >
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="default">{t('default')}</SelectItem>
                <SelectItem value="destructive">{t('destructive')}</SelectItem>
                <SelectItem value="outline">{t('outline')}</SelectItem>
                <SelectItem value="secondary">{t('secondary')}</SelectItem>
                <SelectItem value="ghost">{t('ghost')}</SelectItem>
                <SelectItem value="link">{t('link')}</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-2">
            <Label>{t('size')}</Label>
            <Select
              value={buttonSettings.size}
              onValueChange={(value) => setButtonSettings({...buttonSettings, size: value})}
            >
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="default">{t('default')}</SelectItem>
                <SelectItem value="sm">{t('small')}</SelectItem>
                <SelectItem value="lg">{t('large')}</SelectItem>
                <SelectItem value="icon">{t('icon')}</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-2">
            <Label>{t('borderRadius')}: {buttonSettings.borderRadius}</Label>
            <Slider
              min={0}
              max={2}
              step={0.1}
              value={[parseFloat(buttonSettings.borderRadius)]}
              onValueChange={([value]) => setButtonSettings({...buttonSettings, borderRadius: `${value}rem`})}
            />
          </div>

          <div className="flex items-center justify-between">
            <Label>{t('enableAnimations')}</Label>
            <Switch
              checked={buttonSettings.animationEnabled}
              onCheckedChange={(checked) => setButtonSettings({...buttonSettings, animationEnabled: checked})}
            />
          </div>
        </CardContent>
      </Card>

      {/* 卡片设置 */}
      <Card>
        <CardHeader>
          <CardTitle>{t('cardSettings')}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label>{t('shadow')}</Label>
            <Select
              value={cardSettings.shadow}
              onValueChange={(value) => setCardSettings({...cardSettings, shadow: value})}
            >
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="none">{t('none')}</SelectItem>
                <SelectItem value="sm">{t('small')}</SelectItem>
                <SelectItem value="md">{t('medium')}</SelectItem>
                <SelectItem value="lg">{t('large')}</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-2">
            <Label>{t('borderRadius')}: {cardSettings.borderRadius}</Label>
            <Slider
              min={0}
              max={2}
              step={0.1}
              value={[parseFloat(cardSettings.borderRadius)]}
              onValueChange={([value]) => setCardSettings({...cardSettings, borderRadius: `${value}rem`})}
            />
          </div>

          <div className="space-y-2">
            <Label>{t('borderColor')}</Label>
            <Select
              value={cardSettings.borderColor}
              onValueChange={(value) => setCardSettings({...cardSettings, borderColor: value})}
            >
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="default">{t('default')}</SelectItem>
                <SelectItem value="primary">{t('primary')}</SelectItem>
                <SelectItem value="secondary">{t('secondary')}</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      {/* 输入框设置 */}
      <Card>
        <CardHeader>
          <CardTitle>{t('inputSettings')}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <Label>{t('variant')}</Label>
            <Select
              value={inputSettings.variant}
              onValueChange={(value) => setInputSettings({...inputSettings, variant: value})}
            >
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="default">{t('default')}</SelectItem>
                <SelectItem value="ghost">{t('ghost')}</SelectItem>
                <SelectItem value="filled">{t('filled')}</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-2">
            <Label>{t('borderRadius')}: {inputSettings.borderRadius}</Label>
            <Slider
              min={0}
              max={2}
              step={0.1}
              value={[parseFloat(inputSettings.borderRadius)]}
              onValueChange={([value]) => setInputSettings({...inputSettings, borderRadius: `${value}rem`})}
            />
          </div>

          <div className="flex items-center justify-between">
            <Label>{t('focusRing')}</Label>
            <Switch
              checked={inputSettings.focusRing}
              onCheckedChange={(checked) => setInputSettings({...inputSettings, focusRing: checked})}
            />
          </div>
        </CardContent>
      </Card>

      {/* 操作按钮 */}
      <div className="flex gap-2">
        <Button onClick={saveSettings}>{t('saveSettings')}</Button>
        <Button variant="outline" onClick={loadSettings}>{t('loadSettings')}</Button>
        <Button variant="outline" onClick={() => {
          setButtonSettings({
            variant: 'default',
            size: 'default',
            borderRadius: '0.5rem',
            animationEnabled: true,
          });
          setCardSettings({
            shadow: 'sm',
            borderRadius: '0.5rem',
            borderColor: 'default',
          });
          setInputSettings({
            variant: 'default',
            borderRadius: '0.5rem',
            focusRing: true,
          });
        }}>
          {t('resetToDefaults')}
        </Button>
      </div>
    </div>
  );
}