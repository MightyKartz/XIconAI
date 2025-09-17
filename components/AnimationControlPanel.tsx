// components/AnimationControlPanel.tsx
'use client';

import React, { useState, useEffect } from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/swiftcn-ui/card';
import { Label } from '@/components/swiftcn-ui/label';
import { Switch } from '@/components/swiftcn-ui/switch';
import { Input } from '@/components/swiftcn-ui/input';
import { interactionService } from '@/services/interaction-service';

interface AnimationControlPanelProps {
  className?: string;
}

const AnimationControlPanel: React.FC<AnimationControlPanelProps> = ({
  className = ''
}) => {
  const [animationsEnabled, setAnimationsEnabled] = useState(interactionService.getAnimationsEnabled());
  const [animationSpeed, setAnimationSpeed] = useState(interactionService.getAnimationSpeed());

  // Update state when service values change
  useEffect(() => {
    setAnimationsEnabled(interactionService.getAnimationsEnabled());
    setAnimationSpeed(interactionService.getAnimationSpeed());
  }, []);

  const handleToggleAnimations = (enabled: boolean) => {
    setAnimationsEnabled(enabled);
    interactionService.setAnimationsEnabled(enabled);
  };

  const handleSpeedChange = (speed: number) => {
    const clampedSpeed = Math.max(0.1, Math.min(3, speed));
    setAnimationSpeed(clampedSpeed);
    interactionService.setAnimationSpeed(clampedSpeed);
  };

  return (
    <Card className={className}>
      <CardHeader>
        <CardTitle>Animation Settings</CardTitle>
      </CardHeader>
      <CardContent className="space-y-6">
        <div className="space-y-4">
          {/* Animation Toggle */}
          <div className="flex items-center justify-between">
            <div className="space-y-1">
              <Label>Enable Animations</Label>
              <p className="text-sm text-muted-foreground">
                Toggle all UI animations
              </p>
            </div>
            <Switch
              checked={animationsEnabled}
              onCheckedChange={handleToggleAnimations}
            />
          </div>

          {/* Animation Speed */}
          <div className="space-y-3">
            <div className="flex justify-between">
              <Label>Animation Speed</Label>
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
              onChange={(e) => handleSpeedChange(parseFloat(e.target.value))}
              className="w-full"
            />
            <div className="flex justify-between text-xs text-muted-foreground">
              <span>Slower</span>
              <span>Faster</span>
            </div>
          </div>

          {/* Preview */}
          <div className="pt-4 border-t">
            <Label className="mb-3 block">Preview</Label>
            <div className="flex items-center gap-4">
              <div
                className={`h-12 w-12 rounded-lg bg-primary ${animationsEnabled ? 'animate-pulse' : ''}`}
                style={{
                  animationDuration: animationsEnabled ? `${1 / animationSpeed}s` : '1s',
                  animationPlayState: animationsEnabled ? 'running' : 'paused'
                }}
              />
              <div className="text-sm">
                <p className="font-medium">Animation Preview</p>
                <p className="text-muted-foreground">
                  {animationsEnabled
                    ? `Speed: ${animationSpeed.toFixed(1)}x`
                    : 'Animations disabled'}
                </p>
              </div>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};

export default AnimationControlPanel;