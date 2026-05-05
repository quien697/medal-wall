//
//  LoginViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-05-01.
//

import Foundation
import Network
import CryptoKit
import AuthenticationServices
import FirebaseCore
import GoogleSignIn

@Observable
final class LoginViewModel {
  // MARK: - Properties
  private let authService = AuthService()
  private var currentNonce: String?
  var isLoading = false
  var error: AppError?
  var email = ""
  var isEmailLinkSent = false
  
  // MARK: - Computed
  var isEmailValid: Bool {
    let parts = email.split(separator: "@")
    return parts.count == 2 && parts[1].contains(".")
  }
  
  // MARK: - Functions
  
  func isConnected() async -> Bool {
    await withCheckedContinuation { continuation in
      let monitor = NWPathMonitor()
      monitor.pathUpdateHandler = { path in
        monitor.cancel()
        continuation.resume(returning: path.status == .satisfied)
      }
      monitor.start(queue: .global())
    }
  }
  
  /// Sends a Firebase sign-in link to the given email address.
  func sendEmailLink() async {
    isLoading = true
    defer { isLoading = false }
    
    do {
      try await authService.sendSignInLink(to: email)
      UserDefaults.standard.set(email, forKey: AuthService.pendingEmailSignInKey)
      isEmailLinkSent = true
    } catch {
      self.error = .sendEmailSignInLinkFailed(error.localizedDescription)
    }
  }
  
  /// Resets email link flow state; call on sheet dismiss.
  func resetEmailFlow() {
    email = ""
    isEmailLinkSent = false
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
    
    let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
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
  
  /// Configures the Apple Sign In request with a hashed nonce and requested scopes.
  /// Call this from `SignInWithAppleButton`'s `onRequest` closure.
  func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
    do {
      let nonce = try randomNonceString()
      currentNonce = nonce
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)
    } catch {
      self.error = error
    }
  }
  
  /// Handles the result from Apple's authentication sheet and signs in to Firebase.
  /// Call this from `SignInWithAppleButton`'s `onCompletion` closure.
  func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) async {
    switch result {
    case .success(let authorization):
      guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
        self.error = .invalidCredential
        return
      }
      guard let nonce = currentNonce else {
        self.error = .missingNonce
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
      
      isLoading = true
      defer { isLoading = false }
      
      do {
        try await authService.signInWithApple(idTokenString: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
      } catch {
        self.error = .signInFailed
      }
    case .failure(let error):
      if let authError = error as? ASAuthorizationError,
         authError.code == .canceled || authError.code == .unknown {
        return
      }
      self.error = .signInFailed
    }
  }
  
  /// Presents the Google Sign-In sheet and signs the user in to Firebase.
  func signInWithGoogle() async {
    isLoading = true
    defer { isLoading = false }
    
    guard let clientID = FirebaseApp.app()?.options.clientID else {
      self.error = .signInFailed
      return
    }
    
    GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
    
    guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
          let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
      self.error = .signInFailed
      return
    }
    
    do {
      let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
      guard let idToken = result.user.idToken?.tokenString else {
        self.error = .missingIdentityToken
        return
      }
      
      let accessToken = result.user.accessToken.tokenString
      try await authService.signInWithGoogle(idToken: idToken, accessToken: accessToken)
    } catch {
      if (error as NSError).code == GIDSignInError.Code.canceled.rawValue {
        return
      }
      self.error = .signInFailed
    }
  }
}
