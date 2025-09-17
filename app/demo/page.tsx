// app/demo/page.tsx
'use client';

import React, { useState } from 'react';
import InteractiveFeedbackView from '@/components/InteractiveFeedbackView';
import AnimationControlPanel from '@/components/AnimationControlPanel';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/swiftcn-ui/card';

const DemoPage = () => {
  const [loadingStates, setLoadingStates] = useState({
    button1: false,
    button2: false,
    button3: false,
  });

  const handleAction = (buttonId: string) => {
    // Simulate async action
    setLoadingStates(prev => ({ ...prev, [buttonId]: true }));

    setTimeout(() => {
      setLoadingStates(prev => ({ ...prev, [buttonId]: false }));
    }, 2000);
  };

  return (
    <div className="min-h-screen p-8 bg-background">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-3xl font-bold mb-8">交互式组件演示</h1>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Interactive Feedback Demo */}
          <div className="space-y-6">
            <h2 className="text-2xl font-semibold">交互式反馈视图</h2>

            <div className="p-6 bg-card rounded-lg border shadow-sm space-y-4">
              <h3 className="text-lg font-medium">按钮变体</h3>

              <div className="flex flex-wrap gap-4">
                <InteractiveFeedbackView
                  label="默认"
                  variant="default"
                  isLoading={loadingStates.button1}
                  onAction={() => handleAction('button1')}
                />

                <InteractiveFeedbackView
                  label="破坏性"
                  variant="destructive"
                  isLoading={loadingStates.button2}
                  onAction={() => handleAction('button2')}
                />

                <InteractiveFeedbackView
                  label="轮廓"
                  variant="outline"
                  isLoading={loadingStates.button3}
                  onAction={() => handleAction('button3')}
                />
              </div>

              <div className="flex flex-wrap gap-4 mt-4">
                <InteractiveFeedbackView
                  label="次要"
                  variant="secondary"
                />

                <InteractiveFeedbackView
                  label="幽灵"
                  variant="ghost"
                />

                <InteractiveFeedbackView
                  label="链接"
                  variant="link"
                />
              </div>
            </div>

            <div className="p-6 bg-card rounded-lg border shadow-sm">
              <h3 className="text-lg font-medium mb-4">禁用状态</h3>
              <InteractiveFeedbackView
                label="禁用按钮"
                disabled={true}
              />
            </div>
          </div>

          {/* Animation Control Panel */}
          <div className="space-y-6">
            <h2 className="text-2xl font-semibold">动画控制面板</h2>

            <Card>
              <CardHeader>
                <CardTitle>交互式演示</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <p className="text-muted-foreground">
                  尝试调整下面的动画设置，查看它们如何影响交互式组件。
                </p>

                <div className="p-4 bg-muted rounded-lg">
                  <h4 className="font-medium mb-2">试试看：</h4>
                  <p className="text-sm text-muted-foreground">
                    点击左侧的任何按钮查看悬停、按下和加载效果。
                    调整动画设置查看它们如何影响动画。
                  </p>
                </div>
              </CardContent>
            </Card>

            <AnimationControlPanel />
          </div>
        </div>

        {/* Instructions */}
        <Card className="mt-8">
          <CardHeader>
            <CardTitle>如何使用此演示</CardTitle>
          </CardHeader>
          <CardContent className="space-y-2">
            <ul className="list-disc pl-5 space-y-1 text-sm text-muted-foreground">
              <li>将鼠标悬停在任何按钮上查看悬停效果</li>
              <li>点击并按住按钮查看按下效果</li>
              <li>点击带有加载状态的按钮查看加载动画</li>
              <li>在控制面板中调整动画速度查看对所有动画的影响</li>
              <li>切换动画开关查看差异</li>
            </ul>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default DemoPage;