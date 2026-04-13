//
//  AddFavoriteExpenseIntent.swift
//  DailyHomeWidget
//

import AppIntents
import WidgetKit

/// 위젯 즐겨찾기 버튼 탭 시 호출되는 AppIntent.
/// openAppWhenRun = false → 앱 포그라운드 전환 없이 백그라운드에서 실행.
/// UserDefaults(App Group)에 pending 항목을 기록하면 Flutter 앱이
/// 다음 실행 시(또는 홈 위젯 backgroundCallback을 통해) 처리한다.
@available(iOS 17.0, *)
struct AddFavoriteExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "즐겨찾기 지출 추가"
    static var openAppWhenRun: Bool = false

    @Parameter(title: "즐겨찾기 ID")
    var favoriteId: Int

    @Parameter(title: "금액")
    var amount: Int

    @Parameter(title: "카테고리")
    var category: Int

    @Parameter(title: "메모")
    var memo: String

    init() {
        self.favoriteId = 0
        self.amount = 0
        self.category = 0
        self.memo = ""
    }

    init(favoriteId: Int, amount: Int, category: Int, memo: String) {
        self.favoriteId = favoriteId
        self.amount = amount
        self.category = category
        self.memo = memo
    }

    func perform() async throws -> some IntentResult {
        let appGroup = "group.seong.dailyManwon.homeWidget"

        // URL scheme 문자열을 App Group UserDefaults에 pending 키로 저장.
        // Flutter backgroundCallback(Task 4)이 이 값을 읽어 지출을 처리한다.
        let urlString = "addFavoriteExpense://add?amount=\(amount)&category=\(category)&favoriteId=\(favoriteId)&memo=\(memo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        let defaults = UserDefaults(suiteName: appGroup)
        defaults?.set(urlString, forKey: "widget.pendingExpenseUrl")
        defaults?.synchronize()

        // 위젯 타임라인 갱신 — 잔액 반영
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
