//
//  EmailLogInSheetView.swift
//  PODZ
//
//  Created by Nick Miller on 10/5/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import SwiftUI
import FirebaseAuth

struct EmailCreateAccountView: View {
    
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    @State var firstName = ""
    @State var lastName = ""
    @State var errorMessage = ""
    
    
    @State var showActionSheet = false
    @State var actionSheet: ActionSheet?
    
    @State var textFieldTapped = false
    @State var textFieldHeight: CGFloat = 37.5
    
    @State var viewCreateAccountLoadingSound = false
    
    @EnvironmentObject var currentUserWrapper: UserWrapper


    
    var body: some View {
        VStack {
            
            TextField("First Name", text: self.$firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle()).padding(5)
            
            
            TextField("Last Name", text: self.$lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle()).padding(5)

            TextField("Email", text: self.$email).textFieldStyle(RoundedBorderTextFieldStyle()).padding(5)
            SecureField("Enter a password", text: self.$password).textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(5)
            SecureField("Confirm Password", text: self.$confirmPassword).textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(5)
            if self.password != self.confirmPassword {
                HStack{
                    Image(systemName: "xmark.octagon.fill").foregroundColor(.red)
                    Text("Passwords do not match").foregroundColor(.red)
                }
            }
            Button(action: {
                if !email.isValidEmail() {
                    
                    errorMessage = "Please enter a valid email"
                    self.showActionSheet.toggle()
                    
                } else if firstName.count > 20 {
                    
                    errorMessage = "First name is too long"
                    self.showActionSheet.toggle()
                    
                } else if lastName.count > 20 {
                    
                    errorMessage = "Last name is too long"
                    self.showActionSheet.toggle()
                    
                } else {
                    viewCreateAccountLoadingSound = true
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if error != nil {
                            viewCreateAccountLoadingSound = false
                            print("______________error with auth_________")
                            print(error!)
                            print(error.debugDescription)
                            print((error?.localizedDescription)!)
                            print("______________error with auth_________")
                            self.errorMessage = (error?.localizedDescription)!
                            self.showActionSheet.toggle()
                            print("______________error with auth_________")
                            return
                        }
                        else {
                            
                            errorMessage = ""
                            currentUserWrapper.startedToLoadUser = true
                            print("creating email account")
                            currentUserWrapper.emailFirstName = firstName
                            currentUserWrapper.emailLastName = lastName
                            
                        }
                    }
                }
                

            }){
                VStack {
                    if viewCreateAccountLoadingSound {
                        
                        PodRowLoader()

                    } else {
                    
                        Text("Create Account")
                        .bold()

                    }
                
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .foregroundColor(.black)
                .padding(.top)
                .padding(.bottom)
                .background(Color.gray)
                .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                .padding(.leading)
                .padding(.trailing)
            }

            .disabled((password != confirmPassword || viewCreateAccountLoadingSound))
            .opacity(password != confirmPassword ? 0.5 : 1)
            
            
            Spacer()
        }.actionSheet(isPresented: $showActionSheet, content: {ActionSheet(
            title: Text("Error").foregroundColor(.red),
            message: Text(self.errorMessage).foregroundColor(.red),
            buttons: [
                .cancel()
            ]
        )})
        .onTapGesture {
            UIApplication.shared.endEditing()

        }
        .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                            .onEnded({ value in

                                if value.translation.height > 0 {
                                    UIApplication.shared.endEditing()
                                    self.textFieldTapped = false
                                    print("dismiss text field")
                                }
                            }))
        
        
    }
}

struct EmailCreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        EmailCreateAccountView()
    }
}
