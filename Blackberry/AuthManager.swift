//
//  AuthManager.swift
//  Blackberry
//
//  Created by Emily Pullen on 2025-04-24.
//

import FirebaseAuth

class AuthManager {
    static let shared = AuthManager()

    private init() {}

    var isLoggedIn: Bool {
        Auth.auth().currentUser != nil
    }

    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    @MainActor
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    @MainActor
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    @MainActor
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}

