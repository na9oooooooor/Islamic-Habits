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

            VStack(spacing: 0) {

                // Handle
                RoundedRectangle(cornerRadius: 2)
                    .fill(gold.opacity(0.3))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)

                // Focus deed badge
                HStack(spacing: 6) {
                    Image(systemName: "scope")
                        .font(.system(size: 11))
                        .foregroundColor(gold)
                    Text(localizedString("quran.sheet.focus.badge", language: selectedLanguage))
                        .font(.system(size: 12))
                        .foregroundColor(gold)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(gold.opacity(0.12))
                        .overlay(Capsule().stroke(gold.opacity(0.3), lineWidth: 0.5))
                )
                .padding(.top, 16)

                // Title
                VStack(spacing: 4) {
                    Text(localizedString("quran.sheet.title", language: selectedLanguage))               .font(.system(size: 22, weight: .light))
                        .foregroundColor(gold)
                    Text(localizedString("quran.sheet.subtitle", language: selectedLanguage))
                        .font(.system(size: 10, weight: .medium))
                        .tracking(1.5)
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(.top, 16)

                // Ayahs count
                VStack(spacing: 4) {
                    Text("\(ayahsRead)")
                        .font(.system(size: 56, weight: .ultraLight))
                        .foregroundColor(gold)
                    Text(localizedString("quran.sheet.ayahs.read", language: selectedLanguage))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(.vertical, 20)

                Divider().background(gold.opacity(0.15)).padding(.horizontal, 24)

                // FROM
                VStack(alignment: .leading, spacing: 10) {
                    Text(localizedString("quran.sheet.from", language: selectedLanguage))
                        .font(.system(size: 10, weight: .medium))
                        .tracking(1.5)
                        .foregroundColor(gold.opacity(0.5))

                    HStack(spacing: 10) {
                        Picker("", selection: $selectedSurahFrom) {
                            ForEach(QuranData.surahs) { surah in
                                Text(surah.localizedName(language: selectedLanguage)).tag(surah)
                                    .foregroundColor(.white)
                                    .tag(surah)
                            }
                        }
                        .colorScheme(.dark)
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .clipped()

                        Picker("", selection: $selectedAyahFrom) {
                            ForEach(1...selectedSurahFrom.ayahs, id: \.self) { ayah in
                                Text("\(ayah)").tag(ayah)
                            }
                        }
                        .colorScheme(.dark)
                        .pickerStyle(.wheel)
                        .frame(width: 72)
                        .frame(height: 100)
                        .clipped()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // TO
                VStack(alignment: .leading, spacing: 10) {
                    Text(localizedString("quran.sheet.to", language: selectedLanguage))
                        .font(.system(size: 10, weight: .medium))
                        .tracking(1.5)
                        .foregroundColor(gold.opacity(0.5))

                    HStack(spacing: 10) {
                        Picker("", selection: $selectedSurahTo) {
                            ForEach(QuranData.surahs.filter { $0.number >= selectedSurahFrom.number }) { surah in
                                Text(surah.localizedName(language: selectedLanguage)).tag(surah)
                                    .foregroundColor(.white)
                                    .tag(surah)
                            }
                        }
                        .colorScheme(.dark)
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .clipped()

                        Picker("", selection: $selectedAyahTo) {
                            let minAyah = selectedSurahTo.number == selectedSurahFrom.number ? selectedAyahFrom : 1
                            ForEach(minAyah...selectedSurahTo.ayahs, id: \.self) { ayah in
                                Text("\(ayah)").tag(ayah)
                            }
                        }
                        .colorScheme(.dark)
                        .pickerStyle(.wheel)
                        .frame(width: 72)
                        .frame(height: 100)
                        .clipped()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 16)

                Divider().background(gold.opacity(0.15)).padding(.horizontal, 24)

                // Save
                Button { saveLog()
                } label: {
                    Text(localizedString("postlog.dismiss", language: selectedLanguage))                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(bg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(gold)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
        }
    }
}
