# Interactive UI Components

This project demonstrates two key components built with React, TypeScript, and shadcn/ui:

## Components

### 1. InteractiveFeedbackView
A button component with:
- Press effects (scale down when pressed)
- Hover effects (scale up when hovered)
- Loading states with animated spinner
- Haptic and visual feedback integration
- Customizable variants and sizes

### 2. AnimationControlPanel
A settings panel for managing application animations:
- Toggle for enabling/disabling all animations
- Slider for adjusting animation speed (0.1x - 3x)
- Real-time preview of animation settings
- Integration with InteractionService

## Integration with InteractionService

Both components integrate with a shared InteractionService that manages:
- Global animation enable/disable state
- Animation speed settings
- Feedback triggering methods

## Usage

```jsx
// Using InteractiveFeedbackView
<InteractiveFeedbackView
  label="Click Me"
  variant="default"
  size="default"
  isLoading={loading}
  onAction={handleClick}
/>

// Using AnimationControlPanel
<AnimationControlPanel className="my-6" />
```

## Getting Started

1. Install dependencies:
   ```bash
   npm install
   ```

2. Run the development server:
   ```bash
   npm run dev
   ```

3. Open [http://localhost:3000](http://localhost:3000) in your browser

4. Visit the demo page at [http://localhost:3000/demo](http://localhost:3000/demo) to see the components in action.

## Project Structure

```
.
├── app/                # Next.js app directory
│   ├── layout.tsx      # Root layout with global styles
│   ├── page.tsx        # Home page
│   └── demo/page.tsx   # Demo page for components
├── components/         # React components
│   ├── InteractiveFeedbackView.tsx
│   ├── AnimationControlPanel.tsx
│   └── ui/             # shadcn/ui components
├── services/           # Service layer
│   └── interaction-service.ts
├── lib/                # Utility functions
│   └── utils.ts
├── app/globals.css     # Global styles
└── tailwind.config.js  # Tailwind CSS configuration
```