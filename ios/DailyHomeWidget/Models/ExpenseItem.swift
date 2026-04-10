//
//  ExpenseItem.swift
//  DailyHomeWidget
//

import Foundation

// MARK: - 지출 항목 모델
struct ExpenseItem: Codable, Identifiable {
    var id: String { "\(category)_\(time)_\(amount)" }
    let category: String  // "점심", "카페", "간식", "교통", "쇼핑" 등
    let time: String      // "12:30", "15:15" 등
    let amount: Int       // 양수값 (3500)

    /// 카테고리별 에셋 파일 이름 매핑
    var categoryAssetName: String {
        switch category {
        case "점심", "저녁", "아침", "식비":
            return "CategoryFood"
        case "카페", "아메리카노", "커피":
            return "CategoryCoffee"
        case "쇼핑":
            return "CategoryShopping"
        case "교통":
            return "CategoryTransport"
        default:
            return "CategoryEtc"
        }
    }
}
