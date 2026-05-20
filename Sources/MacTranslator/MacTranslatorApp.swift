import SwiftData
import SwiftUI

@main
struct MacTranslatorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: VocabularyItem.self)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .defaultSize(width: 1080, height: 720)
    }
}
