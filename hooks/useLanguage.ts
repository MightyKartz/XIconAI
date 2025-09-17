'use client';

import { useState, useEffect } from 'react';

type Language = 'en' | 'zh';

const translations = {
  en: {
    settings: 'Settings',
    globalSettings: 'Global Settings',
    componentSettings: 'Component Settings',
    componentPreview: 'Component Preview',
    appearance: 'Appearance',
    theme: 'Theme',
    language: 'Language',
    animations: 'Animations',
    enableAnimations: 'Enable Animations',
    toggleAllUIAnimations: 'Toggle all UI animations',
    animationSpeed: 'Animation Speed',
    slower: 'Slower',
    faster: 'Faster',
    animationPreview: 'Animation Preview',
    animationsDisabled: 'Animations disabled',
    themePreview: 'Theme Preview',
    currentTheme: 'Current theme',
    systemPreference: 'System preference',
    resetToDefaults: 'Reset to Defaults',
    display: 'Display',
    english: 'English',
    chinese: '中文',
    system: 'System',
    light: 'Light',
    dark: 'Dark',
    buttonSettings: 'Button Settings',
    cardSettings: 'Card Settings',
    inputSettings: 'Input Settings',
    variant: 'Variant',
    size: 'Size',
    borderRadius: 'Border Radius',
    shadow: 'Shadow',
    borderColor: 'Border Color',
    focusRing: 'Focus Ring',
    default: 'Default',
    destructive: 'Destructive',
    outline: 'Outline',
    secondary: 'Secondary',
    ghost: 'Ghost',
    link: 'Link',
    small: 'Small',
    large: 'Large',
    icon: 'Icon',
    none: 'None',
    medium: 'Medium',
    primary: 'Primary',
    filled: 'Filled',
    saveSettings: 'Save Settings',
    loadSettings: 'Load Settings',
    customizableComponentsDemo: 'Customizable Components Demo',
    customButton: 'Custom Button',
    customInput: 'Custom Input',
    customCard: 'Custom Card',
    clickMe: 'Click Me',
    typeSomething: 'Type something...',
    customizableCardDescription: 'This is a customizable card component with adjustable shadow, border radius, and border color.',
    adjustComponentSettings: 'Adjust component settings in the Component Settings panel to see changes in real-time.',
  },
  zh: {
    settings: '设置',
    globalSettings: '全局设置',
    componentSettings: '组件设置',
    componentPreview: '组件预览',
    appearance: '外观',
    theme: '主题',
    language: '语言',
    animations: '动画',
    enableAnimations: '启用动画',
    toggleAllUIAnimations: '切换所有UI动画',
    animationSpeed: '动画速度',
    slower: '较慢',
    faster: '较快',
    animationPreview: '动画预览',
    animationsDisabled: '动画已禁用',
    themePreview: '主题预览',
    currentTheme: '当前主题',
    systemPreference: '系统偏好',
    resetToDefaults: '重置为默认值',
    display: '显示',
    english: 'English',
    chinese: '中文',
    system: '系统',
    light: '浅色',
    dark: '深色',
    buttonSettings: '按钮设置',
    cardSettings: '卡片设置',
    inputSettings: '输入框设置',
    variant: '变体',
    size: '大小',
    borderRadius: '圆角半径',
    shadow: '阴影',
    borderColor: '边框颜色',
    focusRing: '焦点环',
    default: '默认',
    destructive: '破坏性',
    outline: '轮廓',
    secondary: '次要',
    ghost: '幽灵',
    link: '链接',
    small: '小',
    large: '大',
    icon: '图标',
    none: '无',
    medium: '中等',
    primary: '主要',
    filled: '填充',
    saveSettings: '保存设置',
    loadSettings: '加载设置',
    customizableComponentsDemo: '可自定义组件演示',
    customButton: '自定义按钮',
    customInput: '自定义输入框',
    customCard: '自定义卡片',
    clickMe: '点击我',
    typeSomething: '输入内容...',
    customizableCardDescription: '这是一个可自定义的卡片组件，可以调整阴影、圆角半径和边框颜色。',
    adjustComponentSettings: '在组件设置面板中调整设置以实时查看变化。',
  },
};

export function useLanguage() {
  const [language, setLanguageState] = useState<Language>('en');

  useEffect(() => {
    const savedLanguage = localStorage.getItem('language') as Language | null;
    if (savedLanguage) {
      setLanguageState(savedLanguage);
      document.documentElement.lang = savedLanguage;
    }
  }, []);

  const setLanguage = (newLanguage: Language) => {
    setLanguageState(newLanguage);
    localStorage.setItem('language', newLanguage);
    document.documentElement.lang = newLanguage;
  };

  const t = (key: string): string => {
    const translation = translations[language][key as keyof typeof translations.en];
    return translation || key;
  };

  return { language, setLanguage, t };
}