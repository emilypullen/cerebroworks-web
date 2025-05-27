import SwiftUI

struct PrimaryButton: View {
    var title: String
    var action: () -> Void
    var icon: String? = nil
    var fullWidth: Bool = true

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primary)
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding()
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        }
    }
}
