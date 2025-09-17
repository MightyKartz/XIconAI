import SwiftUI

struct CustomCard<Content: View>: View {
    var title: String?
    var description: String?
    var footer: String?
    var backgroundColor: Color?
    var titleColor: Color?
    var descriptionColor: Color?
    var footerColor: Color?
    var content: Content

    init(
        title: String? = nil,
        description: String? = nil,
        footer: String? = nil,
        backgroundColor: Color? = nil,
        titleColor: Color? = nil,
        descriptionColor: Color? = nil,
        footerColor: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.description = description
        self.footer = footer
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.descriptionColor = descriptionColor
        self.footerColor = footerColor
        self.content = content()
    }

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    if let title = title {
                        Text(title)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(titleColor ?? .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if let description = description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(descriptionColor ?? .gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                content

                if let footer = footer {
                    Text(footer)
                        .font(.caption)
                        .foregroundStyle(footerColor ?? .gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 22)
        }
        .background(backgroundColor ?? Color(.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .frame(maxWidth: .infinity)
    }
}

struct CustomCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CustomCard(
                title: "Card title",
                description: "Card description"
            ) {
                Text("Card content")
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            CustomCard(
                title: "Card title",
                description: "Card description",
                footer: "Card footer"
            ) {
                EmptyView()
            }
        }
    }
}