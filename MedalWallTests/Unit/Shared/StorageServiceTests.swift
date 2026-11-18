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
/// Firebase Storage: a file stored without a download URL must get a delete attempt, since no
/// caller ever learns where it is.
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

  @Test("a file stored without a URL gets a delete attempt, and the URL's error is still thrown")
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

  // MARK: - Medal face paths
  @Test("a medal's front is stored as a JPEG with a new name in its front folder")
  func testFrontPath() throws {
    let path = StorageService.Path.medalFace(userId: "uid-a", medalId: "medal-a", face: .front)
    let prefix = "users/uid-a/medals/medal-a/front/"

    #expect(path.hasPrefix(prefix))
    #expect(path.hasSuffix(".jpg"))
    let name = path.dropFirst(prefix.count).dropLast(".jpg".count)
    #expect(UUID(uuidString: String(name)) != nil)
  }

  @Test("a medal's back is stored as a JPEG in its back folder")
  func testBackPath() {
    let path = StorageService.Path.medalFace(userId: "uid-a", medalId: "medal-a", face: .back)

    #expect(path.hasPrefix("users/uid-a/medals/medal-a/back/"))
    #expect(path.hasSuffix(".jpg"))
  }

  @Test("every face upload gets a new name, so it never overwrites a stored face")
  func testFacePathIsNewEachTime() {
    let first = StorageService.Path.medalFace(userId: "uid-a", medalId: "medal-a", face: .front)
    let second = StorageService.Path.medalFace(userId: "uid-a", medalId: "medal-a", face: .front)

    #expect(first != second)
  }
}
