//
//  FBLogin.swift
//  Modules
//
//  Created by Lam Le V. on 12/5/19.
//  Copyright © 2019 Lam Le V. All rights reserved.
//

import Foundation
import FacebookLogin
import Firebase
import FBSDKLoginKit

final class FBLogin {

    enum Action<T> {
        case success(T)
        case failure(Error)
        case cancelled
    }

    typealias Completion = (Action<String>) -> Void

    private var viewController: UIViewController
    private var completion: Completion

    init(viewController: UIViewController, completion: @escaping Completion) {
        self.viewController = viewController
        self.completion = completion
        self.getFBUserData()
    }

    func request() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [], viewController: viewController) { [weak self] loginResult in
            switch loginResult {
            case .failed(let error):
                self?.completion(.failure(error))
            case .cancelled:
                self?.completion(.cancelled)
            case .success:
                self?.getFBUserData()
            }
        }
    }

    private func getFBUserData(){
        if let tokenString = AccessToken.current?.tokenString {
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { [weak self] (connection, result, error) -> Void in
                if let error = error {
                    self?.completion(.failure(error))
                    return
                }
                let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
                Auth.auth().signIn(with: credential) { (result, error) in
                    if let error = error {
                        self?.completion(.failure(error))
                        return
                    }
                    if let result = result {
                        self?.completion(.success(result.user.uid))
                    }
                }
            })
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
