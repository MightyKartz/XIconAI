//
//  InteractionService.swift
//  Icons
//
//  Created by Icons App on 2024/01/15.
//

import SwiftUI
import Combine

// MARK: - Interaction Service
class InteractionService: ObservableObject {
    static let shared = InteractionService()
    
    @Published var isAnimationEnabled: Bool = true
    @Published var hapticFeedbackEnabled: Bool = true
    @Published var soundEffectsEnabled: Bool = true
    @Published var animationSpeed: AnimationSpeed = .normal
    
    private let userDefaults = UserDefaults.standard
    private let animationEnabledKey = "animation_enabled"
    private let hapticFeedbackKey = "haptic_feedback_enabled"
    private let soundEffectsKey = "sound_effects_enabled"
    private let animationSpeedKey = "animation_speed"
    
    private init() {
        loadInteractionSettings()
    }
    
    // MARK: - Public Methods
    
    func setAnimationEnabled(_ enabled: Bool) {
        isAnimationEnabled = enabled
        saveInteractionSettings()
    }
    
    func setHapticFeedbackEnabled(_ enabled: Bool) {
        hapticFeedbackEnabled = enabled
        saveInteractionSettings()
    }
    
    func setSoundEffectsEnabled(_ enabled: Bool) {
        soundEffectsEnabled = enabled
        saveInteractionSettings()
    }
    
    func setAnimationSpeed(_ speed: AnimationSpeed) {
        animationSpeed = speed
        saveInteractionSettings()
    }
    
    // MARK: - Animation Methods
    
    func buttonPressAnimation() -> Animation? {
        guard isAnimationEnabled else { return nil }
        return .easeInOut(duration: animationSpeed.duration * 0.1)
    }
    
    func cardHoverAnimation() -> Animation? {
        guard isAnimationEnabled else { return nil }
        return .easeInOut(duration: animationSpeed.duration * 0.2)
    }
    
    func slideAnimation() -> Animation? {
        guard isAnimationEnabled else { return nil }
        return .easeInOut(duration: animationSpeed.duration * 0.3)
    }
    
    func fadeAnimation() -> Animation? {
        guard isAnimationEnabled else { return nil }
        return .easeInOut(duration: animationSpeed.duration * 0.25)
    }
    
    func scaleAnimation() -> Animation? {
        guard isAnimationEnabled else { return nil }
        return .spring(response: animationSpeed.duration * 0.4, dampingFraction: 0.8)
    }
    
    func bounceAnimation() -> Animation? {
        guard isAnimationEnabled else { return nil }
        return .spring(response: animationSpeed.duration * 0.3, dampingFraction: 0.6)
    }
    
    // MARK: - Haptic Feedback Methods
    
    func lightHaptic() {
        guard hapticFeedbackEnabled else { return }
        // Note: macOS doesn't have haptic feedback like iOS
        // This is a placeholder for potential future implementation
    }
    
    func mediumHaptic() {
        guard hapticFeedbackEnabled else { return }
        // Placeholder for medium haptic feedback
    }
    
    func heavyHaptic() {
        guard hapticFeedbackEnabled else { return }
        // Placeholder for heavy haptic feedback
    }
    
    func successHaptic() {
        guard hapticFeedbackEnabled else { return }
        // Placeholder for success haptic feedback
    }
    
    func errorHaptic() {
        guard hapticFeedbackEnabled else { return }
        // Placeholder for error haptic feedback
    }
    
    // MARK: - Sound Effects Methods
    
    func playClickSound() {
        guard soundEffectsEnabled else { return }
        // Placeholder for click sound effect
    }
    
    func playSuccessSound() {
        guard soundEffectsEnabled else { return }
        // Placeholder for success sound effect
    }
    
    func playErrorSound() {
        guard soundEffectsEnabled else { return }
        // Placeholder for error sound effect
    }
    
    // MARK: - Combined Feedback Methods
    
    func buttonPressed() {
        lightHaptic()
        playClickSound()
    }
    
    func actionCompleted() {
        successHaptic()
        playSuccessSound()
    }
    
    func actionFailed() {
        errorHaptic()
        playErrorSound()
    }
    
    // MARK: - Private Methods
    
    private func loadInteractionSettings() {
        isAnimationEnabled = userDefaults.object(forKey: animationEnabledKey) as? Bool ?? true
        hapticFeedbackEnabled = userDefaults.object(forKey: hapticFeedbackKey) as? Bool ?? true
        soundEffectsEnabled = userDefaults.object(forKey: soundEffectsKey) as? Bool ?? true
        
        if let speedRawValue = userDefaults.object(forKey: animationSpeedKey) as? String,
           let speed = AnimationSpeed(rawValue: speedRawValue) {
            animationSpeed = speed
        }
    }
    
    private func saveInteractionSettings() {
        userDefaults.set(isAnimationEnabled, forKey: animationEnabledKey)
        userDefaults.set(hapticFeedbackEnabled, forKey: hapticFeedbackKey)
        userDefaults.set(soundEffectsEnabled, forKey: soundEffectsKey)
        userDefaults.set(animationSpeed.rawValue, forKey: animationSpeedKey)
    }
}

// MARK: - Animation Speed
enum AnimationSpeed: String, CaseIterable, Identifiable {
    case slow = "slow"
    case normal = "normal"
    case fast = "fast"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .slow: return "慢速"
        case .normal: return "正常"
        case .fast: return "快速"
        }
    }
    
    var duration: Double {
        switch self {
        case .slow: return 0.5
        case .normal: return 0.3
        case .fast: return 0.15
        }
    }
    
}

// MARK: - Interactive Button Style
struct InteractiveButtonStyle: PrimitiveButtonStyle {
    @EnvironmentObject private var interactionService: InteractionService

    let style: InteractiveStyle

    func makeBody(configuration: PrimitiveButtonStyle.Configuration) -> some View {
        configuration.label
            .scaleEffect(style.pressedScale)
            .opacity(style.pressedOpacity)
            .animation(interactionService.buttonPressAnimation(), value: UUID())
            .onTapGesture {
                interactionService.buttonPressed()
                configuration.trigger()
            }
    }
}

// MARK: - Interactive Style
enum InteractiveStyle {
    case subtle
    case normal
    case prominent
    
    var pressedScale: Double {
        switch self {
        case .subtle:
            return 0.98
        case .normal:
            return 0.95
        case .prominent:
            return 0.92
        }
    }
    
    var pressedOpacity: Double {
        switch self {
        case .subtle:
            return 0.9
        case .normal:
            return 0.8
        case .prominent:
            return 0.7
        }
    }
}

// MARK: - Hover Effect Modifier
struct HoverEffectModifier: ViewModifier {
    @EnvironmentObject private var interactionService: InteractionService
    @State private var isHovered = false
    
    let style: HoverStyle
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? style.hoveredScale : 1.0)
            .opacity(isHovered ? style.hoveredOpacity : 1.0)
            .animation(interactionService.cardHoverAnimation(), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// MARK: - Hover Style
enum HoverStyle {
    case subtle
    case normal
    case prominent
    
    var hoveredScale: Double {
        switch self {
        case .subtle:
            return 1.02
        case .normal:
            return 1.05
        case .prominent:
            return 1.08
        }
    }
    
    var hoveredOpacity: Double {
        switch self {
        case .subtle:
            return 1.0
        case .normal:
            return 0.9
        case .prominent:
            return 0.8
        }
    }
}

// MARK: - Loading Animation Modifier
struct LoadingAnimationModifier: ViewModifier {
    @EnvironmentObject private var interactionService: InteractionService
    @State private var isAnimating = false
    
    let isLoading: Bool
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(
                isLoading && interactionService.isAnimationEnabled ?
                Animation.linear(duration: 1.0).repeatForever(autoreverses: false) : nil,
                value: isAnimating
            )
            .onAppear {
                if isLoading {
                    isAnimating = true
                }
            }
            .onChangeCompat(of: isLoading) { loading in
                isAnimating = loading
            }
    }
}

// MARK: - Interaction Environment Key
struct InteractionEnvironmentKey: EnvironmentKey {
    static let defaultValue = InteractionService.shared
}

extension EnvironmentValues {
    var interactionService: InteractionService {
        get { self[InteractionEnvironmentKey.self] }
        set { self[InteractionEnvironmentKey.self] = newValue }
    }
}

// MARK: - View Extensions
extension View {
    func interactiveButton(style: InteractiveStyle = .normal) -> some View {
        self.buttonStyle(InteractiveButtonStyle(style: style))
    }
    
    func hoverEffect(style: HoverStyle = .normal) -> some View {
        self.modifier(HoverEffectModifier(style: style))
    }
    
    func loadingAnimation(isLoading: Bool) -> some View {
        self.modifier(LoadingAnimationModifier(isLoading: isLoading))
    }
    
    func fadeInOut(isVisible: Bool) -> some View {
        self
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.3), value: isVisible)
    }
    
    func slideIn(from edge: Edge, isVisible: Bool) -> some View {
        self
            .offset(
                x: !isVisible && (edge == .leading || edge == .trailing) ?
                   (edge == .leading ? -100 : 100) : 0,
                y: !isVisible && (edge == .top || edge == .bottom) ?
                   (edge == .top ? -100 : 100) : 0
            )
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.4), value: isVisible)
    }
    
    func scaleIn(isVisible: Bool) -> some View {
        self
            .scaleEffect(isVisible ? 1.0 : 0.8)
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isVisible)
    }
}