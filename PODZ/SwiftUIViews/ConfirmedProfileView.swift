//
//  ConfirmedProfileView.swift
//  PODZ
//
//  Created by Nick Miller on 6/22/21.
//  Copyright © 2021 Nick Miller. All rights reserved.
//

import SwiftUI

struct ConfirmedProfileView: View {
    
    @EnvironmentObject var currentUserWrapper: UserWrapper
    
    @State var editedFirstName: String
    @State var editedLastName: String
    @State var editedEmail: String
    @State var makeFirstResonder = false
    @State var calculatedHeight : CGFloat = 37.5
    
    @State var showErrorMessage = false
    @State var errorMessage = ""
    
    var body: some View {
            
            VStack {
            Spacer()
            Text("Edit Profile Info")
                .foregroundColor(.purple)
                .font(.system(size: 28, weight: .bold, design: .default))
                .padding(.horizontal, 2)
                .padding(.bottom,4)
            Spacer()
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                Text("Email:")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                    .padding(5)
                    .padding(.horizontal)
                    .background(Color.purple)
                    .cornerRadius(15, corners: [.topLeft, .topRight])
                    
//                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 50))
                MessagingTextField(text: $editedEmail, wantToMakeFirstResponder: $makeFirstResonder, calculatedHeight: $calculatedHeight, placeHolderText: "")
                    .frame(height: 40)
                    .cornerRadius(5)
                    .foregroundColor(Color.gray.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.purple, lineWidth: 5)
                    )
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 50))
                }.padding(.leading, 5)

                VStack(alignment: .leading, spacing: 0){
                Text("First Name:")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                    .padding(5)
                    .padding(.horizontal)
                    .background(Color.purple)
                    .cornerRadius(15, corners: [.topLeft, .topRight])
                MessagingTextField(text: $editedFirstName, wantToMakeFirstResponder: $makeFirstResonder, calculatedHeight: $calculatedHeight, placeHolderText: "")
                    .frame(height: 40)
                    .cornerRadius(5)
                    .foregroundColor(Color.gray.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.purple, lineWidth: 5)
                    )
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 50))
                }.padding(.leading, 5)
//                .background(Color.purple)
//                .cornerRadius(20)
//                .padding(EdgeInsets(top: 0, leading: 70, bottom: 15, trailing: 70))
                VStack(alignment: .leading, spacing: 0) {
                Text("Last Name:")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.white)
                    .padding(5)
                    .padding(.horizontal)
                    .background(Color.purple)
                    .cornerRadius(15, corners: [.topLeft, .topRight])
                MessagingTextField(text: $editedLastName, wantToMakeFirstResponder: $makeFirstResonder, calculatedHeight: $calculatedHeight, placeHolderText: "")
                    .frame(height: 40)
                    .cornerRadius(5)
                    .foregroundColor(Color.gray.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.purple, lineWidth: 5)
                    )
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 50))
                }
                .padding(.leading, 5)
                

            
            }
            Spacer()
            
            Button(action: {
                
                if !editedEmail.isValidEmail() {
                    errorMessage = "Please enter a valid email"
                    showErrorMessage = true
                } else if editedFirstName.count > 20 {
                    errorMessage = "First name is too long"
                    showErrorMessage = true
                } else if editedLastName.count > 20 {
                    errorMessage = "Last name is too long"
                    showErrorMessage = true
                } else {
                    print("confirming profile info")
                    currentUserWrapper.showConfirmedProfileInformation = false
                    currentUserWrapper.currentUser!.email = editedEmail
                    currentUserWrapper.currentUser!.firstName = editedFirstName
                    currentUserWrapper.currentUser!.lastName = editedLastName
                }
                
                
                
            }, label: {
                Text("Confirm")
                    .foregroundColor(.white)
                    .font(.title2)
                    .bold()
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 2/3)
                    .background(Color.purple)
                    .cornerRadius(10)
                    
            })
            .padding()
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color.gray.opacity(0.2))
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .actionSheet(isPresented: $showErrorMessage, content: {
            
            
            return ActionSheet(
            title: Text("Profile Info Error").font(.system(size: 22)),
            message: Text(errorMessage),
                buttons: [
                .cancel()
                ]
            )
        })
    }
}

struct ConfirmedProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmedProfileView(
           
            editedFirstName: "Nick",
            editedLastName: "Miller",
            editedEmail: "nicholas.miller@berkeley.edu")
    }
}

extension String {
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
