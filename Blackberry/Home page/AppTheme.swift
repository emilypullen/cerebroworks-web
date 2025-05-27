import SwiftUI

// MARK: - App Theme

enum AppTheme: String, CaseIterable, Identifiable {
    case glow = "Purple Glow"
    case dawn = "Coral Dawn"
    case slate = "Soft Slate"

    var id: String { self.rawValue }

    var backgroundView: some View {
        ZStack {
            gradient.ignoresSafeArea()
            RadialWaveOverlay()
        }
    }

    var backgroundColor: Color {
        Color(UIColor.systemBackground).opacity(0.9)
    }

    var primary: Color {
        switch self {
        case .glow: return Color("6A80FF")
        case .dawn: return Color("FB7A5B")
        case .slate: return Color("475569")
        }
    }

    var textColor: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? .white : .black })
    }

    var gradient: LinearGradient {
        switch self {
        case .glow:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color("B47BD2"),
                    Color("8A6FD1"),
                    Color("6A80FF"),
                    Color("5A68DA")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        case .dawn:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color("FDE8E4"),
                    Color("FFD6C0"),
                    Color("FAB7A0")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        case .slate:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color("E3EAF2"),
                    Color("CBD5E1"),
                    Color("94A3B8")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    static var current: AppTheme {
        let selected = UserDefaults.standard.string(forKey: "selectedTheme") ?? AppTheme.glow.rawValue
        return AppTheme(rawValue: selected) ?? .glow
    }
}

// MARK: - Radial Wave Overlay

struct RadialWaveOverlay: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(1..<6) { i in
                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        .frame(width: CGFloat(i) * 140, height: CGFloat(i) * 140)
                        .position(x: geo.size.width * 0.75, y: geo.size.height * 0.25)
                }
            }
        }
    }
}

// MARK: - Color Palette

struct AppColors {
    static var background: Color { AppTheme.current.backgroundColor }
    static var primary: Color { AppTheme.current.primary }
    static var secondary: Color { AppTheme.current.textColor }
    static var text: Color { AppTheme.current.textColor }
    static let border = Color.gray.opacity(0.15)
    static let accent = AppTheme.current.primary
    static let warning = Color.orange

    static var cardBackground: Color {
        Color(UIColor.systemBackground).opacity(0.9)
    }
}

// MARK: - Font Styles

struct AppFonts {
    static let title = Font.system(size: 24, weight: .bold, design: .default)
    static let sectionTitle = Font.system(size: 20, weight: .semibold, design: .default)
    static let heading = Font.system(size: 18, weight: .semibold, design: .default)
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let sectionLabel = Font.system(size: 14, weight: .medium, design: .default) // ✅ Fix
}


// MARK: - Layout & Sizing

struct AppSpacing {
    static let outer: CGFloat = 32
    static let section: CGFloat = 20
    static let element: CGFloat = 14
    static let cardCornerRadius: CGFloat = 20
    static let shadowRadius: CGFloat = 10
    static let verticalPadding: CGFloat = 28
}

// MARK: - Icons

struct AppIcons {
    static let dashboard = "rectangle.grid.2x2.fill"
    static let entries = "list.bullet.rectangle.fill"
    static let insights = "chart.pie.fill"
    static let add = "plus.circle.fill"
    static let export = "square.and.arrow.up.on.square.fill"
}

// MARK: - Colored Card

struct ColoredCard<Content: View>: View {
    var title: String
    var backgroundColor: Color
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.element) {
            Text(title)
                .font(AppFonts.sectionTitle)
                .foregroundColor(AppColors.secondary)

            content
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.08), radius: AppSpacing.shadowRadius, x: 0, y: 6)
    }
}

// MARK: - Tag Colors

struct TagColors {
    static func color(for tag: String) -> Color {
        switch tag.lowercased() {
        case "rest": return .blue
        case "social": return .green
        case "creative": return .purple
        case "outdoors": return .teal
        case "focus": return .orange
        case "other": return .gray
        default: return .gray
        }
    }
}

