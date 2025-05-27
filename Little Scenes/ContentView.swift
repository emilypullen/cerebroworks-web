import SwiftUI

struct ContentView: View {
    @State private var selectedBackground: String? = nil

    var body: some View {
        NavigationView {
            VStack {
                Text("Choose a Background")
                    .font(.largeTitle)
                    .padding()

                NavigationLink(destination: PlaygroundView(backgroundName: "Background1"), tag: "Background1", selection: $selectedBackground) {
                    Button(action: {
                        selectedBackground = "Background1"
                    }) {
                        Image("Background1")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 200)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                            .padding()
                    }
                }

                Spacer()
            }
        }
    }
}
