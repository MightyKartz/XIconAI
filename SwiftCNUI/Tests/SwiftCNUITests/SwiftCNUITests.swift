import Testing
@testable import SwiftCNUI
import SwiftUI

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}

@Test func testCustomButtonCreation() async throws {
    // Test that CustomButton can be created
    let button = CustomButton(action: {
        print("Button tapped!")
    }, label: "Test Button")

    #expect(button != nil)
}

@Test func testCustomButtonWithStyle() async throws {
    // Test that CustomButton can be created with different styles
    let primaryButton = CustomButton(action: {}, label: "Primary", style: .primary)
    let secondaryButton = CustomButton(action: {}, label: "Secondary", style: .secondary)
    let destructiveButton = CustomButton(action: {}, label: "Destructive", style: .destructive)
    let outlineButton = CustomButton(action: {}, label: "Outline", style: .outline)
    let ghostButton = CustomButton(action: {}, label: "Ghost", style: .ghost)

    #expect(primaryButton != nil)
    #expect(secondaryButton != nil)
    #expect(destructiveButton != nil)
    #expect(outlineButton != nil)
    #expect(ghostButton != nil)
}

@Test func testCustomCardCreation() async throws {
    // Test that CustomCard can be created with custom content
    let customContentCard = CustomCard(
        title: "Card Title",
        description: "Card Description"
    ) {
        Text("Custom Content")
    }

    let emptyCard = CustomCard(
        title: "Card Title",
        description: "Card Description"
    ) {
        EmptyView()
    }

    #expect(customContentCard != nil)
    #expect(emptyCard != nil)
}