import SwiftUI
import UIKit

// MARK: - UIApplication Extension

extension UIApplication {
    @MainActor
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Keyboard Toolbar Modifier

struct KeyboardToolbarModifier: ViewModifier {
    var onDone: () -> Void

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done", action: onDone)
                }
            }
    }
}

// MARK: - View Extension for Easier Usage

extension View {
    func keyboardToolbar(onDone: @escaping () -> Void) -> some View {
        modifier(KeyboardToolbarModifier(onDone: onDone))
    }
}

