//
//  PodRowView.swift
//  PODZ
//
//  Created by Nick Miller on 6/15/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import SwiftUI
import Firebase


struct PodRow: View {

    @ObservedObject var podWrapper: PodWrapper
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @Binding var activeSheet: ActiveSheet?
    @State var animateArrow = false
    
    func sortAliasesByScore(podWrapper: PodWrapper) -> [String] {
        
        let sortedTuple = podWrapper.currentPod!.memberAliasesAndScore.sorted(by: { $0.value > $1.value })
        let sortedAliases: [String] =  sortedTuple.map { $0.0 }
        return sortedAliases


    }


    var body: some View {


        if podWrapper.currentPod != nil && currentUserWrapper.currentUser != nil {

            NavigationLink(destination: PodChatView(podWrapper: podWrapper, messagesVM: MessengerViewModel(podWrapper: podWrapper, userID: currentUserWrapper.currentUser!.ID)))
            {
                ZStack {
                    Color.purple
                        HStack(spacing: 0) {
                            VStack(spacing: 0) {
                                VStack {
                                    HStack {

                                        if animateArrow {
                                            Image(systemName : "circlebadge.fill").foregroundColor(.white)
                                        }
                                        Text(podWrapper.currentPod!.podName)
                                            .foregroundColor(.white)
                                            .font(.system(size: 20))
                                            .bold()
                                            .padding(.top, 4)
                                    }
                                    Text("Day " + String(podWrapper.currentPod!.dayNumber) + "/" +  String(podWrapper.currentPod!.dayLimit))
                                        .foregroundColor(.white)
                                        .font(.system(size: 18))
                                        .padding(.top, 1)
                                        .padding(.bottom, 4)
                                }
                                .frame(maxWidth: .infinity)
                                .background(Color.purple)
                                .padding(.leading, 2)
                                .padding(.top, 2)
                                VStack(spacing: 0) {
                                    ForEach(sortAliasesByScore(podWrapper: podWrapper), id: \.self) {
                                        memberAlias in

                                            userInfoBlock(podWrapper: podWrapper, podMemberAlias: memberAlias)

                                        }
                                    if podWrapper.currentPod!.invitedFriendIDs != nil {

                                        ForEach(podWrapper.currentPod!.invitedFriendIDs!, id: \.self) { userID in
                                            pendingFriendJoinInfoBlock(podWrapper: podWrapper, userID: userID)
                                        }
                                    }
                                }
                                .animation(Animation.easeInOut(duration: 0.3))
                                .padding(.bottom, 5)
                                .padding(.horizontal, 5)
                                .background(Color(UIColor.systemGray5))
                                .cornerRadius(15)
                                .padding(EdgeInsets(top: 0, leading: 20, bottom: 15, trailing: 15))
                            }

                            Image(systemName: "chevron.right").font(.largeTitle).foregroundColor(.white)
                                .scaleEffect(animateArrow ? 1.8 : 1.4)
                                .onChange(of: podWrapper.isThereSomethingNewForUser(UID: currentUserWrapper.currentUser!.ID), perform: { value in
                                    print("")
                                    print("IN POD ROW somethingNew CHANGED = ", value)
                                    animateArrow = podWrapper.isThereSomethingNewForUser(UID: currentUserWrapper.currentUser!.ID)
                                    print("")
                                    })
                                .animation(animateArrow ? Animation.easeInOut(duration: 0.3).repeatForever(autoreverses: true) : .default)
                                .padding(15)
                        }
                }
                .cornerRadius(35, corners: [.topRight, .bottomRight])
                .padding(.trailing, 15)
                .padding(.bottom, 15)
                .onAppear {
                    print("In podrow onAppear")
                    if !currentUserWrapper.leftAPod {
                        podWrapper.updateSecondsFromGmtForUser(UID: currentUserWrapper.currentUser!.ID)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                animateArrow = podWrapper.isThereSomethingNewForUser(UID: currentUserWrapper.currentUser!.ID)
                        }
                    } else {
                        animateArrow = false
                        print("IN podrow animate arrow = false")

                    }
                }
            }
        }

        else {
            PodRowLoader()
        }
    }
}
    

//
//struct PodRow: View {
//    
//    @ObservedObject var podWrapper: PodWrapper
//    @EnvironmentObject var currentUserWrapper: UserWrapper
//    @Binding var activeSheet: ActiveSheet?
//    @State var animateArrow = false
//    @State var selection: String? = nil
//    
//    
//    var body: some View {
//        
//        
//        if podWrapper.loaded && currentUserWrapper.currentUser != nil {
//            
//            VStack(spacing: 0) {
//                NavigationLink(destination: PodChatView(podWrapper: podWrapper, messagesVM: MessengerViewModel(podWrapper: podWrapper, userID: currentUserWrapper.currentUser!.ID)),  tag: podWrapper.podID, selection: $selection) {
//                    Color.white.frame(width: 1, height: 1)
//                }
//                Button(action: {selection = podWrapper.podID} )
//                {
//                        ZStack {
//                            Color.purple
//                                HStack(spacing: 0) {
//                                    VStack(spacing: 0) {
//                                        VStack {
//                                            HStack {
//
//                                                if animateArrow {
//                                                    Image(systemName : "circlebadge.fill").foregroundColor(.white)
//                                                }
//                                                Text(podWrapper.currentPod!.podName)
//                                                    .foregroundColor(.white)
//                                                    .font(.system(size: 24))
//                                                    .bold()
//                                                    .padding(.top, 4)
//                                            }
//                                            Text("Day " + String(podWrapper.currentPod!.dayNumber) + "/" +  String(podWrapper.currentPod!.dayLimit))
//                                                .foregroundColor(.white)
//                                                .font(.system(size: 18))
//                                                .padding(.top, 1)
//                                                .padding(.bottom, 4)
//                                        }
//                                        .frame(maxWidth: .infinity)
//                                        .background(Color.purple)
//                                        .padding(.leading, 2)
//                                        .padding(.top, 2)
//                                        VStack(spacing: 0) {
//                                            ForEach(Array(podWrapper.currentPod!.memberAliasesAndIDs.keys), id: \.self) {
//                                                memberAlias in
//
//                                                    userInfoBlock(pod: self.podWrapper.currentPod!, podMemberAlias: memberAlias)
//
//                                                }
//                                            if podWrapper.currentPod!.invitedFriendIDs != nil {
//
//                                                ForEach(podWrapper.currentPod!.invitedFriendIDs!, id: \.self) { userID in
//                                                    pendingFriendJoinInfoBlock(podWrapper: podWrapper, userID: userID)
//                                                }
//                                            }
//                                        }
//                                        .padding(.bottom, 5)
//                                        .padding(.horizontal, 5)
//                                        .background(Color(UIColor.systemGray5))
//                                        .cornerRadius(15)
//                                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 15, trailing: 15))
//                                    }
//
//                                    Image(systemName: "chevron.right").font(.largeTitle).foregroundColor(.white)
//                                        .scaleEffect(animateArrow ? 1.6 : 1.2)
//                                        .onChange(of: podWrapper.isThereSomethingNewForUser(UID: currentUserWrapper.currentUser!.ID), perform: { value in
//                                            print("")
//                                            print("IN POD ROW somethingNew CHANGED = ", value)
//                                            animateArrow = podWrapper.isThereSomethingNewForUser(UID: currentUserWrapper.currentUser!.ID)
//                                            print("")
//                                            })
//                                        .animation(animateArrow ? Animation.easeInOut(duration: 0.3).repeatForever(autoreverses: true) : .default)
//                                        .padding(15)
//                                }
//                        }
//                        .cornerRadius(35, corners: [.topRight, .bottomRight])
//                        .padding(.trailing, 15)
//                        .padding(.bottom, 15)
//                        .onAppear {
//                            podWrapper.updateSecondsFromGmtForUser(UID: currentUserWrapper.currentUser!.ID)
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//                                animateArrow = podWrapper.isThereSomethingNewForUser(UID: currentUserWrapper.currentUser!.ID)
//                            }
//                        }
//                }
//                    
//                }
//            }
//        else {
//            PodRowLoader()
//        }
//    }
//}








struct pendingFriendJoinInfoBlock: View {
    
    @ObservedObject var podWrapper: PodWrapper
    var userID: String
    
    @EnvironmentObject var currentUserWrapper: UserWrapper

    
    func getFriendNameFromUserID(friendList: [User], userID: String) -> String {
        let friend = friendList.first { user in
            return user.ID == userID
        }
        return friend?.firstName ?? ""
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                //Image(profilePic)

                Text(getFriendNameFromUserID(friendList: currentUserWrapper.userFriends, userID: userID))
                    .foregroundColor(.black)
                    .italic()
                    .font(.system(size: 20))
                    .padding(.leading, 10)
                    .padding(.trailing, 5)

                Text("(Invited)")
                    .foregroundColor(.black)
                    .font(.system(size: 20))
                    .italic()
                    .padding(.trailing, 10)
                Spacer()

            }.padding(.top, 7)
            //Color.black.frame(maxWidth: .infinity, maxHeight: 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}


func getPodIDFromFriendMessage(friendMessage: String) -> String {
    let lastSpace = friendMessage.lastIndex(of: " ")!
    var podID = String(friendMessage.suffix(from: lastSpace))
    podID.removeAll { (char) -> Bool in
        return char == " "
    }
    
    return podID
}

func getDisplayMessageFromFriendMessage(friendMessage: String) -> String{
    let firstColon = friendMessage.firstIndex(of: ":")!
    let withoutPodID = friendMessage.prefix(upTo: firstColon)
    let message = withoutPodID.prefix(withoutPodID.count - 10)
    return String(message)
}

func getDisplayMessageFromPendingPodID(podID: String) -> String{
    let firstColon = podID.lastIndex(of: ":")
    if firstColon == nil {
        return podID
    } else {
        let displayMessage = podID.prefix(upTo: firstColon!)
        return String(displayMessage)
    }
}


struct PodRowLoader: View {
    
    
    var body: some View {
        
        ProgressView("Loading...").foregroundColor(.gray)
        
        
    }
}

struct LogoSpinPodRowLoader: View {
    var body: some View {
        HStack(alignment: .bottom){
            LogoSpinnerLoaderView(finishLogoSpinner: .constant(false))
            Text("One sec...")
                .foregroundColor(.purple)
                .bold()
        }.frame(maxHeight: 80)
    }
}

struct PodFinishedRow {
    
    let podSubcatagory: String
    let podMemberIDs: [String]
    @State var podMemberIDsAndBool : [(String, Bool)]
    @State var dropDownMenuActive: Bool = false
    
    @State var friendRequestSent: Bool = false
    @EnvironmentObject var currentUserWrapper: UserWrapper
    
    
    var body: some View {
        
        VStack {
            HStack {
                
                Text("Completed " + podSubcatagory + " Group")
                    .foregroundColor(.purple)
                
                Image(systemName: dropDownMenuActive ? "chevron.up": "chevron.down")
                    .foregroundColor(.purple)
                
            }.padding(15)
            
            if dropDownMenuActive {
                VStack {
                    
                    ForEach(0..<podMemberIDsAndBool.count) { i in
                        VStack {
                            HStack {
                                Text(currentUserWrapper.getUserNameFromID(ID: podMemberIDsAndBool[i].0, completion: { name in
                                    return name
                                }))
                                Spacer()
                                if podMemberIDsAndBool[i].1 {
                                    if !friendRequestSent {
                                        Button {
                                            friendRequestSent = true
                                            currentUserWrapper.sendFriendRequest(friendUID: podMemberIDsAndBool[i].0)
                                        } label: {
                                            
                                            HStack{
                                                Text("Add Friend").padding(2).foregroundColor(Color.white)
                                                Image(systemName: "plus").padding(2).foregroundColor(.white)
                                            }.frame(maxHeight: .infinity).padding(2).background(Color.purple).cornerRadius(5)
                                            
                                        }

                                    } else {
                                        HStack{
                                            
                                            Text("Request Sent").padding(2).foregroundColor(Color.white)
                                            
                                        }.frame(maxHeight: .infinity).padding(2).background(Color.purple).cornerRadius(5)
                                    }

                                }
                            }
                            Color.gray.frame(maxWidth: .infinity, maxHeight: 1).padding(.horizontal, 10)
                        }
                    }
                    
                }
            }
            
        }
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.purple, lineWidth: 7)
        )
    }
}

struct PodPendingRow: View {
    
    @State var pendingPod: PendingPod
    @State var dropDownMenuActive : Bool = false
    @EnvironmentObject var currentUserWrapper: UserWrapper
    
    var body: some View {
        VStack {
            HStack {
                Text("Pending " + (pendingPod.communityCategoryAppliedFor == nil ? "Community" : pendingPod.communityCategoryAppliedFor!) + " Group")
                .font(.title2)
                .foregroundColor(.white)
                .fontWeight(.bold)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 2))
                

                Image(systemName: dropDownMenuActive ? "chevron.up": "chevron.down")
                    .foregroundColor(.white)

            }
            .padding(.horizontal, 5)
            .padding(.vertical, 15)
            
            if dropDownMenuActive {
                VStack {
                    
                    Text("Currently finding group members.")
                        .foregroundColor(.white)
                        .padding(.top, 5)
                        .padding(.leading, 5)
                    Text("Estimated time: 5-60 minutes.")
                        .foregroundColor(.white)
                        .padding(.leading, 5)
                    Text("We'll notify you when your group is formed")
                        .foregroundColor(.white)
                        .padding(.leading, 5)
                        .padding(.bottom, 10)
                    Button(action: {
                        self.currentUserWrapper.deletePodApplication(pendingPod: pendingPod)
                    }, label: {
                        Text("Delete Group Application").foregroundColor(.white).bold().padding(.vertical, 20).padding(.horizontal, 20).background(Color.red).cornerRadius(10).padding(12)
                    })
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.gray)
        .cornerRadius(15)
        .onTapGesture {
            withAnimation {
                dropDownMenuActive.toggle()
            }
        }
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        
    }
}

struct PodInviteFromFriendRow: View {
    var pendingPod: PendingPod
    
    var body: some View {
        HStack {
            Text("Invite from " + pendingPod.friendNameWhoSentInvite!)
            .font(.system(size: 18))
                .foregroundColor(Color(#colorLiteral(red: 0.5027018405, green: 0.1169153133, blue: 0.8552948152, alpha: 0.9034176252)))
            .fontWeight(.bold)
            .padding(.leading, 10)
            Spacer()
            Image(systemName: "plus")
                .foregroundColor(Color(#colorLiteral(red: 0.5027018405, green: 0.1169153133, blue: 0.8552948152, alpha: 0.9034176252)))
                .font(.title)
                .padding(.trailing, 5)
            
        }
        .frame(width: UIScreen.main.bounds.width - 50, height: 60, alignment: .center)
        .background(Color.init("lightPurple"))
        .shadow(color: Color.init("lightPurple"), radius: 0.0)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        
    }
}
    
    
    

struct userInfoBlock: View {
   
    
    @ObservedObject var podWrapper: PodWrapper
    var podMemberAlias: String
    
    func getPercentScore(pod: Pod, alias: String) -> Int {
        
        let daysVerified = pod.memberAliasesAndScore[alias]!
        let totalHabitDays = pod.memberAliasesAndHabitDays[alias]!
        print("For " + pod.memberAliasesAndName[alias]!)
        print("DAYS VERIFIED: ", daysVerified)
        print("TOTAL HABIT DAYS: ", totalHabitDays)

        
        if totalHabitDays == 0 {
            print("totalHabitDays == 0 ", 100)
            return 100
        }
        else if daysVerified > totalHabitDays {
                print("(daysVerified > totalHabitDays) SCORE: ", 100)
                return 100
        } else {

            print("SCORE: ", Int(Float(daysVerified)/Float(totalHabitDays) * 100))
            return Int(Float(daysVerified)/Float(totalHabitDays) * 100)
        }
       
    }
    
    var body: some View {
        if podWrapper.currentPod != nil {
        VStack(spacing: 0) {
            HStack {
                //Image(profilePic)
                
                Text(podWrapper.currentPod!.memberAliasesAndName[podMemberAlias]!)
                    .foregroundColor(colorOfUserFromCode(colorCode: podWrapper.currentPod!.memberAliasesAndColorCode[podMemberAlias]!).opacity(0.8))
                    .fontWeight(.bold)
                    .font(.system(size: 20))
                    .padding(.leading, 10)
                                      
                Spacer()
                Text(String(getPercentScore(pod: podWrapper.currentPod!, alias: podMemberAlias)) + "%")
                    .foregroundColor(colorOfUserFromCode(colorCode: podWrapper.currentPod!.memberAliasesAndColorCode[podMemberAlias]!).opacity(0.8))
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .padding(.trailing, 10)
            
            }.padding(.top, 5)
            //Color.black.frame(maxWidth: .infinity, maxHeight: 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(colorOfUserFromCode(colorCode: pod.memberAliasesAndColorCode[podMemberAlias]!).accessibilityElement())
        .edgesIgnoringSafeArea(.all)
        
    }
    }
    
}


struct FinishedPodRow : View {
    @EnvironmentObject var currentUserWrapper: UserWrapper
    var finishedPod : Pod
    let aliases = ["a", "b", "c"]
    @State var showMoreInfo: Bool = false
    @Binding var activeSheet: ActiveSheet?
    @State var myAlias: String?
    @State var friendIds : [String] = []
    
    @State var friendRequestsSent : [String : Bool] = ["a" : false, "b" : false, "c" : false]
    
    
    func getAliasFromUID(UID: String, pod: Pod) -> String? {
        var flattened: [String] = []
        if UID == "BuddyUp Bot" {
            return "BuddyUp Bot"
        }
        for (alias,ID) in pod.memberAliasesAndIDs {
            flattened.append(alias)
            flattened.append(ID)
        }
        let aliasIndexPlus1 = flattened.firstIndex(of: UID)
        if aliasIndexPlus1 == nil {
            return nil
        }
        let aliasIndex = aliasIndexPlus1! - 1
//        print("_____________________")
//        print("Flattened: ", flattened)
//        print("UID: ", UID)
//        print("aliasIndex: ", aliasIndex)
//        print("Flattened[aliasIndex]: ", flattened[aliasIndex])
//        print("_____________________")
        
        return flattened[aliasIndex]
        
        
    }
    
    
    
    func helper(dayLimitString : String, habit: String) -> String {
        return "You finished a " + dayLimitString + "-day " + habit + " commitment"
    }
    
    func dateToStringConversion(startTimestamp: Timestamp) -> String {
        let dateFromTimestamp = startTimestamp.dateValue()
//        date.secondsSince1970
        let dateFromSeconds = Date(timeIntervalSince1970: dateFromTimestamp.timeIntervalSince1970)
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
         
         
        // US English Locale (en_US)
        dateFormatter.locale = Locale(identifier: "en_US")
//        print(dateFormatter.string(from: dateFromSeconds)) // Jan 2, 2001
        

        return dateFormatter.string(from: dateFromSeconds)
    }
    
    func startTimeStamopToEndDateString(startTimestamp: Timestamp, habitGroupLength: Int) -> String {
        let dateFromTimestamp = startTimestamp.dateValue()
//        date.secondsSince1970
        let dateFromSeconds = Date(timeIntervalSince1970: dateFromTimestamp.timeIntervalSince1970)
        var dateComponent = DateComponents()
        dateComponent.day = habitGroupLength
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: dateFromSeconds)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
         
         
        // US English Locale (en_US)
        dateFormatter.locale = Locale(identifier: "en_US")
//        print(dateFormatter.string(from: dateFromSeconds)) // Jan 2, 2001
        

        return dateFormatter.string(from: futureDate)
        
        
    }
    func getPercentScore(pod: Pod, alias: String) -> Int {
        let daysVerified = pod.memberAliasesAndScore[alias]!
        let totalHabitDays = pod.memberAliasesAndHabitDays[alias]!
        if totalHabitDays == 0 {
            return 100
        } else {
            return Int(Float(daysVerified)/Float(totalHabitDays) * 100)
        }
    }
    var body: some View {
        if currentUserWrapper.currentUser != nil {
        VStack {
            
            ForEach(aliases, id: \.self) { alias in
                if (finishedPod.memberAliasesAndIDs[alias] != nil && finishedPod.memberAliasesAndIDs[alias]! == currentUserWrapper.currentUser!.ID) {
                    VStack {

                        Text("Congratulations!").font(.system(size: 22)).bold().foregroundColor(.white)
                            .padding(.top, 2).padding(.bottom, 1)
                        
                        Text(helper(dayLimitString: String(finishedPod.dayLimit), habit: finishedPod.memberAliasesAndHabit[alias]!))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            
//                        HStack(spacing: 0) {
//                            Text("You completed a " + String(finishedPod.dayLimit))
//                            Text(" day " + finishedPod.memberAliasesAndHabit[alias]! + " commitment")
//                        }
//                        if Array(finishedPod.memberAliasesAndIDs.keys).count > 1 {
//                            Text("with")
//                                .font(.system(size: 22)).bold()
//                                .foregroundColor(.white)
//                        }

                    }

                }
            }
            Button(action: {showMoreInfo.toggle()}, label: {
                HStack {
                    Text(showMoreInfo ? "Hide More Info" : "Show More Info")
                        .bold()
                        .foregroundColor(.white)
                        
                    Image(systemName: showMoreInfo ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white)

                }.padding(5)
            })
            if showMoreInfo {
                VStack {
                    if finishedPod.dateCreated != nil {
                        HStack {
                            
                            Text(dateToStringConversion(startTimestamp: finishedPod.dateCreated!))
                            Text("-")
                            Text(startTimeStamopToEndDateString(startTimestamp: finishedPod.dateCreated!, habitGroupLength: finishedPod.dayLimit))
                        }
                        .padding(5)
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                    }
                    else {
                        Text(" ")
                            .padding(5)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    ForEach(aliases, id: \.self) { alias in
                        if (finishedPod.memberAliasesAndIDs[alias] != nil && finishedPod.memberAliasesAndIDs[alias]! != currentUserWrapper.currentUser!.ID) {
                            HStack {
                                Spacer()
                                Text(finishedPod.memberAliasesAndName[alias]!)
                                    .lineLimit(1)
                                    .fixedSize()
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                                    .padding(.trailing, 10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                Text(String(getPercentScore(pod: finishedPod, alias: alias)) + "%")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                                    .padding(.trailing, 10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                if currentUserWrapper.currentUser!.friendIDs.contains(finishedPod.memberAliasesAndIDs[alias]!) {
                                    
                                    Text("Already friends")
                                        .font(.system(size: 12))
                                        .foregroundColor(.black)
                                    
                                } else if currentUserWrapper.currentUser!.incomingFriendRequestIDs.contains(finishedPod.memberAliasesAndIDs[alias]!) {
                                 
                                        HStack {
                                            Text("Friend Request:")
                                                .font(.system(size: 14))
                                                .foregroundColor(.black)
                                                .lineLimit(1)
                                                .fixedSize(horizontal: true, vertical: true)
                                                
                                            Button(action: {
                                                print("TRYING TO ACCEPT FRIEND REQUEST")
                                                currentUserWrapper.removeIncomingFriendRequest(friendUID: finishedPod.memberAliasesAndIDs[alias]!)
                                                currentUserWrapper.addFriend(friendUID: finishedPod.memberAliasesAndIDs[alias]!)
                                                currentUserWrapper.addUserToFriendList(friendUID: finishedPod.memberAliasesAndIDs[alias]!)
                                                currentUserWrapper.cloudFunctionsOnFriendRequestAccepted(friendID: finishedPod.memberAliasesAndIDs[alias]!)

                                            }, label: {

                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14))
                                                    .padding(4)
                                                    .foregroundColor(.white)
                                                    .frame(maxHeight: .infinity)
                                                    .background(Color.purple)
                                                    .cornerRadius(5)

                                            })

                                            Button(action: {
                                                print("TRYING TO DENY FRIEND REQUEST")
                                                currentUserWrapper.removeIncomingFriendRequest(friendUID: finishedPod.memberAliasesAndIDs[alias]!)

                                            }, label: {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 14))
                                                    .padding(4)
                                                    .foregroundColor(.black)
                                                    .frame(maxHeight: .infinity)
                                                    .background(Color.gray.opacity(0.6))
                                                    .cornerRadius(5)
                                            })
                                        }
                                    
                                }
                                else if currentUserWrapper.currentUser!.pendingSentFriendRequestsIDs.contains(finishedPod.memberAliasesAndIDs[alias]!) {
                                    
                                    Text("Request Sent")
                                        .font(.system(size: 14))
                                        .foregroundColor(.black)
                                    
                                }
                                else {
                                    Button(action: {
                                        print("TRYING TO SEND FRIEND REQUEST")
                                        currentUserWrapper.sendFriendRequest(friendUID: finishedPod.memberAliasesAndIDs[alias]!)

                                        currentUserWrapper.cloudFunctionsOnFriendRequestSent(recieverID: finishedPod.memberAliasesAndIDs[alias]!)
                                        friendRequestsSent[alias] = true

                                    }, label: {
                                        HStack{
                                            Text("Add Friend").foregroundColor(.white).font(.system(size: 12)).bold()
                                            Image(systemName: "plus").font(.title3).foregroundColor(.white)
                                            
                                        }
                                        .padding(2).background(Color.purple).cornerRadius(10).padding(1)
                                    }).frame(maxWidth: .infinity, alignment: .trailing)
                                    

                                }
                                Spacer()
                            }//.padding(.horizontal, 15)
                            
                        }
                    }
                }.padding(2).background(Color(UIColor.systemGray5)).cornerRadius(15).padding(.horizontal, 15)
                if finishedPod.communityOrFriendGroup == "Friend" {
                    
                    
                    NavigationLink(destination:
                                    NewPodView(copyPodApplication: PodApplication(days: finishedPod.memberAliasesAndSchedule[myAlias!]!, time: finishedPod.memberAliasesAndTime[myAlias!]!, catagory: finishedPod.memberAliasesAndHabit[myAlias!]!, subCatagory: finishedPod.memberAliasesAndHabit[myAlias!], UID: finishedPod.memberAliasesAndIDs[myAlias!]!, reminderPhrase: finishedPod.memberAliasesAndReminderPhrase[myAlias!]!, logPhrase: finishedPod.memberAliasesAndLogPhrase[myAlias!]!, bans: currentUserWrapper.currentUser!.userBannedList, currentTime: Timestamp(), secondsFromGMT: finishedPod.memberAliasesAndSecondsFromGMT[myAlias!]!, friendIDs: friendIds, associatedPod: nil, commitmentLength: finishedPod.dayLimit, friendInviteMessage: "Restart our habit group!", isFriendPodLocked: false),
                                               friendIDsAndBool: Array(zip(currentUserWrapper.userFriends, [Bool](repeating: false, count: currentUserWrapper.userFriends.count))),
                                               communityOrFriendSelected: true,
                                               communityPodSelected: false,
                                               isUnaddressedInvite: false,
                                               seenFaqs: true,
                                               chosenFriends: true,
                                               chosenHabit: true,
                                               activeSheet: $activeSheet)
                                    .navigationBarHidden(true)
                                    .navigationBarBackButtonHidden(true)
                    )
                    {
                        HStack {
                        Text("Restart this friend group")
                            .foregroundColor(.purple)
                            Image(systemName: "arrow.right")
                                .foregroundColor(.purple)

                        }
                        
                            .padding(5)
                            .padding(.horizontal)
                            .background(Color.white)
                            .cornerRadius(15)
//                            .onTapGesture {
//
//                                print("Start identical community habit CLICKED")
//
//                                let myAlias = getAliasFromUID(UID: currentUserWrapper.currentUser!.ID, pod: finishedPod)!
//                                currentUserWrapper.currentPodApplication = PodApplication(days: finishedPod.memberAliasesAndSchedule[myAlias]!, time: finishedPod.memberAliasesAndTime[myAlias]!, catagory: finishedPod.memberAliasesAndHabit[myAlias]!, subCatagory: finishedPod.memberAliasesAndHabit[myAlias], UID: finishedPod.memberAliasesAndIDs[myAlias]!, reminderPhrase: finishedPod.memberAliasesAndReminderPhrase[myAlias]!, logPhrase: finishedPod.memberAliasesAndLogPhrase[myAlias]!, bans: currentUserWrapper.currentUser!.userBannedList, currentTime: Timestamp(), secondsFromGMT: finishedPod.memberAliasesAndSecondsFromGMT[myAlias]!, friendIDs: nil, associatedPod: nil, commitmentLength: finishedPod.dayLimit, friendInviteMessage: "", isFriendPodLocked: nil)
//                            }

                    }



                } else {
                    
                    NavigationLink(destination:
                                    NewPodView(copyPodApplication: PodApplication(days: finishedPod.memberAliasesAndSchedule[myAlias!]!, time: finishedPod.memberAliasesAndTime[myAlias!]!, catagory: finishedPod.memberAliasesAndHabit[myAlias!]!, subCatagory: finishedPod.memberAliasesAndHabit[myAlias!], UID: finishedPod.memberAliasesAndIDs[myAlias!]!, reminderPhrase: finishedPod.memberAliasesAndReminderPhrase[myAlias!]!, logPhrase: finishedPod.memberAliasesAndLogPhrase[myAlias!]!, bans: currentUserWrapper.currentUser!.userBannedList, currentTime: Timestamp(), secondsFromGMT: finishedPod.memberAliasesAndSecondsFromGMT[myAlias!]!, friendIDs: nil, associatedPod: nil, commitmentLength: finishedPod.dayLimit, friendInviteMessage: "", isFriendPodLocked: nil),
                                               friendIDsAndBool: Array(zip(currentUserWrapper.userFriends, [Bool](repeating: false, count: currentUserWrapper.userFriends.count))),
                                               communityOrFriendSelected: true,
                                               communityPodSelected: true,
                                               isUnaddressedInvite: false,
                                               seenFaqs: true,
                                               chosenFriends: true,
                                               chosenHabit: true,
                                               activeSheet: $activeSheet)
                                    .navigationBarHidden(true)
                                    .navigationBarBackButtonHidden(true)
                    )
                    {
                        HStack {
                        Text("Start identical community habit")
                            .foregroundColor(.purple)
                            Image(systemName: "arrow.right")
                                .foregroundColor(.purple)

                        }
                        
                            .padding(5)
                            .padding(.horizontal)
                            .background(Color.white)
                            .cornerRadius(15)
//                            .onTapGesture {
//
//                                print("Start identical community habit CLICKED")
//
//                                let myAlias = getAliasFromUID(UID: currentUserWrapper.currentUser!.ID, pod: finishedPod)!
//                                currentUserWrapper.currentPodApplication = PodApplication(days: finishedPod.memberAliasesAndSchedule[myAlias]!, time: finishedPod.memberAliasesAndTime[myAlias]!, catagory: finishedPod.memberAliasesAndHabit[myAlias]!, subCatagory: finishedPod.memberAliasesAndHabit[myAlias], UID: finishedPod.memberAliasesAndIDs[myAlias]!, reminderPhrase: finishedPod.memberAliasesAndReminderPhrase[myAlias]!, logPhrase: finishedPod.memberAliasesAndLogPhrase[myAlias]!, bans: currentUserWrapper.currentUser!.userBannedList, currentTime: Timestamp(), secondsFromGMT: finishedPod.memberAliasesAndSecondsFromGMT[myAlias]!, friendIDs: nil, associatedPod: nil, commitmentLength: finishedPod.dayLimit, friendInviteMessage: "", isFriendPodLocked: nil)
//                            }

                    }


                }
            }
        }.padding(5).frame(width: UIScreen.main.bounds.width * 4/5, alignment: .center).background(Color.purple).cornerRadius(15).padding(.vertical, 3)//.opacity(0.8)
                .onAppear {
                    myAlias = getAliasFromUID(UID: currentUserWrapper.currentUser!.ID, pod: finishedPod)
                    
                    
                    if finishedPod.communityOrFriendGroup == "Friend" {
                        let otherAliases = aliases.filter({ a in
                            return a != myAlias
                        })
                        
                        for a in otherAliases {
                            if finishedPod.memberAliasesAndIDs[a] != nil {
                                friendIds.append(finishedPod.memberAliasesAndIDs[a]!)
                            }
                        }
                    }
                }
        }
        
    }
}



func colorOfUserFromCode(colorCode: Int) -> Color {

if colorCode == 0 {
    return Color.red
} else if colorCode == 1 {
    return Color.blue
} else if colorCode == 2 {
    return Color.green
} else if colorCode == 3 {
    return Color.pink
} else if colorCode == 4 {
    return Color.orange
} else if colorCode == 5 {
    return Color.yellow
} else if colorCode == 100 {
    return Color.purple
}
    
    
    return Color.gray.opacity(0.8)
    
    
}



//struct PodRowView_Previews:
//    PreviewProvider {
//    static var previews: some View {
//        Group{
//            PodRow(podWrapper: PodWrapper(id: "DUMMY"), activeSheet: .constant(.none), selection: .constant("DUMMY"))
//
//        }
//         .previewLayout(.fixed(width: 300, height: 70))
//
//        }
//
//}
//


