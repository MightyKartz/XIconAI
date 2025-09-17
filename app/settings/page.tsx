// app/settings/page.tsx
'use client';

import { SettingsPanel } from '@/components/Settings/SettingsPanel';
import { ComponentSettingsPanel } from '@/components/ComponentSettingsPanel';
import { CustomizableComponentsDemo } from '@/components/CustomizableComponentsDemo';
import { useLanguage } from '@/hooks/useLanguage';

export default function SettingsPage() {
  const { t } = useLanguage();

  return (
    <div className="container mx-auto py-8">
      <div className="max-w-6xl mx-auto space-y-8">
        <h1 className="text-3xl font-bold">{t('settings')}</h1>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="lg:col-span-1 space-y-8">
            <div>
              <h2 className="text-2xl font-semibold mb-4">{t('globalSettings')}</h2>
              <SettingsPanel />
            </div>

            <div>
              <h2 className="text-2xl font-semibold mb-4">{t('componentSettings')}</h2>
              <ComponentSettingsPanel />
            </div>
          </div>

          <div className="lg:col-span-2">
            <h2 className="text-2xl font-semibold mb-4">{t('componentPreview')}</h2>
            <CustomizableComponentsDemo />
          </div>
        </div>
      </div>
    </div>
  );
}