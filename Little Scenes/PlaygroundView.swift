import SwiftUI

struct PlaygroundView: View {
    let backgroundName: String
    @State private var stickerPosition = CGSize.zero

    var body: some View {
        ZStack {
            Image(backgroundName)
                .resizable()
                .ignoresSafeArea()

            Image("Sticker1")
                .resizable()
                .frame(width: 100, height: 100)
                .offset(stickerPosition)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            stickerPosition = value.translation
                        }
                )
        }
    }
}
