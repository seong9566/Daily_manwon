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
// MARK: - 상태별 색상 팔레트
// ─────────────────────────────────────────────────────────────────────────────
struct WidgetColorPalette {
    let background: Color
    let primaryText: Color    // 금액, 제목
    let secondaryText: Color  // 라벨, 설명
    let accentBg: Color       // 스트릭 배지 등
    
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
    
    /// Small 위젯 금액 폰트 크기 — 상태별 차등
    static func amountFontSize(for status: BudgetStatus) -> CGFloat {
        switch status {
        case .comfortable: return 36
        case .tight:       return 30
        case .exceeded:    return 24
        }
    }
}


// @escaping : 함수가 끝난 뒤에도 실행 될 수 있는 클로저, getSnapshot안에서 바로 completion을 호출 할 수 있지만
// 비동기로 데이터를 읽고 나중에 호출할 수 있기 때문 ex) 파일,DB,네트워크 받은 후 실행
struct Provider: TimelineProvider {
    
    // 위젯 데이터가 아직 준비 되지 않았을때 보여질 임시 화면
    // 로딩 화면과 동일 함.
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), total: 10000, used: 0, remaining: 10000)
    }

    
    // 위젯 추가 시 보이는 화면
    // 정적인 미리보기 위젯을 만들어줌.
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        // SimplEntry로 임시 데이터를 만듬
        let entry = SimpleEntry(date: Date(), total: 10000, used: 3000, remaining: 7000)
        
        // completion으로 만든 entry를 넘긴다
        // completion이란?
        // 결과를 나중에 전달 해줄 callback 함수 역할 을 함
        // ex) completion은 미리보기 데이터 준비 되면 나에게 넘겨줘라는 역할을 함
        completion(entry)
    }

    // 위젯 추가 후 홈 화면에 표시될 때 실행 되는 함수
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
       
        
        // 1. 위젯과 앱과 공유할 수 있는 브릿지 선언
        let userDefault = UserDefaults(suiteName: "group.dailyManWon.dailyHomeWidget")
        
        // 2. Flutter에서 가져온 문자열 Key
        let total = userDefault?.integer(forKey: "totalKey") ?? 0
        let used = userDefault?.integer(forKey: "usedKey") ?? 0
        let remaining = userDefault?.integer(forKey: "remainingKey") ?? 0

        
        // 3. 현재 시간을 가지고 옴.
        let currentDate = Date()
        
        // 4. 전달할 Entry생성
        let entry = SimpleEntry(
                    date: currentDate,
                    total: total,
                    used: used,
                    remaining: remaining
                )

        
        // 5. List배열에 entry 추가
        let timeline = Timeline(entries: [entry], policy: .atEnd)
            
        // 6. 최종 데이터를 전달
        completion(timeline)
    }

}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Timeline Entry
// date는 필수 파라미터
// ─────────────────────────────────────────────────────────────────────────────
struct SimpleEntry: TimelineEntry {
    let date:Date
    let total:Int // 총 금액
    let used:Int // 사용한 금액
    let remaining:Int // 남은 금액
}


// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Widget Entry View (Small)
// ─────────────────────────────────────────────────────────────────────────────
struct DailyHomeWidgetEntryView: View {
    var entry: Provider.Entry
    
    // 상태 판별
    private var status: BudgetStatus {
        BudgetStatus(remaining: entry.remaining)
    }
    
    // 색상 팔레트
    private var colors: WidgetColorPalette {
        WidgetColorPalette.palette(for: status)
    }
    
    // 금액 폰트 크기 (상태별 차등)
    private var amountFontSize: CGFloat {
        WidgetColorPalette.amountFontSize(for: status)
    }
    
    // 금액 텍스트 포맷
    private var amountText: String {
        let absValue = abs(entry.remaining)
        let formatted = formatNumber(absValue)
        return entry.remaining < 0 ? "-₩\(formatted)" : "₩\(formatted)"
    }
    
    // 프로그레스 비율
    private var progressRatio: Double {
        guard entry.total > 0 else { return 0.0 }
        return max(0.0, min(1.0, Double(entry.remaining) / Double(entry.total)))
    }
    
    // 상태별 메시지
    private var statusMessage: String {
        switch status {
        case .comfortable: return "오늘도 잘 하고 있어요"
        case .tight:       return "조금만 더 아껴볼까요?"
        case .exceeded:    return "예산을 초과했어요"
        }
    }
    
    // ── View Body ────────────────────────────────────────────────────────────
        var body: some View {
            let content = VStack(alignment: .leading, spacing: 0) {
                
                // 상단: "남은 예산" 라벨 — secondaryText
                Text("남은 예산")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(colors.secondaryText)
                
                Spacer()
                
                // 중앙: 금액 — primaryText, 상태별 폰트 크기
                HStack {
                    Spacer()
                    Text(amountText)
                        .font(.system(size: amountFontSize, weight: .bold))
                        .foregroundColor(colors.primaryText)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Spacer()
                }
                
                // 초과 시 "초과!" 라벨 추가
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
                
                // 하단: 프로그레스 바 — accentBg 트랙 + primaryText 게이지
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
                
                // 하단: 상태 메시지 — secondaryText
                Text(statusMessage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(colors.secondaryText)
                    .lineLimit(1)
            }
            
            // iOS 17 분기 처리
            if #available(iOS 17.0, *) {
                content
                    .containerBackground(for: .widget) {
                        colors.background
                    }
            } else {
                content
                    .padding(16)
                    .background(colors.background)
            }
        }
    }


// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Helper
// ─────────────────────────────────────────────────────────────────────────────

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
            DailyHomeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("하루 만원")
        .description("오늘의 잔여 예산을 확인하세요")
        .supportedFamilies([.systemSmall])
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Preview
// ─────────────────────────────────────────────────────────────────────────────
#Preview(as: .systemSmall) {
    DailyHomeWidget()
} timeline: {
    SimpleEntry(date: Date(), total: 10000, used: 3000, remaining: 7000)  // 여유
    SimpleEntry(date: Date(), total: 10000, used: 7000, remaining: 3000)  // 빠듯
    SimpleEntry(date: Date(), total: 10000, used: 12000, remaining: -2000) // 초과
}
