import SwiftUI

struct TaskRowView: View {
    @Binding var task: UserTask
    var isEditing: Bool
    var isFocused: Bool
    var onEdit: () -> Void
    var onSubmit: () -> Void
    var onDelete: () -> Void
    var color: Color

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.body)
                    .foregroundColor(isEditing ? AppColors.primary : .primary)
                    .lineLimit(2)
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .accessibilityLabel("Delete task")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isEditing ? AppColors.primary.opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
        .onSubmit {
            onSubmit()
        }
    }
}
