import SwiftUI

struct MirrorGuideView: View {
    @AppStorage("selectedLanguage")
    private var selectedLanguage = "en"

    static func title(for language: String) -> String {
        switch language {
        case "ar": return "كيف تعمل مرآة"
        case "th": return "วิธีใช้ Mirror"
        default: return "How Mirror works"
        }
    }

    private var sections: [(title: String, body: String)] {
        switch selectedLanguage {
        case "ar":
            return [
                (
                    "ابدأ بعمل صغير",
                    "اختر حتى ثلاثة أعمال من «التركيز» لبناء روتين يناسبك. ويمكنك تسجيل بقية الأعمال من الصفحة الرئيسية أيضًا."
                ),
                (
                    "سجّل ما أنجزته",
                    "اضغط على بطاقة العمل بعد إنجازه. كل ضغطة تضيف تسجيلًا جديدًا. يمكنك التراجع عن آخر تسجيل لليوم من الصفحة الرئيسية."
                ),
                (
                    "تابع قراءتك للقرآن",
                    "عندما يكون القرآن ضمن أعمال التركيز، تفتح بطاقته نافذة لتحديد السورة والآيات التي قرأتها."
                ),
                (
                    "افهم تقدمك",
                    "يعرض الشريط الرئيسي تقدمك في رحلة مرآة ذات ٦٦ يومًا، وتوضح صفحة التركيز تقدم كل عمل. قد تؤثر فترات الانقطاع في التقدم. هذه الأرقام تذكير شخصي بما سجلته، وليست مقياسًا للإيمان أو ضمانًا لتكوّن العادة في مدة محددة."
                ),
                (
                    "راجع سجلك",
                    "افتح التقويم لمراجعة أعمالك أو إضافة عمل سابق أو حذف تسجيل خاطئ. تكرار قراءة المقطع نفسه يُحسب ضمن كمية القراءة المسجلة."
                ),
                (
                    "متى يبدأ يوم جديد؟",
                    "يبدأ يوم التسجيل الساعة الثانية صباحًا حسب التوقيت المحلي للجهاز. لذلك تُحتسب الأعمال المسجلة بين منتصف الليل والثانية صباحًا ضمن اليوم السابق."
                )
            ]

        case "th":
            return [
                (
                    "เริ่มจากความดีเล็ก ๆ",
                    "เลือกความดีได้สูงสุดสามอย่างในหน้าโฟกัส เพื่อสร้างกิจวัตรที่เหมาะกับคุณ คุณยังบันทึกความดีอื่น ๆ จากหน้าหลักได้"
                ),
                (
                    "บันทึกสิ่งที่ทำแล้ว",
                    "แตะการ์ดหลังทำความดีเสร็จ การแตะแต่ละครั้งจะเพิ่มหนึ่งรายการ คุณยกเลิกรายการล่าสุดของวันนี้ได้จากหน้าหลัก"
                ),
                (
                    "ติดตามการอ่านอัลกุรอาน",
                    "เมื่อเลือกอัลกุรอานเป็นหนึ่งในรายการโฟกัส การแตะการ์ดจะเปิดหน้าต่างให้ระบุซูเราะฮ์และอายะฮ์ที่อ่าน"
                ),
                (
                    "เข้าใจความก้าวหน้า",
                    "แถบหลักแสดงความก้าวหน้าของเส้นทาง 66 วัน ส่วนหน้าโฟกัสแสดงความก้าวหน้าของแต่ละกิจกรรม ช่วงที่เว้นไปอาจส่งผลต่อความก้าวหน้า ตัวเลขเป็นเครื่องเตือนใจจากสิ่งที่คุณบันทึก ไม่ใช่มาตรวัดศรัทธาหรือคำรับรองว่าจะสร้างนิสัยได้ภายในเวลาที่กำหนด"
                ),
                (
                    "ทบทวนประวัติ",
                    "เปิดปฏิทินเพื่อดูประวัติ เพิ่มรายการย้อนหลัง หรือลบรายการที่ผิด การอ่านช่วงเดิมซ้ำจะนับรวมในปริมาณการอ่านที่บันทึก"
                ),
                (
                    "วันใหม่เริ่มเมื่อไร",
                    "วันสำหรับการบันทึกเริ่มเวลา 02:00 น. ตามเวลาท้องถิ่นของอุปกรณ์ รายการตั้งแต่เที่ยงคืนถึงก่อน 02:00 น. จึงนับเป็นวันก่อนหน้า"
                )
            ]

        default:
            return [
                (
                    "Start small",
                    "Choose up to three deeds in Focus to build a routine that suits you. You can also record other deeds from Home."
                ),
                (
                    "Record what you complete",
                    "Tap a deed card after completing it. Each tap adds another entry. Use Undo on Home to remove your latest entry for today."
                ),
                (
                    "Track your Quran reading",
                    "When Quran is one of your focus deeds, tapping its card opens a form for the surah and ayahs you read."
                ),
                (
                    "Understand your progress",
                    "The main bar shows progress through Mirror’s 66-day journey. Focus shows each habit’s progress. Gaps can affect progress. These numbers reflect your recorded activity; they do not measure faith or guarantee a habit will form within a fixed time."
                ),
                (
                    "Review your history",
                    "Open Calendar to review entries, add a past deed, or delete a mistake. Rereading the same Quran passage counts toward your recorded reading volume."
                ),
                (
                    "Know when the day changes",
                    "A tracking day starts at 2 a.m. in your device’s local time. Entries between midnight and 2 a.m. belong to the previous tracking day."
                )
            ]
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(sections.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(sections[index].title)
                            .font(.headline)
                            .foregroundStyle(
                                Color(red: 0.85, green: 0.72, blue: 0.52)
                            )

                        Text(sections[index].body)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .background(
                        Color.white.opacity(0.05),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                }
            }
            .padding(20)
            .padding(.bottom, 100)
        }
        .background(
            Color(red: 0.12, green: 0.09, blue: 0.07)
                .ignoresSafeArea()
        )
        .navigationTitle(Self.title(for: selectedLanguage))
        .navigationBarTitleDisplayMode(.inline)
        .environment(
            \.layoutDirection,
            selectedLanguage == "ar" ? .rightToLeft : .leftToRight
        )
    }
}
