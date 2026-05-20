import SwiftData
import SwiftUI

struct VocabularyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VocabularyItem.timestamp, order: .reverse) private var vocabularyItems: [VocabularyItem]

    @State private var searchText = ""
    @State private var newestFirst = true

    private var visibleItems: [VocabularyItem] {
        let filteredItems = vocabularyItems.filter { item in
            guard searchText.isEmpty == false else {
                return true
            }

            return item.word.localizedStandardContains(searchText) ||
            item.translation.localizedStandardContains(searchText) ||
            item.phonetic.localizedStandardContains(searchText)
        }

        return filteredItems.sorted {
            newestFirst ? $0.timestamp > $1.timestamp : $0.timestamp < $1.timestamp
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("我的生词本")
                        .font(.largeTitle.bold())
                    Text("\(vocabularyItems.count) 个自动归档的单词")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Picker("排序", selection: $newestFirst) {
                    Text("最新优先").tag(true)
                    Text("最早优先").tag(false)
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }

            TextField("搜索单词、译文或音标", text: $searchText)
                .textFieldStyle(.roundedBorder)

            if visibleItems.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? "还没有生词" : "没有匹配结果",
                    systemImage: searchText.isEmpty ? "books.vertical" : "magnifyingglass",
                    description: Text(searchText.isEmpty ? "在即时翻译页输入单词，翻译成功后会自动保存。" : "换个关键词再试试。")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(visibleItems) { item in
                        VocabularyRow(item: item)
                    }
                }
                .listStyle(.inset)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.quaternary, lineWidth: 1)
                }
            }
        }
        .padding(24)
        .navigationTitle("我的生词本")
    }
}

private struct VocabularyRow: View {
    @Bindable var item: VocabularyItem

    var body: some View {
        HStack(spacing: 14) {
            Button {
                SpeechManager.shared.speak(item.word)
            } label: {
                Image(systemName: "speaker.wave.2")
            }
            .buttonStyle(.borderless)
            .help("朗读")

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(item.word)
                        .font(.system(.title3, design: .rounded).weight(.semibold))

                    if item.phonetic.isEmpty == false {
                        Text(item.phonetic)
                            .font(.callout)
                            .foregroundStyle(.blue)
                    }
                }

                Text(item.translation)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Text(item.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            Toggle("已掌握", isOn: $item.isLearned)
                .toggleStyle(.checkbox)
                .help("标记掌握状态")
        }
        .padding(.vertical, 8)
    }
}
