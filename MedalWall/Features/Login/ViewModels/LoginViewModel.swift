//
//  LoginViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-05-01.
//

import AuthenticationServices
import CryptoKit
import Foundation

enum ActiveSignIn {
  case apple, google
}

/// `@MainActor` spelled out: the app target already defaults to it, but this file is also compiled
/// into the test module, which doesn't, and its Apple and Google flows touch UIKit.
@MainActor
@Observable
final class LoginViewModel {
  // MARK: - Data
  var email = ""

  // MARK: - State
  var activeSignIn: ActiveSignIn?
  var isSendingEmail = false
  var isEmailLinkSent = false
  var isPresentingEmailSignIn = false
  var error: AppError?
  /// An error shown over the email sheet while it is open: from sending the link, or from a
  /// link opened from Mail meanwhile.
  var emailSheetError: AppError?
  /// Counts the email sheet's closings, so a send still running when the sheet closed
  /// cannot change what the sheet shows the next time it opens.
  private var emailSheetClosings = 0

  // MARK: - Dependencies
  /// Signs in with Apple and Google.
  private let authService = FirebaseAuthService()
  /// Sends email sign-in links.
  private let emailAuthService: any AuthService
  private let networkMonitor: any NetworkMonitor
  private let defaults: UserDefaults

  // MARK: - Init
  init(
    emailAuthService: (any AuthService)? = nil,
    networkMonitor: (any NetworkMonitor)? = nil,
    defaults: UserDefaults = .standard
  ) {
    self.emailAuthService = emailAuthService ?? FirebaseAuthService()
    self.networkMonitor = networkMonitor ?? NWPathNetworkMonitor()
    self.defaults = defaults
  }

  // MARK: - Computed
  var isEmailValid: Bool {
    let parts = trimmedEmail.split(separator: "@", omittingEmptySubsequences: false)
    return parts.count == 2 && !parts[0].isEmpty && parts[1].contains(".")
  }

  private var trimmedEmail: String { email.trimmingCharacters(in: .whitespacesAndNewlines) }

  var isSigningIn: Bool {
    activeSignIn != nil
  }

  /// The foreground scene's key window, which the Apple and Google sign-in sheets present over.
  private var keyWindow: UIWindow? {
    let windowScene =
      UIApplication.shared.connectedScenes.first(where: {
        $0.activationState == .foregroundActive
      }) as? UIWindowScene
    return windowScene?.windows.first(where: { $0.isKeyWindow })
  }

  // MARK: - Functions -> Sign in with Email link
  /// Shows the email sign-in sheet if the device is online, otherwise surfaces a connection error.
  func signInWithEmailLink() async {
    if await networkMonitor.isConnected() {
      isPresentingEmailSignIn = true
    } else {
      error = .noInternetConnection
    }
  }

  /// Sends a Firebase sign-in link to the entered address, trimmed of surrounding whitespace.
  /// Fails at once when offline, and reports any failure in `emailSheetError`, so it shows over
  /// the sheet the user is still on. Once sent, the field holds the address the link went to.
  /// A send that outlives its sheet still saves that address, so the link works, but leaves
  /// the next opening alone, its Send button included. A second tap while a send is running
  /// is ignored, so one tap sends one email.
  func sendEmailLink() async {
    guard !isSendingEmail else { return }
    isSendingEmail = true
    let address = trimmedEmail
    let closingsAtStart = emailSheetClosings
    defer { if emailSheetClosings == closingsAtStart { isSendingEmail = false } }

    guard await networkMonitor.isConnected() else {
      if emailSheetClosings == closingsAtStart { emailSheetError = .noInternetConnection }
      return
    }
    do {
      try await emailAuthService.sendSignInLink(to: address)
      defaults.set(address, forKey: FirebaseAuthService.pendingEmailSignInKey)
      if emailSheetClosings == closingsAtStart {
        email = address
        isEmailLinkSent = true
      }
    } catch {
      if emailSheetClosings == closingsAtStart {
        emailSheetError = .sendEmailSignInLinkFailed(error.localizedDescription)
      }
    }
  }

  /// Shows a sign-in failure from outside the login buttons — an email link opened from Mail.
  /// It goes over the email sheet while that is open, since the login screen cannot present
  /// anything until the sheet closes; otherwise it goes on the login screen.
  func showSignInError(_ signInError: AppError) {
    if isPresentingEmailSignIn {
      emailSheetError = signInError
    } else {
      error = signInError
    }
  }

  /// Resets email link flow state, call on sheet dismiss.
  func resetEmailFlow() {
    email = ""
    isEmailLinkSent = false
    emailSheetError = nil
    isSendingEmail = false
    emailSheetClosings += 1
  }

  // MARK: - Functions -> Sign in with Apple
  /// Presents the Apple Sign-In sheet and signs the user in to Firebase.
  func signInWithApple() async {
    guard let keyWindow else {
      self.error = .signInFailed
      return
    }

    do {
      let nonce = try randomNonceString()
      let request = ASAuthorizationAppleIDProvider().createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let delegate = AppleSignInDelegate(anchor: keyWindow)
      let controller = ASAuthorizationController(authorizationRequests: [request])
      controller.delegate = delegate
      controller.presentationContextProvider = delegate
      controller.performRequests()

      let authorization = try await delegate.waitForAuthorization()

      guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
      else {
        self.error = .invalidCredential
        return
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        self.error = .missingIdentityToken
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        self.error = .tokenSerializationFailed(appleIDToken.debugDescription)
        return
      }

      activeSignIn = .apple
      defer { activeSignIn = nil }

      try await authService.signInWithApple(
        idTokenString: idTokenString,
        rawNonce: nonce,
        fullName: appleIDCredential.fullName
      )
    } catch {
      guard let authError = error as? ASAuthorizationError else {
        self.error = .signInFailed
        return
      }

      switch authError.code {
      case .canceled, .unknown:
        break
      default:
        self.error = .signInFailed
      }
    }
  }

  /// Generates a cryptographically secure random nonce string using `SecRandomCopyBytes`.
  /// The nonce is sent with the sign-in request so Apple can tie the ID token back to
  /// this specific request, preventing replay attacks.
  private func randomNonceString(length: Int = 32) throws(AppError) -> String {
    precondition(length > 0)
    var randomBytes = [UInt8](repeating: 0, count: length)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    guard errorCode == errSecSuccess else {
      throw AppError.nonceFailed("\(errorCode)")
    }

    let charset: [Character] = Array(
      "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    let nonce = randomBytes.map { byte in
      // Pick a random character from the set, wrapping around if needed.
      charset[Int(byte) % charset.count]
    }

    return String(nonce)
  }

  /// Returns the SHA256 hash of the given string as a hex-encoded string.
  /// The hashed nonce is sent to Apple; Firebase then re-hashes the original
  /// and compares both values to verify the response is untampered.
  private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
      String(format: "%02x", $0)
    }.joined()
    return hashString
  }

  // MARK: - Functions -> Sign in with Google
  /// Presents the Google Sign-In sheet and signs the user in to Firebase.
  func signInWithGoogle() async {
    guard let rootViewController = keyWindow?.rootViewController else {
      self.error = .signInFailed
      return
    }

    do {
      let tokens = try await authService.requestGoogleTokens(presenting: rootViewController)

      activeSignIn = .google
      defer { activeSignIn = nil }

      try await authService.signInWithGoogle(
        idToken: tokens.idToken,
        accessToken: tokens.accessToken
      )
    } catch is CancellationError {
      // The user closed Google's sheet; there is nothing to report.
    } catch let error as AppError {
      self.error = error
    } catch {
      self.error = .signInFailed
    }
  }
}
