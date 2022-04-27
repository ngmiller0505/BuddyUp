//
//  EmailPasswordResetPage.swift
//  PODZ
//
//  Created by Nick Miller on 1/6/21.
//  Copyright © 2021 Nick Miller. All rights reserved.
//

import SwiftUI
import Firebase


struct EmailPasswordResetPage: View {
    
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @State var email = ""
    @State var emailResetSent = false
    @Binding var activeSheet: ActiveSheet?
    @State var searchResultMessage: String = ""
    
    
    var body: some View {
        VStack{
            


            TextField("Email", text: $email).textFieldStyle(RoundedBorderTextFieldStyle()).padding()
            

            
            Button(action: {
                passwordReset(email: email) { (res) in
                    if res == "There is no user record corresponding to this identifier. The user may have been deleted." {
                        
                        searchResultMessage = "No email found. Please ensure you entered the email correctly and try again. If you see this error message again, please try a different email, or consider making a new account."
                    } else {
                        searchResultMessage = res
                    }
                     
                    emailResetSent = true
                }
        
            }, label: {
                Text("Send Password Reset Email").foregroundColor(.black).padding().background(Color.gray.opacity(0.5)).cornerRadius(5)
            })
            
            if emailResetSent {
                
                Text(searchResultMessage).foregroundColor(.black).font(.subheadline).padding().frame(alignment: .center)
            }
        
        }
    }
}


func passwordReset(email: String, completion: @escaping (String) -> ()) {
    Auth.auth().sendPasswordReset(withEmail: email) { err in
        if err != nil {
            print(err.debugDescription)
            completion(err!.localizedDescription)
            print(err!.localizedDescription)
        }
        else {
            print("Reset Email Successfully Sent")
            completion("Reset Email Successfully Sent")
        }
    }
}

struct EmailPasswordResetPage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EmailPasswordResetPage(activeSheet: .constant(.passwordReset))
        }
    }
}
