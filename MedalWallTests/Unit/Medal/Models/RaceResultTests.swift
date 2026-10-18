//
//  RaceResultTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-17.
//

import Foundation
import Testing

@testable import MedalWall

struct RaceResultTests {

  // MARK: - Support
  /// Decodes a `RaceResult` from a JSON object literal.
  private static func decode(_ json: String) throws -> RaceResult {
    try JSONDecoder().decode(RaceResult.self, from: Data(json.utf8))
  }

  // MARK: - Encoding
  @Test("A finish time encodes as its seconds and the seconds unit")
  func testEncodedFields() throws {
    let data = try JSONEncoder().encode(RaceResult.seconds(13500))
    let fields = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]

    #expect(fields["value"] as? Double == 13500)
    #expect(fields["unit"] as? String == "seconds")
    #expect(fields.count == 2)
  }

  // MARK: - Decoding
  @Test("A stored finish time decodes as seconds")
  func testDecodeSeconds() throws {
    let result = try Self.decode(#"{"value": 13500, "unit": "seconds"}"#)

    #expect(result == .seconds(13500))
  }

  @Test("A result in a unit other than seconds does not decode")
  func testDecodeUnknownUnit() {
    #expect(throws: (any Error).self) {
      try Self.decode(#"{"value": 174.2, "unit": "kilometers"}"#)
    }
  }

  @Test("A result with no unit does not decode")
  func testDecodeMissingUnit() {
    #expect(throws: (any Error).self) {
      try Self.decode(#"{"value": 13500}"#)
    }
  }
}
