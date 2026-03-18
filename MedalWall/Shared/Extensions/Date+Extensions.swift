//
//  Date+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2026-03-18.
//

import Foundation

extension Date {
  
  func formattedMonthDay() -> String {
    formatted(.dateTime.month().day())
  }
  
  func formattedMonthDayYear() -> String {
    formatted(.dateTime.month().day().year())
  }
}
