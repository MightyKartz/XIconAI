# Shared Components Documentation

This directory contains shared UI components used throughout the Icons application.

## ResponsiveContainerView

The `ResponsiveContainerView` is a SwiftUI component that automatically adjusts its layout based on screen size. It integrates with the `LayoutService` to provide responsive behavior across different device sizes.

### Features

- Automatic layout adjustment based on screen size breakpoints
- Integration with LayoutService for consistent spacing and sizing
- Smooth animation transitions between layout modes
- Customizable alignment and breakpoints

### Usage

```swift
ResponsiveContainerView(
    breakpoints: Breakpoints(compact: 768, comfortable: 1024, spacious: 1440),
    alignment: .center
) {
    // Your content here
}
```

### Breakpoints

The component uses the following default breakpoints:
- Compact: < 768px
- Comfortable: 768px - 1024px
- Spacious: > 1024px

## SpacingControlView

The `SpacingControlView` provides a user interface for controlling spacing and layout settings throughout the application. It allows users to adjust sidebar width, layout mode, and padding settings.

### Features

- Collapsible interface to save space
- Layout mode selection (Compact, Comfortable, Spacious)
- Sidebar width adjustment slider
- Custom padding controls
- Real-time preview of current settings
- Integration with ThemeService for consistent styling

### Usage

```swift
SpacingControlView()
```

## Integration with Services

Both components integrate with the following services:

- `LayoutService`: Provides layout information and handles layout changes
- `InteractionService`: Provides animation and interaction feedback
- `ThemeService`: Provides theming and accent colors

## Animation Support

All transitions and layout changes are animated using the `InteractionService` for a smooth user experience. Animations can be customized or disabled through the interaction settings.