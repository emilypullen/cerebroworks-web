import SwiftUI

struct FirstSceneView: View {
    @State private var bunnyOffset: CGSize = .zero
    @State private var lastBunnyOffset: CGSize = .zero

    @State private var bunnyScale: CGFloat = 1.0
    @State private var lastBunnyScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Image("ParkImage")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            Image("Bunny")
                .resizable()
                .frame(width: 150, height: 150)
                .scaleEffect(bunnyScale)
                .offset(x: bunnyOffset.width, y: bunnyOffset.height)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            bunnyOffset = CGSize(
                                width: lastBunnyOffset.width + value.translation.width,
                                height: lastBunnyOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastBunnyOffset = bunnyOffset
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            bunnyScale = lastBunnyScale * value
                        }
                        .onEnded { _ in
                            lastBunnyScale = bunnyScale
                        }
                )
        }
    }
}
