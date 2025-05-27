import SwiftUI

struct AppColors {
    static let softBeige = Color("SoftBeige")       // #FDF6EC
    static let lavender = Color("Lavender")         // #C8A2C8
    static let freshGreen = Color("FreshGreen")     // #A8D5BA
    static let softBlue = Color("SoftBlue")         // #A3CEF1
    static let peach = Color("Peach")               // #FFCBA4
}

struct AppFonts {
    static func heading(size: CGFloat = 36) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func button(size: CGFloat = 28) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func body(size: CGFloat = 20) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
}
