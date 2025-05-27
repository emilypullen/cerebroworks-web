import SwiftUI

struct KidsMenuView: View {
    var body: some View {
        ZStack {
            // 🌈 New base background using asset
            Color("LightBlue")
                .ignoresSafeArea()

            // Optional soft overlay gradient for visual depth
            LinearGradient(
                colors: [Color.white.opacity(0.05), AppColors.peach.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                // Title
                Text("Choose a Scene")
                    .font(AppFonts.heading())
                    .foregroundColor(AppColors.lavender)
                    .padding(.top, 40)
                    .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)

                // Park Scene
                NavigationLink(destination: FirstSceneView()) {
                    Text("🌳 Park Scene")
                        .modifier(SceneButtonStyle(color: AppColors.freshGreen))
                }

                // Snow Scene
                NavigationLink(destination: SnowSceneView()) {
                    Text("❄️ Snow Scene")
                        .modifier(SceneButtonStyle(color: Color.white.opacity(0.85)))
                }

                // Frying Pan Scene
                NavigationLink(destination: FryingPanSceneView()) {
                    Text("🍳 Frying Pan Scene")
                        .modifier(SceneButtonStyle(color: AppColors.peach))
                }

                // Firetruck Scene
                NavigationLink(destination: FiretruckSceneView()) {
                    Text("🚒 Firetruck Scene")
                        .modifier(SceneButtonStyle(color: AppColors.lavender))
                }

                Spacer()
            }
            .padding()
        }
    }
    // MARK: - Scene Button Modifier
    struct SceneButtonStyle: ViewModifier {
        var color: Color

        func body(content: Content) -> some View {
            content
                .font(AppFonts.button())
                .foregroundColor(.white)
                .frame(width: 260, height: 90)
                .background(color)
                .cornerRadius(30)
                .shadow(color: .gray.opacity(0.3), radius: 6, x: 0, y: 4)
        }
    }

}

