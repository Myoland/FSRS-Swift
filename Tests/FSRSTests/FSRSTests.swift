//
//  File.swift
//  
//
//  Created by 尼诺 on 2022/4/10.
//

import XCTest
import Foundation
@testable import FSRS_Swift

final class FSRSTests: XCTestCase {
   
    struct FSRSParam: FSRSUserParam, CustomStringConvertible{
        var difficultyDecay: Double
        var stabilityDecay: Double
        var increaseFactor: Double
        var requestRetention: Double
        var totalCase: Int
        var totalDiff: Double
        var totalReview: Int
        var defaultDifficulty: Double
        var defaultStability: Double
        var stabilityDataArry: [UserRetrievabilityHistory]
        
        var description:String {
            return "{ difficultyDecay: \(difficultyDecay) stabilityDecay: \(stabilityDecay) increaseFactor: \(increaseFactor) requestRetention: \(requestRetention) totalCase: \(totalCase) totalDiff: \(totalDiff) totalReview: \(totalReview) defaultDifficulty: \(defaultDifficulty) defaultStability: \(defaultStability) stabilityDataArry: \(stabilityDataArry) }"
        }
        
        init() {
            self.init(parmDefalut: FSRSUserParamDefault())
        }
        
        init(parmDefalut: FSRSUserParamDefault) {
            self.difficultyDecay = parmDefalut.difficultyDecay
            self.stabilityDecay = parmDefalut.stabilityDecay
            self.increaseFactor = parmDefalut.increaseFactor
            self.requestRetention = parmDefalut.requestRetention
            self.totalCase = parmDefalut.totalCase
            self.totalDiff = parmDefalut.totalDiff
            self.totalReview = parmDefalut.totalReview
            self.defaultDifficulty = parmDefalut.defaultDifficulty
            self.defaultStability = parmDefalut.defaultStability
            self.stabilityDataArry = parmDefalut.stabilityDataArry
        }
    }
    
    class CardTest: FSRSCalculable, CustomStringConvertible {
       
        var id: UUID = UUID()
        var due: Date
        var interval: Int
        var difficulty: Double
        var stability: Double
        var retrievability: Double
        var grade: CardReviewGrade
        var review: Date
        var reps: Int
        var lapses: Int
        var history: [FSRSAble]
        
        required init() {
            self.due = Date()
            self.interval = 0
            self.difficulty = 0.0
            self.stability = 0.0
            self.retrievability = 0.0
            self.grade = .notRewiewed
            self.review = Date()
            self.reps = 0
            self.lapses = 0
            self.history = []
        }
        
        required convenience init(param: FSRSUserParam, history: [FSRSAble]) {
            self.init(hyperParam: param)
            self.history = history
        }
        
        func saveToHistory() -> Bool {
            // self.history.append(self)
            return true
        }
        
        var description: String {
            return "id: \(id) due: \(due) interval: \(interval) difficulty: \(difficulty) stability: \(stability) retrievability: \(retrievability) grade: \(grade) review: \(review) reps: \(reps) lapses: \(lapses)"
            // For CSV Output
            // return "\(id), \(due), \(interval), \(difficulty), \(stability), \(retrievability), \(grade), \(review), \(reps), \(lapses)"
        }
    }
    
    func testCardCreate() throws {
        let _ = CardTest(param: FSRSUserParamDefault(), history: [])
    }
    
    func testAlgorithmOnce() throws {
        var param = FSRSParam()
        var card = CardTest(param: param, history: [])
        
        param = card.fsrs(grade: .proficient, hyperParam: param)
    }
    
    func testFSRS() throws {
        let learnPerDay = 100
        
        var userParam: FSRSParam = FSRSParam()
        
        var cardArray: [CardTest] = []
        
        for day in 0...100 {
            
            let now = Date(timeIntervalSinceNow: day * OneDayTimeInterval)
            
            let reviewCard = cardArray.filter({ card in
                return card.due <= now
            }).sorted { a, b in
                // a.retrievability < b.retrievability
                a.due < b.due
            }
            
            let reviewCardCount = min(reviewCard.count, learnPerDay)
            let newLearnCardCount = learnPerDay - reviewCardCount
            
            for idx in 0 ..< reviewCardCount {
                var card = reviewCard[idx]
                let grade = CardReviewGrade(intValue: Int.random(in: 0...2))
                userParam = card.fsrs(now: now, grade: grade!, hyperParam: userParam)
            }

            for _ in 0..<newLearnCardCount {
                let card = CardTest(param: userParam, history: [])
                cardArray.append(card)
            }
        }
    }
    
    
    func testFSRSBenchmark() throws {
        
        var userParam: FSRSParam = FSRSParam()
        var card = CardTest(param: userParam, history: []);
        
        measure {
            let days = 10000
            
            for _ in 1...days {
                userParam = card.fsrs(grade: .proficient, hyperParam: userParam)
            }
        }
    }
    
    // TODO: extract update method and support tests.
    func testUpdateS() throws {
        
    }
}

