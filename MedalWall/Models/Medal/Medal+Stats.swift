//
//  Medal+Stats.swift
//  MedalWall
//
//  Created by Quien on 2026-05-28.
//

import Foundation

extension Array where Element == Medal {
  var fullCount: Int { filter { $0.distance.category == .full }.count }
  var halfCount: Int { filter { $0.distance.category == .half }.count }

  var bestFullTime: TimeInterval? {
    filter { $0.distance.category == .full }.compactMap { $0.finishTime }.min()
  }

  var bestHalfTime: TimeInterval? {
    filter { $0.distance.category == .half }.compactMap { $0.finishTime }.min()
  }
}
