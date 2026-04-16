//
//  OpenAddExpenseIntent.swift
//  DailyHomeWidget
//

import AppIntents
import WidgetKit

/// 위젯 "+" 버튼 탭 시 앱을 열고 지출 입력 화면을 트리거하는 AppIntent.
/// openAppWhenRun = true → 앱이 포어그라운드로 전환된다.
/// UserDefaults(App Group)에 pendingAction 플래그를 기록하고,
/// 앱이 활성화되면 HomeScreen이 showExpenseAddBottomSheet를 호출한다.
@available(iOS 17.0, *)
struct OpenAddExpenseIntent: AppIntent {
    static var title: LocalizedStringResource = "지출 직접 입력"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: WidgetConstants.appGroup)
        defaults?.set("open_add_expense", forKey: WidgetConstants.pendingActionKey)
        defaults?.synchronize()
        return .result()
    }
}
