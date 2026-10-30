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
    @State private var showSaveError = false
    
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
        guard ayahsRead > 0 else { return }

        let timestamp = Date()

        let deedLog = DeedLog(
            worshipType: .quran,
            loggedAt: timestamp
        )

        let quranLog = QuranLog(
            surahFromNumber: selectedSurahFrom.number,
            ayahFrom: selectedAyahFrom,
            surahToNumber: selectedSurahTo.number,
            ayahTo: selectedAyahTo,
            ayahsRead: ayahsRead
        )

        quranLog.loggedAt = timestamp

        let sessionID = UUID()
        deedLog.quranSessionID = sessionID
        quranLog.quranSessionID = sessionID

        context.insert(deedLog)
        context.insert(quranLog)

        do {
            try context.save()
            MirrorAnalytics.deedSubmitted()
            onSave()
            dismiss()
        } catch {
            context.delete(quranLog)
            context.delete(deedLog)

            showSaveError = true
            print("Failed to save Quran log: \(error)")
        }
    }
    
    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            IslamicPattern().ignoresSafeArea()

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
                    Text(localizedString("quran.sheet.title", language: selectedLanguage))
                        .font(.system(size: 22, weight: .light))
                        .foregroundColor(gold)
                    Text(localizedString("quran.sheet.subtitle", language: selectedLanguage))
                        .font(.system(size: 10, weight: .medium))
                        .tracking(1.5)
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(.top, 12)

                // Ayahs count hero
                ZStack {
                    Ellipse()
                        .fill(gold.opacity(0.06))
                        .frame(width: 120, height: 50)
                        .blur(radius: 16)

                    VStack(spacing: 2) {
                        Text("\(ayahsRead)")
                            .font(.system(size: 52, weight: .ultraLight))
                            .foregroundColor(gold)
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.2), value: ayahsRead)
                        Text(localizedString("quran.sheet.ayahs.read", language: selectedLanguage))
                            .font(.system(size: 11))
                            .foregroundColor(gold.opacity(0.5))
                            .tracking(0.5)
                    }
                }
                .padding(.vertical, 16)

                // Pickers area
                VStack(spacing: 12) {

                    // FROM
                    pickerCard(
                        label: localizedString("quran.sheet.from", language: selectedLanguage),
                        surahBinding: $selectedSurahFrom,
                        ayahBinding: $selectedAyahFrom,
                        surahList: QuranData.surahs,
                        minAyah: 1
                    )

                    // Arrow
                    Image(systemName: "arrow.down")
                        .font(.system(size: 12))
                        .foregroundColor(gold.opacity(0.3))

                    // TO
                    pickerCard(
                        label: localizedString("quran.sheet.to", language: selectedLanguage),
                        surahBinding: $selectedSurahTo,
                        ayahBinding: $selectedAyahTo,
                        surahList: QuranData.surahs.filter { $0.number >= selectedSurahFrom.number },
                        minAyah: selectedSurahTo.number == selectedSurahFrom.number ? selectedAyahFrom : 1
                    )
                }
                .padding(.horizontal, 20)

                Spacer()

                // Save button
                Button {
                    saveLog()
                } label: {
                    Text(localizedString("postlog.dismiss", language: selectedLanguage))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(bg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(gold)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .padding(.top, 16)
                .disabled(ayahsRead <= 0)
                .opacity(ayahsRead > 0 ? 1 : 0.5)
                .alert(
                    selectedLanguage == "ar"
                        ? "تعذّر الحفظ"
                        : selectedLanguage == "th"
                            ? "บันทึกไม่สำเร็จ"
                            : "Couldn’t save",
                    isPresented: $showSaveError
                ) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(
                        selectedLanguage == "ar"
                            ? "لم يتم حفظ القراءة. اختياراتك ما زالت موجودة؛ حاول مجددًا."
                            : selectedLanguage == "th"
                                ? "บันทึกการอ่านไม่สำเร็จ ตัวเลือกของคุณยังอยู่ กรุณาลองอีกครั้ง"
                                : "Your reading wasn’t saved. Your selections are still here; please try again."
                    )
                }
            }
        }.onChange(of: selectedSurahFrom.number) { _, _ in
            
            selectedAyahFrom = min(
                selectedAyahFrom,
                selectedSurahFrom.ayahs
            )

            if selectedSurahTo.number < selectedSurahFrom.number {
                selectedSurahTo = selectedSurahFrom
                selectedAyahTo = selectedAyahFrom
            }

            if selectedSurahTo.number == selectedSurahFrom.number {
                selectedAyahTo = max(
                    selectedAyahTo,
                    selectedAyahFrom
                )

                selectedAyahTo = min(
                    selectedAyahTo,
                    selectedSurahTo.ayahs
                )
            }
        }

        .onChange(of: selectedAyahFrom) { _, newAyah in
            if selectedSurahFrom.number == selectedSurahTo.number {
                selectedAyahTo = max(
                    selectedAyahTo,
                    newAyah
                )
            }
        }

        .onChange(of: selectedSurahTo.number) { _, _ in
            selectedAyahTo = min(
                selectedAyahTo,
                selectedSurahTo.ayahs
            )

            if selectedSurahFrom.number == selectedSurahTo.number {
                selectedAyahTo = max(
                    selectedAyahTo,
                    selectedAyahFrom
                )
            } else if selectedAyahTo < 1 {
                selectedAyahTo = 1
            }
        }
    }
    

    // MARK: - Picker Card
    func pickerCard(
        label: String,
        surahBinding: Binding<Surah>,
        ayahBinding: Binding<Int>,
        surahList: [Surah],
        minAyah: Int
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.5)
                .foregroundColor(gold.opacity(0.5))
                .padding(.horizontal, 4)

            HStack(spacing: 0) {
                Picker("", selection: surahBinding) {
                    ForEach(surahList) { surah in
                        Text(surah.localizedName(language: selectedLanguage))
                            .tag(surah)
                    }
                }
                .colorScheme(.dark)
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .clipped()

                Rectangle()
                    .fill(gold.opacity(0.1))
                    .frame(width: 1, height: 80)

                Picker("", selection: ayahBinding) {
                    ForEach(minAyah...max(minAyah, surahBinding.wrappedValue.ayahs), id: \.self) { ayah in
                        Text("\(ayah)").tag(ayah)
                    }
                }
                .colorScheme(.dark)
                .pickerStyle(.wheel)
                .frame(width: 70)
                .frame(height: 100)
                .clipped()
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(gold.opacity(0.12), lineWidth: 1)
                )
        )
    }
}
