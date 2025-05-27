import SwiftUI

struct AnalyticsContainerView: View {
    var body: some View {
        TabView {
            LogisticsMainPage()
                .tag(0)
                .modifier(FillScreenSwipeFix())

            DailyAnalyticsPage()
                .tag(1)
                .modifier(FillScreenSwipeFix())

            WeeklyAnalyticsPage()
                .tag(2)
                .modifier(FillScreenSwipeFix())

            MonthlyAnalyticsPage()
                .tag(3)
                .modifier(FillScreenSwipeFix())
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .ignoresSafeArea()
    }
}

struct FillScreenSwipeFix: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
            .ignoresSafeArea()
    }
}

