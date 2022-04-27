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



struct PodChatView13: View {

    
    @ObservedObject var podWrapper: PodWrapper
    //@State var toDisplay = dataToDisplayMessages(pod: testPod)
    @ObservedObject var messagesVM: MessagesViewModel
    @EnvironmentObject var currentUserFirebase : UserWrapper

    
    
    @State var activeSheet: ActiveSheet?

    
    @State var message = "Send Message"
    @State var openUpTextField = false
    @State var typingOccured = false
    @State var textFieldHeight: CGFloat = 40
    
    @State var currentMessageViewHeight:CGFloat = 0
    

    
    var onEditingChanged: ((Bool)->()) = {_ in }
    @State private var formOffset: CGFloat = 0
  
    @State var isPresentingVerifyModal = false
    
    @State var isPresentingInfoModal = false
        
    @State var moveGrayViewContainerUp = false

    
    
    var body: some View {
         
        
        VStack {
            ScrollView{
//                ForEach(self.messagesVM.observableMessages, id: \.self) {
//                    
//                    mess in
//                    
//                    if mess.type == "chat" {
//                        if mess.sender == currentUser.userName {
//                            
//                            
//                            OutgoingMessageView(message: mess.message, colorCode: self.pod.membersIDandColorCodeandScore[currentUser.ID]![0], viewHeight: $currentMessageViewHeight)
//                            
//                        } else {
//                            
//                            IncomingMessageView(message: mess.message, colorCode: 1, viewHeight: $currentMessageViewHeight)
//                            //Color Code hard coded at two for testing purpoes
//                            
//                        }
//                    }
//                    else {
//                        if mess.sender == currentUser.userName {
//                            
//                            OutgoingVerify(message: mess.message, colorCode: self.pod.membersIDandColorCodeandScore[currentUser.ID]![0], viewHeight: $currentMessageViewHeight)
//                            
//                        } else {
//                            
//                            IncomingVerify(message: mess.message, name: mess.sender, colorCode: 1, viewHeight: $currentMessageViewHeight)
//                        }
//                    }
//                }
//                .environment(\.defaultMinListRowHeight, 20)
//                .onAppear(){
//                    UITableView.appearance().separatorColor = .clear
//                    
//
//
//                    
//                    
//                    
//                }
//                .onTapGesture(count: 1, perform: {
//                    withAnimation(.timingCurve(0.16, 1, 0.37, 1, duration: 0.50)) {
//                        self.openUpTextField = false
//                        self.formOffset = 0
//                        UIApplication.shared.endEditing()
//                    }
//                    
//                })
            
            }
            HStack(alignment: .bottom) {
                
                MessagingTextField(text: self.$message, wantToMakeFirstResponder: self.$moveGrayViewContainerUp, calculatedHeight: self.$textFieldHeight, placeHolderText: "Send Message")
                   
                    .onTapGesture(count: 1, perform: {
                        if !self.openUpTextField {
                            withAnimation(.timingCurve(0.16, 1, 0.37, 1, duration: 0.5)) {
                                    self.openUpTextField = true
                        
                            }
                        }
                    })
                    .cornerRadius(10)
                    .foregroundColor(Color.gray.opacity(0.3))

                if (self.openUpTextField) {
                Button(action: {
               
                    print("button pressed with message: ", self.message)
                    //testPod.messages.append([currentUser.userName, self.message, "chat"])
                    let timeStamp = Timestamp()
                    self.messagesVM
                        .observableMessages
                        .append(Message(text: self.message, senderID: currentUserFirebase.currentUser!.ID, type: "chat", timeStamp: timeStamp, previousTimeStamp: messagesVM.observableMessages.last?.id ?? timeStamp))
                    self.message = ""
                    typingOccured = false
                    
                       }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.purple)
                        .background(Color.white)
                        .font(.largeTitle)
                        .clipShape(Circle())
                    }.padding(.bottom, 3)
                    
                }
            else
                
            {
               
                VStack {
                    
                        Button(action:
                                {
                                print("Verify modal presenting")
                                self.isPresentingVerifyModal.toggle()
                                print(self.isPresentingVerifyModal)
                                
                                })
                            {
                                Text("Verify")
                                .fontWeight(.bold)
                                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(.top, 7)
                                    .padding(.bottom, 7)
                                .foregroundColor(Color.white)
                                .background(Color.purple)
                                .cornerRadius(10)
                                                                
                        }
                    
                }
                        

//                    .sheet(isPresented: $isPresentingVerifyModal, content:
//                        {
//                                
//                                PodVerifyPopup(activeSheet: self.$activeSheet,
//                                    didAddVerify:
//                                    {
//                                    verifyMessage in
//                                        
//                                        testPod.messages.append([currentUser.userName, self.message, "verify"])
//                                        
//                                        self.messagesVM.observableMessages.append(
//                                            displayMessage(
//                                            id: self.messagesVM.observableMessages.count,
//                                            message: verifyMessage,
//                                            sender: currentUser.userName,
//                                            type: "verify"))
//                                    }
//                                )
//                        }
//                    )
            }
            }
            .padding(11)
            .background(Color.gray)
            .frame(maxHeight: 55)
            .offset(y: openUpTextField ? -262: 0)
           

        }.gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local).onEnded({ (value) in
            if value.translation.height > 0 && value.translation.width < 100 && value.translation.width > -100 {
                withAnimation {
                    self.openUpTextField = false
                    self.formOffset = 0
                    UIApplication.shared.endEditing()
                }
            }
        }))
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
        .onAppear(){
            UITableView.appearance().separatorStyle = .none
     }
        
    }
}
    
    


struct PodChatView13_Previews: PreviewProvider {
    static var previews: some View {
        PodChatView13(podWrapper: PodWrapper(id:"DUMMY"), messagesVM: MessagesViewModel(podID: "DUMMY"))
    }
}


