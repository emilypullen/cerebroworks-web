import SwiftUI

enum HomeDestination: Hashable {
    case kidsMenu
    case parkScene
}

struct HomeView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 30) {
                    // Title
                    Text("Welcome to Little Scenes")
                        .font(AppFonts.heading())
                        .foregroundColor(Color("Midnight"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                        .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)

                    // Subheading
                    Text("A calm, creative space for little ones to explore.\nNo ads. No overstimulation. Just peaceful play.")
                        .font(AppFonts.body())
                        .foregroundColor(Color("Midnight"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Info Box
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Designed for minimal screen time", systemImage: "clock")
                        Label("Moveable scenes, no loud music", systemImage: "leaf")
                        Label("Parent-controlled access", systemImage: "lock.shield")
                    }
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .gray.opacity(0.2), radius: 6, x: 0, y: 4)
                    .padding(.horizontal)

                    // Kids Menu Button
                    Button(action: {
                        path.append(HomeDestination.kidsMenu)
                    }) {
                        Text("Open Kids Menu")
                            .font(AppFonts.button())
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppColors.softBlue)
                            .cornerRadius(20)
                            .padding(.horizontal, 30)
                    }

                    // Preview Scene Button
                    Button(action: {
                        path.append(HomeDestination.parkScene)
                    }) {
                        Text("Preview Park Scene")
                            .font(AppFonts.body())
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppColors.freshGreen)
                            .cornerRadius(20)
                            .padding(.horizontal, 30)
                    }

                    Spacer(minLength: 40)
                }
                .padding()
            }
            // 🔵 LightBlue background from Assets
            .background(
                ZStack {
                    Color("LightBlue").ignoresSafeArea()
                    // Optional overlay
                    LinearGradient(
                        colors: [Color.white.opacity(0.05), AppColors.peach.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }
            )
            .navigationBarHidden(true)
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .kidsMenu:
                    KidsMenuView()
                case .parkScene:
                    FirstSceneView()
                }
            }
        }
    }
}

