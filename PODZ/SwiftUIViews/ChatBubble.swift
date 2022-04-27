//
//  ChatBubble.swift
//  PODZ
//
//  Created by Nick Miller on 10/12/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import SwiftUI
import Firebase

struct IncomingMessageView: View {
    var message: Message
    var colorCode: Int
    var name: String

    var body: some View {

        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(name)
                    .foregroundColor(colorOfUserFromCode(colorCode: colorCode))
                    .bold()
                    .font(.system(size: 14))
                    .padding(EdgeInsets(top: 8, leading: 2, bottom: 0, trailing: 8))
                    .clipped()
                Text(message.text)
                    .foregroundColor(.black)
                    .font(.system(size: 14))
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .clipped()
               
                Text(stringToChatBubbleFormat(fullString: timeStampToLongString(timeStamp: message.id))).font(.caption)
                    .foregroundColor(.black).opacity(0.6)
                    .frame(alignment: .bottomTrailing)
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                }
                .background(Color(UIColor.systemGray5))
                .cornerRadius(15, corners: [.bottomLeft, .bottomRight, .topRight])
                .frame(maxWidth: 350, alignment: .leading)
                //.scaledToFill()
                .opacity(0.8)
                .padding(.leading, 3)
                
                Spacer()
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
}

struct BotIntro: View {
    
    var message: Message
    //@Binding var seePodTutorialAgain: Bool
    
    var body: some View {
        
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("BuddyUp Bot")
                    .foregroundColor(.purple)
                    .bold()
                    .font(.system(size: 14))
                    .padding(EdgeInsets(top: 8, leading: 2, bottom: 0, trailing: 8))
                    .clipped()
                Text(message.text)
                    .foregroundColor(.black)
                    .font(.system(size: 14))
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .clipped()
//                Button(action: {
//                    seePodTutorialAgain = true
//                    print("buttom")
//                }, label: {
//                    Text("See Tutorial Again")
//                        .font(.title3)
//                        .foregroundColor(.purple)
//                        .bold()
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(15)
//                })

                Text(stringToChatBubbleFormat(fullString: timeStampToLongString(timeStamp: message.id))).font(.caption)
                    .foregroundColor(.black).opacity(0.6)
                    .frame(alignment: .bottomTrailing)
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                }
                .background(Color(UIColor.systemGray5))
                .cornerRadius(15, corners: [.bottomLeft, .bottomRight, .topRight])
                .frame(maxWidth: 350, alignment: .leading)
                //.scaledToFill()
                .opacity(0.8)
                .padding(.leading, 3)
                
                Spacer()
            }.frame(maxWidth: .infinity, alignment: .leading)
    }
}
struct OutgoingMessageView: View {
var message: Message
var colorCode: Int

var body: some View {

        HStack(alignment: .top) {
            Spacer()
                VStack(alignment: .trailing) {
                    Text(message.text)
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                        .padding(EdgeInsets(top: 8, leading: 8, bottom: 4, trailing: 8))
                        .clipped()
                    Text(stringToChatBubbleFormat(fullString: timeStampToLongString(timeStamp: message.id)))
                        .font(.caption)
                        .foregroundColor(Color(white: 0.9))
                        .padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 8))
                }
                .background(colorOfUserFromCode(colorCode: colorCode))
                .cornerRadius(15, corners: [.bottomLeft, .bottomRight, .topLeft])
                .frame(maxWidth: 350, alignment: .trailing)
                //.scaledToFill()
                .opacity(0.8)
                .padding(.trailing, 3)
            
        }.frame(maxWidth: .infinity)
    }
}


struct IncomingVerify: View{
    
    var message: Message
    var logPhrase: String
    var name: String
    var colorCode: Int
    var habitName: String

var body: some View {

        HStack {
            VStack{
                VStack(spacing: 0) {
                    Text("Habit Log:  " + name + " - " + habitName)
                        .foregroundColor(.white)
                        .font(.headline)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                        .padding(.leading, 13)
                        .frame(maxWidth : .infinity, alignment: .leading)
                        .padding(.bottom, 2)
                    
                    Color.white.frame(maxWidth: .infinity, maxHeight: 2, alignment: .center).padding(.horizontal)
                    Text(logPhrase)
                        .foregroundColor(.white)
                        .font(.headline)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)
                        .padding(.horizontal, 43)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                }.frame(maxWidth: .infinity)
                
                Text(message.text)
                    .foregroundColor(.white)
                    .font(.system(size: 13, weight: .light, design: .default))
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.top, 2)
                    .frame(alignment: .center)
                Text(stringToChatBubbleFormat(fullString: timeStampToLongString(timeStamp: message.id)))
                    
                    .frame(alignment: .leading)
                    .font(.caption)
                    .foregroundColor(Color(white: 0.9))
                    .padding(EdgeInsets(top: 1, leading: 8, bottom: 1, trailing: 8))
                    
                }
            //Spacer()
        }
        .background(colorOfUserFromCode(colorCode: colorCode))
        .cornerRadius(30)
        .shadow(color: colorOfUserFromCode(colorCode: colorCode), radius: 10)
        .padding(.leading, 15)
        .padding(.trailing, 15)
    }
}

struct MissingVerify: View {
    
    var message: Message
    var logPhrase: String
    var colorCode: Int
    var name: String
    var timeAsHHMM: Int
    var habitName: String
    

    var body: some View {
        
        ZStack {
        


           HStack{
                VStack{
                    VStack(spacing: 0) {
                        Text("Habit Log:  " + name + " - " + habitName)
                            .foregroundColor(Color.white)
                            .font(.headline)
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                            .padding(.leading, 13)
                            .frame(maxWidth : .infinity, alignment: .leading)
                            .padding(.bottom, 2)

                        
                        Color.white.frame(maxWidth: .infinity, maxHeight: 2, alignment: .center).padding(.horizontal)
                            
                        Text(logPhrase)
                            .foregroundColor(Color.white)
                            .font(.headline)
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(.top, 2)
                            .padding(.horizontal, 43)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                    }
                    //.opacity(0.8)
                    .frame(maxWidth: .infinity)
                    
                    
                    Text(message.text)
                        .font(.system(size: 13))
                        .foregroundColor(Color.white)
                        .padding(.leading)
                        .padding(.trailing)
                        .padding(.top, 2)
                        .frame(alignment: .center)
                    
                    VStack(alignment: .trailing) {
                        
                        Text(timeAsHHMMIntToStringInChat(timeAsHHMM: timeAsHHMM))
                            .frame(alignment: .leading)
                            .font(.caption)
                            .foregroundColor(Color(white: 0.9))
                            .padding(EdgeInsets(top: 1, leading: 8, bottom: 1, trailing: 8))
                        }
                }
            }
           .background(Color(UIColor.systemGray2))
           .opacity(0.8)
           .cornerRadius(30)
           .shadow(color: Color.gray, radius: 10)
           .padding(.leading, 15)
           .padding(.trailing, 15)
            
            Text("MISSING")
                .font(.system(size: 60))
                .foregroundColor(Color(UIColor.systemGray))
                .kerning(3)
                .bold()
                .rotationEffect(Angle(degrees: -11))
                .opacity(0.6)
        }
    }
}


struct OutgoingVerify: View {
    
    var message: Message
    var logPhrase: String
    var colorCode: Int
    var name: String
    var habitName: String

    var body: some View {

           HStack {
                VStack {
                    VStack(spacing: 0) {
                        
                        Text("Habit Log:  " + name + " - " + habitName)
                            .foregroundColor(Color.white)
                            .font(.headline)
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                            .padding(.leading, 13)
                            .frame(maxWidth : .infinity, alignment: .leading)
                            .padding(.bottom, 2)

                        Color.white.frame(maxWidth: .infinity, maxHeight: 2, alignment: .center).padding(.horizontal)

                        Text(logPhrase)
                            .foregroundColor(Color.white)
                            .font(.headline)
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(.top, 2)
                            .padding(.horizontal, 43)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }.frame(maxWidth: .infinity)
                    Text(message.text)
                        .font(.system(size: 13))
                        .foregroundColor(Color.white)
                        .padding(.leading)
                        .padding(.trailing)
                        .padding(.top, 2)
                        .frame(alignment: .center)
                    
                    VStack(alignment: .trailing) {
                        Text(stringToChatBubbleFormat(fullString: timeStampToLongString(timeStamp: message.id)))
                            .frame(alignment: .leading)
                            .font(.caption)
                            .foregroundColor(Color(white: 0.9))
                            .padding(EdgeInsets(top: 1, leading: 8, bottom: 1, trailing: 8))
                        }
                }
            }
           .background(colorOfUserFromCode(colorCode: colorCode))
           .cornerRadius(30)
           .opacity(0.9)
           .shadow(color: colorOfUserFromCode(colorCode: colorCode), radius: 10)
           .padding(.leading, 15)
           .padding(.trailing, 15)
        

    }

}


struct TimeBubble : View {
    let oldTimeStamp: Timestamp
    let newTimeStamp: Timestamp
    
    var body: some View {
        HStack{
            Color.gray.frame(maxWidth: 100, maxHeight: 1, alignment: .leading).padding(.trailing, 2).opacity(0.8)
            Text(getWrittenOutDate(myDate: newTimeStamp.dateValue())).font(.caption).foregroundColor(Color.gray).opacity(0.8).lineLimit(1)
            Color.gray.frame(maxWidth: 100, maxHeight: 1, alignment: .trailing).padding(.leading, 2).opacity(0.8)

        }
    }
}


struct FullChatSection: View {
    
    @EnvironmentObject var currentUserWrapper: UserWrapper

    
    @State var message: Message
    var oldTimeStamp: Timestamp
    var name: String
    var colorCode: Int
//    @Binding var seePodTutorialAgain: Bool
    @ObservedObject var podWrapper: PodWrapper
    
    var body: some View {
        
        
        //if currentUserWrapper.leftAPod {
        if currentUserWrapper.leftAPod {
            Color.white
        } else {
            VStack {
                if podWrapper.currentPod!.memberAliasesAndLogPhrase[podWrapper.getAliasFromUID(UID: message.senderID) ?? "none"] != nil || message.type == "bot intro" {
                if message.newDay {
                    TimeBubble(oldTimeStamp: oldTimeStamp, newTimeStamp: message.id)
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                }
                if message.type == "chat" {
                    if message.senderID == currentUserWrapper.currentUser!.ID {

                        OutgoingMessageView(message: message, colorCode: colorCode)
                            .id(message.id)
                            .padding(.leading)

                    } else {

                        IncomingMessageView(message: message, colorCode: colorCode, name: name)
                            .id(message.id)
                            .padding(.trailing)

                    }
                }
                else if message.type == "bot intro" {
                    BotIntro(message: message)//, seePodTutorialAgain: $seePodTutorialAgain)
                        .id(message.id)
                }
                else if message.type == "verify" {
                    if message.senderID == currentUserWrapper.currentUser!.ID {

                        OutgoingVerify(message: message,
                                       logPhrase: podWrapper.currentPod!.memberAliasesAndLogPhrase[podWrapper.getAliasFromUID(UID: message.senderID)!]!,
                                       colorCode: colorCode,
                                       name: currentUserWrapper.currentUser?.firstName ?? "",
                                       habitName: podWrapper.currentPod!.memberAliasesAndHabit[podWrapper.getAliasFromUID(UID: message.senderID)!]!)
                            .id(message.id)

                    } else {

                        IncomingVerify(message: message,
                                       logPhrase: podWrapper.currentPod!.memberAliasesAndLogPhrase[podWrapper.getAliasFromUID(UID: message.senderID)!]!,
                                       name: name,
                                       colorCode: colorCode,
                                       habitName: podWrapper.currentPod!.memberAliasesAndHabit[podWrapper.getAliasFromUID(UID: message.senderID)!]!)
                            .id(message.id)
                    }
                }
                else if message.type == "Missing Verify" && podWrapper.currentPod!.memberAliasesAndLogPhrase[podWrapper.getAliasFromUID(UID: message.senderID) ?? "none"] != nil {
                    
                    MissingVerify(message: message,
                                  logPhrase: podWrapper.currentPod!.memberAliasesAndLogPhrase[podWrapper.getAliasFromUID(UID: message.senderID)!]!,
                                  colorCode: colorCode,
                                  name: name,
                                  timeAsHHMM: podWrapper.currentPod!.memberAliasesAndTime[podWrapper.getAliasFromUID(UID: message.senderID)!]!,
                                  habitName: podWrapper.currentPod!.memberAliasesAndHabit[podWrapper.getAliasFromUID(UID: message.senderID)!]!)
                        .id(message.id)
                }
                else
                if message.type == "Info"  {
                    PodChatMemberIntro(podWrapper: podWrapper, alias: podWrapper.getAliasFromUID(UID: message.senderID) ?? "None")
                        .id(message.id)
                }
            }
            
            }.padding(.bottom, 2)
            .animation(.easeInOut)
        
        }

    }
    
//    init(message: Message, oldTimeStamp: Timestamp, podWrapper: PodWrapper, name: String, colorCode: Int){//}, seePodTutorialAgain: Binding<Bool>) {
//        self.message = message
//        self.oldTimeStamp = oldTimeStamp
//        self.podWrapper = podWrapper
//        self.name = name
//        self.colorCode = colorCode
//        //self.seePodTutorialAgain = false
//
//    }
}



struct PodChatMemberIntro: View {
    
    @ObservedObject var podWrapper: PodWrapper
    var alias: String
    @EnvironmentObject var currentUserWrapper: UserWrapper
    
    
    func getPercentScore(pod: Pod, alias: String) -> Int {
        let daysVerified = pod.memberAliasesAndScore[alias]!
        let totalHabitDays = pod.memberAliasesAndHabitDays[alias]!
        if totalHabitDays == 0 {
            return 100
        } else {
            return Int(Float(daysVerified)/Float(totalHabitDays) * 100)
        }
    }
    func convertFriendHabitTimeToLocalUserTimeAsHHMM(userSecondsFromGMT : Int, friendSecondsFromGMT : Int, timeAsHHMM : Int) -> Int {
        //friendSecondsFromGmt =
        let hours = (userSecondsFromGMT - friendSecondsFromGMT) / 3600
        var convertedTime = timeAsHHMM + hours * 100
        //shift = (-14400 - 3600) * 100 = -500
        //convertedTime = 845 + shift = 345
        if convertedTime >= 2400 {
            convertedTime = convertedTime - 2400
        } else if convertedTime < 0 {
            convertedTime = convertedTime + 2400
        }
        
        return convertedTime
    }
    
    func formPodInfoCommitmentStatement(daysArray: [Bool], timeAsHHM: Int, commitmentLength: Int) -> String {
           
            let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
            let zipped = zip(days, daysArray)
            var onDays: [String] = []
            
            for (day,boolean) in zipped {
                if boolean {
                    onDays.append(day)
                }
            }
                var timeCommitment = ""
                if onDays.count == 7 {
                    timeCommitment = "Everyday at " + timeAsHHMMIntToStringInSentance(timeAsHHMM: timeAsHHM)
                } else {

                    for day in onDays {
                        timeCommitment = timeCommitment + " " + day + ", "
                    }
                    timeCommitment =  timeCommitment + "at " + timeAsHHMMIntToStringInSentance(timeAsHHMM: timeAsHHM)
                }
//          timeCommitment = timeCommitment + "at " + timeAsHHMMIntToString(timeAsHHMM: timeAsHHM)
            //print("TIME COMMITMENT: ", timeCommitment)
        
            return timeCommitment
        
    }
                    
    
    var body: some View {
        
        if podWrapper.currentPod?.memberAliasesAndName[alias] != nil {
            
            VStack(alignment: .center, spacing: 1) {
                
                HStack {
                    
                    Color.gray.frame(maxWidth: 100, maxHeight: 1, alignment: .leading).padding(.trailing, 2).opacity(0.9)
                    Text(podWrapper.currentPod!.memberAliasesAndName[alias]! + " joined the group").font(.caption).foregroundColor(Color.gray).opacity(0.9).lineLimit(1).fixedSize(horizontal: true, vertical: false)
                    Color.gray.frame(maxWidth: 100, maxHeight: 1, alignment: .trailing).padding(.leading, 2).opacity(0.9)

                }
                
                HStack(spacing: 0) {
                    
                    Text(podWrapper.currentPod!.memberAliasesAndName[alias]! + " - ")
                        .foregroundColor(colorOfUserFromCode(colorCode: getColorCode(memberAlias: alias, currentPod: podWrapper.currentPod!)))
                        .fontWeight(.bold)
                        .font(.system(size: 17))
                        .padding(.leading, 2)
                    Text(podWrapper.currentPod!.memberAliasesAndHabit[alias]!)
                        .foregroundColor(colorOfUserFromCode(colorCode: getColorCode(memberAlias: alias, currentPod: podWrapper.currentPod!)))
                        .fontWeight(.bold)
                        .font(.system(size: 17))

                }
                
                VStack(alignment: .center) {
                        Text("After " + podWrapper.currentPod!.memberAliasesAndHabit[alias]! + ", ")
                            .font(.system(size: 14))
                            .lineLimit(1)
                        Text(podWrapper.currentPod!.memberAliasesAndName[alias]! + " will log the phrase")
                            .font(.system(size: 14))
                        Text("\"" + podWrapper.currentPod!.memberAliasesAndLogPhrase[alias]! + "\"")
                            .font(.system(size: 14))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                    Text(formPodInfoCommitmentStatement(daysArray: podWrapper.currentPod!.memberAliasesAndSchedule[alias]!,
                                                        timeAsHHM: convertFriendHabitTimeToLocalUserTimeAsHHMM(
                                                            userSecondsFromGMT: podWrapper.currentPod!.memberAliasesAndSecondsFromGMT[podWrapper.getAliasFromUID(UID: currentUserWrapper.currentUser!.ID)!]!,
                                                            friendSecondsFromGMT: podWrapper.currentPod!.memberAliasesAndSecondsFromGMT[alias]!,
                                                            timeAsHHMM: podWrapper.currentPod!.memberAliasesAndTime[alias]!),
                                                        commitmentLength: podWrapper.currentPod!.dayLimit))
                            .font(.system(size: 15))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                }
                .padding(1)
                .frame(maxWidth: .infinity, alignment: .center)
                .overlay(RoundedRectangle(cornerRadius: 15)
                            .stroke(colorOfUserFromCode(colorCode: getColorCode(memberAlias: alias, currentPod: podWrapper.currentPod!)), lineWidth: 2)
                )
                .background(Color(UIColor.systemGray5))
                .cornerRadius(15)
                .padding(.horizontal, 20)
            }
            .padding(3)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


struct ChatBubble: Shape {
    let isFromCurrentSender: Bool
    func path(in rect: CGRect) -> Path {
        let cgpath = UIBezierPath(roundedRect: rect, byRoundingCorners: [.bottomLeft, .bottomRight, isFromCurrentSender ? .topLeft : .topRight], cornerRadii: CGSize(width: 12, height: 12))
        return Path(cgpath.cgPath)
    }
}


//
//struct ChatBubble_Previews: PreviewProvider {
//    static var previews: some View {
//        
//        VStack {
//            IncomingMessageView(message: Message(text: "Welcome to your new habit group. For the next 30 days, you and your group will stick to your habit commitments.\n\n" +
//                                                    "You can tap the INFO button in the upper right of your screen to view your group's commitments.\n\n" +
//                                                    "After you do your habit for the day, log it by pressing LOG HABIT in the bottom right of your screen.\n\n" +
//                                                    "In the meantime, feel free to introduce yourself and chat with your groupmates. Good Luck!", senderID: "DUMMY", type: "chat", timeStamp: Timestamp(), isNewDay: true, messageID: "DUMMY"), colorCode: 0, name: "SENDER")
//            
//            OutgoingMessageView(message: Message(text: "DUMMY", senderID: "DUMMY", type: "chat", timeStamp: Timestamp(), isNewDay: true, colorCode: 1))
//                                
//            IncomingVerify(message: Message(text: "DUMMY", senderID: "DUMMY", type: "verify", timeStamp: Timestamp(), isNewDay: true, userID: "DUMMY", messageID: "DUMMY"), logPhrase: "01234567890123456789012345678901234567890123456789", name: "Annie", colorCode: 0)
//            
//            OutgoingVerify(message: Message(text: "Welcome to your new habit group. For the next 30 days, you and your group will stick to your habit commitments.\n\n" +
//                                                "You can tap the INFO button in the upper right of your screen to view your group's commitments.\n\n" +
//                                                "After you do your habit for the day, log it by pressing LOG HABIT in the bottom right of your screen.\n\n" +
//                                                "In the meantime, feel free to introduce yourself and chat with your groupmates. Good Luck!", senderID: "DUMMY", type: "verify", timeStamp: Timestamp(), isNewDay: true, logPhrase: "01234567890123456789012345678901234567890123456789", colorCode: 1, name: "JOE"))
//            
//            MissingVerify(message: Message(text: "", senderID: "DUMMY", type: "Missing Verify", timeStamp: Timestamp(), isNewDay: true, logPhrase: "I meditated today", colorCode: 100, name: "Nick", timeAsHHMM: 1105))
//            
//        }
//    }
//}
