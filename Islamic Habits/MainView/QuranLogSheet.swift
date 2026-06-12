import SwiftUI
import SwiftData

struct QuranLogSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let selectedLanguage: String
    let onSave: () -> Void

    private let gold = Color("#D9B883")
    private let bg = Color("#1F1712")

    @State private var selectedSurahFrom: Surah = QuranData.surahs[0]
    @State private var selectedAyahFrom: Int = 1
    @State private var selectedSurahTo: Surah = QuranData.surahs[0]
    @State private var selectedAyahTo: Int = 1

    var ayahsRead: Int {
        let engine = DeedEngine(logs: [], dailyGoal: 1)
        return engine.calculateAyahsRead(
            surahFromNumber: selectedSurahFrom.number,
            ayahFrom: selectedAyahFrom,
            surahToNumber: selectedSurahTo.number,
            ayahTo: selectedAyahTo
        )
    }
    
    func saveLog() {
        let log = QuranLog(
            surahFromNumber: selectedSurahFrom.number,
            ayahFrom: selectedAyahFrom,
            surahToNumber: selectedSurahTo.number,
            ayahTo: selectedAyahTo,
            ayahsRead: ayahsRead
        )
        context.insert(log)
        onSave()
        dismiss()
    }
    
    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 24) {

                // Title
                Text("القرآن الكريم")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(gold)
                    .padding(.top, 24)

                // Live ayahs count
                Text("\(ayahsRead)")
                    .font(.system(size: 52, weight: .thin))
                    .foregroundColor(gold)

                Text("ayahs")
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(.white.opacity(0.4))

                Divider()
                    .background(Color.white.opacity(0.08))

                // FROM pickers
                HStack(spacing: 0) {
                    Picker("", selection: $selectedSurahFrom) {
                        ForEach(QuranData.surahs) { surah in
                            Text(surah.localizedName(language: selectedLanguage))
                                .tag(surah)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)

                    // Ayah picker
                    Picker("", selection: $selectedAyahFrom) {
                        ForEach(1...selectedSurahFrom.ayahs, id: \.self) { ayah in
                            Text("\(ayah)").tag(ayah)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80)
                }

                Divider()
                    .background(Color.white.opacity(0.08))

                // TO pickers
                HStack(spacing: 0) {
                    Picker("", selection: $selectedSurahTo) {
                        ForEach(QuranData.surahs.filter { $0.number >= selectedSurahFrom.number }) { surah in
                            Text(surah.localizedName(language: selectedLanguage))
                                .tag(surah)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)

                    Picker("", selection: $selectedAyahTo) {
                        let minAyah = selectedSurahTo.number == selectedSurahFrom.number ? selectedAyahFrom : 1
                        ForEach(minAyah...selectedSurahTo.ayahs, id: \.self) { ayah in
                            Text("\(ayah)").tag(ayah)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80)
                }

                // Save button
                Button {
                    saveLog()
                } label: {
                    Text("بارك الله فيك")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(bg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(gold)
                        .cornerRadius(14)
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 24)
            }
        }
    }
}
