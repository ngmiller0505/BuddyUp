//
//  SignInView.swift
//  PODZ
//
//  Created by Nick Miller on 10/6/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import SwiftUI
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn
import FirebaseAuth


struct SignInView: View {

    
    @Binding var emailTabViewPresented: Bool
    @Binding var activeSheet: ActiveSheet?
    @EnvironmentObject var currentUserWrapper: UserWrapper
    
    var body: some View {
        

        NavigationView {
            
            VStack(spacing: 10) {
                
                LogoAndTextView()
//                VStack{
//                    Color.purple.frame(maxHeight: 3)
//                    Text("Sign In or Create Account").fontWeight(.bold).foregroundColor(.purple).multilineTextAlignment(.center)
//                    Color.purple.frame(maxHeight: 3)
//
//                }
                
                EmailButton(activeSheet: $activeSheet)
                CustomFacebookSignInButton()
                GoogleSignInButton().padding(.bottom)
            }

            
        }
    }
}



struct GoogleSignInButton: View {
    @EnvironmentObject var currentUserWrapper: UserWrapper
    
    var body: some View {
        Button(action: {
            //currentUserWrapper.startedToLoadUser = true

            googleSignIn()
            
        }) {
            HStack{
                Image("Google clip 2").resizable().scaledToFit().padding(.leading, 5).padding(.trailing).padding(.bottom).padding(.top)
                Spacer()
                Text("Google").bold().foregroundColor(.white).padding(.leading, -33)//.padding(.leading, 20)
                Spacer()
            }
            .frame(height: 52)
            .background(Color.red)
            .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
            .padding(.leading)
            .padding(.trailing)

            
        }
    }
    func googleSignIn() {
            
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
            
        GIDSignIn.sharedInstance.signIn(with: config, presenting: (UIApplication.shared.windows.first?.rootViewController)!) { user, error in

            guard error == nil else {
                
                
                    print("_____________________________")
                    print("_____________________________")

                    print("boo custom")
                    print(error?.localizedDescription ?? "no localized desciption")
                    currentUserWrapper.startedToLoadUser = false
                    print(error ?? "error with no description")
                    print("_____________________________")

                    print("_____________________________")

                    return
                }
          guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
          else {
            let error = NSError(
              domain: "GIDSignInError",
              code: -1,
              userInfo: [
                NSLocalizedDescriptionKey: "Unexpected sign in result: required authentication data is missing.",
              ]
            )
            print(error.localizedDescription)
//            return displayError(error)
            return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: authentication.accessToken)

          Auth.auth().signIn(with: credential) { result, error in
            if error != nil {
                print("______________error with Auth.auth()______")
                print((error?.localizedDescription)!)
                print("______________error with Auth.auth()________")
                currentUserWrapper.startedToLoadUser = false
                return
            } else {
                currentUserWrapper.startedToLoadUser = true

            }
          }
        }
    }
}


struct CustomFacebookSignInButton: View {
    @EnvironmentObject var currentUserWrapper: UserWrapper

    var body: some View {
        Button(action: {
            LoginManager().logIn(permissions: ["public_profile", "email"], from: nil) { (result, err) in
                
                if err == nil
                
                {
                    print("ya custtom")
                    print(result.debugDescription)
                    print(AccessToken.current.debugDescription)
                    if AccessToken.current != nil {
                        
                        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                        
                        Auth.auth().signIn(with: credential) { (res, err) in
                            if err != nil {
                                print("______________error with auth_________")
                                print((err?.localizedDescription)!)
                                print("______________error with auth_________")
                                currentUserWrapper.startedToLoadUser = false
                                return
                            } else {
                                currentUserWrapper.startedToLoadUser = true

                            }
                        }
                    }
                    
                    
                    
                }
                else
                {
                    print("_____________________________")
                    print("_____________________________")

                    print("boo custom")
                    print(err?.localizedDescription ?? "no localized desciption")
                    currentUserWrapper.startedToLoadUser = false
                    print(err ?? "error with no description")
                    print("_____________________________")

                    print("_____________________________")

                    return
                }
            }
            
        }){
            HStack{
                Image("Facebook Clipart").resizable().scaledToFit().padding(.trailing).padding(.bottom).padding(.top)
                Spacer()
                Text("Facebook").bold().foregroundColor(.white).padding(.leading, -18)//.padding(.leading, 20)
                Spacer()
            }
            .frame(height: 52)
            .background(Color.blue)
            .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
            .padding(.leading)
            .padding(.trailing)

        }
    }

}

struct LogoView: View {
    
    var body: some View {
        
        VStack {
        
            Color.white
                
            
        }
        .edgesIgnoringSafeArea(.all)

//        Image("logo-transparent")
//            .resizable()
//            .aspectRatio(contentMode: .fill)
//
//            //.scaledToFit()
//
//            .frame(width: UIScreen.main.bounds.width - 5, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//            .offset(y: 48)
//            .clipped()
//            .frame(width: UIScreen.main.bounds.width - 2, height: UIScreen.main.bounds.height * 1/3, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }

}
struct LogoAndTextView: View {
    var body: some View {
        VStack {
        Image("logo-transparent")
            .resizable()
            .aspectRatio(contentMode: .fill)
            
            //.scaledToFit()

            .frame(width: UIScreen.main.bounds.width - 2, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .offset(y: 45)
            .clipped()
        Image("logo-transparent")
            .resizable()
            .aspectRatio(contentMode: .fill)
            
            //.scaledToFit()

            .frame(width: UIScreen.main.bounds.width - 2, height: 110, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .offset(y: -110)
            .clipped()
        }
            
    }
}

struct EmailButton: View {
    
    @Binding var activeSheet: ActiveSheet?
    
    var body: some View {
        
        Button(action: {
            activeSheet = .email
        }){
            HStack{
                Text("Email")
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
            }
        }
        .foregroundColor(.black)
        .padding(.top)
        .padding(.bottom)
        .background(Color.gray)
        .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
        .padding(.leading)
        .padding(.trailing)
        
        
    }
}
    



struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(emailTabViewPresented: .constant(false), activeSheet: .constant(ActiveSheet.email))
        LogoView()
        LogoAndTextView()
        
        
        
    }
}









//struct FacebookButton: UIViewRepresentable {
//
//
//    func makeCoordinator() -> Coordinator {
//
//        return FacebookButton.Coordinator()
//    }
//
//
//    func makeUIView(context: UIViewRepresentableContext<FacebookButton>) -> FBLoginButton {
//        let loginButton = FBLoginButton()
//        loginButton.delegate = context.coordinator
//        loginButton.permissions = ["public_profile", "email"]
//        return loginButton
//    }
//
//    func updateUIView(_ uiView: FBLoginButton, context: UIViewRepresentableContext<FacebookButton>) {
//
//    }
//
//    class Coordinator : NSObject, LoginButtonDelegate {
//
//        @State var loggedIn = false
//
//        func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
//
//            if error != nil {
//                print((error?.localizedDescription)!)
//                return
//            }
//
//            print(AccessToken.current.debugDescription)
//            if AccessToken.current != nil {
//
//                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
//
//                Auth.auth().signIn(with: credential) { (res, err) in
//                    if err != nil {
//                        print("______________error with auth_________")
//                        print((err?.localizedDescription)!)
//                        print("______________error with auth_________")
//                        return
//                    }
//                }
//            }
//        }
//
//        func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
//
//        }
//    }
//}

