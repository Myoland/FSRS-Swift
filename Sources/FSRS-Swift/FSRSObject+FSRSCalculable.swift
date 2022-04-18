//
//  FSRS.swift
//  
//  自由间隔重复调度算法
//  SuperMemo-17 Algorithm Implement
//
// Created by 尼诺 on 2022/4/9.

import Foundation

extension Int {
    static func +(lhs: Self, rhs: Double) -> Double {
        return Double(lhs) + rhs
    }
    
    static func -(lhs: Self, rhs: Double) -> Double {
        return Double(lhs) - rhs
    }
    
    static func *(lhs: Self, rhs: Double) -> Double {
        return Double(lhs) * rhs
    }
    
    static func /(lhs: Self, rhs: Double) -> Double {
        return Double(lhs) / rhs
    }
}

extension Double {
    static func +(lhs: Self, rhs: Int) -> Double {
        return lhs + Double(rhs)
    }
    
    static func -(lhs: Self, rhs: Int) -> Double {
        return lhs - Double(rhs)
    }
    
    static func *(lhs: Self, rhs: Int) -> Double {
        return lhs * Double(rhs)
    }
    
    static func /(lhs: Self, rhs: Int) -> Double {
        return lhs / Double(rhs)
    }
}

public protocol FSRSCalculable: FSRSAble {
    func saveToHistory() -> Bool
}

public extension FSRSCalculable {
    init(hyperParam: FSRSUserParam) {
        let addDay: Int = Int((Double(hyperParam.defaultStability) * log10(hyperParam.requestRetention) / log10(0.9)).rounded())
        self.init()
        self.due = Date(timeIntervalSinceNow: addDay * OneDayTimeInterval)
        self.interval = 0
        self.difficulty = hyperParam.defaultDifficulty
        self.stability = hyperParam.defaultStability
        self.retrievability = 1
        self.grade = .notRewiewed
        self.review = Date()
        self.reps = 1
        self.lapses = 0
    }

    // fsrs 实现
    mutating func fsrs<A>(now: Date = Date(), grade: CardReviewGrade, hyperParam: A) -> A where A: FSRSUserParam {
        
        var param = hyperParam
        
        let _ = self.saveToHistory()
        let now = now
        
        let lastDifficult = self.difficulty
        let lastStability = self.stability
        let lastLapses = self.lapses
        let lastReps = self.reps
        let lastReview = self.review
        
        // Start SM-17
        let reviewDayInterval = Int(( now.timeIntervalSince1970 - lastReview.timeIntervalSince1970) / OneDayTimeInterval)
        self.review = now
        self.interval = reviewDayInterval > 0 ? reviewDayInterval : 0
        self.grade = grade
        
        // use memery loss function
        self.retrievability = exp(log10(0.9) * self.interval / lastStability)
        
        // Adaptive difficulty. Notice $difficulty \in (1, 10)$
        // TODO: use cut-off function
        self.difficulty = min(max(lastDifficult + self.retrievability - grade.value + 0.2, 1), 10)
        
        if grade == .forget {
            
            if lastLapses != 0 {
                param.totalDiff = param.totalDiff - self.retrievability
            }
            
            self.lapses = lastLapses + 1
            self.reps = 1
            
            self.stability = param.defaultStability * exp(-0.3 * (lastLapses + 1))
            
        } else if grade == .normal || grade == .proficient {
            // grade == .normal or .proficient

            if lastLapses != 0 {
                param.totalDiff = param.totalDiff + (1 - self.retrievability)
            }
            
            self.lapses = lastLapses
            self.reps = lastLapses + 1
            
            self.stability = self.update_stability(
                difficulty: self.difficulty,
                stability: lastStability,
                retrievability: self.retrievability,
                increase_factor: param.increaseFactor,
                difficulty_decay: param.difficultyDecay,
                stability_decay: param.stabilityDecay
            )
        }
        
        
        param.totalCase = param.totalCase + 1
        param.totalReview = param.totalReview + 1;
        
        let addDay = Int((self.stability * log(hyperParam.requestRetention) / log(0.9)).rounded())
        self.due = now + addDay * OneDayTimeInterval
        
        if param.totalCase > 100 {
            
            let t = max(log(param.requestRetention + param.totalDiff / param.totalCase), 0)
            let d =
                1 / pow(Double(param.totalReview), 0.3)
                * pow(
                    log(param.requestRetention) / t,
                    1 / param.difficultyDecay
                )
                * 5
            param.defaultDifficulty = d + (1 - 1 / pow(Double(param.totalReview), 0.3)) * param.defaultDifficulty
        
            param.totalCase = 0
            param.totalDiff = 0
        }
        
        if lastReps == 1 && lastLapses == 0 {
            param.stabilityDataArry.append(
                UserRetrievabilityHistory(
                    interval: self.interval,
                    retrievability: self.retrievability
                )
            )
            
            // TODO: use async method to update S.
            // Adaptive defaultStability
            if param.stabilityDataArry.count > 0 && param.stabilityDataArry.count % 50 == 0 {
                param.defaultStability = self.cal_stability_p_default(history: param.stabilityDataArry, oldStability: param.defaultStability)
            }
        }
        
        return param
    }
    
    // TODO: May it be possible to use iterated algorithm and store last result to speed up calculator.
    func cal_stability_p_default(history: [UserRetrievabilityHistory], oldStability: Double) -> Double {
        
        var sumRI2S: Double = 0.0
        var sumI2S: Double = 0.0
        
        let ivlSet = Set(history.map {$0.interval})
        for ivl in ivlSet {
            let ivlFiltered = history.filter { $0.interval == ivl}
            let retrievabilitySum = ivlFiltered.map({$0.retrievability}).reduce(0.0) { res, new in
                res + new
            }
            let retrievabilityMean = retrievabilitySum / ivlFiltered.count
            
            sumRI2S += ivl * log(retrievabilityMean) * ivlFiltered.count
            sumI2S = sumI2S +  ivl * ivl * ivlFiltered.count
        }
        let newS = max(0.1, log(0.9) / (sumRI2S / sumI2S))
        return (newS + oldStability) / 2
    }
    
    func update_stability(difficulty: Double, stability: Double, retrievability: Double, increase_factor: Double, difficulty_decay: Double, stability_decay: Double) -> Double {
        return stability * (1 + increase_factor * pow(difficulty, difficulty_decay) * pow(stability, stability_decay) * (exp(1 - retrievability) - 1))
    }
    
    func cal_stability(difficulty: Double) -> Double {
        return log(0.9) / log(0.95 + 0.005 * (10 - difficulty))
    }
    
}
