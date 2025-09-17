import SwiftUI

enum ButtonStyle {
    case primary
    case secondary
    case destructive
    case outline
    case ghost
}

struct CustomButton: View {
    let action: () -> Void
    let label: String
    var style: ButtonStyle = .primary

    var backgroundColor: Color?
    var foregroundColor: Color?

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            Text(label)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(background)
        .foregroundColor(foreground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: style == .outline ? 1 : 0)
        )
    }

    private var background: Color {
        if let backgroundColor = backgroundColor {
            return backgroundColor
        }

        switch style {
        case .primary:
            return .primary
        case .secondary:
            return colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.9)
        case .destructive:
            return .red
        case .outline, .ghost:
            return .clear
        }
    }

    private var foreground: Color {
        if let foregroundColor = foregroundColor {
            return foregroundColor
        }

        switch style {
        case .primary:
            return colorScheme == .dark ? .black : .white
        case .secondary:
            return .primary
        case .destructive:
            return colorScheme == .dark ? .black : .white
        case .outline:
            return .primary
        case .ghost:
            return .primary
        }
    }

    private var borderColor: Color {
        switch style {
        case .outline:
            return .primary
        default:
            return .clear
        }
    }
}

struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomButton(action: {
            print("Button tapped!")
        }, label: "Button")
    }
}