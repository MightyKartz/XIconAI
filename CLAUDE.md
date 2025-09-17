# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Next.js/React project demonstrating interactive UI components built with TypeScript and shadcn/ui. The project includes two main components:

1. InteractiveFeedbackView - A button component with press/hover effects, loading states, and haptic/visual feedback
2. AnimationControlPanel - A settings panel for managing application animations

The components integrate with a shared InteractionService that manages global animation settings.

## Architecture

### Frontend (Next.js/React)
- Main application structure in `app/` directory (Next.js App Router)
- Components in `components/` directory:
  - UI components in `components/swiftcn-ui/` (shadcn/ui components)
  - Custom components in `components/` root
- Services in `services/` handle shared functionality
- Uses Tailwind CSS for styling with a custom color palette

### Component Structure
- InteractiveFeedbackView.tsx: Button component with interactive feedback
- AnimationControlPanel.tsx: Settings panel for animation control
- interaction-service.ts: Singleton service for managing animation settings

## Development Commands

### Development Server
```bash
# Install dependencies
npm install

# Run development server
npm run dev
```

### Building
```bash
# Build for production
npm run build

# Start production server
npm run start
```

### Linting
```bash
# Run linting
npm run lint
```

### Testing
```bash
# Run tests (if configured)
npm run test
```

## Project Structure
```
.
├── app/                   # Next.js app directory
│   ├── layout.tsx         # Root layout with global styles
│   ├── page.tsx           # Home page
│   └── demo/page.tsx      # Demo page for components
├── components/            # React components
│   ├── InteractiveFeedbackView.tsx
│   ├── AnimationControlPanel.tsx
│   └── swiftcn-ui/        # shadcn/ui components (button, card, switch, etc.)
├── services/              # Service layer
│   └── interaction-service.ts
├── lib/                   # Utility functions
│   └── utils.ts
├── app/globals.css        # Global styles
└── tailwind.config.js     # Tailwind CSS configuration
```

## Key Implementation Details

### State Management
The project uses React's useState and useEffect hooks for local component state management. A singleton InteractionService provides global state management for animation settings.

### Component Integration
Both components integrate with the shared InteractionService:
- InteractiveFeedbackView uses animation speed settings for transition durations
- AnimationControlPanel controls the global animation settings

### Styling
The project uses Tailwind CSS with a custom color palette defined in tailwind.config.js. shadcn/ui components provide pre-built UI elements with consistent styling.

### Animation System
The InteractionService manages:
- Global animation enable/disable state
- Animation speed settings (0.1x - 3x)
- Feedback triggering methods (haptic and visual)

Components respond to these settings in real-time, providing a cohesive user experience.