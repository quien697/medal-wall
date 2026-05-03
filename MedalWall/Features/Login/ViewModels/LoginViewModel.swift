//
//  LoginViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-05-01.
//

import Foundation
import CryptoKit
import AuthenticationServices

@Observable
final class LoginViewModel {
  private let authService = AuthService()
  private var currentNonce: String?
  var isLoading = false
  var error: AppError?
  
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
    case .failure:
      self.error = .signInFailed
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
}
