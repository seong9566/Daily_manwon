//
//  AddFavoriteExpenseIntent.swift
//  DailyHomeWidget
//

import AppIntents
import WidgetKit

/// 위젯 즐겨찾기 버튼 탭 시 호출되는 AppIntent.
/// openAppWhenRun = false -> 앱 포그라운드 전환 없이 실행.
/// UserDefaults(App Group)에 pending URL을 기록하고,
/// 앱이 foreground로 전환될 때 HomeWidget.widgetClicked 스트림이 URL을 전달한다.
@available(iOS 17.0, *)
struct AddFavoriteExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "즐겨찾기 지출 추가"
    static var openAppWhenRun: Bool = false

    @Parameter(title: "즐겨찾기 ID")
    var favoriteId: Int

    @Parameter(title: "금액")
    var amount: Int

    /// 카테고리 인덱스 (0=식비, 1=교통, 2=카페, 3=쇼핑, 4=기타)
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
        // URL scheme 조립 (& = + # 제거한 문자셋으로 메모 인코딩)
        var valueAllowed = CharacterSet.urlQueryAllowed
        valueAllowed.remove(charactersIn: "&=+#")
        let encodedMemo = memo.addingPercentEncoding(withAllowedCharacters: valueAllowed) ?? ""
        let urlString = "addFavoriteExpense://add?amount=\(amount)&category=\(category)&favoriteId=\(favoriteId)&memo=\(encodedMemo)"

        // UserDefaults(App Group)에 pending URL 저장
        // 앱을 열면 HomeWidget.widgetClicked 스트림으로 전달되어 widgetBackgroundCallback이 실행됨
        let defaults = UserDefaults(suiteName: WidgetConstants.appGroup)
        defaults?.set(urlString, forKey: WidgetConstants.pendingExpenseKey)
        defaults?.synchronize()

        // 위젯 타임라인 갱신
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
