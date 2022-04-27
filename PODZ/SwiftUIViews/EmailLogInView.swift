//
//  EmailLogInView.swift
//  PODZ
//
//  Created by Nick Miller on 10/6/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import SwiftUI
import FirebaseAuth


@available(iOS 14.0, *)
struct EmailLogInView: View {
    @State var email = ""
    @State var password = ""
    @State var errorMessage = ""
    @State var showActionSheet = false
    @State var actionSheet: ActionSheet?
    @State var AlertIsPresented = false
    @State var loading = false
    
    @EnvironmentObject var currentUserWrapper: UserWrapper
    //@Environment(\.presentationMode) var presentationMode
    
    @Binding var activeSheet: ActiveSheet?


    var body: some View {
        VStack{
            TextField("Email", text: self.$email).textFieldStyle(RoundedBorderTextFieldStyle()).padding(5)
            SecureField("Password", text: self.$password).textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(5)
            Button(action: {
                print("signing into existing acocunt")
               

                Auth.auth().signIn(withEmail: email.lowercased(), password: password) { (authResult, err2) in
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
                        currentUserWrapper.startedToLoadUser = false
                        self.showActionSheet.toggle()
                    } else {
                        currentUserWrapper.startedToLoadUser = true
                        loading = true
                        print("Starting to load")
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
            .onChange(of: currentUserWrapper.currentUser?.email, perform: { value in
                print("current user loaded, closing sheet")
                loading = false
                //self.presentationMode.wrappedValue.dismiss()
            })
            
            Button(action: {
                activeSheet = .passwordReset
            }, label: {
                Text("Forgot Password?").foregroundColor(Color.black.opacity(0.8)).padding().frame(alignment: .leading)
            })

            Spacer()
            
        }.actionSheet(isPresented: $showActionSheet, content: {self.actionSheet!})
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
    

    
}

@available(iOS 14.0, *)
struct EmailLogInView_Previews: PreviewProvider {
    static var previews: some View {
        EmailLogInView(activeSheet: .constant(nil)).environmentObject(UserWrapper())
    }
}
