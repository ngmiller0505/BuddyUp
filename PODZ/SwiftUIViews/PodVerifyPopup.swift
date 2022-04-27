//
//  PodVerifyPopup.swift
//  PODZ
//
//  Created by Nick Miller on 7/13/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import SwiftUI
import Firebase

struct PodVerifyPopup: View {
    
    @Binding var activePodSheet : ActivePodSheet?
    @Binding var extraDetails: String
    @State var typingOccurred = false
    @State var unUsedMove = false
    @State var textFieldHeight: CGFloat = 40
    @ObservedObject var messagesVM: MessengerViewModel
    @EnvironmentObject var currentUserWrapper : UserWrapper
    @ObservedObject var podWrapper: PodWrapper
    @Binding var showHabitLogPopUp: Bool
    @State var logPressed = false
    
    @State var verifyMessage : Message?
    
    
    @Namespace var podVerifyAnimation
    

    
    var didAddVerify: (String, MessengerViewModel, String, PodWrapper) -> Void
    
    var body: some View {
        ZStack {
            
            Color.black.opacity(0.85).onTapGesture {
                showHabitLogPopUp = false
            }
            
            
            
            if !logPressed {
                
                ZStack {
                    Color.purple
                    
                    VStack {
                        Button(action: {showHabitLogPopUp = false}, label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(5)
                        }).frame(maxWidth: .infinity, alignment: .topTrailing)
                        
                        Text(podWrapper.currentPod!.memberAliasesAndHabit[podWrapper.getAliasFromUID(UID: currentUserWrapper.currentUser!.ID)!]!)
                            .foregroundColor(Color.white)
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                        Text(podWrapper.currentPod!.memberAliasesAndLogPhrase[podWrapper.getAliasFromUID(UID: currentUserWrapper.currentUser!.ID)!]!)
                            .foregroundColor(Color.white)
                            .font(.title3)
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(5)
                        
                        
                        HStack {
                            Spacer()
                            MessagingTextField(text: self.$extraDetails, wantToMakeFirstResponder: self.$unUsedMove, calculatedHeight: self.$textFieldHeight, placeHolderText: "Optional Extra Details")
                                .frame(minWidth: 175, maxWidth: 293.0, maxHeight: textFieldHeight)
                                .cornerRadius(10)
                            Spacer()
                        }
                        Button(action: {
                            
                            let timestamp = Timestamp()
                            let isNewDay = messagesVM.requiresNewDayMessage(newMessageTimestamp: Timestamp())
                            
                            verifyMessage = Message(text: extraDetails, senderID: currentUserWrapper.currentUser!.ID, type: "verify", timeStamp: timestamp, isNewDay: isNewDay, messageID: UUID().uuidString)
                            //withAnimation(.easeInOut(duration: 1.8)){
                            logPressed = true
                            //}
                            //self.didAddVerify(self.extraDetails, messagesVM, currentUserWrapper.currentUser!.ID, podWrapper)
                            podWrapper.cloudFunctionsOnHabitLogged(alias: podWrapper.getAliasFromUID(UID: currentUserWrapper.currentUser!.ID)!)
                            podWrapper.cloudFunctionsOnMessageSent(message: verifyMessage!)
                            messagesVM.addMessageToFirestore(podID: podWrapper.podID, message: verifyMessage!)
                            podWrapper.userJustLogged = true
//                            activePodSheet = nil
//                            withAnimation(.easeIn(duration: 10)) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                showHabitLogPopUp = false
                            }
                            
                            extraDetails = ""
                        })
                        {
                            Text("Log Habit")
                                .foregroundColor(Color.purple)
                                .font(.title3)
                                .bold()
                                .frame(maxWidth: .infinity, alignment:  .center)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(5)
                                .padding(EdgeInsets(top: 7, leading: 30, bottom: 7, trailing: 30))
                            
                        }
                        .disabled(!podWrapper.expectingHabitLogToday(UID: currentUserWrapper.currentUser!.ID))
                        .opacity(podWrapper.expectingHabitLogToday(UID: currentUserWrapper.currentUser!.ID) ? 1 : 0.5)
                        .padding(.bottom, 5)
                        if !podWrapper.expectingHabitLogToday(UID: currentUserWrapper.currentUser!.ID) {
                            
                            Text("You don't have a habit to log today.")
                                .foregroundColor(.white)
                        }
                        Spacer()
         
                    }
                    
                }
                //.transition(.asymmetric(insertion: AnyTransition.identity, removal: AnyTransition.scale.animation(.spring().speed(0.2))))
                .transition(AnyTransition.move(edge: .bottom).animation(.spring()))
                .matchedGeometryEffect(id: "PodVerifyPopUp",in:  podVerifyAnimation, anchor: .bottom)
                .ignoresSafeArea(.keyboard)
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
                .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                                    .onEnded({ value in
                                        if value.translation.height > 0 {
                                            UIApplication.shared.endEditing()
                                        }
                                    }))
                .frame(width: UIScreen.main.bounds.width * 9/10, height: UIScreen.main.bounds.height * 3/5, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .cornerRadius(10)
                .shadow(radius: 30)

                
                
                
            } else {
                
//                @EnvironmentObject var currentUserWrapper: UserWrapper
//
//                
//                @State var message: Message
//                var oldTimeStamp: Timestamp
//                var name: String
//                var colorCode: Int
//            //    @Binding var seePodTutorialAgain: Bool
//                @ObservedObject var podWrapper: PodWrapper
//                
            FullChatSection(message: verifyMessage!, oldTimeStamp: Timestamp(), name: currentUserWrapper.currentUser!.firstName, colorCode: podWrapper.currentPod!.memberAliasesAndColorCode[podWrapper.getAliasFromUID(UID: currentUserWrapper.currentUser!.ID)!]!,  podWrapper: podWrapper)
                //.transition(AnyTransition.offset(y: 215).combined(with: AnyTransition.scale.animation(.spring())))
                .matchedGeometryEffect(id: "PodVerifyPopUp",in:  podVerifyAnimation)
                //.transition(.asymmetric(insertion: AnyTransition.offset(y: 215), removal: AnyTransition.scale.animation(.spring())))
                .transition(AnyTransition.scale.animation(.spring()))
                //.offset(y:  messagesVM.totalMessageHeight > UIScreen.main.bounds.height - 200 ? UIScreen.main.bounds.height / 4 - 10 : 0)
                .transition(AnyTransition.opacity)
                //.matchedGeometryEffect(id: "PodVerifyPopUp",in:  podVerifyAnimation, anchor: .bottom)
            }
        }
    }
}



//
//struct PodVerifyPopup_Previews: PreviewProvider {
//    static var previews: some View {
//        PodVerifyPopup(activePodSheet: .constant(nil), extraDetails: .constant(""), messagesVM: MessengerViewModel(podWrapper: PodWrapper(id: "DUMMY"), userID: "nil"), podWrapper: PodWrapper(id: "DUMMY"), showHabitLogPopUp: .constant(true)) { a, b, c, d in
//            return
//        }
//    }
//}

