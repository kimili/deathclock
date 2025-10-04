//
//  Item.swift
//  Death Clock
//
//  Created by Michael Bester on 7/16/25.
//

import Foundation
import SwiftData

@Model
final class UserSettings {
  var birthDate: Date
  var lifeExpectancyYears: Int
  var lifeExpectancyMonths: Int
  var lifeExpectancyWeeks: Int
  
  // Cache expensive calculations
  private var _cachedWeeksLived: Int?
  private var _lastCalculationDate: Date?
  private var _cachedTotalLifeExpectancy: Int?
  
  init(
    birthDate: Date = Date(),
    lifeExpectancyYears: Int = 75,
    lifeExpectancyMonths: Int = 0,
    lifeExpectancyWeeks: Int = 0
  ) {
    self.birthDate = birthDate
    self.lifeExpectancyYears = lifeExpectancyYears
    self.lifeExpectancyMonths = lifeExpectancyMonths
    self.lifeExpectancyWeeks = lifeExpectancyWeeks
  }
  
  var totalLifeExpectancyInWeeks: Int {
    // Cache total life expectancy since it only changes when settings change
    if let cached = _cachedTotalLifeExpectancy {
      return cached
    }
    
    let totalYears = lifeExpectancyYears
    let totalMonths = lifeExpectancyMonths
    let totalWeeks = lifeExpectancyWeeks
    
    let result = (totalYears * 52) + Int(Double(totalMonths) * 4.33) + totalWeeks
    _cachedTotalLifeExpectancy = result
    return result
  }
  
  var weeksLived: Int {
    let now = Date()
    
    // Cache weeks lived calculation - only recalculate if more than an hour has passed
    if let lastCalc = _lastCalculationDate,
       let cached = _cachedWeeksLived,
       now.timeIntervalSince(lastCalc) < 3600 { // 1 hour
      return cached
    }
    
    let calendar = Calendar.current
    let components = calendar.dateComponents([.weekOfYear], from: birthDate, to: now)
    let result = max(0, components.weekOfYear ?? 0)
    
    _cachedWeeksLived = result
    _lastCalculationDate = now
    
    return result
  }
  
  var weeksRemaining: Int {
    return max(0, totalLifeExpectancyInWeeks - weeksLived)
  }
  
  // Cache invalidation methods
  func invalidateCache() {
    _cachedTotalLifeExpectancy = nil
    _cachedWeeksLived = nil
    _lastCalculationDate = nil
  }
}
