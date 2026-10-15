//
//  LoginViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-07.
//

import Foundation
import Testing

@testable import MedalWall

@MainActor
struct LoginViewModelTests {

  private let email = "runner@example.com"

  // MARK: - Support
  /// A private defaults suite with no email saved.
  private func makeDefaults(function: String = #function) throws -> UserDefaults {
    let suiteName = "LoginViewModelTests.\(function).\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defaults.removePersistentDomain(forName: suiteName)
    return defaults
  }

  // MARK: - Opening the email sheet
  @Test("continuing with email offline shows no connection and keeps the sheet closed")
  func testContinueOfflineKeepsSheetClosed() async throws {
    let networkMonitor = StubNetworkMonitor()
    networkMonitor.isConnectedNow = false
    let viewModel = LoginViewModel(
      emailAuthService: StubAuthService(), networkMonitor: networkMonitor,
      defaults: try makeDefaults())

    await viewModel.signInWithEmailLink()

    #expect(viewModel.error == .noInternetConnection)
    #expect(!viewModel.isPresentingEmailSignIn)
  }

  @Test("continuing with email online opens the sheet")
  func testContinueOnlineOpensSheet() async throws {
    let viewModel = LoginViewModel(
      emailAuthService: StubAuthService(), networkMonitor: StubNetworkMonitor(),
      defaults: try makeDefaults())

    await viewModel.signInWithEmailLink()

    #expect(viewModel.isPresentingEmailSignIn)
    #expect(viewModel.error == nil)
  }

  // MARK: - Sending the email link
  @Test("sending offline shows no connection on the sheet and sends nothing")
  func testSendOfflineIsRefused() async throws {
    let authService = StubAuthService()
    let networkMonitor = StubNetworkMonitor()
    networkMonitor.isConnectedNow = false
    let defaults = try makeDefaults()
    let viewModel = LoginViewModel(
      emailAuthService: authService, networkMonitor: networkMonitor, defaults: defaults)
    viewModel.email = email

    await viewModel.sendEmailLink()

    #expect(viewModel.emailSheetError == .noInternetConnection)
    #expect(viewModel.error == nil)
    #expect(authService.sentLinkEmails.isEmpty)
    #expect(defaults.string(forKey: FirebaseAuthService.pendingEmailSignInKey) == nil)
    #expect(!viewModel.isEmailLinkSent)
  }

  @Test("a send that fails shows the error on the sheet, not the login screen")
  func testSendFailureShowsOnSheet() async throws {
    let authService = StubAuthService(sendLinkOutcome: .failure(.unknown))
    let defaults = try makeDefaults()
    let viewModel = LoginViewModel(
      emailAuthService: authService, networkMonitor: StubNetworkMonitor(), defaults: defaults)
    viewModel.email = email

    await viewModel.sendEmailLink()

    let sheetError = viewModel.emailSheetError
    guard case .sendEmailSignInLinkFailed = sheetError else {
      Issue.record("expected sendEmailSignInLinkFailed, got \(String(describing: sheetError))")
      return
    }
    #expect(viewModel.error == nil)
    #expect(defaults.string(forKey: FirebaseAuthService.pendingEmailSignInKey) == nil)
    #expect(!viewModel.isEmailLinkSent)
  }

  @Test("a send that works saves the email and shows the confirmation")
  func testSendSuccessSavesEmail() async throws {
    let authService = StubAuthService()
    let defaults = try makeDefaults()
    let viewModel = LoginViewModel(
      emailAuthService: authService, networkMonitor: StubNetworkMonitor(), defaults: defaults)
    viewModel.email = email

    await viewModel.sendEmailLink()

    #expect(authService.sentLinkEmails == [email])
    #expect(defaults.string(forKey: FirebaseAuthService.pendingEmailSignInKey) == email)
    #expect(viewModel.isEmailLinkSent)
    #expect(viewModel.emailSheetError == nil)
  }

  @Test("an email typed with spaces and a line break is sent and saved trimmed")
  func testSendTrimsEmail() async throws {
    let authService = StubAuthService()
    let defaults = try makeDefaults()
    let viewModel = LoginViewModel(
      emailAuthService: authService, networkMonitor: StubNetworkMonitor(), defaults: defaults)
    viewModel.email = "  \(email) \n"

    await viewModel.sendEmailLink()

    #expect(authService.sentLinkEmails == [email])
    #expect(defaults.string(forKey: FirebaseAuthService.pendingEmailSignInKey) == email)
  }

  @Test("an address with only a space before the @ is not valid")
  func testBlankLocalPartIsInvalid() throws {
    let viewModel = LoginViewModel(
      emailAuthService: StubAuthService(), networkMonitor: StubNetworkMonitor(),
      defaults: try makeDefaults())

    viewModel.email = " @example.com"

    #expect(!viewModel.isEmailValid)
  }

  @Test("closing the sheet mid-send saves the address the link went to and nothing else")
  func testClosingSheetMidSendKeepsSentAddress() async throws {
    let authService = StubAuthService()
    let defaults = try makeDefaults()
    let viewModel = LoginViewModel(
      emailAuthService: authService, networkMonitor: StubNetworkMonitor(), defaults: defaults)
    viewModel.email = email
    authService.whileSendingLink = { viewModel.resetEmailFlow() }

    await viewModel.sendEmailLink()

    #expect(defaults.string(forKey: FirebaseAuthService.pendingEmailSignInKey) == email)
    #expect(!viewModel.isEmailLinkSent)
  }

  @Test("a send that fails after the sheet closed leaves no error for its next opening")
  func testSendFailingAfterSheetClosedShowsNothing() async throws {
    let authService = StubAuthService(sendLinkOutcome: .failure(.unknown))
    let viewModel = LoginViewModel(
      emailAuthService: authService, networkMonitor: StubNetworkMonitor(),
      defaults: try makeDefaults())
    viewModel.email = email
    authService.whileSendingLink = { viewModel.resetEmailFlow() }

    await viewModel.sendEmailLink()

    #expect(viewModel.emailSheetError == nil)
  }

  @Test("a plain address is valid")
  func testPlainAddressIsValid() throws {
    let viewModel = LoginViewModel(
      emailAuthService: StubAuthService(), networkMonitor: StubNetworkMonitor(),
      defaults: try makeDefaults())

    viewModel.email = email

    #expect(viewModel.isEmailValid)
  }

  @Test(
    "an address with an extra @ is not valid",
    arguments: ["runner@@example.com", "runner@example.com@", "@runner@example.com"])
  func testExtraAtSignIsInvalid(address: String) throws {
    let viewModel = LoginViewModel(
      emailAuthService: StubAuthService(), networkMonitor: StubNetworkMonitor(),
      defaults: try makeDefaults())

    viewModel.email = address

    #expect(!viewModel.isEmailValid)
  }

  @Test("after a send works, the field holds the address the link went to")
  func testSendShowsTrimmedAddress() async throws {
    let viewModel = LoginViewModel(
      emailAuthService: StubAuthService(), networkMonitor: StubNetworkMonitor(),
      defaults: try makeDefaults())
    viewModel.email = "  \(email) \n"

    await viewModel.sendEmailLink()

    #expect(viewModel.email == email)
  }

  @Test("closing the sheet mid-send leaves the next opening's Send button ready")
  func testClosingSheetMidSendClearsSpinner() async throws {
    let authService = StubAuthService()
    let viewModel = LoginViewModel(
      emailAuthService: authService, networkMonitor: StubNetworkMonitor(),
      defaults: try makeDefaults())
    viewModel.email = email
    authService.whileSendingLink = {
      viewModel.resetEmailFlow()
      #expect(!viewModel.isSendingEmail)
    }

    await viewModel.sendEmailLink()
  }

  @Test("a send that outlives its sheet leaves the next sheet's own send spinning")
  func testOldSendKeepsNewSendSpinner() async throws {
    let authService = StubAuthService()
    let viewModel = LoginViewModel(
      emailAuthService: authService, networkMonitor: StubNetworkMonitor(),
      defaults: try makeDefaults())
    viewModel.email = email
    authService.whileSendingLink = {
      viewModel.resetEmailFlow()
      // The reopened sheet starts its own send before the old one finishes.
      viewModel.isSendingEmail = true
    }

    await viewModel.sendEmailLink()

    #expect(viewModel.isSendingEmail)
  }

  // MARK: - Sign-in link errors
  @Test("a sign-in link error while the email sheet is open shows on the sheet")
  func testSignInErrorWithSheetOpenShowsOnSheet() throws {
    let viewModel = LoginViewModel(
      emailAuthService: StubAuthService(), networkMonitor: StubNetworkMonitor(),
      defaults: try makeDefaults())
    viewModel.isPresentingEmailSignIn = true

    viewModel.showSignInError(.emailLinkSignInFailed)

    #expect(viewModel.emailSheetError == .emailLinkSignInFailed)
    #expect(viewModel.error == nil)
  }

  @Test("a sign-in link error with the email sheet closed shows on the login screen")
  func testSignInErrorWithSheetClosedShowsOnLoginScreen() throws {
    let viewModel = LoginViewModel(
      emailAuthService: StubAuthService(), networkMonitor: StubNetworkMonitor(),
      defaults: try makeDefaults())

    viewModel.showSignInError(.emailLinkFromAnotherDevice)

    #expect(viewModel.error == .emailLinkFromAnotherDevice)
    #expect(viewModel.emailSheetError == nil)
  }

  @Test("closing the email sheet forgets an error it was still showing")
  func testClosingSheetClearsItsError() async throws {
    let networkMonitor = StubNetworkMonitor()
    networkMonitor.isConnectedNow = false
    let viewModel = LoginViewModel(
      emailAuthService: StubAuthService(), networkMonitor: networkMonitor,
      defaults: try makeDefaults())
    viewModel.email = email
    await viewModel.sendEmailLink()

    viewModel.resetEmailFlow()

    #expect(viewModel.emailSheetError == nil)
  }
}
