//
//  File.swift
//  
//
//  Created by 尼诺 on 2022/4/10.
//

import Foundation

public struct UserRetrievabilityHistory: Codable {
    public var interval: Int
    public var retrievability: Double
}

public protocol FSRSUserParam {
    var difficultyDecay: Double { get set }
    var stabilityDecay: Double { get set }
    var increaseFactor: Double { get set }
    var requestRetention: Double { get set }
    var totalCase: Int { get set }
    var totalDiff: Double { get set }
    var totalReview: Int { get set }
    var defaultDifficulty: Double { get set }
    var defaultStability: Double { get set }
    var stabilityDataArry: [UserRetrievabilityHistory] { get set }
}

public struct FSRSUserParamDefault: FSRSUserParam {
    public var difficultyDecay = -0.7
    public var stabilityDecay = -0.2
    public var increaseFactor = 60.0
    public var requestRetention = 0.9
    public var totalCase = 0
    public var totalDiff = 0.0
    public var totalReview = 0
    public var defaultDifficulty = 5.0
    public var defaultStability = 2.0
    public var stabilityDataArry: [UserRetrievabilityHistory] = []
}
