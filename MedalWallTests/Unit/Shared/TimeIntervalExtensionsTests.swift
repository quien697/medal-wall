//
//  TimeIntervalExtensionsTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-15.
//

import Foundation
import Testing

@testable import MedalWall

struct TimeIntervalExtensionsTests {

  // MARK: - formattedHMS
  @Test("formattedHMS pads the hour to two digits")
  func testFormattedHMSPadsHour() {
    #expect(TimeInterval(18608).formattedHMS == "05:10:08")
  }

  @Test("formattedHMS counts hours past 24 rather than wrapping")
  func testFormattedHMSDoesNotWrapPastOneDay() {
    // A 30h12m finish is an ordinary result for a 100-mile race. Wrapping would
    // render it as 06:12:00 and silently rob the run of a day.
    #expect(TimeInterval(108_720).formattedHMS == "30:12:00")
  }

  @Test("formattedHMS rounds fractional seconds rather than truncating")
  func testFormattedHMSRoundsFractionalSeconds() {
    // Firestore stores the finish time as a Double, so a stopwatch-derived value
    // arrives with a fraction. 1:01:01.7 rounds up, it does not truncate to :01.
    #expect(TimeInterval(3661.7).formattedHMS == "01:01:02")
  }
}
