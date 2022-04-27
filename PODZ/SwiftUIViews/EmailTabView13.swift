//
//  EmailTabView13.swift
//  PODZ
//
//  Created by Nick Miller on 11/5/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import SwiftUI

struct EmailTabView13: View {
    @Binding var activeSheet: ActiveSheet?
    @State var selection = 0
    @State var isPresented = false

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
                    if #available(iOS 14.0, *) {
                        EmailLogInView().animation(.easeInOut)
                    } else {
                        EmailLoginView13(isPresented: $isPresented).animation(.easeInOut)
                    }
                }
            }
            
        
        

    }
}

//struct EmailTabView13_Previews: PreviewProvider {
//    static var previews: some View {
//        EmailTabView13(activeSheet: .constant(.email), isPresented: .constant(true))
//    }
//}
