//
//  SwiftUIView.swift
//  PODZ
//
//  Created by Nick Miller on 10/6/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
struct EmailTabView: View {
    
    @Binding var activeSheet: ActiveSheet?
    @State var selection = 0
    @EnvironmentObject var currentUserWrapper: UserWrapper
    //@Environment(\.presentationMode) var presentationMode


    var body: some View {

            

            VStack{

            
                HStack(spacing:30) {
                    Button(action: {self.selection = 0}){
                        
                        Text("Create Account").font(.system(size: CGFloat(30 - selection * 10))).fontWeight(.bold).opacity(1.0 - Double(self.selection) * 0.5)
                    }
                    .foregroundColor(.black)
                    .animation(nil)
                    
                    Button(action: {self.selection = 1}){
                        Text("Sign In").font(.system(size: 20.0 + CGFloat(selection * 10))).fontWeight(.bold).opacity(0.5 + Double(self.selection) * 0.5)
                    }
                    
                    .foregroundColor(.black)
                    .animation(nil)
                }.padding()
                
                if self.selection == 0 {
                    EmailCreateAccountView().animation(.easeInOut)
                } else {

                    EmailLogInView(activeSheet: $activeSheet).animation(.easeInOut)
                
                    
                }
            }.onChange(of: currentUserWrapper.currentUser?.email, perform: { value in
                print("CHANGE OF CURRENT USER: ", currentUserWrapper.currentUser ?? "no user")
                print("DISMISS TAB VIEW")
                activeSheet = nil
                //self.presentationMode.wrappedValue.dismiss()
                //isPresented.toggle()
            })
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            
        
        

    }
}

@available(iOS 14.0, *)
struct EmailTabView_Previews: PreviewProvider {
    static var previews: some View {
        EmailTabView(activeSheet: .constant(.email))
    }
}
