//
//  GoogleSignInDelegate.swift
//  PODZ
//
//  Created by Nick Miller on 10/3/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import Foundation
import GoogleSignIn
import FirebaseAuth
import Firebase

//
//class GoogleDelegate: NSObject, ObservableObject {
//    
//    @Published var signedIn: Bool = false
//    
//    func performGoogleAccountLink() {
//        
//    guard let clientID = FirebaseApp.app()?.options.clientID else { return }
//
//    // Create Google Sign In configuration object.
//    let config = GIDConfiguration(clientID: clientID)
//        
//    GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
//
//      guard error == nil else { return displayError(error) }
//
//      guard
//        let authentication = user?.authentication,
//        let idToken = authentication.idToken
//      else {
//        let error = NSError(
//          domain: "GIDSignInError",
//          code: -1,
//          userInfo: [
//            NSLocalizedDescriptionKey: "Unexpected sign in result: required authentication data is missing.",
//          ]
//        )
//        return displayError(error)
//      }
//
//      let credential = GoogleAuthProvider.credential(withIDToken: idToken,
//                                                     accessToken: authentication.accessToken)
//
//      Auth.auth().signIn(with: credential) { result, error in
//        guard error == nil else { return self.displayError(error) }
//
//        // At this point, our user is signed in
//        // so we advance to the User View Controller
//        self.transitionToUserViewController()
//      }
//    }
//    }
    
    
    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if let error = error {
//            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
//                print("The user has not signed in before or they have since signed out.")
//            } else {
//                print("____________________________")
//                print("____________________________")
//                print("\(error.localizedDescription)")
//                print("____________________________")
//                print("____________________________")
//            }
//            return
//        }
//        // If the previous `error` is null, then the sign-in was succesful
//
//        print("Successful sign-in!")
//
//        guard let authentication = user.authentication else { return }
//        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
//                                                          accessToken: authentication.accessToken)
//
//        Auth.auth().signIn(with: credential) { (res, err) in
//            if err != nil {
//                print("______________error with auth_________")
//                print((err?.localizedDescription)!)
//                print("______________error with auth_________")
//                return
//            }        else {
//                self.signedIn = true
//            }
//
//        }
//
//    }
    


    
//}

//class GoogleDelegate: NSObject, GIDSignInDelegate, ObservableObject {
//
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if let error = error {
//            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
//                print("The user has not signed in before or they have since signed out.")
//            } else {
//                print("____________________________")
//                print("____________________________")
//                print("\(error.localizedDescription)")
//                print("____________________________")
//                print("____________________________")
//            }
//            return
//        }
//        // If the previous `error` is null, then the sign-in was succesful
//
//        print("Successful sign-in!")
//
//        guard let authentication = user.authentication else { return }
//        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
//                                                          accessToken: authentication.accessToken)
//
//        Auth.auth().signIn(with: credential) { (res, err) in
//            if err != nil {
//                print("______________error with auth_________")
//                print((err?.localizedDescription)!)
//                print("______________error with auth_________")
//                return
//            }        else {
//                self.signedIn = true
//            }
//
//        }
//
//    }
//
//    @Published var signedIn: Bool = false
//
//
//}
