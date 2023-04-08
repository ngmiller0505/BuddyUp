//
//  NewPodView.swift
//  PODZ
//
//  Created by Nick Miller on 6/15/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import SwiftUI
import Firebase
import Combine

struct NewPodView: View {

    @State var copyPodApplication: PodApplication?
    
    
    @State var subHabitSelected: String?
    @State var reminderPhrase: String  = ""
    @State var logPhrase: String = ""
    
    @State var friendIDs: [String]?
    @State var friendIDsAndBool: [(User,Bool)]
    
    @State var invitedFriends: [User]?
    
    @State var communityOrFriendSelected: Bool
    @State var communityPodSelected: Bool
    @State var isUnaddressedInvite: Bool
    @State var seenFaqs: Bool
    @State var chosenFriends: Bool
    @State var chosenHabit: Bool = false
    @State var chosenReminderPhrase: Bool = false
    @State var chosenLogPhrase: Bool = false
    @State var chosenDayAndTime: Bool = false
    
    @State var seenPodTutorial: Bool = false

    
    
    @State private var currentDate = Date()
    
    @State private var everydayChecked = false
    @State private var mondayChecked = false
    @State private var tuesdayChecked = false
    @State private var wednesdayChecked = false
    @State private var thursdayChecked = false
    @State private var fridayChecked = false
    @State private var saturdayChecked = false
    @State private var sundayChecked = false
    
    
    @State var showActionSheet = false
    @EnvironmentObject var currentUserWrapper: UserWrapper
    
    @State var applicationError: String?
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding var activeSheet: ActiveSheet?
    
    @State var showCommitmentSheet = false
    
    
    @State var daysArray = [Bool](repeating: false, count: 7)
    
    @State var pendingPodFriendInvite: PendingPod?
    @State var podToJoin: Pod?
    
    @State var appeared = false
    
    @State var showLeaveWarning = false
    
    
    @State var bypassPaywallClicked = false
    
    
    @State var timelineEnter = true
    @State var timelineExit = false
    
    
    func getPodToJoin(podID: String, completion : @escaping ((Pod?) -> ())) {
        let db = Firestore.firestore()
        db.collection("pods").document(podID).getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")

                let result = Result {
                    try document.data(as: Pod.self)
                    }
                    switch result {
                    case .success(let pod):
                        if let pod = pod {
                            completion(pod)
                        } else {
                            // A nil value was successfully initialized from the DocumentSnapshot,
                            // or the DocumentSnapshot was nil.
                            print("podToJoin does not exist")
                            completion(nil)
                            
                        }
                    case .failure(let error):
                        // A `City` value could not be initialized from the DocumentSnapshot.
                        print("Error decoding user: \(error)")
                        completion(nil)
                    }
            } else {
                print("something is wrong with firestore", (document.debugDescription))
                completion(nil)
            }
        }
    }
    
    var body: some View {
        
//
        if currentUserWrapper.currentUser != nil {

            VStack {
                VStack(spacing: 0) {
                    Button(action: {
                        if chosenHabit {
                            showLeaveWarning = true
                        } else {
                            self.presentationMode.wrappedValue.dismiss()

                        }
                    }, label: {
                        HStack(spacing: 0) {

                            Image(systemName: "chevron.backward").font(.title2).foregroundColor(.blue)
                            Text("Exit").foregroundColor(.blue)

                        }
                        .padding(.leading, 10)
                        .padding(.top, 10)
                    }).position(x: 30, y: 20).frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading).background(Color.white)

                    if communityOrFriendSelected {
                        ProgressBar(communityOrFriendSelected: $communityOrFriendSelected,
                                    seenFaqs: $seenFaqs,
                                    chosenFriends: $chosenFriends,
                                    chosenHabit: $chosenHabit,
                                    chosenReminderPhrase: $chosenReminderPhrase,
                                    chosenLogPhrase: $chosenLogPhrase,
                                    chosenDayAndTime: $chosenDayAndTime)
                    }
                }.ignoresSafeArea(.keyboard)

                ZStack {
//                    PickTimesView(chosenHabitType: $timelineEnter, chosenTimes: $timelineExit)
                    if isUnaddressedInvite {
                        InviteScreen(showActionSheet: $showActionSheet, isUnadressedInvite: $isUnaddressedInvite, pendingPodFromFriend: pendingPodFriendInvite!, podToJoin: $podToJoin)
                    }
                    else
                    if (currentUserWrapper.currentUser!.podsApartOfID.count +  currentUserWrapper.currentUser!.finishedPodIDs.count >= 1 && !currentUserWrapper.isPremium) && !bypassPaywallClicked {
                        FreeTrialLimitReachedView(bypassPaywallClicked: $bypassPaywallClicked)
                    }
                    else if !(seenPodTutorial || currentUserWrapper.currentUser!.donePodTutorial) {
                        PodTutorial2(seenPodTutorial: $seenPodTutorial)
                    }
                    else if !communityOrFriendSelected
                    {
                        communityOrFriendSelection(communityOrFriendSelected: $communityOrFriendSelected, communityPodSelected: $communityPodSelected, friendIDAndBool: $friendIDsAndBool, activeSheet: $activeSheet)
                    }
                    else if (communityPodSelected && !seenFaqs) {
                        FAQView(communityOrFriendSelected: $communityOrFriendSelected, seenFaqs: $seenFaqs)
                    }
                    else if (!communityPodSelected && !chosenFriends) {
                        FriendSelectView(communityOrFriendSelected: $communityOrFriendSelected, friendIDsAndBool: friendIDsAndBool, chosenFriends: $chosenFriends, activeSheet: $activeSheet)
                    }
                    else if ((chosenFriends || seenFaqs) && !chosenHabit) {
                        ChooseHabitView(chosenFriends: $chosenFriends, seenFaqs: $seenFaqs, chosenHabit: $chosenHabit, pendingPodFromFriend : pendingPodFriendInvite, podToJoin: podToJoin)
                    }
                    else
                    if (chosenHabit && !chosenDayAndTime) {
                        ChooseDayAndTimeView(chosenHabit: $chosenHabit,
                                             chosenDayAndTime: $chosenDayAndTime,
                                             duration: String(currentUserWrapper.currentPodApplication.commitmentLength!),
                                             currentDate: $currentDate,
                                             communityPodSelected : $communityPodSelected,
                                             daysArray: $daysArray,
                                             pendingPodInviteFromFriend: pendingPodFriendInvite)
                    }
                    else if (chosenDayAndTime && !chosenLogPhrase) {
                        LogPhraseView(chosenDayAndTime: $chosenDayAndTime, logPhrase: $logPhrase, chosenLogPhrase: $chosenLogPhrase)

                    }
                    else if (chosenLogPhrase && !chosenReminderPhrase) {
                        ReminderPhraseView(chosenLogPhrase: $chosenLogPhrase, reminderPhrase: $reminderPhrase, chosenReminderPhrase: $chosenReminderPhrase)

                    }
                    else {
                        ReviewPodApplicationView(communityPodSelected: $communityPodSelected, friendIDsAndBool: $friendIDsAndBool, showCommitmentSheet: $showCommitmentSheet, communityOrFriendSelected: $communityOrFriendSelected, chosenHabit: $chosenHabit, chosenReminderPhrase: $chosenReminderPhrase, chosenLogPhrase: $chosenLogPhrase, chosenFriends: $chosenFriends, chosenDayAndTime: $chosenDayAndTime, currentDate: $currentDate, appeared: $appeared)
                    }
                }
            }
            .onAppear {
                print("")
                print("NEW POD VIEW ON APPEAR currentUserWrapper.notificationAction = ", currentUserWrapper.notificationAction ?? "none")
                print("")
                if copyPodApplication != nil {
                    
                    currentUserWrapper.currentPodApplication = copyPodApplication!
                    seenPodTutorial = true
                    chosenDayAndTime = true
                    chosenHabit = true
                    chosenReminderPhrase = true
                    chosenLogPhrase = true
                    if copyPodApplication!.subCatagory != nil {
                        if catagories.contains(copyPodApplication!.subCatagory!) {
                            currentUserWrapper.currentPodApplication.subCatagory = "N/A"
//                        for catagory in catagories {
//                            if subCatagories[catagory]

                        }
                    }
                }
                if isUnaddressedInvite {
                    
                    getPodToJoin(podID: self.pendingPodFriendInvite!.podIDIfFriendInvite!) { podData in
                        self.podToJoin = podData

                    }
                }

                    
            }
            .alert(isPresented: $showLeaveWarning, content: {
                Alert(title: Text("Are you sure you want to leave?"), message: Text("Your new commitment data will be lost."), primaryButton: .default( Text("Leave"),
                      action: {
                        self.presentationMode.wrappedValue.dismiss()
                        showLeaveWarning = false
                        //currentUserWrapper.currentPodApplication = PodApplication(currentTime: Timestamp())
                      }
                ), secondaryButton: .cancel())
            })
        }
        else {
            PodRowLoader()
        }

    }

}


struct ProgressBar: View {
    
    @Binding var communityOrFriendSelected: Bool
    @Binding var seenFaqs: Bool
    @Binding var chosenFriends: Bool
    @Binding var chosenHabit: Bool
    @Binding var chosenReminderPhrase: Bool
    @Binding var chosenLogPhrase: Bool
    @Binding var chosenDayAndTime: Bool
    
    func proportion(progressBools: [Bool]) -> Float {
        let numTrues = progressBools.filter { i in
            return i
        }.count
        let proportion = Float(numTrues)/Float(progressBools.count)
//        print(progressBools)
//        print(proportion)
        return proportion
    }
    
    var body: some View {
        VStack(spacing: 1) {
            Text("Application Progress: " + String(Int(100 * proportion(progressBools: [communityOrFriendSelected, (seenFaqs || chosenFriends), chosenHabit, chosenReminderPhrase, chosenLogPhrase, chosenDayAndTime]))) + "%")
                .foregroundColor(.gray)
                .font(.system(size: 14, weight: .light, design: .default))
        HStack(spacing: 0) {
            
            Color.purple
                .frame(width: CGFloat(proportion(progressBools: [communityOrFriendSelected, (seenFaqs || chosenFriends), chosenHabit, chosenReminderPhrase, chosenLogPhrase, chosenDayAndTime])) * 250)
            Color.init("lightPurple")
        }
        .frame(width: 250, height: 10, alignment: .center)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.purple, lineWidth: 2)
        )
        }
        
    }
}


struct FreeTrialLimitReachedView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @State var justPaid = false
    @State var showBadPurchaseAlert: Bool = false
    
    @Binding var bypassPaywallClicked: Bool

    
    var body: some View {
        VStack {
                VStack {
                    Button {

                        self.presentationMode.wrappedValue.dismiss()
                        print("press x dismissing")

                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(alignment: .topLeading)
                            .padding(3)
                    }
                    .frame(maxWidth: .infinity, alignment: .topTrailing)
                    .padding(3)

                    Spacer()



//                if currentUserWrapper.purchaseStatus == "loading" {
//
//                    ProgressView("Loading...")
//                        .foregroundColor(.white)
//                        .accentColor(.white)
//
//                        .frame(height: UIScreen.main.bounds.height * 3/10)
//
//                        Spacer()
//
//                     }
//                else
                
                if currentUserWrapper.purchaseStatus == "Purchase Successful" {
                        VStack {
                        Text("Successfully Subscribed")
                            .foregroundColor(.white)
                            .font(.title)
                            .bold()
                            .padding()
                        }
                        Image(systemName : "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.largeTitle)

                    }
               else {

                        if currentUserWrapper.userPods.count + currentUserWrapper.pendingPods.count + currentUserWrapper.finishedPods.count == 0 {
                            VStack {
                                    Text("You have one free Habit Group ready to start at anytime.")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                        .bold()
                                        .multilineTextAlignment(.center)
                                        .padding()

                                    Text("Subscribe for unlimited habit groups.")
                                            .font(.title3)
                                            .bold()
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .padding()
                            }.animation(.easeOut)
                        }
                    else {

                            VStack {
                                Text("You've used your one free Habit group")
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .bold()
                                    .multilineTextAlignment(.center)
                                    .padding()
                                Text("Subscribe for unlimited habit groups.")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .padding()
                            }.animation(.easeIn)
                        }

                }
                    Spacer()
                    VStack {
//                        Button(action: {
//                            print("current purchaseStatus is " + (currentUserWrapper.purchaseStatus ?? "nil") + " changing now...")
//                            if currentUserWrapper.purchaseStatus == nil {
//                                currentUserWrapper.purchaseStatus = "Purchase Successful"
//                            }
//                            else if currentUserWrapper.purchaseStatus == "Purchase Successful" {
//                                currentUserWrapper.purchaseStatus = "Purchase invalid, check payment source. Please try again or contact support at NickBuddyUp@gmail.com"
//                            } else {
//                                currentUserWrapper.purchaseStatus = nil
//                            }
//
//
//                        }) {
//                            Text("Change purchase result")
//                                .foregroundColor(.purple)
//                                .bold()
//                                .padding()
//                                .frame(maxWidth: .infinity)
//                                .background(Color.white)
//                                .cornerRadius(10)
//                                .padding()
                        
//                        Button(action: {bypassPaywallClicked = true}, label: {
//                                Text("BYPASS PAYWALL")
//                                    .foregroundColor(.purple)
//                                    .bold()
//                                    .padding()
//                                    .frame(maxWidth: .infinity)
//                                    .background(Color.white)
//                                    .cornerRadius(10)
//                                    .padding()
//
//                        })
//                        }
                        Button(action: {currentUserWrapper.enterPromoCode()}, label: {
                                Text("Enter Promo Code")
                                    .foregroundColor(.purple)
                                    .bold()
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .padding()
                            
                        }).disabled(true)
                        if currentUserWrapper.packages == nil {
                            Button (action: {currentUserWrapper.getPackages { packages in
                                currentUserWrapper.packages = packages
                            }}, label: {
                                VStack {
                                    Text("Could not load packages. Please try again")
                                        .foregroundColor(.white)
                                    
                                    Image(systemName: "arrow.counterclockwise")
                                        .foregroundColor(.white)
                                }
                            }).disabled(true)

                        } else {
                        ForEach(currentUserWrapper.packages! , id: \.self) { package in
//                            Text("test").foregroundColor(.white)
                            Button(action: {

                                currentUserWrapper.purchaseSubscription(packageToPurchase: package)


                            }, label: {
                                Text((currentUserWrapper.formPackageDisplayString(package: package)))
                                    .foregroundColor(.purple)
                                    .bold()
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .padding()
                            })
                        }
                    }
                    }






    //                    Text("Note: If you are on the beta disregard this message. You've been given a free subscription. Thanks for your help").foregroundColor(.white).font(.subheadline).multilineTextAlignment(.center)
                    }
                    .background(Color.purple)
                .onChange(of: currentUserWrapper.purchaseStatus, perform: { value in
                        print("onChange of purchaseResult = ", value ?? "nil")
                        if !(value == nil || value == "Purchase Successful" || value == "loading" || value == "User Cancelled Payment") {
                            showBadPurchaseAlert.toggle()
                        }
                    })
                .onDisappear(perform: {
                    currentUserWrapper.purchaseStatus = nil
                })
                    .alert(isPresented: $showBadPurchaseAlert, content: {
                        Alert(title: Text("Purchase Unsuccessful"), message: Text(currentUserWrapper.purchaseStatus ?? ""), dismissButton: .cancel())
                    })
            }.background(Color.purple)
        
    }
}


struct communityOrFriendSelection: View {
    
    @Binding var communityOrFriendSelected : Bool
    @Binding var communityPodSelected : Bool
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @Binding var friendIDAndBool: [(User, Bool)]
    @Binding var activeSheet : ActiveSheet?
    
    
    
    var body: some View {
        
        ZStack {
            VStack(spacing: 0) {
                Text("Select a group type")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(10)

                    
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        Button(action: {
                            communityPodSelected = true
                            currentUserWrapper.currentPodApplication.friendIDs = nil
                            currentUserWrapper.currentPodApplication.commitmentLength = 30
                            
                        }, label: {

                            VStack {
                                Text("Community Group")
                                    .foregroundColor(communityPodSelected ? .white : .black)
                                    .font(.system(size: communityPodSelected ? 30 : 23))
                                    .fontWeight(communityPodSelected ? .bold : .medium )
                                    .padding(5)
                                Text("Three person group created from pool of community members interested in building similar habits.")
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(communityPodSelected ? .white : .black)
                                    .font(.system(size: communityPodSelected ? 22 : 14))
                                Spacer()
                            }
                            .padding(5)
                            .frame(maxHeight: .infinity)

                        })
                        .frame(width: communityPodSelected ? UIScreen.main.bounds.width * 3/5 :  UIScreen.main.bounds.width * 2/5)
                        .background(communityPodSelected ? Color.purple: Color(UIColor.lightGray))

                        Button(action: {communityPodSelected = false}, label: {
                            VStack{
                                Text("Friend Group")
                                    .foregroundColor(communityPodSelected ? .black : .white)
                                    .font(.system(size: communityPodSelected ? 22 : 30 ))
                                    .fontWeight(communityPodSelected ? .medium : .bold )
                                    
                                Text("Group Members invited by you from your BuddyUp friends.\n\nNote: If you want to do a solo group, you can continue and select no friends.")
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(communityPodSelected ? .black : .white)
                                    .font(.system(size: communityPodSelected ? 14 : 22))
                                    .padding(5)
                                
                                Spacer()
                                    
                            }.padding(5)
                            .frame(maxHeight: .infinity)

                        })
                        .frame(width: communityPodSelected ? UIScreen.main.bounds.width * 2/5 :  UIScreen.main.bounds.width * 3/5)
                        .background(communityPodSelected ? Color(UIColor.lightGray) : .purple)
                    }

                    Button(action: {communityOrFriendSelected = true}, label: {
                        Text("Start \(communityPodSelected ? "Community" : "Friend") Pod Application")
                            .foregroundColor(Color.purple)
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding()
                    })
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(10)
                    .padding(.bottom, 45)
                    .background(Color.purple)

                }
            }
        
        }
        .edgesIgnoringSafeArea(.all)
        .animation(.easeInOut(duration: 0.2))
      
    }
    
}

struct FAQView : View {
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @Binding var communityOrFriendSelected: Bool
    @Binding var seenFaqs: Bool
    
    var body: some View {
        VStack {
            Text("Community Pod FAQs")
                .bold()
                .font(.title)

            Spacer()
            ScrollView {

                ForEach(Array(currentUserWrapper.faqs.keys.enumerated()), id: \.element) { _, key in
                    FAQText(question: key, answer: currentUserWrapper.faqs[key]!)
                }
                .frame(alignment: .leading)
            }
            
            
            HStack {
                
                Button(action: {seenFaqs = true}, label: {
                    HStack {
                    Text("Next")
                        .foregroundColor(.white)
                        .bold()
                        .font(.title2)
                        .padding()
                        
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .cornerRadius(10)
                    .padding()
                        
                })
            }
            
            
            
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .foregroundColor(.black)
        .background(Color.white)
        .padding(5)
    }
}




struct FriendSelectView: View {
    
    @Binding var communityOrFriendSelected: Bool
    @State var friendIDsAndBool: [(User,Bool)]
    @Binding var chosenFriends: Bool
    @Binding var activeSheet: ActiveSheet?
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @State var showLessThan3FriendsAlert : Bool = false
    @State var showTooLongInviteMessage: Bool = false
    
    @State var inviteMessage = "Join my habit group!"
    @State var groupName = ""
    
    
    @State var makeFirstResonder = false
    @State var calculatedHeight : CGFloat = 37.5
    @State var isFriendPodLocked: Bool = false
    

    var body: some View {
                VStack{
                    Text("Choose Friends")
                        .fontWeight(.bold)
                        .font(.title)
                        .padding()
                        
                    VStack(spacing: 0) {
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Invite Message:")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                                .padding(5)
                                .padding(.horizontal)
                                .background(Color.purple)
                                .cornerRadius(15, corners: [.topLeft, .topRight])
                            HStack {
                                TextField("Invite Message", text: $inviteMessage)
                                .frame(height: 40)
                                .cornerRadius(5)
                                .foregroundColor(Color.black)
                                .padding(.leading, 3)
                                
                                Button(action: {
                                    inviteMessage = ""
                                }, label: {
                                    Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                                }).padding(.trailing, 5)
                            }
                            .background(Color.gray.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.purple, lineWidth: 3)
                            )
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 3, trailing: 25))
                                
                        }.padding(.leading, 5)

                        Text(String(50 - inviteMessage.count) + " characters left")
                            .font(.footnote)
                            .foregroundColor(inviteMessage.count > 50 ? .red : .black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 7)
                            .padding(.bottom, 5)
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                    
                    Toggle("Lock invited friends into my habit type?", isOn: $isFriendPodLocked)
                        .padding()
                        
                    
                    
                    if friendIDsAndBool.count == 0 {
                        VStack(spacing: 15) {
                            Text("Oops, you have no friends on BuddyUp :(")
                            Text("You can continue and do a solo commitment,")
                            Text(" or, ")
                            Text(" go back and select Community group,")
                            Text(" or, ")
                            Button(action: {activeSheet = .profileInfo}, label: {
                                Text("Search for Friends")
                            })
                        }
                        } else  {
                        ScrollView {
                            VStack(spacing: 0) {
                            ForEach(0..<friendIDsAndBool.count) { index in
                                HStack {
                                    Button(action: {
                                            //friendIDAndBool[i][1] = true
                                        friendIDsAndBool[index].1.toggle()
                                    }, label: {
                                        Image(systemName: friendIDsAndBool[index].1 ? "checkmark.square" : "square")
                                            .foregroundColor(.black)
                                            .font(.title2)
                                            .padding(.leading, 15)
                                    })
                                    friendCell(user: friendIDsAndBool[index].0, isFriendRequest: false, nonUserEmail: nil, isFriend: true)
                                        .frame(maxHeight: 70)
                                        .padding(.trailing, 10)

                                }
                                .background(Color.gray.opacity(friendIDsAndBool[index].1 ? 0.3 : 0.0))
                                .onTapGesture {
                                    UIApplication.shared.endEditing()
                                    withAnimation(.easeIn(duration: 0.1)) {
                                        friendIDsAndBool[index].1.toggle()
                                    }
                                    
                                }

                                .gesture(DragGesture(minimumDistance: 8, coordinateSpace: .global)
                                                        .onChanged({ value in

                                                            if value.translation.height > 8 && value.translation.height > abs(value.translation.width) {
                                                                UIApplication.shared.endEditing()
                                                            }
                                                        }))
                                
                            }
                            }.padding(.leading, 10)


                        }
                    }
                    
                    Spacer()
                    HStack {
                        Button(action: {
                            if inviteMessage.count > 50 {
                                showTooLongInviteMessage = true
                            }
                            else if currentUserWrapper.getFriendIDList(friendIDsAndBool: friendIDsAndBool).count > 2 {
                                showLessThan3FriendsAlert = true
                                
                            } else {
                                chosenFriends = true
                                currentUserWrapper.currentPodApplication.friendIDs = currentUserWrapper.getFriendIDList(friendIDsAndBool: friendIDsAndBool)
                                currentUserWrapper.currentPodApplication.friendInviteMessage = inviteMessage
                                currentUserWrapper.currentPodApplication.isFriendPodLocked = isFriendPodLocked

                                showLessThan3FriendsAlert = false
                                showTooLongInviteMessage = false
                            }
                        }, label: {
                            HStack {
                            Text("Next")
                                .foregroundColor(.white)
                                .bold()
                                .font(.title2)
                                .padding()
                                
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .cornerRadius(10)
                            .padding()
                        })
                    }
            }
            .onAppear {
                inviteMessage = currentUserWrapper.currentPodApplication.friendInviteMessage!
                isFriendPodLocked = currentUserWrapper.currentPodApplication.isFriendPodLocked != nil ? currentUserWrapper.currentPodApplication.isFriendPodLocked! : false
//                groupName = currentUserWrapper.currentPodApplication.podName == nil ? currentUserWrapper.currentPodApplication.podName! : (currentUserWrapper.currentUser!.firstName + "'s" + " Habit Group")
                

            }
//            .ignoresSafeArea(.keyboard)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .gesture(DragGesture(minimumDistance: 8, coordinateSpace: .global)
                                    .onChanged({ value in

                                        if value.translation.height > 8 && value.translation.height > abs(value.translation.width) {
                                            UIApplication.shared.endEditing()
                                        }
                                    }))
//            .actionSheet(isPresented: $showLessThan3FriendsAlert, content: {
//
//
//                return ActionSheet(
//                title: Text("Error Selecting friends").font(.system(size: 22)),
//                message: Text("Maximum of two friends"),
//                    buttons: [
//                    .cancel()
//                    ]
//                )
//            })
                .actionSheet(isPresented: showTooLongInviteMessage ? $showTooLongInviteMessage : $showLessThan3FriendsAlert , content: {
                
                return ActionSheet(
                    title: Text(showTooLongInviteMessage ? "Invite Message Error" : "Error Selecting friends").font(.system(size: 22)),
                    message: Text(showTooLongInviteMessage ? "Invite Message is too long" : "Maximum of two friends"),
                    buttons: [
                    .cancel()
                    ]
                )
            })
    }
            

}




struct FAQText: View {
    var question: String
    var answer: String
    
    var body : some View {
        VStack{
            Text(question)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            Text(answer)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 15)
                .padding(.leading, 15)
            
        }
    }
}







extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


struct InviteScreenMoreInfo: View {
    
    @Binding var podToJoin: Pod?
    var alias: String
    
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
        
        if podToJoin?.memberAliasesAndName[alias] != nil {
            
            VStack(alignment: .center, spacing: 1) {
                

                
                HStack(spacing: 0) {
                    
                    Text(podToJoin!.memberAliasesAndName[alias]! + " - ")
                        .foregroundColor(colorOfUserFromCode(colorCode: getColorCode(memberAlias: alias, currentPod: podToJoin!)))
                        .font(.system(size: 17))
                        .bold()
                        .padding(.leading, 2)
                    Text(podToJoin!.memberAliasesAndHabit[alias]!)
                        .foregroundColor(colorOfUserFromCode(colorCode: getColorCode(memberAlias: alias, currentPod: podToJoin!)))
                        .font(.system(size: 17))
                        .bold()

                }
                .padding(.bottom, 3)
                
                VStack(alignment: .center) {


                        Text("Log phrase: " + podToJoin!.memberAliasesAndLogPhrase[alias]! + "\"")
                            .font(.system(size: 15))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                    Text(formPodInfoCommitmentStatement(daysArray: podToJoin!.memberAliasesAndSchedule[alias]!,
                                                        timeAsHHM: convertFriendHabitTimeToLocalUserTimeAsHHMM(
                                                            userSecondsFromGMT: TimeZone.current.secondsFromGMT(),
                                                            friendSecondsFromGMT: podToJoin!.memberAliasesAndSecondsFromGMT[alias]!,
                                                            timeAsHHMM: podToJoin!.memberAliasesAndTime[alias]!),
                                                        commitmentLength: podToJoin!.dayLimit))
                            .font(.system(size: 15))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                }
                .padding(1)
                .frame(maxWidth: .infinity, alignment: .center)
                .overlay(RoundedRectangle(cornerRadius: 15)
                            .stroke(colorOfUserFromCode(colorCode: getColorCode(memberAlias: alias, currentPod: podToJoin!)), lineWidth: 3)
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


struct InviteScreen: View {
    
    @Binding var showActionSheet: Bool
    @Binding var isUnadressedInvite: Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @State var failedToLoadPod = false
    let pendingPodFromFriend: PendingPod
    @Binding var podToJoin: Pod?
    @State var showFullInviteInfo: Bool = false
    
    //TODO: LOAD POD DATA FROM PENDING podID SO WE CAN ADD IN MORE POD INFO
    
    func checkIfFriendPodExists(friendUsers : [User], pendingPod: PendingPod) -> Bool {
        let friendWhoInvitedUser = friendUsers.filter { user in
            return user.ID == pendingPod.UID
        }
        if friendWhoInvitedUser.isEmpty {
            return false
        }
        let filteredFriendPodIDs = friendWhoInvitedUser[0].podsApartOfID.filter { podID in
            return podID == pendingPod.podIDIfFriendInvite!
        }
        return !filteredFriendPodIDs.isEmpty
        
    }
    

    var body: some View {
        if failedToLoadPod {
            if checkIfFriendPodExists(friendUsers: currentUserWrapper.userFriends, pendingPod: pendingPodFromFriend)
            {
                VStack {
                    Text("Invite could not be found")
                        .fontWeight(.bold)
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15))
                        .font(.largeTitle)
                        .foregroundColor(.purple)
                    Text("It's probably our bad, but make sure to check your internet connection and please try again later.")
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                        .padding(EdgeInsets(top: 5, leading: 15, bottom: 0, trailing: 15))

                }

            } else {
                VStack {

                    Spacer()
                    
                    Text("Invite does not exist.")
                        .fontWeight(.bold)
                        .padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15))
                        .font(.largeTitle)
                        .foregroundColor(.purple)
                    Text("The person who invited you probably ended the group.")
                        .fontWeight(.bold)
                        .padding(EdgeInsets(top: 5, leading: 15, bottom: 0, trailing: 15))
                        .font(.title2)
                        .foregroundColor(.purple)
                    
                    Spacer()
                    
                    Button(action: {
                        currentUserWrapper.deleteFriendPodInvite(pendingPod: pendingPodFromFriend)
                        print("deleted friendPodInvite. dismissing")

                        self.presentationMode.wrappedValue.dismiss()

                    }, label: {
                        VStack{
                            Text("Remove invite")
                                .foregroundColor(.white)
                                .font(.title)
                                .fontWeight(.semibold)
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.title)
                        }
                        .padding(5)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.horizontal, 5)
                    })
                    Spacer()
                }
            }
        } else {
        VStack {
            
            Spacer()
            
            VStack {

                Text("Invite from ")
                    .fontWeight(.bold)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                    .font(.title)
                    .foregroundColor(.purple)
                Text(pendingPodFromFriend.friendNameWhoSentInvite!)
                    .fontWeight(.bold)
                    .font(.title)
                    .foregroundColor(.purple)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))

                Text(pendingPodFromFriend.friendInviteMessage!)
                    .fontWeight(.bold)
                    .font(.title3)
                    .foregroundColor(.purple)
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))

            }
            .border(Color.purple, width: 3)
            .padding(5)
            .padding(.bottom)
            
            if podToJoin != nil {
                
                VStack {
                    
                    
                
                    Button(action: {withAnimation {showFullInviteInfo.toggle()}}, label: {
                        HStack {
                            Text("Show More Details")
                                .foregroundColor(Color(UIColor.systemGray))
                                .font(.system(size: 19))
                                .bold()

                                
                            Image(systemName: showFullInviteInfo ? "chevron.up" : "chevron.down")
                                .foregroundColor(Color(UIColor.systemGray))
                        }
                        .padding(5)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                    })
                
                    if showFullInviteInfo {

                        VStack {
                            Spacer()
                            Text("Group Length: " + String(podToJoin!.dayLimit) + " days")
                                .foregroundColor(.purple)
                                .fontWeight(.bold)
                                .font(.system(size: 17))
                            Spacer()
                            InviteScreenMoreInfo(podToJoin: $podToJoin, alias: "a")
                            InviteScreenMoreInfo(podToJoin: $podToJoin, alias: "b")
                        }.padding(.vertical, 10)
                        
                        if pendingPodFromFriend.isFriendPodLockedIn! {
                            VStack {
                                Text("Note: " + pendingPodFromFriend.friendNameWhoSentInvite! +  " has chosen to lock this group's habit.")
                                    .foregroundColor(Color(UIColor.systemGray))
                                    .font(.caption)
                                Text("You must do a " + podToJoin!.memberAliasesAndHabit["a"]! + " habit.")
                                    .foregroundColor(Color(UIColor.systemGray))
                                    .font(.caption)

                            }.padding(5)
                        } else {
                            Text("Note: You can pick any habit to work on for this group.")
                                .foregroundColor(Color(UIColor.systemGray))
                                .font(.caption)
                                .padding(5)
                                
                        }

                    }


                }
                .background(Color(UIColor.systemGray5))
                .cornerRadius(15)
                .overlay(RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.purple, lineWidth: 2)
                )
                .padding()
            }

            
            
            VStack {
                Button(action: {



                    currentUserWrapper.currentPodApplication.associatedPod = pendingPodFromFriend.podIDIfFriendInvite!

                    currentUserWrapper.getSinglePod(podID: pendingPodFromFriend.podIDIfFriendInvite!, completion: { (pod) in
                    
                        if pendingPodFromFriend.isFriendPodLockedIn != nil {
                            //if friend wanted to lock groupmates in, we must set their catagory and subcatagory here
                            
                            if pendingPodFromFriend.isFriendPodLockedIn! {
                                if podToJoin != nil {
                                    if catagories.contains(podToJoin!.memberAliasesAndHabit["a"]!) {
                                        currentUserWrapper.currentPodApplication.subCatagory = nil
                                        currentUserWrapper.currentPodApplication.catagory = podToJoin!.memberAliasesAndHabit["a"]!
                                       
                                    } else {
                                        for cat in catagories {
                                            if subCatagories[cat]!.contains(podToJoin!.memberAliasesAndHabit["a"]!) {
                                                currentUserWrapper.currentPodApplication.catagory = cat
                                                currentUserWrapper.currentPodApplication.subCatagory = podToJoin!.memberAliasesAndHabit["a"]!
                                            }
                                        }
                                        if currentUserWrapper.currentPodApplication.catagory == nil {
                                            currentUserWrapper.currentPodApplication.catagory = podToJoin!.memberAliasesAndHabit["a"]!
                                            currentUserWrapper.currentPodApplication.subCatagory = nil
                                        }

                                    }
                                    
                                    
                                } else {
                                    currentUserWrapper.currentPodApplication.isFriendPodLocked = false
                                }
                            }
                        }
                        if pod == nil {
                            failedToLoadPod = true

                        }
                        else {
                            currentUserWrapper.currentPodApplication.friendIDs = pod!.invitedFriendIDs?.filter({ (id) -> Bool in
                                id != currentUserWrapper.currentUser!.ID
                            })
                            //add third user id

                            currentUserWrapper.currentPodApplication.friendIDs?.append(pod!.memberAliasesAndIDs["a"]!)
                            //add original sender user id
                            currentUserWrapper.currentPodApplication.commitmentLength = pendingPodFromFriend.commitmentLength

                            isUnadressedInvite = false
                        }
                    })

                }, label: {
                    VStack {
                        Text("Start Commitment")
                            .foregroundColor(.white)
                            .font(.title)
                            .fontWeight(.semibold)
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.title)
                    }.padding(5)
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(5)
                })


                Button(action: {
                    currentUserWrapper.deleteFriendPodInvite(pendingPod: pendingPodFromFriend)
                    print("deleted friendPodInvite. dismissing")

                    self.presentationMode.wrappedValue.dismiss()

                }, label: {
                    VStack{
                        Text("Deny")
                            .foregroundColor(.white)
                            .font(.title)
                            .fontWeight(.semibold)
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
                    .padding(.horizontal, 5)
                })

            }
            
            Spacer()
            
        }

        }
        
        
        
    }
}


func formPhraseCommitmentClarification(phrase: String, daysArray: [Bool], time: Date, commitmentLength: Int) -> String {
    
    var phraseCommitmentClarification = "Your phrase, "
    let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    let zipped = zip(days, daysArray)
    var onDays: [String] = []

    
    for (day,boolean) in zipped {
        if boolean {
            onDays.append(day)
        }

    }
    

    let formatter2 = DateFormatter()
    formatter2.timeStyle = .short
    let localTimeSelectedAsString = formatter2.string(from: time)
    print(localTimeSelectedAsString)
    var timeCommitment = ""
//
    if onDays.count == 7 {
        timeCommitment = " Everyday at " + localTimeSelectedAsString
    } else {

        for day in onDays {
            timeCommitment = timeCommitment + " " + day + ", "
        }
//
        timeCommitment = timeCommitment + "at "
        timeCommitment = timeCommitment + localTimeSelectedAsString
//
    }
    
//
    
    phraseCommitmentClarification = timeCommitment
    phraseCommitmentClarification = phraseCommitmentClarification + " for " + String(commitmentLength) + " days."
     
    return phraseCommitmentClarification
}

var catagories = ["Exercise", "Meditation", "Dieting", "Journaling", "Reading", "Studying", "Creative Work", "Waking Up Early","Other"]

var subCatagories = ["Exercise": ["Weight Lifting", "Yoga", "Running", "Sports", "Other"],
                "Creative Work": ["Practicing Music", "Writing", "Programming", "Drawing", "Other"],
                "Dieting": ["Keto Dieting", "Vegan Dieting", "Paleo Dieting", "Drinking Water","Other"],
                "Journaling": ["N/A"],
                "Studying": ["N/A"],
                "Reading": ["N/A"],
                "Meditation": ["N/A"],
                "Waking Up Early":["N/A"],
                "Other": ["N/A"]]

struct ChooseHabitView: View {
    
    @Binding var chosenFriends: Bool
    @Binding var seenFaqs: Bool
    @Binding var chosenHabit: Bool

    

    @State private var catagoryIndex = 0
    @State private var subCatagoryIndex = 0
    
    @State var otherSpecify: String = ""
    @State var otherSubSpecify: String = ""
    @State var showActionSheet = false
    
    @State var subHabitSelected: String?
    var pendingPodFromFriend: PendingPod?
    var podToJoin: Pod?
    @EnvironmentObject var currentUserWrapper: UserWrapper
    
    var body: some View {
        VStack (spacing: 0){
            
            Text("Choose Habit")
                .fontWeight(.bold)
                .font(.title2)
                .padding(.bottom, 10)
            
            if pendingPodFromFriend != nil {
                if pendingPodFromFriend!.isFriendPodLockedIn! {
                    VStack {
                        Text("Note: " + pendingPodFromFriend!.friendNameWhoSentInvite! +  " has chosen to lock this group's habit.")
                            .foregroundColor(Color(UIColor.systemGray))
                            .font(.caption)
                        Text("You must do a " + podToJoin!.memberAliasesAndHabit["a"]! + " habit.")
                            .foregroundColor(Color(UIColor.systemGray))
                            .font(.caption)

                    }.padding(5)
                } else {
                    Text("Note: You can pick any habit to work on for this group.")
                        .foregroundColor(Color(UIColor.systemGray))
                        .font(.caption)
                        .padding(5)
                }
            }
            Section(header: Text("")){
                Text("Habit")
                    .fontWeight(.bold)
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))

                Picker(selection: $catagoryIndex, label: Text("Habit")) {
                    ForEach(0..<catagories.count){
                        Text(catagories[$0])
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxHeight: 70)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))

                if catagories[catagoryIndex] == "Other" {
                    VStack {
                        HStack(spacing: 5) {
                            TextField("If other, please specify habit", text: $otherSpecify)
                                .padding(EdgeInsets(top: 10, leading: 8, bottom: 4, trailing: 0))
                                .background(Color.gray.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                            Button(action: {


                                if catagories[catagoryIndex] == "Other" {
                                    if otherSpecify.count < 3 || otherSpecify.count > 25 {
                                        showActionSheet = true
                                    } else {
                                        currentUserWrapper.currentPodApplication.catagory = otherSpecify
                                        currentUserWrapper.currentPodApplication.subCatagory = "N/A"
                                        chosenHabit = true
                                        currentUserWrapper.currentPodApplication.UID = currentUserWrapper.currentUser!.ID
                                    }
                                } else if subCatagories[catagories[catagoryIndex]]![subCatagoryIndex] == "Other"{

                                    if otherSubSpecify.count < 3 || otherSubSpecify.count > 25 {
                                        showActionSheet = true
                                    } else {
                                        currentUserWrapper.currentPodApplication.catagory =  catagories[catagoryIndex]
                                        currentUserWrapper.currentPodApplication.subCatagory = otherSubSpecify
                                        chosenHabit = true
                                        currentUserWrapper.currentPodApplication.UID = currentUserWrapper.currentUser!.ID
                                    }

                                } else {
                                    chosenHabit = true
                                    currentUserWrapper.currentPodApplication.UID = currentUserWrapper.currentUser!.ID
                                    currentUserWrapper.currentPodApplication.catagory =  catagories[catagoryIndex]
                                    currentUserWrapper.currentPodApplication.subCatagory = subCatagories[catagories[catagoryIndex]]![subCatagoryIndex]
                                }



                            }, label: {

                                Image(systemName: "arrow.right").font(.title3).foregroundColor(.white).padding().background(Color.purple).clipShape(Circle())
                                }
                            )

                        }
                        Text(String(25 - otherSpecify.count) + " characters left")
                            .font(.footnote)
                            .foregroundColor(otherSpecify.count > 25 ? .red : .black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 7)
                            .padding(.bottom, 5)

                    }

                }
                else if subCatagories[catagories[catagoryIndex]]!.count > subCatagoryIndex {
                    VStack {
                        Text("Subcatagory")
                            .fontWeight(.bold)
                            .font(.title3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(EdgeInsets(top: 60, leading: 10, bottom: 0, trailing: 10))


                            Picker(selection: $subCatagoryIndex, label: Text("Type of " + catagories[catagoryIndex])) {

                                ForEach(0..<subCatagories[catagories[catagoryIndex]]!.count, id: \.self){

                                    Text(subCatagories[catagories[catagoryIndex]]![$0])

                                    }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxHeight: 70)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))

                            if subCatagories[catagories[catagoryIndex]]![subCatagoryIndex] == "Other" {

                                VStack {
                                    HStack {
                                        TextField("If other, please specify habit", text: $otherSubSpecify)
                                            .padding(EdgeInsets(top: 10, leading: 8, bottom: 4, trailing: 0))
                                            .background(Color.gray.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(Color.gray, lineWidth: 1)
                                            )
                                            .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                                        Button(action: {


                                            if catagories[catagoryIndex] == "Other" {
                                                if otherSpecify.count < 3 || otherSpecify.count > 25 {
                                                    showActionSheet = true
                                                } else {
                                                    currentUserWrapper.currentPodApplication.catagory = otherSpecify
                                                    currentUserWrapper.currentPodApplication.subCatagory = "N/A"
                                                    chosenHabit = true
                                                    currentUserWrapper.currentPodApplication.UID = currentUserWrapper.currentUser!.ID
                                                }
                                            } else if subCatagories[catagories[catagoryIndex]]![subCatagoryIndex] == "Other"{

                                                if otherSubSpecify.count < 3 || otherSubSpecify.count > 25 {
                                                    showActionSheet = true
                                                } else {
                                                    currentUserWrapper.currentPodApplication.catagory =  catagories[catagoryIndex]
                                                    currentUserWrapper.currentPodApplication.subCatagory = otherSubSpecify
                                                    chosenHabit = true
                                                    currentUserWrapper.currentPodApplication.UID = currentUserWrapper.currentUser!.ID
                                                }

                                            } else {
                                                chosenHabit = true
                                                currentUserWrapper.currentPodApplication.UID = currentUserWrapper.currentUser!.ID
                                                currentUserWrapper.currentPodApplication.catagory =  catagories[catagoryIndex]
                                                currentUserWrapper.currentPodApplication.subCatagory = subCatagories[catagories[catagoryIndex]]![subCatagoryIndex]
                                            }
                                            if currentUserWrapper.currentPodApplication.commitmentLength == nil {
                                                currentUserWrapper.currentPodApplication.commitmentLength = 30
                                            }


                                        }, label: {

                                            Image(systemName: "arrow.right").font(.title).foregroundColor(.white).padding(3).background(Color.purple).clipShape(Circle()).padding(.leading, 3)
                                            }
                                        )


                                    }
                                    Text(String(25 - otherSubSpecify.count) + " characters left")
                                        .font(.footnote)
                                        .foregroundColor(otherSubSpecify.count > 25 ? .red : .black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.leading, 7)
                                        .padding(.bottom, 5)
                                }

                            }
                    }
                }
            }
//            .offset(y: UIScreen.main.bounds.height * -1/11)
            .disabled(pendingPodFromFriend != nil ? (pendingPodFromFriend!.isFriendPodLockedIn! ? true : false) : false)
            .opacity(pendingPodFromFriend != nil ? (pendingPodFromFriend!.isFriendPodLockedIn! ? 0.5 : 1) : 1)
            
            Spacer()
            HStack {

                Button(action: {
                    chosenFriends = false
                    seenFaqs = false

                }, label: {
                    HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)

                        Text("Back")
                            .foregroundColor(.black)
                            .bold()
                            .font(.title2)
                            .padding()

                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding()

                    }
                )
                Button(action: {

                    if catagories[catagoryIndex] == "Other" {
                        if otherSpecify.count < 3 || otherSpecify.count > 25 {
                            showActionSheet = true
                        } else {
                            currentUserWrapper.currentPodApplication.catagory = "Other"
                            currentUserWrapper.currentPodApplication.subCatagory = otherSpecify
                            chosenHabit = true
                            currentUserWrapper.currentPodApplication.UID = currentUserWrapper.currentUser!.ID
                        }
                    } else if subCatagories[catagories[catagoryIndex]]![subCatagoryIndex] == "Other"{

                        if otherSubSpecify.count < 3 || otherSubSpecify.count > 25 {
                            showActionSheet = true
                        } else {
                            currentUserWrapper.currentPodApplication.catagory =  catagories[catagoryIndex]
                            currentUserWrapper.currentPodApplication.subCatagory = otherSubSpecify
                            chosenHabit = true
                            currentUserWrapper.currentPodApplication.UID = currentUserWrapper.currentUser!.ID
                        }

                    } else {
                        chosenHabit = true
                        currentUserWrapper.currentPodApplication.UID = currentUserWrapper.currentUser!.ID
                        currentUserWrapper.currentPodApplication.catagory =  catagories[catagoryIndex]
                        currentUserWrapper.currentPodApplication.subCatagory = subCatagories[catagories[catagoryIndex]]![subCatagoryIndex]
                    }

                    if currentUserWrapper.currentPodApplication.commitmentLength == nil {
                        currentUserWrapper.currentPodApplication.commitmentLength = 30
                    }


                }, label: {
                    HStack {
                    Text("Next")
                        .foregroundColor(.white)
                        .bold()
                        .font(.title2)
                        .padding()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .cornerRadius(10)
                    .padding()
                    }
                )

            }
        }
        .onAppear {
            //If pod is locked by friend, catagory and subcatagory are already set when invite is accepted
                if pendingPodFromFriend != nil {
                    if pendingPodFromFriend!.isFriendPodLockedIn! {
                        
                            if catagories.contains(currentUserWrapper.currentPodApplication.catagory!) {
                                catagoryIndex = catagories.firstIndex(of: currentUserWrapper.currentPodApplication.catagory!)!
                                if currentUserWrapper.currentPodApplication.subCatagory != nil {
                                    subCatagoryIndex = subCatagories[currentUserWrapper.currentPodApplication.catagory!]!.firstIndex(of: currentUserWrapper.currentPodApplication.subCatagory!)!
                                    print("friend invite is locked in")
                                    print("catagory: ", currentUserWrapper.currentPodApplication.catagory!)
                                    print("subcatagory: ", currentUserWrapper.currentPodApplication.subCatagory!)
                                    print("catagoryIndex: ", catagoryIndex)
                                    print("catagories[catagoryIndex]: ", catagories[catagoryIndex])
                                    print("subCatagoryIndex: ", subCatagoryIndex)
                                    print("subCatagories[catagories[catagoryIndex]][subCatagoryIndex]: ", subCatagories[catagories[catagoryIndex]]![subCatagoryIndex])
                                }
                            } else {
                                //catagory is other
                                catagoryIndex = catagories.count - 1
                                otherSpecify = currentUserWrapper.currentPodApplication.catagory!
                            }
                        }
                }
        
            
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                            .onEnded({ value in

                                if value.translation.height > 0 {
                                    UIApplication.shared.endEditing()
                                }
                            }))
        
//        .ignoresSafeArea(.keyboard)
        .onChange(of: catagoryIndex, perform: { value in
            print("subCatagoryIndex: ", subCatagoryIndex)
            print("catagoryIndex: ", catagoryIndex)
            if pendingPodFromFriend != nil {
                if pendingPodFromFriend!.isFriendPodLockedIn! {
                    print("friendPodLockedin")
                } else {
                    subCatagoryIndex = 0

                }
            } else{
                subCatagoryIndex = 0
            }
        })
        .onChange(of: subCatagoryIndex, perform: { value in
            print("subCatagoryIndex: ", subCatagoryIndex)
            print("catagoryIndex: ", catagoryIndex)
        })
        .actionSheet(isPresented: $showActionSheet, content: {

            return ActionSheet(
                title: Text("Habit Selection Error").font(.system(size: 22)),
                message: Text(otherSpecify.count < 3 ? "Please make your habit at least 3 characters." : "Please make your habit no more than 25 characters."),
                buttons: [
                .cancel()
                ]
            )
        })
    }
}


struct ChooseDayAndTimeView: View {
    
    @Binding var chosenHabit: Bool
    @Binding var chosenDayAndTime: Bool
    @EnvironmentObject var currentUserWrapper: UserWrapper
    
    @State var duration: String
    @State var errorMessage = ""
    
    @Binding var currentDate: Date
    @State var noDaysSelected = true
    @State var displayAlert = false
    
    @State private var everydayChecked = false
    @State private var mondayChecked = false
    @State private var tuesdayChecked = false
    @State private var wednesdayChecked = false
    @State private var thursdayChecked = false
    @State private var fridayChecked = false
    @State private var saturdayChecked = false
    @State private var sundayChecked = false
    
    @Binding var communityPodSelected: Bool
    @State var message: String = ""
    
    @Binding var daysArray: [Bool]
    
    let pendingPodInviteFromFriend: PendingPod?
        
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {

            Text("Select Days And Time")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 15, trailing: 0))

            if currentUserWrapper.currentPodApplication.catagory == "Dieting" {
                Text("Note: Most dieting habits work best if commited to everyday and logged after your last meal of the day").font(.caption).foregroundColor(Color.gray).multilineTextAlignment(.leading).padding(.bottom).padding(.horizontal, 10)
            } else {
                Text("Note: It is important to do your habit at the same time everyday.").font(.caption).foregroundColor(Color.gray).multilineTextAlignment(.leading).padding(.bottom).padding(.horizontal, 10)
                
            }
            DatePicker("Select Time", selection: $currentDate, displayedComponents: .hourAndMinute).datePickerStyle(WheelDatePickerStyle())
                .datePickerStyle(WheelDatePickerStyle())
                .frame(width: .infinity, height: 80, alignment: .center)
                .clipped()
                .foregroundColor(.purple)
                .accentColor(.purple)
                .labelsHidden()
                .frame(width: .infinity, height: 80, alignment: .center)


            Spacer()
            
            HStack {
            VStack {
                Button(action:{
                    self.everydayChecked.toggle()

                    if self.everydayChecked {
                        daysArray = [Bool](repeating: true, count: 7)

                    }
                },label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: self.everydayChecked ? "checkmark.square" : "square")
                            .foregroundColor(.purple)
                            .font(.title3)

                        Text("Every Day")
                            .fontWeight(self.everydayChecked ? .bold : .none)
                            .foregroundColor(.purple)
                            .font(.title3)
                    }
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 7, bottom: 1, trailing: 7))

                Button(action:{
                    self.daysArray[0].toggle()
                },label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: self.daysArray[0] ? "checkmark.square" : "square")
                            .foregroundColor(.purple)
                            .font(.title3)

                        Text("Sunday")
                            .fontWeight(self.daysArray[0] ? .bold : .none)
                            .foregroundColor(.purple)
                            .font(.title3)
                    }
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 7, bottom: 1, trailing: 7))


                Button(action:{
                    self.daysArray[1].toggle()
                },label:  {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: self.daysArray[1] ? "checkmark.square" : "square")
                            .foregroundColor(.purple)
                            .font(.title3)

                        Text("Monday")
                            .fontWeight(self.daysArray[1] ? .bold : .none)
                            .foregroundColor(.purple)
                            .font(.title3)
                    }
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 7, bottom: 1, trailing: 7))

                Button(action:{
                    self.daysArray[2].toggle()
                }, label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: self.daysArray[2] ? "checkmark.square" : "square")
                            .foregroundColor(.purple)
                            .font(.title3)

                        Text("Tuesday")
                            .fontWeight(self.daysArray[2] ? .bold : .none)
                            .foregroundColor(.purple)
                            .font(.title3)
                        }

                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 7, bottom: 1, trailing: 7))

                Button(action:{
                    self.daysArray[3].toggle()
                }, label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: self.daysArray[3] ? "checkmark.square" : "square")
                            .foregroundColor(.purple)
                            .font(.title3)

                        Text("Wednesday")
                            .fontWeight(self.daysArray[3] ? .bold : .none)
                            .foregroundColor(.purple)
                            .font(.title3)
                    }
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 7, bottom: 1, trailing: 7))
    //
                Button(action:{
                    self.daysArray[4].toggle()
                },label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: self.daysArray[4] ? "checkmark.square" : "square")
                            .foregroundColor(.purple)
                            .font(.title3)

                        Text("Thursday")
                            .fontWeight(self.daysArray[4] ? .bold : .none)
                            .foregroundColor(.purple)
                            .font(.title3)
                    }
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 7, bottom: 1, trailing: 7))
    //
                Button(action: {
                    self.daysArray[5].toggle()
                } ,label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: self.daysArray[5] ? "checkmark.square" : "square")
                            .foregroundColor(.purple)
                            .font(.title3)

                        Text("Friday")
                            .fontWeight(self.daysArray[5] ? .bold : .none)
                            .foregroundColor(.purple)
                            .font(.title3)
                    }
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 7, bottom: 1, trailing: 7))

                Button(action: {
                    self.daysArray[6].toggle()
                }, label: {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: self.daysArray[6] ? "checkmark.square" : "square")
                            .foregroundColor(.purple)
                            .font(.title3)

                        Text("Saturday")
                            .fontWeight(self.daysArray[6] ? .bold : .none)
                            .foregroundColor(.purple)
                            .font(.title3)
                    }
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 0, leading: 7, bottom: 1, trailing: 7))
                .padding(.bottom, 10)

            }.padding(.bottom, 10)
                
                VStack {
                Text("Duration")
                    HStack(spacing: 3) {
                    TextField("", text: $duration)
                        .keyboardType(.numberPad)
                        .onReceive(Just(duration)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.duration = filtered
                            }
                        }
                        .frame(width: 40)
                        .padding(3)
                        .background(Color.white)
                        .cornerRadius(5)
                        .padding(3)
                        Text("days")
                    }
                    
                    if !communityPodSelected && !currentUserWrapper.isPremium {

                        Text("Subscription required for custom habit length")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    else if pendingPodInviteFromFriend != nil {
                            Text("Group Creator sets habit length")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        
                        
                    } else if communityPodSelected {
                        
                        Text("Duration set at 30 days for all community groups. Switch to friend group application to change duration length.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(13)
                .background(Color(UIColor.systemGray3))
                .cornerRadius(7)
                .padding()
                .disabled(!currentUserWrapper.isPremium  || communityPodSelected || (pendingPodInviteFromFriend != nil))
                .opacity((!currentUserWrapper.isPremium || communityPodSelected || (pendingPodInviteFromFriend != nil)) ? 0.5 : 1)
                
            }.onTapGesture {
                UIApplication.shared.endEditing()
            }

        
            
                
            
            
            Spacer()

            Text(formPhraseCommitmentClarification(phrase: "fdsafds", daysArray: daysArray, time: currentDate, commitmentLength: Int(duration) ?? 30))
                .font(.system(size: 20))
                .bold()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .fixedSize(horizontal: false, vertical: true)

            
            Spacer()
            
            HStack {
                Button(action: {
                    chosenHabit = false


                }, label: {
                    HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                    Text("Back")
                        .foregroundColor(.black)
                        .bold()
                        .font(.title2)
                        .padding()


                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding()



                    }
                )

            Button(action: {

                if daysArray.allSatisfy({ $0 == false }) {
                    errorMessage = "Please select at least one day"
                    displayAlert = true
                } else if duration == "" || Int(duration) == 0 {
                    errorMessage = "Please enter a valid duration"
                    displayAlert = true

                }
                else {
                    chosenDayAndTime = true
                    currentUserWrapper.currentPodApplication.daysOfTheWeek = daysArray
                    let timeAsHHMM: Int =  Calendar.current.component(.hour, from: currentDate) * 100 + Calendar.current.component(.minute, from: currentDate)
                    currentUserWrapper.currentPodApplication.timeOfDay = timeAsHHMM
                    currentUserWrapper.currentPodApplication.commitmentLength = Int(duration)
                }

            }, label: {
                HStack {
                Text("Next")
                    .foregroundColor(.white)
                    .bold()
                    .font(.title2)
                    .padding()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .background(Color.purple)
                .cornerRadius(10)
                .padding()

                })

            }
            
       }
        .gesture(DragGesture(minimumDistance: 15, coordinateSpace: .local)
                .onEnded({ value in

                    if value.translation.height > 0 {
                        UIApplication.shared.endEditing()
                    }
                }))
        .animation(.easeInOut(duration: 0.2))
        .frame(maxWidth: .infinity)
        .actionSheet(isPresented: $displayAlert, content: {


            return ActionSheet(
                title: Text("Error in Pod Application").font(.system(size: 22)),
            message: Text(errorMessage),
                buttons: [
                .cancel()
                ]
            )
        })
        
    }
}

struct CommitmentPopUpInfo: View {
    
    
    
    @EnvironmentObject var currentUserWrapper: UserWrapper
    
    
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
        
            
            VStack(alignment: .center, spacing: 1) {

                VStack(alignment: .center) {
                    Text("After " + (currentUserWrapper.currentPodApplication.subCatagory! == "N/A" ? currentUserWrapper.currentPodApplication.catagory! : currentUserWrapper.currentPodApplication.subCatagory!) + ",")
                            .font(.system(size: 16))
                            .lineLimit(1)
                    Text("You will log the phrase,")
                            .font(.system(size: 16))
                        Text("\"" + currentUserWrapper.currentPodApplication.logPhrase! + "\",")
                            .font(.system(size: 16))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                    Text(formPodInfoCommitmentStatement(daysArray: currentUserWrapper.currentPodApplication.daysOfTheWeek,
                                                        timeAsHHM: currentUserWrapper.currentPodApplication.timeOfDay!,
                                                        commitmentLength: currentUserWrapper.currentPodApplication.commitmentLength!))
                            .font(.system(size: 16))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                    Text("for " + String(currentUserWrapper.currentPodApplication.commitmentLength!) + " days.")
                            .font(.system(size: 16))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                }
                .padding(4)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color(UIColor.systemGray5))
                .cornerRadius(15)
                .padding(.horizontal, 18)
                Text("Note: This commitment will be shown to your group and cannot be changed after pressing confirm.").font(.footnote).foregroundColor(.white).fixedSize(horizontal: false, vertical: true).multilineTextAlignment(.center).padding()
            }
            .padding(7)
            .padding(.bottom, 3)
            .padding(.top, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
        
    }
}

struct CommitmentPopUp: View {
    
    var date: Date
    var podApplication: PodApplication
    var communityPodSelected: Bool
    @EnvironmentObject var currentUserWrapper: UserWrapper
    var friendIDsAndBool : [(User, Bool)]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var associatedPodID: String?
    @Binding var showCommitmentPopUp: Bool

    var body: some View {
        VStack {
            Text("Your " + (((podApplication.subCatagory! == "N/A" || podApplication.subCatagory! == "Other" || podApplication.subCatagory! == "General") ? podApplication.catagory! : podApplication.subCatagory)!) + " Commitment")
                .bold()
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundColor(.purple)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .shadow(radius: 20)
                .padding()
            Spacer()
            CommitmentPopUpInfo()
            Spacer()
            VStack {
                Button(action: {
                    
                    if communityPodSelected {

                        currentUserWrapper.sendCommunityPodApplicationToFirebase(podApplication: podApplication)

                    } else {
                        currentUserWrapper.sendFriendPodApplication(podApplication: podApplication)
                    }

//                    print(currentUserWrapper.currentPodApplication.UID)
//                    print(currentUserWrapper.currentPodApplication.appID)
//                    print(currentUserWrapper.currentPodApplication.associatedPod)
//                    print(currentUserWrapper.currentPodApplication.catagory)
//                    print(currentUserWrapper.currentPodApplication.subCatagory)
//                    print(currentUserWrapper.currentPodApplication.daysOfTheWeek)
//                    print(currentUserWrapper.currentPodApplication.friendIDs)
//                    print(currentUserWrapper.currentPodApplication.reminderPhrase)
//                    print(currentUserWrapper.currentPodApplication.logPhrase)
//                    print(currentUserWrapper.currentPodApplication.myTimestamp)
//                    print(currentUserWrapper.currentPodApplication.secondsFromGMT)
//                    print(currentUserWrapper.currentPodApplication.timeOfDay)
//                    print(currentUserWrapper.currentPodApplication.userBannedList)

                    print("CONFIRMED COMMITMENT, dismissing")
                    self.presentationMode.wrappedValue.dismiss()
                    showCommitmentPopUp = false
                
                }, label: {
                    VStack{
                        Text("Confirm Commitment")
                            .bold()
                            .foregroundColor(.green)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .font(.title3)
                    }
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)

                })
                .padding(4)
                .padding(.horizontal, 20)

                Button(action: {
                   
                    showCommitmentPopUp = false
                }, label: {
                    VStack{
                        Text("Cancel")
                            .bold()
                            .foregroundColor(.red)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                            .font(.title3)
                    }
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)

                })
                .padding(.bottom, 4)
                .padding(.horizontal, 24)
                

            }.padding(.bottom, 10)
            
        }
        .background(Color.purple)
        .cornerRadius(10)
        
        
        
        
    }
}


struct ReminderPhraseView : View {
    
    @Binding var chosenLogPhrase: Bool
    @Binding var reminderPhrase: String
    
    @Binding var chosenReminderPhrase: Bool
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @State var openInfoPopup: Bool = false
    @State var calculatedKeyboardHeight : CGFloat = 40
    @State var showActionSheet: Bool = false
    @State var applicationError: String? = nil
    
    func isOtherCatagory(podApplication : PodApplication, phraseExamples: [PhraseExample]) -> Bool {
        let catagories: [String] = phraseExamples.map { phraseExample in
            return phraseExample.habitType
        }
        return !catagories.contains(podApplication.catagory!)
    }
    func isOtherSubcatagory(podApplication : PodApplication, phraseExamples: [PhraseExample]) -> Bool{
        let subCatagories: [String] = phraseExamples.map { phraseExample in
            return phraseExample.habitType
        }
        return !subCatagories.contains(podApplication.subCatagory!)
    }
    var body: some View {
        
        VStack {
            Text("Set Reminder Message")
                .font(.title2)
                .bold()
                .padding()
            Text("Note: This is a personalized notification reminder to yourself. No one but you will see this message.")
                .multilineTextAlignment(.center)
                .font(.system(size: 14, weight: .light, design: .default))
            
            ReminderPhraseNotificationOverlay(reminderPhrase: $reminderPhrase)
            
            TextField("Reminder Phrase", text: $reminderPhrase)

                .padding(EdgeInsets(top: 10, leading: 7, bottom: 3, trailing: 0))
                .background(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
            Text(String(50 - reminderPhrase.count) + " characters left")
                .font(.footnote)
                .foregroundColor(reminderPhrase.count > 50 ? .red : .black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 7)
                .padding(.bottom, 5)
                
            VStack(spacing: 0) {
                
                Text("Reminder Examples")
                    .fontWeight(.bold)
                    .font(.title3)
                    .padding(.bottom, 1)
                    
                Color.black.frame(width: .infinity, height: 3, alignment: .center)
                    .padding(.bottom, 1)
                                        
                    VStack(spacing: 0) {

                        
                        if isOtherCatagory(podApplication: currentUserWrapper.currentPodApplication, phraseExamples: currentUserWrapper.phraseExamples) {
                            ForEach(currentUserWrapper.phraseExamples.filter {
                                $0.habitType == "Other"
                            }[0].reminderPhrases, id: \.self) { reminderPhrase in
                            
                            Text("- " + reminderPhrase)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(EdgeInsets(top: 7, leading: 3, bottom: 5, trailing: 0))
                        }
                        } else {
                        ForEach(currentUserWrapper.phraseExamples.filter {
                            $0.habitType == (currentUserWrapper.currentPodApplication.subCatagory! == "N/A" || isOtherSubcatagory(podApplication: currentUserWrapper.currentPodApplication, phraseExamples: currentUserWrapper.phraseExamples) ? currentUserWrapper.currentPodApplication.catagory! : currentUserWrapper.currentPodApplication.subCatagory!)
                            
                        }[0].reminderPhrases, id: \.self) { reminderPhrase in
                                Text("- " + reminderPhrase)
                                    .font(.title3)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(EdgeInsets(top: 7, leading: 3, bottom: 5, trailing: 0))
                            }
                        }
                    }
                    //.frame(maxWidth: UIScreen.main.bounds.width * 1/2, maxHeight: .infinity, alignment: .top)
                    //.padding(.trailing)

                Spacer()
                
            }
            .onTapGesture {
                UIApplication.shared.endEditing()

            }
            HStack {
                Button(action: {
                    chosenLogPhrase = false
                    
                }, label: {
                    HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)

                    Text("Back")
                        .foregroundColor(.black)
                        .bold()
                        .font(.title2)
                        .padding()
                        
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding()

                    }
                )
                Button(action: {
                    applicationError = nil
                    if  reminderPhrase.count > 50 {
                        applicationError = "Phrase is too long"
                    } else if reminderPhrase.count < 3 {
                        applicationError = "Please enter a longer phrase"
                    }
                    
                    if applicationError != nil {
                        showActionSheet.toggle()
                    } else {
                        chosenReminderPhrase = true
                        currentUserWrapper.currentPodApplication.reminderPhrase = reminderPhrase
                    }
                }, label: {
                    HStack {
                    Text("Next")
                        .foregroundColor(.white)
                        .bold()
                        .font(.title2)
                        .padding()
                        
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .cornerRadius(10)
                    .padding()
                })
            }
        }
        .gesture(DragGesture(minimumDistance: 15, coordinateSpace: .local)
                .onEnded({ value in

                    if value.translation.height > 0 {
                        UIApplication.shared.endEditing()
                    }
                }))
        .actionSheet(isPresented: $showActionSheet, content: {

            return ActionSheet(
            title: Text("Error in Pod Application").font(.system(size: 22)),
            message: Text(applicationError!),
                buttons: [
                .cancel()
                ]
            )
        })
    }
}

struct LogPhraseView : View {
    
    @Binding var chosenDayAndTime: Bool
    @Binding var logPhrase: String
    
    @Binding var chosenLogPhrase: Bool
    
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @State var openInfoPopup: Bool = false
    @State var calculatedKeyboardHeight : CGFloat = 40
    @State var showActionSheet: Bool = false
    @State var applicationError: String? = nil
    
    func isOtherCatagory(podApplication : PodApplication, phraseExamples: [PhraseExample]) -> Bool {
        let catagories: [String] = phraseExamples.map { phraseExample in
            return phraseExample.habitType
        }
        return !catagories.contains(podApplication.catagory!)
    }
    func isOtherSubcatagory(podApplication : PodApplication, phraseExamples: [PhraseExample]) -> Bool{
        let subCatagories: [String] = phraseExamples.map { phraseExample in
            return phraseExample.habitType
        }
        return !subCatagories.contains(podApplication.subCatagory!)
    }
    var body: some View {
        ZStack {
        VStack {
        Text("Customize " + (currentUserWrapper.currentPodApplication.subCatagory! == "N/A" ? currentUserWrapper.currentPodApplication.catagory! : currentUserWrapper.currentPodApplication.subCatagory!) + " Commitment")
            .font(.title2)
            .bold()
            .multilineTextAlignment(.center)
            .padding()
        
            Button(action: {
                UIApplication.shared.endEditing()
                withAnimation(.spring()) {
                    openInfoPopup = true
                }
                
            }, label: {
                Text("What is a Log Phrase?").font(.system(size: 15)).foregroundColor(.white).padding(EdgeInsets(top: 7, leading: 17, bottom: 7, trailing: 17)).background(Color.purple)
                    .cornerRadius(5)
            })
        TextField("Log Phrase", text: $logPhrase)

            .padding(EdgeInsets(top: 10, leading: 7, bottom: 3, trailing: 0))
            .background(Color.gray.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding(EdgeInsets(top: 10, leading: 5, bottom: 0, trailing: 5))
        Text(String(50 - logPhrase.count) + " characters left")
            .font(.footnote)
            .foregroundColor(logPhrase.count > 50 ? .red : .black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 7)
            .padding(.bottom, 5)
            
            
        Color.black.frame(width: .infinity, height: 3, alignment: .center)
            .padding(.bottom, 1)
            VStack(spacing: 0) {
                
                Text("Log Phrase Examples")
                    .fontWeight(.bold)
                    .font(.title3)
                    .padding(.bottom, 1)
                    
                Color.black.frame(width: .infinity, height: 3, alignment: .center)
                    .padding(.bottom, 1)
                                        
                    VStack(spacing: 0) {

                        
                        if isOtherCatagory(podApplication: currentUserWrapper.currentPodApplication, phraseExamples: currentUserWrapper.phraseExamples) {
                            ForEach(currentUserWrapper.phraseExamples.filter {
                                $0.habitType == "Other"
                            }[0].logPhrases, id: \.self) { logPhrase in
                            
                            Text("- " + logPhrase)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(EdgeInsets(top: 7, leading: 3, bottom: 5, trailing: 0))
                        }
                        } else {
                        ForEach(currentUserWrapper.phraseExamples.filter {
                            $0.habitType == (currentUserWrapper.currentPodApplication.subCatagory! == "N/A" || isOtherSubcatagory(podApplication: currentUserWrapper.currentPodApplication, phraseExamples: currentUserWrapper.phraseExamples) ? currentUserWrapper.currentPodApplication.catagory! : currentUserWrapper.currentPodApplication.subCatagory!)
                            
                        }[0].logPhrases, id: \.self) { logPhrase in
                                Text("- " + logPhrase)
                                    .font(.title3)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(EdgeInsets(top: 7, leading: 3, bottom: 5, trailing: 0))
                            }
                        }
                    }
                    //.frame(maxWidth: UIScreen.main.bounds.width * 1/2, maxHeight: .infinity, alignment: .top)
                    //.padding(.trailing)
                
                Spacer()
            }
            .onTapGesture {
                UIApplication.shared.endEditing()

            }
            HStack {
                Button(action: {
                    chosenDayAndTime = false
                    
                }, label: {
                    HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)

                    Text("Back")
                        .foregroundColor(.black)
                        .bold()
                        .font(.title2)
                        .padding()
                        
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding()

                    }
                )
                Button(action: {
                    applicationError = nil
                    if  logPhrase.count > 50 {
                        applicationError = "Phrase is too long"
                    } else if logPhrase.count < 3 {
                        applicationError = "Please enter a longer phrase"
                    }
                    if applicationError != nil {
                        showActionSheet.toggle()
                    } else {
                        chosenLogPhrase = true
                        currentUserWrapper.currentPodApplication.logPhrase = logPhrase
                    }
                }, label: {
                    HStack {
                    Text("Next")
                        .foregroundColor(.white)
                        .bold()
                        .font(.title2)
                        .padding()
                        
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .cornerRadius(10)
                    .padding()
                })
                
            }
        }
        .gesture(DragGesture(minimumDistance: 15, coordinateSpace: .local)
                .onEnded({ value in

                    if value.translation.height > 0 {
                        UIApplication.shared.endEditing()
                    }
                }))
        .actionSheet(isPresented: $showActionSheet, content: {

            return ActionSheet(
            title: Text("Error in Pod Application").font(.system(size: 22)),
            message: Text(applicationError!),
                buttons: [
                .cancel()
                ]
            )
        })
            
        if openInfoPopup {
            LogPhrasePopUp(showLogPhrasePopUp: $openInfoPopup)
            .transition(AnyTransition.scale)
        }
            
        }
    }
}

struct LogPhrasePopUp: View {
    @Binding var showLogPhrasePopUp : Bool
    @State var showOrExplainView: Int = 0
    @State var slideOffset: CGFloat = 0
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    showLogPhrasePopUp = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(alignment: .topLeading)
                    }
                    .frame(maxWidth: .infinity, alignment: .topTrailing)
                    .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 5))
            }

            Text(showOrExplainView == 0 ? "What is a Log Phrase?" : "Log Phrase Example")
                .foregroundColor(.white)
                .font(.title3)
                .bold()
                .underline()
                .lineLimit(1)
                //.offset(x: UIScreen.main.bounds.width * 1/4)
            Spacer()
            
            
            
            if showOrExplainView == 1 {
                
                VStack(spacing: 0) {
                    Image("croppedNewLogMessage")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: UIScreen.main.bounds.height * 3/10)
                        .cornerRadius(10)
                    Text("_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _")
                        .padding(.bottom, 5)
                    Image("newAfterLogExample")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: UIScreen.main.bounds.height * 3/10)
                        .cornerRadius(10)
                }
                .padding(17)
                .frame(maxWidth: UIScreen.main.bounds.width - 30)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(25)
                .animation(.linear(duration: 0.25))
                .transition(AnyTransition.move(edge: .leading))
                .offset(x: slideOffset, y: 0)
                
            } else {
                VStack {
                    Text("The habit types on BuddyUp are general catagories. You should be as specific as possible when planning to build a habit. It helps to customize the action taken each day using a LOG PHRASE.")
                        .multilineTextAlignment(.center)
                        .padding(7)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text("The LOG PHRASE is a description of your specific action taken each day. It is logged into your group's chat everytime you complete your habit.")
                        .multilineTextAlignment(.center)
                        .padding(7)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(17)
                .frame(maxWidth: UIScreen.main.bounds.width - 30)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(20)
                .animation(.linear(duration: 0.25))
                .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                .offset(x: slideOffset, y: 0)
                
            }
            Spacer()
            HStack {
                
                Button(action: {showOrExplainView = 1}, label: {
                    Text("Show Me")
                        .font(.system(size: 16 + (showOrExplainView == 1 ? 4 : 0), weight: showOrExplainView == 1 ? .bold : .regular, design: .default))
                        .foregroundColor(showOrExplainView == 1 ? .white : Color(UIColor.systemGray5))
                        .underline(showOrExplainView == 1, color: .white)
                    
                    Button(action: {showOrExplainView = 0}, label: {
                        Text("Explain To Me")
                            .font(.system(size: 16 + (showOrExplainView == 0 ? 4 : 0), weight: showOrExplainView == 0 ? .bold : .regular, design: .default))
                            .foregroundColor(showOrExplainView == 0 ? .white : Color(UIColor.systemGray5))
                            .underline(showOrExplainView == 0, color: .white)
                    })
                    .padding(.trailing, 5)
                    
                })
            }.padding(.bottom)

        }
        .background(Color.purple)
        .gesture(DragGesture(minimumDistance: 1, coordinateSpace: .global)
            .onChanged({ value in
                print("gesture value.translation.width: ", value.translation.width )
                if showOrExplainView == 1 {
                    if value.translation.width > -70 && value.translation.width < 0 {
                        slideOffset = value.translation.width
                    } else if value.translation.width < -70 {
                        showOrExplainView = 0
                    }
                } else  {
                    if value.translation.width < 70 && value.translation.width > 0 {
                        slideOffset = value.translation.width
                    } else if value.translation.width > 70 {
                        showOrExplainView = 1
                    }
                }
            })
            .onEnded({ value in
                slideOffset = 0
            })
        )
        
    }
}
struct ReminderPhraseNotificationOverlay : View {
    @Binding var reminderPhrase: String
    var body: some View {
        ZStack {
        Image("blankNotification")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: UIScreen.main.bounds.height * 1/10)
            .cornerRadius(20)
        Text(reminderPhrase)
            .font(.system(size: 14, weight: .medium, design: .default))
            .multilineTextAlignment(.leading)
            .frame(width: UIScreen.main.bounds.width * 39/40,height: 20 ,alignment: .center)
            //.padding(.leading, UIScreen.main.bounds.width * 1/5)
            
        }.frame(height: UIScreen.main.bounds.height * 1/8)
    }
}


struct ReviewPodApplicationView: View {
    
    @Binding var communityPodSelected: Bool
    @Binding var friendIDsAndBool: [(User, Bool)]
    @Binding var showCommitmentSheet: Bool
    
    @Binding var communityOrFriendSelected: Bool
    @Binding var chosenHabit: Bool
    @Binding var chosenReminderPhrase: Bool
    @Binding var chosenLogPhrase: Bool
    @Binding var chosenFriends: Bool
    @Binding var chosenDayAndTime: Bool
    
    @Binding var currentDate: Date
    
    //@State var friendUsers: [User]
    
    @Binding var appeared : Bool
    
    
    var dummyHabitType = "Meditation"
    var dummyReminderPhrase = "You should meditate today"
    var dummyLogPhrase = "I meditated today"
    var dummyDays: [Bool] = [true, false, true, false, true, false, true]
    var dummyTimeASHHMM = 1234
    var dummyDate = Date()
    
    @EnvironmentObject var currentUserWrapper: UserWrapper
//    var pendingPOD = PendingPod(UID: "DUMMY", id: "DUMMY", communityOrFriendGroup: "Friend", podIDIfFriend: "DUMMY", friendWhoSentInvite: "DUMMY", friendInviteMessage: "Join my habit group!", friendNameWhoSentInvite: "Justine Miller", communityCategoryAppliedFor: nil, communityPodETABottom: nil, communityPodETATop: nil, commitmentLength: 30)

    var body: some View {

        ZStack {

            VStack(alignment: .leading, spacing: 0) {

                Text("Review Commitment")
                    .fontWeight(.bold)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    
                
                
                VStack(alignment: .leading) {
                    if appeared {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Group Type")
                                    .fontWeight(.bold)
                                    .font(.title2)
                                Button(action: {communityOrFriendSelected = false}, label: {
                                    Text("Edit").foregroundColor(.blue)
                                })

                            }
                            Text(communityPodSelected ? "Community" : "Friend")
                                .font(.title3)
                        }
                        .padding(.bottom, 5)
                        .transition(AnyTransition.scale.animation(.spring().delay(0.3)))
                    }
                    

                
                    

                    if !communityPodSelected && appeared {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Friends in group")
                                    .fontWeight(.bold)
                                    .font(.title2)
                                Button(action: {chosenFriends = false}, label: {
                                    Text("Edit")
                                        .foregroundColor(.blue)
                                })

                            }
                            if currentUserWrapper.currentPodApplication.associatedPod != nil {
                                ForEach(0..<currentUserWrapper.currentPodApplication.friendIDs!.count) { index in
                                    Text(currentUserWrapper.getFriendNameWithID(friendID: currentUserWrapper.currentPodApplication.friendIDs![index]) ?? "")
                                        .font(.title3)
                                }
                            }
                            else if currentUserWrapper.currentPodApplication.friendIDs == nil || currentUserWrapper.currentPodApplication.friendIDs?.count == 0 {
                                Text("None")
                            } else {
                                VStack(alignment: .leading, spacing: 7) {
                                    ForEach(0..<currentUserWrapper.currentPodApplication.friendIDs!.count) { index in

                                        Text(currentUserWrapper.getFriendNameWithID(friendID: currentUserWrapper.currentPodApplication.friendIDs![index]) ?? "")
                                            .font(.title3)
                                    }
                                    if currentUserWrapper.currentPodApplication.isFriendPodLocked! {
                                        Text("Note: You've locked in this group. Friends must choose " + (currentUserWrapper.currentPodApplication.subCatagory! == "N/A" ? currentUserWrapper.currentPodApplication.catagory!: currentUserWrapper.currentPodApplication.subCatagory!) + " as their habit.")
                                            .font(.caption)

                                    } else {
                                        Text("Note: You haven't locked in this group. Friends can choose any habit.")
                                            .font(.caption)

                                    }
                                    HStack {
                                            Text("Invite Message")
                                                .fontWeight(.bold)
                                                .font(.title2)
                                                .padding(.top, 13)
                                            Button(action: {chosenFriends = false}, label: {
                                                Text("Edit")
                                                    .foregroundColor(.blue)
                                            })
                                        }
                                    Text(currentUserWrapper.currentPodApplication.friendInviteMessage!)
                                    }
                                }
                            }
                            .padding(.bottom, 5)
                            .transition(AnyTransition.scale.animation(.spring().delay(1.0)))
                        }
                    }
                    .disabled(currentUserWrapper.currentPodApplication.associatedPod != nil)
                    .opacity(currentUserWrapper.currentPodApplication.associatedPod != nil ? 0.5 : 1)
                

                VStack(alignment: .leading) {
                    if appeared {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Habit Type")
                                    .fontWeight(.bold)
                                    .font(.title2)
                                Button(action: {chosenHabit = false}, label: {
                                    Text("Edit").foregroundColor(.blue)
                                })
                            }
                            Text(currentUserWrapper.currentPodApplication.subCatagory! == "N/A" ? currentUserWrapper.currentPodApplication.catagory!: currentUserWrapper.currentPodApplication.subCatagory!)
                                .font(.title3)
                        }
                        .padding(.bottom, 5)
                        .transition(AnyTransition.scale.animation(.spring().delay(!communityPodSelected ? 1.7 : 1.0)))
                    }

                    if appeared {

                    VStack(alignment: .leading) {

                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Log Phrase")
                                        .fontWeight(.bold)
                                        .font(.title2)
                                    Button(action: {chosenLogPhrase = false}, label: {
                                        Text("Edit").foregroundColor(.blue)
                                    })
                                }
                                Text(currentUserWrapper.currentPodApplication.reminderPhrase!)
                                    .fixedSize(horizontal: false, vertical: true)

                                
                                HStack {
                                    Text("Reminder Phrase")
                                        .fontWeight(.bold)
                                        .font(.title2)
                                    Button(action: {chosenReminderPhrase = false}, label: {
                                        Text("Edit")
                                            .foregroundColor(.blue)
                                    })
                                }
                                Text(currentUserWrapper.currentPodApplication.logPhrase!)
                                    .fixedSize(horizontal: false, vertical: true)

                            }
                        }
                    .padding(.bottom, 5)
                    .transition(AnyTransition.scale.animation(.spring().delay(!communityPodSelected ? 2.4 : 1.7)))
                    }

                    if appeared {
                        VStack(alignment: .leading) {
                            HStack{
                                Text("Day and Time")
                                    .fontWeight(.bold)
                                    .font(.title2)
                                Button(action: {chosenDayAndTime = false}, label: {
                                    Text("Edit").foregroundColor(.blue)
                                })
                            }
                            Text(formPhraseCommitmentClarification(phrase: dummyReminderPhrase, daysArray: currentUserWrapper.currentPodApplication.daysOfTheWeek, time: currentDate, commitmentLength: currentUserWrapper.currentPodApplication.commitmentLength!))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 7)
                        }
                        .padding(.bottom, 5)
                        .transition(AnyTransition.scale.animation(.spring().delay(!communityPodSelected ? 3.1 : 2.4)))
                    }
                }

                Spacer()
                
                if appeared {
                    Button(action: {
                        currentUserWrapper.currentPodApplication.userBannedList = currentUserWrapper.currentUser!.userBannedList
                        currentUserWrapper.currentPodApplication.secondsFromGMT = TimeZone.current.secondsFromGMT()
                            showCommitmentSheet.toggle()
                    
        //                var applicationError: String? = nil
        //                let timeAsHHMM: Int =  Calendar.current.component(.hour, from: currentDate) * 100 + Calendar.current.component(.minute, from: currentDate)

        //                currentUserWrapper.currentPodApplication. = convertToGMTTime(userRequestedTimeHHMM: timeAsHHMM, secondsFromGMT: TimeZone.current.secondsFromGMT())

                    }, label: {
                        Text("Submit Group Application")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Color.purple)
                            .cornerRadius(10)
                    
                    })
                    .padding(.bottom, 20)
                    .transition(AnyTransition.scale.animation(.spring().delay(!communityPodSelected ? 3.8 : 3.1)))
                }
            }
            //.disabled(showCommitmentSheet == true)
            .frame(maxWidth: .infinity)
            .padding()
                
            if showCommitmentSheet {
                Color.black.opacity(0.7)
                    .onTapGesture {
                        withAnimation(.interpolatingSpring(mass: 3, stiffness: 1000, damping: 500, initialVelocity: 4)) {
                            showCommitmentSheet.toggle()
                        }
                }
                CommitmentPopUp(date: currentDate, podApplication: currentUserWrapper.currentPodApplication, communityPodSelected: communityPodSelected, friendIDsAndBool: friendIDsAndBool, showCommitmentPopUp: $showCommitmentSheet)
                    .frame(maxWidth: UIScreen.main.bounds.width * 5/6, maxHeight: UIScreen.main.bounds.height * 3/4, alignment: .center)
                    .cornerRadius(10)
            }
        }
        .onAppear{
            appeared = true
        }
        .animation(.interpolatingSpring(mass: 3, stiffness: 1000, damping: 500, initialVelocity: 4))
        
    }
}
//
//
//struct NewPodView_Previews: PreviewProvider {
//
//
//    static var previews: some View {

//        NewPodView(friendIDsAndBool: [], communityOrFriendSelected: true, communityPodSelected: false, isUnaddressedInvite: false, seenFaqs: true, chosenFriends: true, chosenHabit: false, inviteMessage: "Dummy", activeSheet: .constant(nil)).environmentObject(UserWrapper())//        ReviewPodApplicationView(communityPodSelected: .constant(true), friendIDsAndBool: .constant([]), showCommitmentSheet: .constant(true), chosenHabit: .constant(true), chosenPhrases: .constant(true), chosenFriends: .constant(false), chosenDayAndTime: .constant(false), currentDate: .constant(Date())).environmentObject(UserWrapper())
//        ChooseDayAndTimeView(chosenDayAndTime: .constant(false), currentDate: .constant(Date()), daysArray: .constant([true, false, true, false, false, true, true])).environmentObject(UserWrapper())
//        PhraseSelectView(chosenDayAndTime: .constant(true), reminderPhrase: .constant(""), logPhrase: .constant(""), chosenPhrases: .constant(false)).environmentObject(UserWrapper())
//        InviteScreen(showActionSheet: .constant(nil), isUnadressedInvite: .constant(true), pendingPodFromFriend: PendingPod(UID: "DUMMY", appID: "DUMMY", communityOrFriendGroup: "Friend", podIDIfFriend: "DUMMY", friendWhoSentInvite: "DUMMY", friendInviteMessage: "Join my habit group!", friendNameWhoSentInvite: "Justine Miller", communityCategoryAppliedFor: nil, communityPodETABottom: nil, communityPodETATop: nil)).environmentObject(UserWrapper())
        
        //ProgressBar(progressBools: [true, false])
//        ProgressBar(communityOrFriendSelected: .constant(true),
//                    seenFaqs: .constant(true),
//                    chosenFriends: .constant(true),
//                    chosenHabit: .constant(false),
//                    chosenReminderPhrase: .constant(false), chosenLogPhrase: .constant(true), chosenDayAndTime: .constant(false))
//        ReminderPhraseNotificationOverlay(reminderPhrase: .constant("fdsajl;f jds;al fjdk;sa jfdlk;as lfkjds;a jfkd;as fds"))
        
//        InviteScreenMoreInfo(podToJoin: Binding<Pod> (Pod(id: "Dummy", n: "DUMMT", memberScoreDict: ["a": 1], memberNameDict: ["a": "Meret"], memberScheduleDict: ["a": [true, true, true, true, true, true, true]], memberPhraseDict: ["a": "Meditation makes me feel good"], memberTimeDict: ["a": 800], communityOrFriend: "Friend", habit: nil, memberAliasesAndIDs: ["a": "DUMMY USER ID"], memberColorDict: ["a": 0], memberAliasHasLogged: ["a": true], memberAliasLogPhrase: ["a": "I meditated this morning"], dayNumber: 1, dayLimit: 30, memberAliasesAndSecondsFromGMT: ["a": 0], memberAliasesAndHabitDays: ["a": 1], memberAliasesAndHabit: ["a": "Meditation"], memberAliasesAndSomethingNew: ["a": false])), alias: "a")
//    }
//}
