import SwiftUI

struct StyledGraphCard<Content: View>: View {
    let title: String
    let color: Color
    let content: Content

    init(title: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.color = color
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)

            content
                .frame(height: 200)
                .padding(.horizontal)
                .padding(.bottom)
        }
        .background(color.opacity(0.2))
        .cornerRadius(16)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}
