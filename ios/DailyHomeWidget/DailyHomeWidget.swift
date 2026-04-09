//
//  DailyHomeWidget.swift
//  DailyHomeWidget
//
//  Created by stecdev_mac on 4/1/26.
//

import WidgetKit
import SwiftUI


// ─────────────────────────────────────────────────────────────────────────────
// MARK: - 상태 Enum
// ─────────────────────────────────────────────────────────────────────────────
enum BudgetStatus {
    case comfortable  // 여유: ≥ 5,000
    case tight        // 빠듯: 1 ~ 4,999
    case exceeded     // 초과: < 0
    
    init(remaining: Int) {
        if remaining >= 5000 {
            self = .comfortable
        } else if remaining >= 0 {
            self = .tight
        } else {
            self = .exceeded
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - 지출 항목 모델
// ─────────────────────────────────────────────────────────────────────────────
struct ExpenseItem: Codable, Identifiable {
    var id: String { "\(category)_\(time)_\(amount)" }
    let category: String  // "점심", "카페", "간식" 등
    let time: String      // "12:30", "15:15" 등
    let amount: Int       // 양수값 (3500)
    
    /// 카테고리별 이모지 아이콘 매핑
    var icon: String {
        switch category {
        case "점심", "저녁", "아침", "식비":
            return "🍚"
        case "카페", "아메리카노", "커피":
            return "☕"
        case "간식":
            return "🍪"
        case "교통":
            return "🚗"
        case "쇼핑":
            return "🛍️"
        default:
            return "💰"
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - 상태별 색상 팔레트 (디자인 가이드 기반)
// ─────────────────────────────────────────────────────────────────────────────
struct WidgetColorPalette {
    let background: Color
    let primaryText: Color    // 금액, 제목
    let secondaryText: Color  // 라벨, 설명
    let accentBg: Color       // 스트릭 배지, 구분선 등
    
    static func palette(for status: BudgetStatus) -> WidgetColorPalette {
        switch status {
        case .comfortable:
            return WidgetColorPalette(
                background:    Color(red: 241/255, green: 245/255, blue: 249/255), // #F1F5F9
                primaryText:   Color(red: 15/255,  green: 23/255,  blue: 42/255),  // #0F172A
                secondaryText: Color(red: 71/255,  green: 85/255,  blue: 105/255), // #475569
                accentBg:      Color(red: 226/255, green: 232/255, blue: 240/255)  // #E2E8F0
            )
        case .tight:
            return WidgetColorPalette(
                background:    Color(red: 254/255, green: 243/255, blue: 199/255), // #FEF3C7
                primaryText:   Color(red: 120/255, green: 53/255,  blue: 15/255),  // #78350F
                secondaryText: Color(red: 194/255, green: 65/255,  blue: 12/255),  // #C2410C
                accentBg:      Color(red: 254/255, green: 215/255, blue: 170/255)  // #FED7AA
            )
        case .exceeded:
            return WidgetColorPalette(
                background:    Color(red: 254/255, green: 226/255, blue: 226/255), // #FEE2E2
                primaryText:   Color(red: 185/255, green: 28/255,  blue: 28/255),  // #B91C1C
                secondaryText: Color(red: 220/255, green: 38/255,  blue: 38/255),  // #DC2626
                accentBg:      Color(red: 254/255, green: 202/255, blue: 202/255)  // #FECACA
            )
        }
    }
    
    /// Small 위젯 금액 폰트 크기
    static func smallFontSize(for status: BudgetStatus) -> CGFloat {
        switch status {
        case .comfortable: return 24
        case .tight:       return 24
        case .exceeded:    return 24
        }
    }
    
    /// Medium 위젯 "남은 예산" 금액 폰트 크기
    static func mediumRemainingFontSize(for status: BudgetStatus) -> CGFloat {
        switch status {
        case .comfortable: return 26
        case .tight:       return 26
        case .exceeded:    return 26
        }
    }
    
    /// Medium 위젯 "사용한 예산" 금액 폰트 크기 (남은 예산과 동일)
    static func mediumUsedFontSize(for status: BudgetStatus) -> CGFloat {
        return mediumRemainingFontSize(for: status)
    }
    
    /// Large 위젯 "남은 예산" 금액 폰트 크기
    static func largeRemainingFontSize(for status: BudgetStatus) -> CGFloat {
        switch status {
        case .comfortable: return 26
        case .tight:       return 26
        case .exceeded:    return 26
        }
    }
    
    /// Large 위젯 "사용한 예산" 금액 폰트 크기 (남은 예산과 동일)
    static func largeUsedFontSize(for status: BudgetStatus) -> CGFloat {
        return largeRemainingFontSize(for: status)
    }
}


// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Timeline Provider
// ─────────────────────────────────────────────────────────────────────────────
struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(), total: 10000, used: 0,
            remaining: 10000, streak: 0, expenses: [], catMood: "comfortable"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(), total: 10000, used: 2800,
            remaining: 7200, streak: 12,
            expenses: [
                ExpenseItem(category: "점심", time: "12:30", amount: 3500),
                ExpenseItem(category: "아메리카노", time: "15:15", amount: 1300),
            ],
            catMood: "comfortable"
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefault = UserDefaults(suiteName: "group.dailyManWon.homeWidget")

        let total     = userDefault?.integer(forKey: "totalKey")     ?? 0
        let used      = userDefault?.integer(forKey: "usedKey")      ?? 0
        let remaining = userDefault?.integer(forKey: "remainingKey") ?? 0
        let streak    = userDefault?.integer(forKey: "streakKey")    ?? 0
        let catMood   = userDefault?.string(forKey: "cat_mood")      ?? "comfortable"

        // JSON 문자열로 저장된 지출 목록 파싱
        var expenses: [ExpenseItem] = []
        if let jsonString = userDefault?.string(forKey: "expensesKey"),
           let data = jsonString.data(using: .utf8) {
            expenses = (try? JSONDecoder().decode([ExpenseItem].self, from: data)) ?? []
        }

        let entry = SimpleEntry(
            date: Date(),
            total: total,
            used: used,
            remaining: remaining,
            streak: streak,
            expenses: expenses,
            catMood: catMood
        )

        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Timeline Entry
// ─────────────────────────────────────────────────────────────────────────────
struct SimpleEntry: TimelineEntry {
    let date: Date
    let total: Int
    let used: Int
    let remaining: Int
    let streak: Int
    let expenses: [ExpenseItem]
    let catMood: String  // "comfortable", "normal", "danger", "over"
}


// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Widget Entry View (Small 2×2)
// ─────────────────────────────────────────────────────────────────────────────
struct DailyHomeSmallView: View {
    var entry: Provider.Entry
    
    private var status: BudgetStatus { BudgetStatus(remaining: entry.remaining) }
    private var colors: WidgetColorPalette { WidgetColorPalette.palette(for: status) }
    
    private var amountText: String {
        let abs = abs(entry.remaining)
        let formatted = formatNumber(abs)
        return entry.remaining < 0 ? "-₩\(formatted)" : "₩\(formatted)"
    }
    
    private var progressRatio: Double {
        guard entry.total > 0 else { return 0.0 }
        return max(0.0, min(1.0, Double(entry.remaining) / Double(entry.total)))
    }
    
    private var statusMessage: String {
        switch status {
        case .comfortable: return "오늘도 잘 하고 있어요"
        case .tight:       return "조금만 더 아껴볼까요?"
        case .exceeded:    return "예산을 초과했어요"
        }
    }
    
    var body: some View {
        let content = VStack(alignment: .leading, spacing: 0) {
            // 상단: 남은 예산 라벨 + 스트릭 배지
            HStack {
                Text("남은 예산")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(colors.secondaryText)
                
                Spacer()
                
                HStack(spacing: 2) {
                    Text("🔥")
                        .font(.system(size: 10))
                    Text("\(entry.streak)일째")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(colors.primaryText)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(colors.accentBg)
                )
            }
            
            Spacer()

            HStack {
                Spacer()
                Image(catImageName(for: entry.catMood))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                Spacer()
            }

            HStack {
                Spacer()
                Text(amountText)
                    .font(.system(size: WidgetColorPalette.smallFontSize(for: status), weight: .bold))
                    .foregroundColor(colors.primaryText)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Spacer()
            }

            if status == .exceeded {
                HStack {
                    Spacer()
                    Text("초과!")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(colors.secondaryText)
                    Spacer()
                }
            }
            
            Spacer()
            
            // 프로그레스 바
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(colors.accentBg)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(colors.primaryText)
                        .frame(width: geometry.size.width * CGFloat(progressRatio))
                }
            }
            .frame(height: 6)
            
            Spacer().frame(height: 8)
            
            Text(statusMessage)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(colors.secondaryText)
                .lineLimit(1)
        }
        
        if #available(iOS 17.0, *) {
            content.containerBackground(for: .widget) { colors.background }
        } else {
            content.padding(16).background(colors.background)
        }
    }
}


// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Widget Entry View (Medium 4×2)
// 이미지 레이아웃:
//  ┌──────────────────────────────────────┐
//  │ 총 예산 ₩10,000            🔥 12일  │
//  │──────────────────────────────────────│
//  │ 남은 예산       │  사용한 예산       │
//  │ ₩7,200 (큰글씨) │  ₩2,800           │
//  └──────────────────────────────────────┘
// ─────────────────────────────────────────────────────────────────────────────
struct DailyHomeMediumView: View {
    var entry: Provider.Entry
    
    private var status: BudgetStatus { BudgetStatus(remaining: entry.remaining) }
    private var colors: WidgetColorPalette { WidgetColorPalette.palette(for: status) }
    
    private var remainingText: String {
        let abs = abs(entry.remaining)
        let formatted = formatNumber(abs)
        return entry.remaining < 0 ? "-₩\(formatted)" : "₩\(formatted)"
    }
    
    private var usedText: String {
        "₩\(formatNumber(entry.used))"
    }
    
    private var totalText: String {
        "총 예산 ₩\(formatNumber(entry.total))"
    }
    
    private var progressRatio: Double {
        guard entry.total > 0 else { return 0.0 }
        return max(0.0, min(1.0, Double(entry.remaining) / Double(entry.total)))
    }
    
    private var statusMessage: String {
        switch status {
        case .comfortable: return "오늘도 잘 하고 있어요"
        case .tight:       return "조금만 더 아껴볼까요?"
        case .exceeded:    return "예산을 초과했어요"
        }
    }
    
    var body: some View {
        let content = VStack(alignment: .leading, spacing: 0) {
            
            // ── 상단 행: 총 예산 + 스트릭 배지 ─────────────────────────
            HStack {
                Text(totalText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(colors.secondaryText)
                
                Spacer()
                
                // 🔥 스트릭 배지
                HStack(spacing: 3) {
                    Text("🔥")
                        .font(.system(size: 11))
                    Text("\(entry.streak)일째")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(colors.primaryText)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colors.accentBg)
                )
            }
            
            // 구분선
            Divider()
                .padding(.vertical, 8)
            
            // ── 하단: 남은 예산 | 사용한 예산 (좌우 분할) ────────────
            HStack(alignment: .center, spacing: 0) {
                // 좌측: 남은 예산
                VStack(alignment: .leading, spacing: 4) {
                    Text("남은 예산")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(colors.secondaryText)
                    
                    Text(remainingText)
                        .font(.system(size: WidgetColorPalette.mediumRemainingFontSize(for: status), weight: .bold))
                        .foregroundColor(colors.primaryText)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 세로 구분선 (텍스트와 수직 중앙 정렬)
                Divider()
                    .frame(height: 40)
                    .padding(.horizontal, 12)
                
                // 우측: 사용한 예산
                VStack(alignment: .leading, spacing: 4) {
                    Text("사용한 예산")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(colors.secondaryText)

                    Text(usedText)
                        .font(.system(size: WidgetColorPalette.mediumUsedFontSize(for: status), weight: .bold))
                        .foregroundColor(colors.primaryText)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(catImageName(for: entry.catMood))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .padding(.leading, 8)
            }

            Spacer()

            // 프로그레스 바
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(colors.accentBg)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(colors.primaryText)
                        .frame(width: geometry.size.width * CGFloat(progressRatio))
                }
            }
            .frame(height: 6)

            Spacer().frame(height: 6)

            Text(statusMessage)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(colors.secondaryText)
                .lineLimit(1)
        }

        if #available(iOS 17.0, *) {
            content.containerBackground(for: .widget) { colors.background }
        } else {
            content.padding(16).background(colors.background)
        }
    }
}


// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Widget Entry View (Large 4×4)
// 이미지 레이아웃:
//  ┌──────────────────────────────────────┐
//  │ 총 예산 ₩10,000            🔥 12일  │
//  │ 남은 예산       │  사용한 예산       │
//  │ ₩5,200 (큰글씨) │  ₩4,800           │
//  │──────────────────────────────────────│
//  │ 오늘의 지출                     2건  │
//  │ ☕ 점심     12:30           -3,500   │
//  │ ☕ 아메리카노 15:15          -1,300   │
//  └──────────────────────────────────────┘
// ─────────────────────────────────────────────────────────────────────────────
struct DailyHomeLargeView: View {
    var entry: Provider.Entry
    
    private var status: BudgetStatus { BudgetStatus(remaining: entry.remaining) }
    private var colors: WidgetColorPalette { WidgetColorPalette.palette(for: status) }
    
    private var remainingText: String {
        let abs = abs(entry.remaining)
        let formatted = formatNumber(abs)
        return entry.remaining < 0 ? "-₩\(formatted)" : "₩\(formatted)"
    }
    
    private var usedText: String {
        "₩\(formatNumber(entry.used))"
    }
    
    private var totalText: String {
        "총 예산 ₩\(formatNumber(entry.total))"
    }
    
    /// 표시할 지출 목록 (최대 4건)
    private var displayExpenses: [ExpenseItem] {
        Array(entry.expenses.prefix(4))
    }
    
    var body: some View {
        let content = VStack(alignment: .leading, spacing: 0) {
            
            // ── 상단: 총 예산 + 스트릭 배지 ──────────────────────────
            HStack {
                Text(totalText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(colors.secondaryText)
                
                Spacer()
                
                HStack(spacing: 3) {
                    Text("🔥")
                        .font(.system(size: 11))
                    Text("\(entry.streak)일째")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(colors.primaryText)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colors.accentBg)
                )
            }
            
            Spacer().frame(height: 8)
            
            // ── 중간: 남은 예산 | 사용한 예산 (좌우 분할, 중앙 정렬) ──
            HStack(alignment: .center, spacing: 0) {
                // 좌측: 남은 예산
                VStack(alignment: .leading, spacing: 4) {
                    Text("남은 예산")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(colors.secondaryText)
                    
                    Text(remainingText)
                        .font(.system(size: WidgetColorPalette.largeRemainingFontSize(for: status), weight: .bold))
                        .foregroundColor(colors.primaryText)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 우측: 사용한 예산
                VStack(alignment: .leading, spacing: 4) {
                    Text("사용한 예산")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(colors.secondaryText)
                    
                    Text(usedText)
                        .font(.system(size: WidgetColorPalette.largeUsedFontSize(for: status), weight: .bold))
                        .foregroundColor(colors.primaryText)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // ── 구분선 ──────────────────────────────────────────────
            Divider()
                .padding(.vertical, 10)
            
            // ── 오늘의 지출 헤더 ─────────────────────────────────────
            HStack {
                Text("오늘의 지출")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(colors.secondaryText)
                
                Spacer()
                
                Text("\(entry.expenses.count)건")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(colors.secondaryText)
            }
            
            Spacer().frame(height: 8)
            
            // ── 지출 목록 ────────────────────────────────────────────
            if displayExpenses.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text("아직 지출이 없어요")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(colors.secondaryText.opacity(0.6))
                    Spacer()
                }
                Spacer()
            } else {
                VStack(spacing: 6) {
                    ForEach(displayExpenses) { expense in
                        ExpenseRowView(
                            expense: expense,
                            colors: colors
                        )
                    }
                    
                    // 4건 초과 시 "외 N건 더보기" 표시
                    if entry.expenses.count > 4 {
                        HStack {
                            Spacer()
                            Text("외 \(entry.expenses.count - 4)건 더보기")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(colors.secondaryText.opacity(0.7))
                            Spacer()
                        }
                        .padding(.top, 4)
                    }
                }
                Spacer()
            }
        }
        
        if #available(iOS 17.0, *) {
            content.containerBackground(for: .widget) { colors.background }
        } else {
            content.padding(16).background(colors.background)
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - 지출 항목 행 (Large 위젯용)
// ─────────────────────────────────────────────────────────────────────────────
struct ExpenseRowView: View {
    let expense: ExpenseItem
    let colors: WidgetColorPalette
    
    var body: some View {
        HStack(spacing: 8) {
            // 아이콘
            Text(expense.icon)
                .font(.system(size: 16))
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(colors.accentBg)
                )
            
            // 카테고리 + 시간
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.category)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(colors.primaryText)
                
                Text(expense.time)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(colors.secondaryText)
            }
            
            Spacer()
            
            // 금액 (음수 표시)
            Text("-\(formatNumber(expense.amount))")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(colors.primaryText)
        }
        .padding(.vertical, 4)
    }
}


// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Helper
// ─────────────────────────────────────────────────────────────────────────────

/// cat_mood 문자열로 Asset 이미지 이름을 반환한다
private func catImageName(for mood: String) -> String {
    switch mood {
    case "comfortable": return "CatComfortable"
    case "normal":      return "CatNormal"
    case "danger":      return "CatDanger"
    case "over":        return "CatOver"
    default:            return "CatComfortable"
    }
}

private func formatNumber(_ number: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Widget Configuration
// ─────────────────────────────────────────────────────────────────────────────
struct DailyHomeWidget: Widget {
    let kind: String = "DailyHomeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyHomeWidgetRouter(entry: entry)
        }
        .configurationDisplayName("하루 만원")
        .description("오늘의 잔여 예산을 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Widget Router (사이즈별 뷰 분기)
// ─────────────────────────────────────────────────────────────────────────────
struct DailyHomeWidgetRouter: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    
    var body: some View {
        switch widgetFamily {
        case .systemMedium:
            DailyHomeMediumView(entry: entry)
        case .systemLarge:
            DailyHomeLargeView(entry: entry)
        default:
            DailyHomeSmallView(entry: entry)
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Preview (Small)
// ─────────────────────────────────────────────────────────────────────────────
#Preview(as: .systemSmall) {
    DailyHomeWidget()
} timeline: {
    SimpleEntry(date: Date(), total: 10000, used: 3000, remaining: 7000, streak: 12, expenses: [], catMood: "comfortable")
    SimpleEntry(date: Date(), total: 10000, used: 7000, remaining: 3000, streak: 7, expenses: [], catMood: "normal")
    SimpleEntry(date: Date(), total: 10000, used: 12000, remaining: -2000, streak: 0, expenses: [], catMood: "over")
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Preview (Medium)
// ─────────────────────────────────────────────────────────────────────────────
#Preview(as: .systemMedium) {
    DailyHomeWidget()
} timeline: {
    SimpleEntry(date: Date(), total: 10000, used: 2800, remaining: 7200, streak: 12, expenses: [], catMood: "comfortable")
    SimpleEntry(date: Date(), total: 10000, used: 7200, remaining: 2800, streak: 7, expenses: [], catMood: "normal")
    SimpleEntry(date: Date(), total: 10000, used: 13000, remaining: -3000, streak: 0, expenses: [], catMood: "over")
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Preview (Large - 여유)
// ─────────────────────────────────────────────────────────────────────────────
#Preview(as: .systemLarge) {
    DailyHomeWidget()
} timeline: {
    SimpleEntry(
        date: Date(), total: 10000, used: 4800, remaining: 5200, streak: 12,
        expenses: [
            ExpenseItem(category: "점심", time: "12:30", amount: 3500),
            ExpenseItem(category: "아메리카노", time: "15:15", amount: 1300),
        ],
        catMood: "comfortable"
    )
    SimpleEntry(
        date: Date(), total: 10000, used: 11500, remaining: -1500, streak: 0,
        expenses: [
            ExpenseItem(category: "점심", time: "12:30", amount: 8500),
            ExpenseItem(category: "카페", time: "15:15", amount: 2800),
            ExpenseItem(category: "카페", time: "15:15", amount: 3800),
            ExpenseItem(category: "카페", time: "15:15", amount: 4800),
            ExpenseItem(category: "카페", time: "15:15", amount: 5800),
            ExpenseItem(category: "간식", time: "17:40", amount: 2200),
        ],
        catMood: "over"
    )
}
