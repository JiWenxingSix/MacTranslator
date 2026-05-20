import SwiftUI

enum SidebarDestination: String, CaseIterable, Identifiable {
    case translator
    case vocabulary

    var id: Self { self }

    var title: String {
        switch self {
        case .translator:
            "即时翻译"
        case .vocabulary:
            "我的生词本"
        }
    }

    var symbolName: String {
        switch self {
        case .translator:
            "character.book.closed"
        case .vocabulary:
            "books.vertical"
        }
    }
}

struct ContentView: View {
    @State private var selection: SidebarDestination? = .translator

    var body: some View {
        NavigationSplitView {
            List(SidebarDestination.allCases, selection: $selection) { destination in
                Label(destination.title, systemImage: destination.symbolName)
                    .tag(destination)
            }
            .navigationSplitViewColumnWidth(min: 190, ideal: 220)
        } detail: {
            switch selection ?? .translator {
            case .translator:
                TranslationView()
            case .vocabulary:
                VocabularyView()
            }
        }
    }
}
