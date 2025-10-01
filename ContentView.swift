import SwiftUI

struct ContentView: View {
    @State private var page: LayoutPage?

    var body: some View {
        Group {
            if let page {
                DynamicPageView(page: page)          // <- show the dynamic UI
            } else {
                ProgressView().task { await loadLayout() }  // <- load JSON once
            }
        }
    }

    private func loadLayout() async {
        // Looks for spa_layout.json inside your app bundle
        if let url = Bundle.main.url(forResource: "spa_layout", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(LayoutPage.self, from: data)
                page = decoded
            } catch {
                print("Decoding error:", error)       // helpful if JSON is malformed
            }
        } else {
            print("spa_layout.json not found in bundle") // happens if Target Membership is unticked
        }
    }
}

#Preview { ContentView() }
