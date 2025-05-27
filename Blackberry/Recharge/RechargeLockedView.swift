import SwiftUI

struct RechargeLockedView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "lock.heart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(AppColors.accent)

                VStack(spacing: 8) {
                    Text("Recharge is a Pro Feature")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppColors.secondary)
                        .multilineTextAlignment(.center)

                    Text("Track your non-work hours, reflect on rest patterns, and unlock balance insights — only with Tempo Pro.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

                Button(action: {
                    // TODO: Trigger your Pro purchase flow here
                }) {
                    Text("Upgrade to Pro")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.accent.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .padding(.top, 4)
                .padding(.horizontal, 16)

                Button(action: {
                    // Optional: show modal with Pro feature benefits
                }) {
                    Text("Learn more")
                        .font(.footnote)
                        .foregroundColor(AppColors.accent)
                        .underline()
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 60)
        .background(AppTheme.current.backgroundView.ignoresSafeArea())
        .navigationTitle("Recharge")
        .navigationBarTitleDisplayMode(.inline)
    }
}
