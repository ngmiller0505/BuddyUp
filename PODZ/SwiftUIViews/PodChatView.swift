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
import UIKit


@available(iOS 14.0, *)
struct PodChatView: View {
    

    @ObservedObject var podWrapper: PodWrapper
    @ObservedObject var messagesVM: MessengerViewModel
    @EnvironmentObject var currentUserWrapper : UserWrapper

    @State var currentMessageHeight: CGFloat = 0
    
    @State var activePodSheet: ActivePodSheet?
    
    @State var message: String = ""
    @State var typingOccured: Bool = false
    @State var moveGrayViewContainerUp: Bool = false
    @State var textFieldHeight: CGFloat = 37.5
    @State var initialTextFieldHeight: CGFloat = 37.5
    @State var previousTextFieldHeight: CGFloat = 37.5
    
    @State var grayContainerOffset: CGFloat = 0
    
    @State var lastMessPresented : Message?
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    @State var showHabitLogPopUp : Bool = false
    
    @State var podVerifyOptionalExtraDetails: String = ""
    
    
    @State var numberOfScrollToBottoms = 0
    @State var justSentOrRecieved = false
    
    func getMessages() {
        messagesVM.startToListen(podID: podWrapper.podID)
    }
    

    
    @State var seenPodTutorial = true
    
    func calculateAmountScrollOffset(messagesHeight: CGFloat, scrollHeight: CGFloat, textFieldHeight: CGFloat, initialTextFieldHeight: CGFloat, differentDevice: DeviceType) -> CGFloat {

        print("\n\n")
        let additionalTextFieldHeight = textFieldHeight - initialTextFieldHeight
        
//        let grayContainerHeightWithoutKeyboard = 75 + initialTextFieldHeight + additionalTextFieldHeight
        
        let keyboardHeight =  CGFloat(290 - (differentDevice == .old ? 80 : 0)) //textFieldHeight
       
        let whiteSpace = scrollHeight - messagesHeight
        
        let grayContainerHeightWithKeyboard : CGFloat = keyboardHeight + initialTextFieldHeight + additionalTextFieldHeight + 15
        
//        print("UISCREEN MAIN BOUND HEIGhT: ", UIScreen.main.bounds.height)
//        print("SCROLL HEIGHT: ", scrollHeight)
//        print("MESSAGES HEIGHT: ", messagesHeight)
//        print("TEXT FIELD HEIGHT: ", textFieldHeight)
//        print("GRAY CONTAINER HEIGHT WITH KEYBOARD: ", grayContainerHeightWithKeyboard)
//        print("GRAY CONTAINER HEIGHT WITHOUT KEYBOARD: ", grayContainerHeightWithoutKeyboard)
//        print("WHITESPACE: ", whiteSpace)
//        print("KEYBOARD HEIGHT: ", keyboardHeight)
        

        if whiteSpace > grayContainerHeightWithKeyboard {
//            print("IF whiteSpace > grayContainerHeightWithKeyboard: return 0")
            return 0
        } else {
            if whiteSpace > 0 {
//                print("ELSE IF. offset = -1 * (keyboardHeight - whiteSpace) : ",  -1 * (keyboardHeight - whiteSpace))
                return -1 * (keyboardHeight - whiteSpace)
            } else {
//                print("ELSE new SCROLL OFFSET ~ keyboardHeight * -1 = ",  keyboardHeight * -1)
                return keyboardHeight * -1
            }
        }
    }
    
    
    func setHigherLoadLimit(message: Message, loadLimitNumber: Int, firstTimeStampLoaded: Timestamp?) -> Int {
        if let firstTimeStampLoaded = firstTimeStampLoaded {
            if message.id.compare(firstTimeStampLoaded).rawValue == 0 {
                print("GOT TO TOP OF MESSAGE, TRYING TO LOAD MORE")
                return loadLimitNumber + 20
            }
        }
        return loadLimitNumber
    }

    
    var body: some View {
        
        if podWrapper.currentPod == nil {
            PodRowLoader()
        } else  {
        ZStack {
            VStack {
                Spacer()
                Color.init("keyboardGrey").frame(height: moveGrayViewContainerUp ? 305 - (currentUserWrapper.differentDevice == .old ? 40 : 0) + textFieldHeight: 75 + self.textFieldHeight, alignment: .bottom)
            }
            VStack(spacing: 0) {
            GeometryReader { proxy in
                ScrollView {
                        ScrollViewReader { scroll in
//                            VStack {
                                ForEach(self.messagesVM.observableMessages, id: \.self) {
                                    mess in
                                    
                                    VStack {
                                        
                                    FullChatSection(message: mess,
                                                    oldTimeStamp: lastMessPresented?.id ?? mess.id,
                                                    
                                                    name: getSenderName(senderAlias: podWrapper.getAliasFromUID(UID: mess.senderID) ?? "Not Found", currentPod: podWrapper.currentPod!),
                                                    colorCode : getColorCode(memberAlias: podWrapper.getAliasFromUID(UID: mess.senderID) ?? "Not Found", currentPod: podWrapper.currentPod!), podWrapper: podWrapper)
//                                        .environmentObject(currentUserWrapper)

                                        
                                        if mess.type == "bot intro" {
                                            HStack {
                                            Button(action: {
                                                UIApplication.shared.endEditing()
                                                seenPodTutorial = false
                                                print("buttom")
                                            }, label: {
                                                Text("See Tutorial Again")
                                                    .font(.system(size: 18))
                                                    .foregroundColor(.white)
                                                    .bold()
                                                    .padding(6)
                                                    .background(Color.purple)
                                                    .cornerRadius(15)
                                                    
//                                                  .background(Color(UIColor.systemGray2))

                                            })
                                            .padding(12)
                                            .background(Color(UIColor.systemGray5).opacity(0.8))
                                            .cornerRadius(15, corners: [.bottomLeft, .bottomRight, .topRight])
                                            .frame(maxWidth: 350, alignment: .leading)
                                            //.scaledToFill()
                                            .padding(.leading, 3)
                                                
                                            Spacer()
                                            }.frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                    .id(mess.id)
                                    .transition(AnyTransition.opacity.animation(.linear(duration: 0.1)))

                                    
                                }
//                            }
                            .onChange(of: self.showHabitLogPopUp, perform: { newValue in
                                    print("ClOSED OR OPENED HABIT LOG. SCROLLING TO BOTTOM")


                                })
                            .onChange(of: self.messagesVM.observableMessages.last?.id, perform: { newValue in
                                    print("NEW MESSAGE. SCROLLING TO BOTTOM")
                                    
                                    
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.justSentOrRecieved = true
                                    
                                withAnimation(.linear(duration: 0.1)) {
                                        //note: taking away the animation causes bug
                                        print("self.messagesVM.observableMessages.count scrollTo")
                                        numberOfScrollToBottoms += 1
                                        print("numberOfScrollsToBottom = ", self.numberOfScrollToBottoms)
//                                        scroll.scrollTo(self.messagesVM.observableMessages.last?.id, anchor : .bottom)
                                        scroll.scrollTo(newValue, anchor : .bottom)

                                    }
//                                }

//
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
//                                        scroll.scrollTo(self.messagesVM.observableMessages.last?.id)//, anchor: .bottom)
//                                }

                                })
                                .onChange(of: self.moveGrayViewContainerUp, perform: { value in
//                                    print("self.moveGrayViewController CHANGED. SCROLLING TO BOTTOM")
                                    
                                    self.justSentOrRecieved = false



                                        if value {
                                            withAnimation(.interpolatingSpring(mass: 3, stiffness: 1000, damping: 500, initialVelocity: 4)) {
                                            self.grayContainerOffset =  -398 + 75 + initialTextFieldHeight + (currentUserWrapper.differentDevice == .old ? 75 : 0)
                                                print("self.grayContainerOffset UP = ", self.grayContainerOffset)
                                            }
                                        }
                                })
                            .onChange(of: self.grayContainerOffset, perform: { value in
                                print("grayContainerOffset changed, new ammountOffset = ", grayContainerOffset)
                                print("scrollOffset changed, new scrollOffset: ", calculateAmountScrollOffset(messagesHeight: self.messagesVM.totalMessageHeight, scrollHeight: proxy.frame(in: .local).maxY, textFieldHeight: textFieldHeight, initialTextFieldHeight: initialTextFieldHeight, differentDevice: currentUserWrapper.differentDevice))
                                
//                                withAnimation(.linear(duration: 1)) {
//                                    scroll.scrollTo(self.messagesVM.observableMessages.last?.id, anchor : .bottom)
//                                }
                            })
                            .onChange(of: self.textFieldHeight, perform: { value in
                                    print("textFieldHeight CHANGE. NEW TEXT FIELD HEIGHT IS: ", value)

//                                if !justSentOrRecieved {
                                if value - previousTextFieldHeight > 1 ||  value - previousTextFieldHeight < -1 {
//                                     DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                         withAnimation(.linear(duration: 0.1)) {
                                             print("textfieldchange scrollto")
                                             numberOfScrollToBottoms += 1
                                             print("numberOfScrollsToBottom = ", self.numberOfScrollToBottoms)
                                             scroll.scrollTo(self.messagesVM.observableMessages.last?.id, anchor : .bottom)
//                                         }
                                    }
                                }
//                                }
                                previousTextFieldHeight = value
//                                    else if value - initialTextFieldHeight < -1{
//                                    withAnimation(.linear(duration: 1)) {
//                                        print("textfieldheight negetive scrollTo")
//                                        scroll.scrollTo(self.messagesVM.observableMessages.last?.id, anchor : .bottom)
//                                    }
//
//                                } else  {
//                                        print("not scrolling ")
//                                }



                                })
                            .onAppear {
                                print("on appear make sure we are at the bottom")
                                //scroll.scrollTo(self.messagesVM.observableMessages.last?.id, anchor: .top)
                                print("onAppear textFieldHeight = ", self.textFieldHeight)
                                print("onAppear grayContainerOffset = ", self.grayContainerOffset)

                               // DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                withAnimation(.linear(duration: 0.1)) {
                                        print("onAppear scrollTo")
                                        //note: taking away the animation causes bug
                                        numberOfScrollToBottoms += 1
                                        print("numberOfScrollsToBottom = ", self.numberOfScrollToBottoms)
                                        scroll.scrollTo(self.messagesVM.observableMessages.last?.id, anchor : .bottom)
                                    }

                            //}

                            }
                        }
                }
                .onTapGesture {
                    UIApplication.shared.endEditing()
                    withAnimation(.linear(duration: 0.2)) {
                        self.grayContainerOffset = 0
                        moveGrayViewContainerUp = false
                        print("self.grayContainerOffset DOWN = ", 0)

                    }
                }
                .offset(y : self.moveGrayViewContainerUp ? calculateAmountScrollOffset(messagesHeight: self.messagesVM.totalMessageHeight, scrollHeight: proxy.frame(in: .local).maxY, textFieldHeight: textFieldHeight, initialTextFieldHeight: initialTextFieldHeight, differentDevice: currentUserWrapper.differentDevice) : 0)
            }
            
                HStack(alignment: .bottom) {

                    MessagingTextField(text: self.$message, wantToMakeFirstResponder: self.$moveGrayViewContainerUp.animation(.interpolatingSpring(mass: 3, stiffness: 1000, damping: 500, initialVelocity: 4)), calculatedHeight: self.$textFieldHeight, placeHolderText: "Send Message")
                        .cornerRadius(10)
//                        .foregroundColor(Color.gray.opacity(0.3))


                        VerifyButton(moveGrayViewContainerUp: $moveGrayViewContainerUp, message: $message, messagesVM: messagesVM, activePodSheet: $activePodSheet, podWrapper: podWrapper, showHabitLogPopUp: $showHabitLogPopUp)
                        .frame(minWidth: UIScreen.main.bounds.width * 2/16, minHeight: initialTextFieldHeight, maxHeight: initialTextFieldHeight)

                }
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 65, trailing: 20))
                .frame(maxWidth: .infinity, maxHeight: 75 + self.textFieldHeight, alignment: .bottom)
                .background(Color.init("keyboardGrey"))
                .padding(.top, 3)
                .offset(y : grayContainerOffset)
//                .opacity(0.5)

        }
        .blur(radius: showHabitLogPopUp ? 5 : 0)
        .navigationBarTitle(podWrapper.currentPod!.podName, displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action:
                {
                    activePodSheet = .podInfo

                })
            {
                Image(systemName: "info.circle")
                .imageScale(.large)
            })
        .edgesIgnoringSafeArea(.bottom)
        .sheet(item: $activePodSheet)
            { item in
            switch item {
            case .podVerify:
                PodVerifyPopup(activePodSheet: $activePodSheet, extraDetails: $podVerifyOptionalExtraDetails, messagesVM: messagesVM, podWrapper: podWrapper,showHabitLogPopUp: $showHabitLogPopUp, didAddVerify: sendVerify)
                    .environmentObject(currentUserWrapper)

            case .podInfo:
                PodInfoView(activePodSheet: $activePodSheet, currentPodWrapper: podWrapper).environmentObject(currentUserWrapper)
            }
        }
            if showHabitLogPopUp {

                PodVerifyPopup(activePodSheet: $activePodSheet, extraDetails: $podVerifyOptionalExtraDetails, messagesVM: messagesVM, podWrapper: podWrapper,showHabitLogPopUp: $showHabitLogPopUp, didAddVerify: sendVerify)
            }
            if !seenPodTutorial {
                PodTutorial2(seenPodTutorial: $seenPodTutorial)
                    .navigationBarHidden(true)
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
            }
            
        }
        .highPriorityGesture(DragGesture(minimumDistance: 12, coordinateSpace: .global)
                    .onChanged({ value in
                        print("")
                        print("")
                        print("value.location.y: ", value.location.y)
                        print("value.predictedEndLocation.y: ", value.predictedEndLocation.y)
                        print("value.predictedEndTranslation.height: ",  value.predictedEndTranslation.height)
                        print("threshold : ",  UIScreen.main.bounds.height - 398 + 75 + initialTextFieldHeight + (currentUserWrapper.differentDevice == .old ? 75 : 0) - UIScreen.main.bounds.height / 7)

                        let conditional3 = value.predictedEndTranslation.height > 75

                        print("conditional3: ", conditional3)
                        if conditional3 {
                                UIApplication.shared.endEditing()
                                withAnimation(.linear(duration: 0.2)) {
                                self.grayContainerOffset = 0
                                moveGrayViewContainerUp = false

                                print("ENDED WITH PREDICTED onChange SCROLL, endEditing")
                                }
                        }
                        print("")
                    })
        )
        .edgesIgnoringSafeArea(.bottom)
        .onChange(of: currentUserWrapper.leftAPod, perform: { value in
            print("in ONCHANGE currentUserWrapper.leftAPod")
            if currentUserWrapper.leftAPod {
                print("currentUserWrapper.leftAPod. DISMISSING")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                    self.mode.wrappedValue.dismiss()
                    print("ENTERED leftAPod{")
                    withAnimation {
                        currentUserWrapper.removeUserDataFromPodLocally(podID: currentUserWrapper.activeComplaint!.associatedPodID)
                    }
                    currentUserWrapper.sendInComplaint(complaint: currentUserWrapper.activeComplaint!)
                    currentUserWrapper.activeComplaint = nil
                    currentUserWrapper.leftAPod = false
                    print("AFTER leftAPod")
                })
                
            }
        })
        .onAppear {
            podWrapper.inPodChat = true
            print("podWrapper.inPodChat = true")
        }
        .onDisappear {
            podWrapper.inPodChat = false
            print("podWrapper.inPodChat = false")
            podWrapper.seenSomethingNew(UID: currentUserWrapper.currentUser!.ID)
            //if there was new information in the pod that wasn't published, updated it
            if podWrapper.bufferedNewPod != nil {
                print("LEAVING POD CHAT.  COPYING OVER")
                podWrapper.currentPod = podWrapper.bufferedNewPod
                podWrapper.bufferedNewPod = nil
            }
            
            
            }
        }
    }
}

func sendVerify(vMessage: String, messagesVM: MessengerViewModel, currentUserWrapperID: String, podWrapper: PodWrapper) -> Void {
    //testPod.messages.append([currentUser.userName, vMessage, "verify"])
    print("IN SEND VERIFY")
    let messageID = UUID().uuidString
    let timeStamp = Timestamp()
    
    let isNewDay = messagesVM.requiresNewDayMessage(newMessageTimestamp: timeStamp)
    
    let message = Message(
        text: vMessage,
        senderID: currentUserWrapperID,
        type: "verify",
        timeStamp: timeStamp,
        isNewDay: isNewDay,
        messageID: messageID
    )
    
    messagesVM.addLocalMessageToModel(message: message)
    
    
    }

    
    
enum ActiveSheet: Identifiable {
    case profileInfo , email, passwordReset
    
    var id: Int {
        hashValue
    }
}

enum ActivePodSheet: Identifiable {
    case podVerify, podInfo
    
    var id: Int {
        hashValue
    }
}


public extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod touch (5th generation)"
            case "iPod7,1":                                 return "iPod touch (6th generation)"
            case "iPod9,1":                                 return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPhone12,8":                              return "iPhone SE (2nd generation)"
            case "iPhone13,1":                              return "iPhone 12 mini"
            case "iPhone13,2":                              return "iPhone 12"
            case "iPhone13,3":                              return "iPhone 12 Pro"
            case "iPhone13,4":                              return "iPhone 12 Pro Max"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                    return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                      return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                    return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                    return "iPad (8th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                    return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                    return "iPad Air (4th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad mini (5th generation)"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                     return "iPad Pro (11-inch) (2nd generation)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                    return "iPad Pro (12.9-inch) (4th generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "AudioAccessory5,1":                       return "HomePod mini"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()

}

//@available(iOS 14.0, *)
//struct PodChatView_Previews: PreviewProvider {
//    
////    static let podWrapper = PodWrapper(id: "4ff8504b-e83e-4b33-9fb7-e786768bcd35")
////    static let messagesVM = MessagesViewModel(podID: "4ff8504b-e83e-4b33-9fb7-e786768bcd35")
//    
//    static var previews: some View {
//        PodChatView().environmentObject(UserWrapper())
//            //.environmentObject(podWrapper).environmentObject(messagesVM)
//        //, didAddVerify: sendVerify)
//    }
//}


