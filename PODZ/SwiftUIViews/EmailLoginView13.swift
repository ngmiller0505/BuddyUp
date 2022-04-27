//
//  EmailLoginView13.swift
//  
//
//  Created by Nick Miller on 11/5/20.
//

import SwiftUI
import FirebaseAuth

struct EmailLoginView13: View {
        @State var email = ""
        @State var password = ""
        @State var errorMessage = ""
        @State var showActionSheet = false
        @State var actionSheet: ActionSheet?
        @State var AlertIsPresented = false
        @State var loading = false
        @Binding var isPresented: Bool
        
        @EnvironmentObject var currentUserFirebase: UserWrapper
    


        var body: some View {
            VStack{
                TextField("Email", text: self.$email).textFieldStyle(RoundedBorderTextFieldStyle()).padding(5)
                SecureField("Password", text: self.$password).textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(5)
                Button(action: {
                    print("signing into existing acocunt")
                    Auth.auth().signIn(withEmail: email, password: password) { (authResult, err2) in
                        if err2 != nil {
                            
                            self.errorMessage = (err2?.localizedDescription)!
                            print("______________error with auth_________")
                            print((err2?.localizedDescription)!)
                            
                            //TODO Customize error messages
                            self.actionSheet = ActionSheet(
                                    title: Text("Error").foregroundColor(.red),
                                    message: Text("Could not log in").foregroundColor(.red),
                                    buttons: [
                                        .cancel()
                                    ]
                                )
                            self.showActionSheet.toggle()
                        } else {
                            self.isPresented.toggle()

                            print("status of page toggle: ", isPresented)
                        }
                    }
                        
                }
                ){

                    Text("Sign In")
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)

                }
                .foregroundColor(.black)
                .padding(.top)
                .padding(.bottom)
                .background(Color.gray)
                .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
                .padding(.leading)
                .padding(.trailing)
                .disabled(loading)
                
                Spacer()
                
            }.actionSheet(isPresented: $showActionSheet, content: {self.actionSheet!})
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
        }
        

        
}

struct EmailLoginView13_Previews: PreviewProvider {
    static var previews: some View {
        EmailLoginView13(isPresented: .constant(true))
    }
}
