//
//  StorageServiceTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-13.
//

import Foundation
import Testing

@testable import MedalWall

/// Covers the order an upload's steps run in, which is decided in Swift rather than by
/// Firebase Storage: a file stored without a download URL must be deleted, since no caller
/// ever learns where it is.
struct StorageServiceTests {

  private let retryLimitExceeded = NSError(domain: "FIRStorageErrorDomain", code: -13030)
  private let unknownError = NSError(domain: "FIRStorageErrorDomain", code: -13000)

  @Test("an upload stores the file, then returns its URL")
  func testUploadReturnsURL() async throws {
    let storedURL = try #require(URL(string: "https://example.com/cover.jpg"))
    var steps: [String] = []

    let url = try await StorageService.storeThenFetchURL(
      put: { steps.append("put") },
      downloadURL: {
        steps.append("downloadURL")
        return storedURL
      },
      delete: { steps.append("delete") }
    )

    #expect(url == storedURL)
    #expect(steps == ["put", "downloadURL"])
  }

  @Test("a file stored without a URL is deleted, and the URL's error is the one thrown")
  func testFailedURLDeletesStoredFile() async {
    var steps: [String] = []

    await #expect(throws: retryLimitExceeded) {
      try await StorageService.storeThenFetchURL(
        put: { steps.append("put") },
        downloadURL: {
          steps.append("downloadURL")
          throw retryLimitExceeded
        },
        delete: {
          steps.append("delete")
          throw unknownError
        }
      )
    }

    #expect(steps == ["put", "downloadURL", "delete"])
  }
}
