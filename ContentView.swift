import SwiftUI

struct ContentView: View {
    @State private var page: LayoutPage?

    var body: some View {
        Group {
            if let page { DynamicPageView(page: page) }
            else { ProgressView().task { await loadLayout() } }
        }
    }

    private func loadLayout() async {
        // For now, load local JSON named "spa_layout.json" from the bundle
        if let url = Bundle.main.url(forResource: "spa_layout", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            let dec = JSONDecoder()
            page = try? dec.decode(LayoutPage.self, from: data)
        }
    }
}

#Preview { ContentView() }
