//
//  VerifyButton.swift
//  PODZ
//
//  Created by Nick Miller on 10/26/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseFirestore 
import FirebaseFirestoreSwift

@available(iOS 14.0, *)
struct VerifyButton: View {
    
    @Binding var moveGrayViewContainerUp : Bool
    @Binding var message : String
    @ObservedObject var messagesVM : MessengerViewModel
    @Binding var activePodSheet: ActivePodSheet?
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @Namespace var animation
    @ObservedObject var podWrapper: PodWrapper
    @Binding var showHabitLogPopUp: Bool
    
    var body: some View {
        
        if (self.moveGrayViewContainerUp) || (self.message.count > 0) {
            Button(action: {
                
                
//                withAnimation(.linear(duration: 1)) {
//                    print("button pressed with message: ", self.message)
//                    print("character count: ", self.message.count)
                    //testPod.messages.append([currentUser.userName, self.message, "chat"])
                let timeStamp = Timestamp()
                let isNewDay = messagesVM.requiresNewDayMessage(newMessageTimestamp: timeStamp)
                let message = Message(text: self.message, senderID: currentUserWrapper.currentUser!.ID, type: "chat", timeStamp: timeStamp, isNewDay: isNewDay, messageID: UUID().uuidString)
                self.messagesVM
                    .addMessageToFirestore(podID: podWrapper.podID, message: message)
                podWrapper.cloudFunctionsOnMessageSent(message: message)
                self.message = ""




            }) {
                //ZStack {
                    //Circle().fill(Color.white)
                Image(systemName: "arrow.right.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.purple)
                    .background(Color.white)
                    .clipShape(Circle())

                //}
            }
        //.padding(.bottom, 3)
        .matchedGeometryEffect(id: "SendVerify", in: animation)
            
        }
        else
            
        {
            
            Button(action:
                    {
                    
                    UIApplication.shared.endEditing()
                    print("Verify modal presenting")
                    //activePodSheet = .podVerify
                    showHabitLogPopUp = true
                    self.moveGrayViewContainerUp = false

                    
                    })
                {
                    Text("LOG HABIT")
                    .fontWeight(.bold)
                    .frame(maxWidth: 175, maxHeight: 40)
                    .foregroundColor(Color.white)
                    .background(Color.purple)
                    .cornerRadius(10)
                        
    
            }
            .matchedGeometryEffect(id: "SendVerify", in: animation)
                

        }
    }
    
}

//@available(iOS 14.0, *)
//struct VerifyButton_Previews: PreviewProvider {
//    static var previews: some View {
//        VerifyButton(moveGrayViewContainerUp: .constant(true), message: .constant(""), messagesVM: MessagesViewModel(podID: "DUMMY"), activeSheet: .constant(.verify))
//    }
//}
