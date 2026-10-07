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
  /// An error from sending the link, shown over the email sheet while it is open.
  var emailSheetError: AppError?

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
    let parts = email.split(separator: "@")
    return parts.count == 2 && parts[1].contains(".")
  }

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

  /// Sends a Firebase sign-in link to the given email address. Fails at once when offline, and
  /// reports any failure in `emailSheetError`, so it shows over the sheet the user is still on.
  func sendEmailLink() async {
    isSendingEmail = true
    defer { isSendingEmail = false }

    guard await networkMonitor.isConnected() else {
      emailSheetError = .noInternetConnection
      return
    }
    do {
      try await emailAuthService.sendSignInLink(to: email)
      defaults.set(email, forKey: FirebaseAuthService.pendingEmailSignInKey)
      isEmailLinkSent = true
    } catch {
      emailSheetError = .sendEmailSignInLinkFailed(error.localizedDescription)
    }
  }

  /// Resets email link flow state, call on sheet dismiss.
  func resetEmailFlow() {
    email = ""
    isEmailLinkSent = false
    emailSheetError = nil
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
