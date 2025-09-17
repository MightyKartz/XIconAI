import SwiftUI

struct SwiftCNUIView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("SwiftCN-UI Components Demo")
                .font(.largeTitle)
                .fontWeight(.bold)

            Button("Click Me") {
                print("Button tapped!")
            }
            .primaryStyle()

            Button("Secondary Button") {
                print("Secondary button tapped!")
            }
            .secondaryStyle()

            Button("Destructive Button") {
                print("Destructive button tapped!")
            }
            .destructiveStyle()

            CardView(
                title: "Card Title",
                description: "This is a card description",
                footer: "Card footer"
            ) {
                Text("Card content goes here")
            }

            CardView(
                title: "Custom Content Card",
                description: "This card has custom content"
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("This is custom content inside the card.")
                        .font(.body)

                    Button("Card Button") {
                        print("Button inside card tapped!")
                    }
                    .outlineStyle()
                }
            }
        }
        .padding()
    }
}

#Preview {
    SwiftCNUIView()
}