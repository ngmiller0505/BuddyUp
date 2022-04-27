//
//  PodMessagesView.swift
//  PODZ
//
//  Created by Nick Miller on 6/15/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import SwiftUI
import Combine
import UIKit
import Firebase


@available(iOS 14.0, *)
struct PodChatViewGeometryScroll: View {

    
    @ObservedObject var podWrapper: PodWrapper
    //@State var toDisplay = dataToDisplayMessages(pod: testPod)
    @ObservedObject var messagesVM: MessagesViewModel
    @EnvironmentObject var currentUserFirebase: UserWrapper
    
    @State var activeSheet: ActiveSheet?
    
    @State var message = ""
    @State var openUpTextField = false
    @State var typingOccured = false
    @State var moveGrayViewContainerUp = false
    @State var textFieldHeight: CGFloat = 40
    
    @State var currentMessageHeight: CGFloat = 0

    
    var onEditingChanged: ((Bool)->()) = {_ in }
    @State private var formOffset: CGFloat = 0
  
    @State var isPresentingVerifyModal = false
    
    @State var isPresentingInfoModal = false
    
    @Namespace private var animation
    
    
    
    
    var body: some View {
         
        
        VStack {
            ReverseScrollView {
                LazyVStack {
//                    ForEach(self.messagesVM.observableMessages, id: \.self) {
//
//                            mess in
//
//                            if mess.type == "chat" {
//                                if mess.sender == currentUser.userName {
//
//                                    OutgoingMessageView(message: mess.message, colorCode: self.pod.membersIDandColorCodeandScore[currentUser.ID]![0], viewHeight: $currentMessageHeight)
//
//                                } else {
//
//                                    IncomingMessageView(message: mess.message, colorCode: 1, viewHeight: $currentMessageHeight)
//                                    //Color Code hard coded at two for testing purpoes
//
//                                }
//                            }
//                            else {
//                                if mess.sender == currentUser.userName {
//
//                                    OutgoingVerify(message: mess.message, colorCode: self.pod.membersIDandColorCodeandScore[currentUser.ID]![0], viewHeight: $currentMessageHeight)
//
//                                } else {
//
//                                    IncomingVerify(message: mess.message, name: mess.sender, colorCode: 1, viewHeight: $currentMessageHeight)
//                                }
//                            }
//                        }
//                        .environment(\.defaultMinListRowHeight, 20)
//                        .onAppear(){
//                            UITableView.appearance().separatorColor = .clear
//
//                        }
//                        .onTapGesture(count: 1, perform: {
//                            withAnimation(.timingCurve(0.16, 1, 0.37, 1, duration: 0.50)) {
//                                self.openUpTextField = false
//                                self.moveGrayViewContainerUp = false
//                                self.formOffset = 0
//                                UIApplication.shared.endEditing()
//                            }
//
//                    })
                }
            }
            
                
            
            
            
            HStack(alignment: .bottom) {
                
                MessagingTextField(text: self.$message, wantToMakeFirstResponder: self.$moveGrayViewContainerUp.animation(.interpolatingSpring(mass: 3, stiffness: 1000, damping: 500, initialVelocity: 12)), calculatedHeight: self.$textFieldHeight, placeHolderText: "Send Message")
                    .frame(minWidth: 175, maxWidth: 293.0, maxHeight: textFieldHeight)
                    .cornerRadius(10)
                    .foregroundColor(Color.gray.opacity(0.3))


                if (self.moveGrayViewContainerUp) && (message.count > 0) {
                Button(action: {
               
                    print("button pressed with message: ", self.message)
                    //testPod.messages.append([currentUser.userName, self.message, "chat"])
                    let timeStamp = Timestamp()
                    self.messagesVM
                        .observableMessages
                        .append(Message(text: self.message, senderID: currentUserFirebase.currentUser!.ID, type: "chat", timeStamp: timeStamp, previousTimeStamp: self.messagesVM.observableMessages.last?.id ?? timeStamp))
                    self.message = ""
                    typingOccured = false
                    
                       }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.purple)
                        .background(Color.white)
                        .font(.largeTitle)
                        .clipShape(Circle())
                    }.padding(.bottom, 3)
                .matchedGeometryEffect(id: "SendVerify", in: animation)
                    
                }
            else
                
            {
               
                VStack {
                    
                        Button(action:
                                {
                                
                                UIApplication.shared.endEditing()
                                print("Verify modal presenting")
                                self.isPresentingVerifyModal.toggle()
                                self.moveGrayViewContainerUp = false
                                print(self.isPresentingVerifyModal)

                                
                                })
                            {
                                Text("Verify")
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
            .padding(20)
            .edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: 30 + textFieldHeight)
            .background(Color.gray)
            .offset(y: moveGrayViewContainerUp ? -260: 0)

        }
//        .sheet(isPresented: $isPresentingVerifyModal, content:
//            {
//                    
//                    PodVerifyPopup(activeSheet: self.$activeSheet,
//                        didAddVerify:
//                        {
//                        verifyMessage in
//                            
//                            testPod.messages.append([currentUser.userName, self.message, "verify"])
//                            
//                            self.messagesVM.observableMessages.append(
//                                displayMessage(
//                                id: self.messagesVM.observableMessages.count,
//                                message: verifyMessage,
//                                sender: currentUser.userName,
//                                type: "verify"))
//                        }
//                    )
//            }
//        )
        .offset(y: self.formOffset)
        .navigationBarTitle("Chat UI", displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action:
                {
                    print("info modal present")
                    self.isPresentingInfoModal.toggle()
                    print(self.isPresentingInfoModal)
                    
                })
            {
                Image(systemName: "info.circle")
                .font(.title)
            }
            .sheet(isPresented: $isPresentingInfoModal, content:
                {
                    PodInfoView(currentPod: self.podWrapper.currentPod!, activeSheet: self.$activeSheet)
                }
            )
            
        )
        .edgesIgnoringSafeArea(.bottom)
        
    }
}
    
    


@available(iOS 14.0, *)
struct PodChatViewGeometryScroll_Previews: PreviewProvider {
    static var previews: some View {
        PodChatView(podWrapper: PodWrapper(id: "DUMMY"), messagesVM: MessagesViewModel(podID: "DUMMY"))
    }
}


