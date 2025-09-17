// components/CustomizableComponentsDemo.tsx
'use client';

import { useState, useEffect } from 'react';
import { Button } from '@/components/swiftcn-ui/button';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/swiftcn-ui/card';
import { Input } from '@/components/swiftcn-ui/input';
import { useLanguage } from '@/hooks/useLanguage';

export function CustomizableComponentsDemo() {
  const { t } = useLanguage();
  const [componentSettings, setComponentSettings] = useState({
    button: {
      variant: 'default',
      size: 'default',
      borderRadius: '0.5rem',
      animationEnabled: true,
    },
    card: {
      shadow: 'sm',
      borderRadius: '0.5rem',
      borderColor: 'default',
    },
    input: {
      variant: 'default',
      borderRadius: '0.5rem',
      focusRing: true,
    }
  });

  // 加载保存的设置
  useEffect(() => {
    const saved = localStorage.getItem('componentSettings');
    if (saved) {
      setComponentSettings(JSON.parse(saved));
    }
  }, []);

  // 获取卡片样式类
  const getCardClassName = () => {
    const shadowClass = {
      none: '',
      sm: 'shadow-sm',
      md: 'shadow-md',
      lg: 'shadow-lg'
    }[componentSettings.card.shadow] || 'shadow-sm';

    const borderClass = componentSettings.card.borderColor === 'primary'
      ? 'border-primary'
      : componentSettings.card.borderColor === 'secondary'
        ? 'border-secondary'
        : 'border-border';

    return `rounded-${componentSettings.card.borderRadius} ${shadowClass} ${borderClass}`;
  };

  // 获取按钮样式
  const getButtonStyle = () => {
    const style: React.CSSProperties = {
      borderRadius: componentSettings.button.borderRadius
    };

    if (componentSettings.button.animationEnabled) {
      style.transition = 'all 0.2s ease-in-out';
    }

    return style;
  };

  // 获取输入框样式
  const getInputStyle = () => {
    return {
      borderRadius: componentSettings.input.borderRadius
    };
  };

  return (
    <div className="space-y-6">
      <Card className={getCardClassName()}>
        <CardHeader>
          <CardTitle>{t('customizableComponentsDemo')}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="space-y-2">
            <label className="text-sm font-medium">{t('customButton')}</label>
            <Button
              variant={componentSettings.button.variant as any}
              size={componentSettings.button.size as any}
              style={getButtonStyle()}
            >
              {t('clickMe')}
            </Button>
          </div>

          <div className="space-y-2">
            <label className="text-sm font-medium">{t('customInput')}</label>
            <Input
              placeholder={t('typeSomething')}
              style={getInputStyle()}
            />
          </div>

          <div className="space-y-2">
            <label className="text-sm font-medium">{t('customCard')}</label>
            <Card className={getCardClassName()}>
              <CardContent className="p-4">
                <p className="text-sm text-muted-foreground">
                  {t('customizableCardDescription')}
                </p>
              </CardContent>
            </Card>
          </div>
        </CardContent>
      </Card>

      <div className="text-sm text-muted-foreground">
        <p>{t('adjustComponentSettings')}</p>
      </div>
    </div>
  );
}