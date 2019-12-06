//
//  TWLogin.swift
//  Modules
//
//  Created by Lam Le V. on 12/5/19.
//  Copyright © 2019 Lam Le V. All rights reserved.
//

import UIKit
import Firebase

final class TWLogin {

    let provider: OAuthProvider
    private let completion: Completion<String>

    init(completion: @escaping Completion<String>) {
        provider = OAuthProvider(providerID: "twitter.com")
        self.completion = completion
    }

    // User is signed in.
    // IdP data available in authResult.additionalUserInfo.profile.
    // Twitter OAuth access token can also be retrieved by:
    // authResult.credential.accessToken
    // Twitter OAuth ID token can be retrieved by calling:
    // authResult.credential.idToken
    // Twitter OAuth secret can be retrieved by calling:
    // authResult.credential.secret
    func request() {
        provider.getCredentialWith(nil) { [weak self] credential, error in
            if let error = error {
                self?.completion(.failure(error))
                return
            }
            if let credential = credential {
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let error = error {
                        self?.completion(.failure(error))
                        return
                    }
                    if let userID = authResult?.user.uid {
                        self?.completion(.success(userID))
                        return
                    }
                }
            }
        }
    }

    static func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}
