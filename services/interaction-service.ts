// services/interaction-service.ts
export class InteractionService {
  private static instance: InteractionService;
  private animationsEnabled: boolean = true;
  private animationSpeed: number = 1; // 1x speed

  private constructor() {
    // Load settings from localStorage if available
    if (typeof window !== 'undefined') {
      const savedAnimations = localStorage.getItem('animationsEnabled');
      const savedAnimationSpeed = localStorage.getItem('animationSpeed');

      if (savedAnimations !== null) {
        this.animationsEnabled = savedAnimations === 'true';
      }

      if (savedAnimationSpeed !== null) {
        this.animationSpeed = Math.max(0.1, Math.min(3, parseFloat(savedAnimationSpeed)));
      }
    }
  }

  static getInstance(): InteractionService {
    if (!InteractionService.instance) {
      InteractionService.instance = new InteractionService();
    }
    return InteractionService.instance;
  }

  // Animation control methods
  setAnimationsEnabled(enabled: boolean): void {
    this.animationsEnabled = enabled;
    if (typeof window !== 'undefined') {
      localStorage.setItem('animationsEnabled', enabled.toString());
    }
  }

  getAnimationsEnabled(): boolean {
    return this.animationsEnabled;
  }

  setAnimationSpeed(speed: number): void {
    this.animationSpeed = Math.max(0.1, Math.min(3, speed)); // Clamp between 0.1 and 3
    if (typeof window !== 'undefined') {
      localStorage.setItem('animationSpeed', speed.toString());
    }
  }

  getAnimationSpeed(): number {
    return this.animationSpeed;
  }

  // Feedback methods
  triggerHapticFeedback(): void {
    // In a real implementation, this would trigger device haptic feedback
    console.log("Haptic feedback triggered");
  }

  triggerVisualFeedback(): void {
    // In a real implementation, this would trigger visual feedback
    console.log("Visual feedback triggered");
  }
}

export const interactionService = InteractionService.getInstance();