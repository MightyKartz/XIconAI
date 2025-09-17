// components/InteractiveFeedbackView.tsx
import React, { useState, useEffect } from 'react';
import { Button } from '@/components/swiftcn-ui/button';
import { interactionService } from '@/services/interaction-service';

interface InteractiveFeedbackViewProps {
  onAction?: () => void;
  label?: string;
  variant?: 'default' | 'destructive' | 'outline' | 'secondary' | 'ghost' | 'link';
  size?: 'default' | 'sm' | 'lg' | 'icon';
  isLoading?: boolean;
  disabled?: boolean;
}

const InteractiveFeedbackView: React.FC<InteractiveFeedbackViewProps> = ({
  onAction,
  label = 'Click me',
  variant = 'default',
  size = 'default',
  isLoading = false,
  disabled = false
}) => {
  const [isPressed, setIsPressed] = useState(false);
  const [isHovered, setIsHovered] = useState(false);
  const [showLoading, setShowLoading] = useState(isLoading);

  // Sync internal loading state with prop
  useEffect(() => {
    setShowLoading(isLoading);
  }, [isLoading]);

  const handlePressStart = () => {
    if (disabled || showLoading) return;
    setIsPressed(true);
    interactionService.triggerHapticFeedback();
  };

  const handlePressEnd = () => {
    if (disabled || showLoading) return;
    setIsPressed(false);
  };

  const handleHoverStart = () => {
    if (disabled || showLoading) return;
    setIsHovered(true);
    interactionService.triggerVisualFeedback();
  };

  const handleHoverEnd = () => {
    if (disabled || showLoading) return;
    setIsHovered(false);
  };

  const handleClick = () => {
    if (disabled || showLoading) return;

    // Trigger loading state if needed
    if (onAction) {
      onAction();
    }
  };

  // Calculate animation scale based on state
  const getScale = () => {
    if (isPressed) return 0.95;
    if (isHovered) return 1.05;
    return 1;
  };

  // Calculate opacity based on state
  const getOpacity = () => {
    if (disabled) return 0.5;
    return 1;
  };

  // Apply animation speed from service
  const animationSpeed = interactionService.getAnimationSpeed();
  const animationsEnabled = interactionService.getAnimationsEnabled();
  const baseTransitionTime = 0.2; // 200ms base transition time
  const transitionTime = animationsEnabled ? baseTransitionTime / animationSpeed : 0;
  const transitionStyle = `all ${transitionTime}s ease-in-out`;

  return (
    <div className="inline-block">
      <Button
        variant={variant}
        size={size}
        disabled={disabled || showLoading}
        onMouseDown={handlePressStart}
        onMouseUp={handlePressEnd}
        onMouseEnter={handleHoverStart}
        onMouseLeave={handleHoverEnd}
        onClick={handleClick}
        style={{
          transform: `scale(${getScale()})`,
          opacity: getOpacity(),
          transition: transitionStyle,
        }}
        className={`
          relative overflow-hidden
          ${showLoading ? 'cursor-wait' : ''}
          ${isPressed ? 'shadow-inner' : ''}
        `}
      >
        {showLoading ? (
          <div className="flex items-center">
            <span className="mr-2">Loading...</span>
            <div
              className="animate-spin rounded-full h-4 w-4 border-b-2 border-current"
              style={{ animationDuration: `${1 / animationSpeed}s` }}
            />
          </div>
        ) : (
          label
        )}
      </Button>
    </div>
  );
};

export default InteractiveFeedbackView;