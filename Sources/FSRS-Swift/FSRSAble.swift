//
//  File.swift
//  
//
//  Created by 尼诺 on 2022/4/9.
//

import Foundation

public var OneDayTimeInterval: TimeInterval = 60 * 60 * 24

/// 复习结果等级
public enum CardReviewGrade: String, Codable {
    case notRewiewed = "notRewiewed"
    case forget = "forget"
    case normal = "normal"
    case proficient = "proficient"
}

public extension CardReviewGrade {
    var value: Int {
        switch self {
        case .notRewiewed:
            return -1
        case .forget:
            return 0
        case .normal:
            return 1
        case .proficient:
            return 2
        }
    }
    
    init?(intValue:Int ) {
        switch intValue {
        case -1:
            self = CardReviewGrade.notRewiewed
        case 0:
            self = CardReviewGrade.forget
        case 1:
            self = CardReviewGrade.notRewiewed
        case 2:
            self = CardReviewGrade.proficient
        default:
            return nil
        }
    }
}

/// Card 对象
///
/// User has many Cards.
/// One Card corresponds to One word.
///
/// - Parameters:
///  - due: 下次复习时间
///  - interval: 距离上次复习的时间间隔.
///  - difficulty: [Item difficulty](https://supermemo.guru/wiki/Difficulty) (D) is defined as the maximum possible increase in memory stability (S) at review mapped linearly into 0..1 interval with 0 standing for easiest possible items, and 1 standing for highest difficulty in consideration in SuperMemo.
///  - stability: [Memory stability](https://supermemo.guru/wiki/Memory_stability) (S) is defined as the inter-repetition interval that produces average recall probability of 0.9 at review time.
///  - retrievability: [Memory retrievability](https://supermemo.guru/wiki/Retrievability) (R) is defined as the expected probability of recall at any time on the assumption of negatively exponential forgetting of homogenous learning material with the decay constant determined by memory stability (S).
///  - grade: 本次复习等级.
///  - review: 本次复习日期.
///  - reps: 复习次数.
///  - lapses: 用户复习中 ``CardReviewGrade`` 为 ``forget`` 的次数. [更多参考](https://supermemo.guru/wiki/Lapse)
public protocol FSRSAble {
    var due: Date { get set }
    var interval: Int { get set }
    var difficulty: Double { get set }
    var stability: Double { get set }
    var retrievability: Double { get set }
    var grade: CardReviewGrade { get set }
    var review: Date { get set }
    var reps: Int { get set }
    var lapses: Int { get set }
    
    init()
}
