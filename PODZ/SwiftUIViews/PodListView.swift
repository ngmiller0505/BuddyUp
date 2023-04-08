//
//  SwiftUIView.swift
//  PODZ
//
//  Created by Nick Miller on 6/15/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//
import SwiftUI
import Combine

struct PodListView: View {
    
    //@State var isPresentingProfileInfo = false
    @EnvironmentObject var currentUserWrapper : UserWrapper
    @Binding var activeSheet : ActiveSheet?
    @Binding var tutorialStep : Int
    @State var showSubsriptionPopUp: Bool = false
    //@State var isPodChatActive: Bool = false
    //@Binding var selection : String?
    @State var animateNewPodButton = false
    @State var showFinishedPods = false
    
    
    var body: some View {
        
        ZStack {
        NavigationView {
                
                ScrollView {
                    
                    if currentUserWrapper.currentUser != nil {
                        VStack(spacing: 0) {
                            VStack {
                                NavigationLink(destination:
                                            NewPodView(friendIDsAndBool: Array(zip(currentUserWrapper.userFriends, [Bool](repeating: false, count: currentUserWrapper.userFriends.count))), communityOrFriendSelected: false, communityPodSelected: true, isUnaddressedInvite: false, seenFaqs: false, chosenFriends: false, chosenHabit: false, activeSheet: $activeSheet)
                                                .navigationBarHidden(true)
                                                .navigationBarBackButtonHidden(true)
                                )
                                {
                                    ZStack {
                                        HStack(alignment: .center) {

                                                Text("Start new group")
                                                .font(.system(size: 22))
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
//                                            .shadow(color: Color.init("lightPurple"), radius: animateNewPodButton ? 10 : 0.0)
//                                            .opacity(animateNewPodButton ? 0.5 : 1.0)
                                            .clipShape(RoundedRectangle(cornerRadius: 25))
                                        }
                                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))
                                }

                                if currentUserWrapper.currentUser!.podsApartOfID.count == 0 && currentUserWrapper.currentUser!.pendingPodIDs.count == 0 {
    //                      Color.gray.opacity(0.5).frame(maxWidth: .infinity, maxHeight: 1).padding(EdgeInsets(top: 15, leading: 35, bottom: 15, trailing: 35))
                                    Text("You have no active habit groups.").padding(.top, 20)
                                }
                                else {

                                    ForEach(currentUserWrapper.currentUser!.pendingPodIDs, id: \.self) { pendingPodID in
                                        if currentUserWrapper.getPendingPodFromPendingPodIDs(pendingPodID: pendingPodID) == nil {
                                            PodRowLoader()

                                            //We know this pendingPod exists because we have the IDs in User, but the data hasn't loaded yet
                                        }
                                        else if currentUserWrapper.getPendingPodFromPendingPodIDs(pendingPodID: pendingPodID)!.communityOrFriendGroup == "Friend" {
                                            //We've loaded this pendingPod's data so now we can force unwrap. Here we navigate to NewPodView with a friendInvite (supposedly it works from notification as well)
                                            NavigationLink(destination:
                                                            NewPodView(friendIDsAndBool: Array(zip(currentUserWrapper.userFriends, [Bool](repeating: false, count: currentUserWrapper.userFriends.count))), communityOrFriendSelected: true, communityPodSelected: false, isUnaddressedInvite: true, seenFaqs: false, chosenFriends: true, chosenHabit: false, activeSheet: $activeSheet, pendingPodFriendInvite: currentUserWrapper.getPendingPodFromPendingPodIDs(pendingPodID: pendingPodID)!)
                                                            .navigationBarHidden(true)
                                                            .navigationBarBackButtonHidden(true)
                                            )
                                            {
                                                PodInviteFromFriendRow(pendingPod: currentUserWrapper.getPendingPodFromPendingPodIDs(pendingPodID: pendingPodID)!).padding(.vertical, 5)
                                            }
                                        }
                                    }
                                }
                                Color.gray.opacity(0.5).frame(maxWidth: .infinity, maxHeight: 1).padding(EdgeInsets(top: 15, leading: 35, bottom: 15, trailing: 35))
                            }
                            
//
                            VStack {
                                ForEach(currentUserWrapper.currentUser!.pendingPodIDs, id: \.self) { pendingPodID in
                                    if currentUserWrapper.getPendingPodFromPendingPodIDs(pendingPodID: pendingPodID) == nil {
                                        //We know pendingPods exist because we have the IDs in User, but the data for this pendingPod hasn't loaded yet
                                        PodRowLoader()

                                    } else if currentUserWrapper.getPendingPodFromPendingPodIDs(pendingPodID: pendingPodID)!.communityOrFriendGroup == "Community" {
                                        //We've loaded this pendingPod's data so now we can force unwrap. Here we show pendingCommunityPodWigit
                                        PodPendingRow(pendingPod: currentUserWrapper.getPendingPodFromPendingPodIDs(pendingPodID: pendingPodID)!)
                                    }
                                }
//                          Color.gray.opacity(0.5).frame(maxWidth: .infinity, maxHeight: 1).padding(EdgeInsets(top: 15, leading: 35, bottom: 15, trailing: 35))
                                ForEach(currentUserWrapper.userPods, id: \.podID) { podWrapper in

                                    PodRow(podWrapper: podWrapper, activeSheet: $activeSheet)//, selection: $currentUserWrapper.notificationAction)//, isPodChatActive: $isPodChatActive)
                                }
                            }
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            
                            if currentUserWrapper.finishedPods.count != 0 {
//                                Color.gray.opacity(0.5).frame(maxWidth: .infinity, maxHeight: 1).padding(EdgeInsets(top: 15, leading: 35, bottom: 15, trailing: 35))
                                Button(action: {showFinishedPods.toggle()}, label: {
                                    HStack {
                                        Text(showFinishedPods ? "Hide Finished Groups" : "Show Finished Groups")
                                            .bold()
                                            .foregroundColor(Color(UIColor.systemGray))
                                        Image(systemName: showFinishedPods ? "chevron.up" : "chevron.down")
                                            .foregroundColor(Color(UIColor.systemGray2))
                                    }
                                })
                                if showFinishedPods {
                                VStack {

                                    ForEach(currentUserWrapper.finishedPods) { pod in
                                        FinishedPodRow(finishedPod : pod, activeSheet: $activeSheet)
                                    }

                                }
                                .padding(.vertical, 10)

                                }
                            }
                        }

                        
                    } else {
                
                        PodRowLoader()
                    }
                    
                }//.disabled(!currentUserWrapper.currentUser!.doneAppTutorial)
                .navigationBarTitle(Text("Habit Groups"))
                .navigationBarItems(leading: Button(action: {
                    showSubsriptionPopUp = true
                }, label: {
                    Image("NEWlogo-transparent32x32")
                        .clipShape(Circle())

                })
                .disabled(currentUserWrapper.currentUser == nil), trailing:
                    Button(action:
                    {
                        print("info modal present")
                        self.activeSheet = .profileInfo
                    })
                    {
                        Image(systemName: "person.circle")
                        .imageScale(.large)
                    })
        
        }
        .disabled(currentUserWrapper.currentUser == nil)
        .navigationViewStyle(StackNavigationViewStyle())
            
        if currentUserWrapper.currentUser != nil  {
            if !currentUserWrapper.currentUser!.doneAppTutorial {
                OnboardingView(tutorialStep: $tutorialStep, activeSheet: $activeSheet)
                    .onDisappear(perform: {
                        currentUserWrapper.finishedTutorial()
                    })
            }
        }
        if showSubsriptionPopUp {
            Color.black.opacity(0.4).blur(radius: 3.0).onTapGesture {
                showSubsriptionPopUp = false
            }
            SubscriptionPopUp(showSubsriptionView: $showSubsriptionPopUp, tutorialStep: $tutorialStep)
                .frame(width: UIScreen.main.bounds.width * 9/10, height: UIScreen.main.bounds.height * 2/3, alignment: .center)
                .cornerRadius(7)
                .shadow(radius: 20)
        }

        }
        
    .onAppear {
        UIApplication.shared.applicationIconBadgeNumber = 0
        print("in podList onAppear")
        if currentUserWrapper.activeComplaint != nil {
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//                print("ENTERED currentUserWrapper.activeComplaint != nil { DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {")
//                withAnimation {
//                    currentUserWrapper.removeUserDataFromPodLocally(podID: currentUserWrapper.activeComplaint!.associatedPodID)
//                }
//                currentUserWrapper.sendInComplaint(complaint: currentUserWrapper.activeComplaint!)
//                currentUserWrapper.activeComplaint = nil
//                currentUserWrapper.leftAPod = false
//                print("AFTER currentUserWrapper.activeComplaint = nil")
//            }
        }
        
        if currentUserWrapper.currentUser != nil {
            if currentUserWrapper.currentUser!.podsApartOfID.count == 0 && currentUserWrapper.currentUser!.pendingPodIDs.count == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    print("in Toggle")
                    withAnimation(Animation.linear(duration: 0.3).repeatForever(autoreverses: true)) {
                        animateNewPodButton.toggle()
                    }
                    
                }
            }
        }
    }
        
    .onChange(of: currentUserWrapper.currentUser, perform: { value in
        if currentUserWrapper.currentUser != nil {
            if currentUserWrapper.currentUser!.podsApartOfID.count == 0 && currentUserWrapper.currentUser!.pendingPodIDs.count == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    print("in Toggle")
                    withAnimation(Animation.linear(duration: 0.3).repeatForever(autoreverses: true)) {
                        animateNewPodButton.toggle()
                    }
                    
                }
            }
        }

    })
    .edgesIgnoringSafeArea(.all)
    .onChange(of: currentUserWrapper.notificationAction, perform: { value in
        print("")
        print("IN POD LIST on Change of currentUserWrapper.notificationAction")
        print("value = ", value ?? "none")
        print("")

    })
    }
}





struct SubscriptionPopUp: View {
    //TOOD THIS SHIT ISN'T DONT. PROBABLY SEPERATE THIS POPUP FROM THE FREE TRIAL LIMIT REACHED IN NEW POD VIEW COMPLETELY
//    @State var paid: Bool
    @Binding var showSubsriptionView: Bool
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var tutorialStep: Int
    @State var showBadPurchaseAlert: Bool = false
    
    var body: some View {
        if currentUserWrapper.isPremium {
            VStack {
                Button {
                    print("PRESSED X, dismissing")
                    self.presentationMode.wrappedValue.dismiss()
                    showSubsriptionView = false
                    tutorialStep += 1


                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(alignment: .topLeading)

                }
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                .padding(3)

                Spacer()
                VStack{
                    Text("You have subscribed to BuddyUp.")
                        .foregroundColor(.white)
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text("Thanks for the support.")
                        .foregroundColor(.white)
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding()
                }

                Spacer()
                VStack {
                    Button(action: {
                        showSubsriptionView.toggle()
                        tutorialStep += 1

                    }, label: {
                            Text("OK")
                                .foregroundColor(.purple)
                                .font(.title2)
                                .bold()
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(10)
                                .padding()

                        })
                }
            }.background(Color.purple)
            
        }
        else {
//
            VStack {
                Button {

                    self.presentationMode.wrappedValue.dismiss()
                    print("press x dismissing")
                    showSubsriptionView = false
                    currentUserWrapper.finishedTutorial()
                    tutorialStep += 1


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
//
//            if currentUserWrapper.purchaseStatus == "loading" {
//
//                ProgressView("Loading...")
//                    .foregroundColor(.white)
//                    .frame(height: UIScreen.main.bounds.height * 3/10)
//
//                    Spacer()
//
//                 }
//
//            else
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
            else
            {
                
                    if currentUserWrapper.userPods.count + currentUserWrapper.pendingPods.count + currentUserWrapper.finishedPods.count == 0 {
                        
                        VStack {
                            
                                Text("You have one free Habit Group ready to start.")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .bold()
                                    .multilineTextAlignment(.center)
                                    .padding()
                            
                            Button(action: {
                                self.presentationMode.wrappedValue.dismiss()
                                showSubsriptionView = false
                                currentUserWrapper.finishedTutorial()
                                tutorialStep += 1
                            }, label: {
                                Text("Sounds Good!")
                                    .foregroundColor(.purple)
                                    .bold()
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .padding()
                            })
                            
                            Spacer()
                            
                            Text("Subscribe anytime for unlimited habit groups.")
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
                            Spacer()
                            Text("Subscribe for unlimited habit groups.")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding()
                        }.animation(.easeIn)
                    }
//
//
                    VStack {
                        Button(action: {currentUserWrapper.enterPromoCode()}, label: {
                            
                                Text("Enter Promo Code")
                                    .foregroundColor(.purple)
                                    .bold()
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            
                        })

                        
                        ForEach(currentUserWrapper.packages ?? [], id: \.self) { package in
                            Button(action: {
//                                withAnimation {
//                                    currentUserWrapper.purchaseStatus = "loading"
//                                }
                                currentUserWrapper.purchaseSubscription(packageToPurchase: package)

                            }, label: {
                                Text(currentUserWrapper.formPackageDisplayString(package: package))
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
//                    }
//                }
                
                .onChange(of: currentUserWrapper.purchaseStatus, perform: { value in
                        print("onChange of purchaseResult = ", value ?? "nil")
                        if !(value == nil || value == "Purchase Successful" || value == "loading" || value == "User Cancelled Payment") {
                            showBadPurchaseAlert.toggle()
                        }
                })
                .onDisappear(perform: {
                    currentUserWrapper.purchaseStatus = nil
                    currentUserWrapper.finishedTutorial()
                    print("Finished Pod Tutorial")
                })
                .alert(isPresented: $showBadPurchaseAlert, content: {
                    Alert(title: Text("Purchase Unsuccessful"), message: Text(currentUserWrapper.purchaseStatus ?? ""), dismissButton: .cancel())
                })
            }
            }.background(Color.purple)
        }
    }
}


struct OnboardingView: View {
    @Binding var tutorialStep: Int
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @Binding var activeSheet: ActiveSheet?

    var body: some View {
        
        
        ZStack {
        
        if tutorialStep == 0 {
            ZStack {
                Color.black.opacity(0.4).blur(radius: 3.0)

                VStack {
                    Spacer()
                    Text("Welcome to BuddyUp.")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .bold()
                        .padding()
                        .multilineTextAlignment(.center)
                    Text("Use small groups to build positive habits in the best possible way.")
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                        .padding()
                        .multilineTextAlignment(.center)
                    Spacer()
                    Button(action: {
                            tutorialStep = 1
                            print("starting tutorial")

                    }, label: {
                        Text("Get Started")
                            .foregroundColor(.purple)
                            .font(.title2)
                            .bold()
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding()
                    })
                    Spacer()
                
            }
            .frame(width: UIScreen.main.bounds.width * 4/5, height: UIScreen.main.bounds.height * 7/10, alignment: .center)
            .background(Color.purple)
            .cornerRadius(7)
            .shadow(radius: 20)
                
            }
        } else if tutorialStep == 1 {
            
            ZStack {
                Color.black.opacity(0.4).blur(radius: 3.0)
                
                SubscriptionPopUp(showSubsriptionView: .constant(true), tutorialStep: $tutorialStep)
                    .frame(width: UIScreen.main.bounds.width * 4/5, height: UIScreen.main.bounds.height * 7/10, alignment: .center)
                    .background(Color.purple)
                    .cornerRadius(7)
                    .shadow(radius: 20)
                
            }

        }
        
//        else if tutorialStep == 1 {
//            ZStack {
//
//                ClearCircle(width: 55, height: 55, x: 27 * Int(UIScreen.main.bounds.width)/32, y: Int(UIScreen.main.bounds.height)/22)
//                    .fill(Color.black.opacity(0.4), style: FillStyle(eoFill: true))
//
//                VStack{
//                    HStack{
//                        Spacer()
//                        Button(action: {
//                            print("Clear Circle Tapped, opening Profile Sheet")
//                            activeSheet = .profileInfo
//                            withAnimation {
//                                tutorialStep = 2
//                            }
//                            },
//                        label: {
//                            Circle().fill(Color.clear)
//                        })
//                        .frame(width:100, height: 100)
//                        .clipShape(Circle())
//                        .offset(x: 0, y: 20)
//                    }
//
//                    Text("Tap here to view your profile")
//                        .fontWeight(.bold)
//                        .font(.title3)
//                        .foregroundColor(.white)
//                        .padding(15)
//                        .background(Color.purple)
//                        .cornerRadius(30, corners: [.topLeft, .bottomLeft, .bottomRight])
//
//                        //.font(.title2)
//                        //.forgroundColor(.white)
//                        //.background(Color.purple)
//                        //.cornerRadius(10, corners: [.topLeft, .bottonLeft, .bottomRight])
//                    Spacer()
//                }
//                //.position(26 * Int(UIScreen.main.bounds.width)/32, y: Int(UIScreen.main.bounds.height)/24)
//            }

//        } else if tutorialStep == 2 {
//            ZStack {
//                Color.clear
//            }
//        }
            
        }
        
    }
}

struct ClearCircle: Shape {
    let width: Int
    let height: Int
    let x: Int
    let y: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        path.addEllipse(in: CGRect(x: x, y: y, width: width, height: height) )
        return path
        
    }
}

//struct Window: Shape {
//    let size: CGSize
//    func path(in rect: CGRect) -> Path {
//        var path = Rectangle().path(in: rect)
//
//        let origin = CGPoint(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2)
//        path.addRect(CGRect(origin: origin, size: size))
//        return path
//    }
//}




struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {

        SubscriptionPopUp(showSubsriptionView: .constant(true), tutorialStep: .constant(100))

    }
}


///n/n
//VIEW APPEARED. ENSURING WE ARE AT THE BOTTOM
//
//IN POD ROW NOTIFICATION ACTION CHANGED, currentUserWrapper.notificationAction =  nil
//on Change selection =  nil
//
//IN ContentView ON CHANGE OF currentUserWrapper.notificationAction, value =  nil
//
//IN POD LIST on Change of currentUserWrapper.notificationAction
//selection =  nil
//
//NEW MESSAGE. SCROLLING TO BOTTOM


//IN POD CHAT ON CHANGE:  nil

//self.textFieldHeight CHANGE. SCROLLING TO BOTTOM. NEW TEXT FIELD HEIGHT IS:  37.666666666666664

