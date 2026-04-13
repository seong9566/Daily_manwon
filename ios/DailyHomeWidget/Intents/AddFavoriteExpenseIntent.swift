//
//  AddFavoriteExpenseIntent.swift
//  DailyHomeWidget
//

import AppIntents
import home_widget
import WidgetKit

/// 위젯 즐겨찾기 버튼 탭 시 호출되는 AppIntent.
/// openAppWhenRun = false -> 앱 포그라운드 전환 없이 백그라운드에서 실행.
/// HomeWidgetBackgroundWorker를 통해 Flutter의 widgetBackgroundCallback으로
/// URL을 전달하여 지출을 저장한다.
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
        // URL scheme 문자열을 조립하여 Flutter 콜백에 전달한다.
        // .urlQueryAllowed 에서 쿼리 구분자(&, =, +, #)를 제거한 문자셋으로 인코딩.
        // 메모에 & 또는 = 가 포함돼도 URL 파라미터가 깨지지 않는다.
        var valueAllowed = CharacterSet.urlQueryAllowed
        valueAllowed.remove(charactersIn: "&=+#")
        let encodedMemo = memo.addingPercentEncoding(withAllowedCharacters: valueAllowed) ?? ""
        let urlString = "addFavoriteExpense://add?amount=\(amount)&category=\(category)&favoriteId=\(favoriteId)&memo=\(encodedMemo)"

        // UserDefaults에도 pending 기록 (앱 열었을 때 fallback 용도)
        let defaults = UserDefaults(suiteName: WidgetConstants.appGroup)
        defaults?.set(urlString, forKey: WidgetConstants.pendingExpenseKey)
        defaults?.synchronize()

        // HomeWidgetBackgroundWorker를 통해 Flutter 콜백 실행
        await HomeWidgetBackgroundWorker.run(
            url: URL(string: urlString),
            appGroup: WidgetConstants.appGroup
        )

        // 위젯 타임라인 갱신 — 잔액 반영
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

/// 앱이 완전히 suspend 상태일 때 포그라운드로 전환하여 실행할 수 있도록 허용.
/// 이 extension이 없으면 앱이 suspend 상태에서 백그라운드 실행이 불가능하다.
@available(iOS 17, *)
@available(iOSApplicationExtension, unavailable)
extension AddFavoriteExpenseIntent: ForegroundContinuableIntent {}
