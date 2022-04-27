//
//  PodInfoView.swift
//  PODZ
//
//  Created by Nick Miller on 7/13/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import SwiftUI


//let dummyPod = Pod(id: "DUMMY", n: "DUMMY", memberScoreDict: [:], memberNameDict: [:], memberScheduleDict: [:], memberPhraseDict: [:], memberTimeDict: [:], podType: "DUMMY",memberAliasesAndIDs: [:], memberColorDict: [:], memberAliasHasLogged: [:], memberAliasLogPhrase: [:], dayNumber: 0, dayLimit: 30)


struct PodInfoView: View {
    
    @Binding var activePodSheet: ActivePodSheet?
    @ObservedObject var currentPodWrapper: PodWrapper
    
    @State var showLeavingPopUp: Bool = false
    @EnvironmentObject var currentUserWrapper: UserWrapper
    
    
    var dummyPodName = "Weightlifting Group"
    var dummyDayNumberAndLimit = "Day 5/30"
    var aliases: [String] = ["a", "b", "c"]
    @State var showPodNameEditPopUp = false
    

    
    var body: some View {
        ZStack {

            VStack {
                VStack {
                    HStack {

                        Text(currentPodWrapper.currentPod!.podName)
                            .foregroundColor(Color.white)
                            .fontWeight(.bold)
                            .font(.system(size: 20))
                            .padding(.leading, 10)

                        Spacer()

                        if currentPodWrapper.currentPod!.communityOrFriendGroup == "Friend" {
                            Button {
                                showPodNameEditPopUp = true
                            } label: {
                                Text("Edit")
                                    .font(.system(size: 16))
                                    .foregroundColor(.purple)
                                    .padding(4)
                                    .padding(.horizontal, 4)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                            }
                        }
                    }

                    Text("Day " + String(currentPodWrapper.currentPod!.dayNumber) + "/" + String(currentPodWrapper.currentPod!.dayLimit))
                        .foregroundColor(Color.white)
                        .font(.title3)
                        .padding(.bottom, 10)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 15)
                .background(Color.purple)
                .padding(.bottom, 10)


                ForEach(aliases, id: \.self) { alias in
                    PodMemberInfo(podWrapper: currentPodWrapper, alias: alias)
                }
                Spacer()
                Button(action: {
                    showLeavingPopUp.toggle()
                }, label: {
                    Text("Leave Habit Group")
                        .foregroundColor(Color.red)
                        .bold()
                        .font(.title3)
                        .frame(maxWidth: .infinity, maxHeight: 60, alignment: .center)
                        .background(Color.red.opacity(0.4))
                        .cornerRadius(10)
                }).padding()

            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if showLeavingPopUp {
                Color.black.opacity(0.5).onTapGesture {
                    showLeavingPopUp = false
                }
                LeavingPopUp(showLeavingPopUp: $showLeavingPopUp , currentPodWrapper: currentPodWrapper, activePodSheet: $activePodSheet)
                    .environmentObject(currentUserWrapper)
                    .frame(width: UIScreen.main.bounds.width * 5/6, height: UIScreen.main.bounds.height * 3/4, alignment: .center)
                    .cornerRadius(10)
                    .shadow(radius: 20)

            }
            if showPodNameEditPopUp {
                Color.black.opacity(0.5).onTapGesture {
                    showPodNameEditPopUp = false
                }
                PodNameEditPopUp(showPodNameEditPopUp: $showPodNameEditPopUp, currentPodWrapper: currentPodWrapper, editedPodName: currentPodWrapper.currentPod!.podName)
                    .environmentObject(currentUserWrapper)
//                    .frame(width: UIScreen.main.bounds.width * 5/6, height: UIScreen.main.bounds.height * 3/4, alignment: .center)
                    .cornerRadius(10)
                    .shadow(radius: 20)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
    }
}


struct PodNameEditPopUp: View {
    
    @Binding var showPodNameEditPopUp: Bool
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @ObservedObject var currentPodWrapper: PodWrapper
    @State var editedPodName: String

    @State var makeFirstResonder = false
    @State var calculatedHeight : CGFloat = 37.5
    
    var body: some View {
        
        ZStack {
            VStack {
                
                Button {
                    showPodNameEditPopUp = false
                } label: {
                    Image(systemName: "xmark.circle.fill").font(.title2).foregroundColor(.gray).frame(alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                .padding(5)

                Text("Edit Group Name")
                    .foregroundColor(.black)
                    .bold()
                    .font(.title2)
                    .padding(3)
                    .padding(.bottom, 5)

                VStack {
                    
                    MessagingTextField(text: $editedPodName, wantToMakeFirstResponder: $makeFirstResonder, calculatedHeight: $calculatedHeight, placeHolderText: "")
                        .frame(height: 40)
                        .cornerRadius(5)
                        .foregroundColor(Color.gray.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    Text(String(35 - editedPodName.count) + " characters left")
                        .font(.footnote)
                        .foregroundColor(editedPodName.count > 35 ? .red : .black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 7)
                        .padding(.bottom, 5)
                }
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 20, trailing: 50))

                    

                HStack {
                    
                    Button {
                        currentPodWrapper.updatePodName(newPodName: editedPodName)
                        showPodNameEditPopUp = false
                    } label: {
                        Text("Confirm")
                            .bold()
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(maxWidth: UIScreen.main.bounds.width * 2/5)
                            .padding(5)
                            .background(Color.purple)
                            .cornerRadius(10)
                            .padding(EdgeInsets(top: 0, leading: 5, bottom: 10, trailing: 2))
                    }
                    .disabled(editedPodName.count > 35)
                    .opacity(editedPodName.count > 35 ? 0.5 : 1)
                    
                    Button(action: {
                        showPodNameEditPopUp = false
                    }, label: {
                        Text("Cancel")
                            .bold()
                            .font(.title3)
                            .foregroundColor(.black)
                            .frame(maxWidth: UIScreen.main.bounds.width * 2/5)
                            .padding(5)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                            .padding(EdgeInsets(top: 0, leading: 2, bottom: 10, trailing: 5))
                    })
                }

            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .ignoresSafeArea(.keyboard)
            //.shadow(radius: 30)
            }
            .background(Color.white)
        }
        
    }
}

struct PodMemberInfo: View {
    
    @ObservedObject var podWrapper: PodWrapper
    var alias: String
    @EnvironmentObject var currentUserWrapper: UserWrapper
    
    func getPercentScore(pod: Pod, alias: String) -> Int {
        
        let totalHabitDays = pod.memberAliasesAndHabitDays[alias]!
        let daysVerified = pod.memberAliasesAndScore[alias]!
//        print("For " + pod.memberAliasesAndName[alias]!)
//        print("DAYS VERIFIED: ", daysVerified)
//        print("TOTAL HABIT DAYS: ", totalHabitDays)


        if totalHabitDays == 0 {
//            print("SCORE : " , 100)
//            print("___________________________")
            return 100

        }
        else if daysVerified > totalHabitDays {
//            print("daysVerified > totalHabitDays, giving max score of 100")
            return 100
        }else {
//            print("SCORE : " , Int(Float(daysVerified)/Float(totalHabitDays) * 100))
//            print("___________________________")
            return Int(Float(daysVerified)/Float(totalHabitDays) * 100)
        }
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
//            print("TIME COMMITMENT: ", timeCommitment)
        
            return timeCommitment
        
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
                    
    func nameText(podWrapper: PodWrapper, alias: String) -> String {
        if podWrapper.bufferedNewPod != nil {
            return podWrapper.bufferedNewPod!.memberAliasesAndName[alias]! + " - "
        } else {
            return podWrapper.currentPod!.memberAliasesAndName[alias]! + " - "
        }
    }
    
    func habitText(podWrapper: PodWrapper, alias: String) -> String {
        if podWrapper.bufferedNewPod != nil {
            return podWrapper.bufferedNewPod!.memberAliasesAndHabit[alias]! + " - Score: "
        } else {
            return podWrapper.currentPod!.memberAliasesAndHabit[alias]! + " - Score: "
        }
    }
    var body: some View {
        
        if podWrapper.currentPod!.memberAliasesAndName[alias] != nil {
            
            VStack(alignment: .center) {
                HStack(spacing: 0) {
                    
                    Text(nameText(podWrapper: podWrapper, alias: alias))
                        .foregroundColor(colorOfUserFromCode(colorCode: getColorCode(memberAlias: alias, currentPod: podWrapper.currentPod!)))
                        .fontWeight(.bold)
                        .font(.system(size: 17))
                        .padding(.leading, 2)
                    Text(habitText(podWrapper: podWrapper, alias: alias))
                            .foregroundColor(colorOfUserFromCode(colorCode: getColorCode(memberAlias: alias, currentPod: podWrapper.currentPod!)))
                            .fontWeight(.bold)
                            .font(.system(size: 17))
                        Text(String(getPercentScore(pod: podWrapper.currentPod!, alias: alias)) + "%")
                            .foregroundColor(colorOfUserFromCode(colorCode: getColorCode(memberAlias: alias, currentPod: podWrapper.currentPod!)))
                            .fontWeight(.bold)
                            .font(.system(size: 17))
                }
                VStack(alignment: .center) {
                        Text("After " + podWrapper.currentPod!.memberAliasesAndHabit[alias]! + ", ")
                            .font(.system(size: 17))
                            .lineLimit(1)
                        Text(podWrapper.currentPod!.memberAliasesAndName[alias]! + " will log the phrase")
                            .font(.system(size: 17))
                        Text("\"" + podWrapper.currentPod!.memberAliasesAndLogPhrase[alias]! + "\"")
                            .font(.system(size: 17))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                    Text(formPodInfoCommitmentStatement(daysArray: podWrapper.currentPod!.memberAliasesAndSchedule[alias]!,
                                                        timeAsHHM: convertFriendHabitTimeToLocalUserTimeAsHHMM(
                                                            userSecondsFromGMT: podWrapper.currentPod!.memberAliasesAndSecondsFromGMT[podWrapper.getAliasFromUID(UID: currentUserWrapper.currentUser!.ID)!]!,
                                                            friendSecondsFromGMT: podWrapper.currentPod!.memberAliasesAndSecondsFromGMT[alias]!,
                                                            timeAsHHMM: podWrapper.currentPod!.memberAliasesAndTime[alias]!),
                                                        commitmentLength: podWrapper.currentPod!.dayLimit))
                    
                    
                            .font(.system(size: 17))
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                }
                .padding(.vertical, 3)
                .frame(maxWidth: .infinity, alignment: .center)
                .overlay(RoundedRectangle(cornerRadius: 15)
                            .stroke(colorOfUserFromCode(colorCode: getColorCode(memberAlias: alias, currentPod: podWrapper.currentPod!)), lineWidth: 2)
                )
                .background(Color(UIColor.systemGray5))
                .cornerRadius(15)
                .padding(.horizontal, 20)


            }
            .padding(.horizontal, 3)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct LeavingPopUp: View {
    @State var showPersonIssue = false
    @State var showHabitIssue = false
    @Binding var showLeavingPopUp: Bool
    @ObservedObject var currentPodWrapper: PodWrapper
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @Binding var activePodSheet: ActivePodSheet?
    
    var body: some View {
        ZStack {
            
            if showPersonIssue {
                Color.white
                PersonIssue(showLeavingPopUp: $showLeavingPopUp, showPersonIssue: $showPersonIssue, currentPodWrapper: currentPodWrapper, activePodSheet: $activePodSheet)
                    .environmentObject(currentUserWrapper)
//                    .frame(width: UIScreen.main.bounds.width * 5/6, height: UIScreen.main.bounds.height * 2/3, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//                Color.black.opacity(0.5)
            }
            else if showHabitIssue {
                Color.white
                HabitIssue(showHabitIssue: $showHabitIssue, currentPodWrapper: currentPodWrapper, showLeavingPopUp: $showLeavingPopUp, activePodSheet: $activePodSheet)
                    .environmentObject(currentUserWrapper)
                
            } else {
                VStack {
                    Text("Why do you want to leave this habit group?")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                        .padding(.bottom, 3)
                        .padding(10)
                    Text("Note: Please be honest to help us improve the BuddyUp experience. Any information shared here will be strictly confidential.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(10)
                    Spacer()
                    Button(action: {showPersonIssue = true}, label: {
                        Text("I don't like someone in my group")
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            
                    })
                    .disabled(currentPodWrapper.currentPod?.memberAliasesAndIDs == nil ? true : Array(currentPodWrapper.currentPod!.memberAliasesAndIDs.keys).count < 2 ? true: false)
                    .opacity(currentPodWrapper.currentPod?.memberAliasesAndIDs == nil ? 0.5 : (Array(currentPodWrapper.currentPod!.memberAliasesAndIDs.keys).count < 2 ? 0.5 : 1))
                    
                    Button(action: {showHabitIssue = true}, label: {
                        Text("I don't want to do this habit anymore")
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                    })
                    Spacer()
                    Button(action: {showLeavingPopUp = false}, label: {
                        Text("Cancel")
                            .foregroundColor(.black)
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            
                    })
                    
                }.background(Color.white)
            }
        }
    }
}

struct PersonIssue: View {
    //var dummyFirstNames: [User]
    @State var boolList: [Bool] = [Bool](repeating: false, count: 26)
    @State var aliasOfProblemPerson: [String] = []
    @State var personIssueDetail: String = ""
    @Binding var showLeavingPopUp: Bool
    @Binding var showPersonIssue: Bool
    
    @ObservedObject var currentPodWrapper: PodWrapper
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @State var displayAlert: Bool = false
    
    @State var keyboardOpen: Bool = false
    
    @State var calculatedHeight: CGFloat = UIScreen.main.bounds.height * 3/10
    
    let alphabet = ["a","b","c","d","e","f","g","h"]
    @Binding var activePodSheet: ActivePodSheet?
    
    var body: some View {
        VStack {
            Button(action: {showPersonIssue = false}, label: {
                HStack(spacing: 0) {
                    
                    Image(systemName: "chevron.backward").font(.title2)
                    Text("Back")
                    
                }.padding()
            }).frame(maxWidth: .infinity, alignment: .leading)

            Text("To help improve the BuddyUp community, please indicate which of your group members you didn't like and give some details.")
                .multilineTextAlignment(.center)
                .padding()
            
            ForEach(0..<alphabet.count) { index in

                if currentPodWrapper.currentPod?.memberAliasesAndName[alphabet[index]] != nil
                    && currentPodWrapper.currentPod!.memberAliasesAndIDs[alphabet[index]] != currentUserWrapper.currentUser!.ID
                {

                        Button(action: {
                            boolList[index].toggle()
                            aliasOfProblemPerson.append(alphabet[index])
                        }, label: {
                            HStack {
                                Text(currentPodWrapper.currentPod!.memberAliasesAndName[alphabet[index]]!)
                                    .foregroundColor(.black)
                                    .font(.title3)
                                Image(systemName: boolList[index] ? "checkmark.square" : "square")
                                    .foregroundColor(.black)
                                    .font(.title3)
                                    .padding(.leading, 10)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .background(Color.gray.opacity(boolList[index] ? 0.3 : 0.0))
                        })
                        .frame(maxHeight: 60)
                        .padding(.trailing, 10)
                    }
                }

            //.animation(.interpolatingSpring(mass: 3, stiffness: 1000, damping: 500, initialVelocity: 12))
            MessagingTextField(text: $personIssueDetail, wantToMakeFirstResponder: $keyboardOpen, calculatedHeight: $calculatedHeight, placeHolderText: "Extra Details")
                .frame(maxWidth: UIScreen.main.bounds.width * 13/16, maxHeight: UIScreen.main.bounds.height * 2/10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                        
                )

                

            Button(action: {
                if boolList.first(where: { $0 == true }) == nil {
                    displayAlert = true
                } else {
                    
                    var complainedAgainstIDs: [String] = []
                    for alias in aliasOfProblemPerson {
                        complainedAgainstIDs.append(currentPodWrapper.currentPod!.memberAliasesAndIDs[alias]!)
                    }
                    let complaint: Complaint = Complaint(type: "person", complainerID: currentUserWrapper.currentUser!.ID, complainedAgainstIDs: complainedAgainstIDs, details: personIssueDetail, associatedPod: currentPodWrapper.podID, complainerAlias: currentPodWrapper.getAliasFromUID(UID: currentUserWrapper.currentUser!.ID)!)
                    currentUserWrapper.activeComplaint = complaint
                    withAnimation {
                        showLeavingPopUp = false
                    }
                    
                    activePodSheet = nil
                    //currentUserWrapper.popBackToPodList = true

                }

            }, label: {
                Text("Leave Group")
                    .foregroundColor(.red)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .padding(7)
                    .background(Color.red.opacity(0.3))
                    .cornerRadius(10)
                    .padding()
                

            })
            Spacer()
        }
        .actionSheet(isPresented: $displayAlert, content: {
            
            
            return ActionSheet(
                title: Text("Please select at least one of your group members").font(.system(size: 22)),
            message: Text("If you can't pinpoint at least one person, please go back and select the other reason to leave group"),
                buttons: [
                .cancel()
                ]
            )
        })
        
        .background(Color.white)
        .onTapGesture {
            UIApplication.shared.endEditing()

        }
        .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onEnded({ value in

                if value.translation.height > 0 {
                    UIApplication.shared.endEditing()
                }
            }))
    }
}

struct SuccessfullyLeftGroupView: View {
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    
    var body: some View {
        VStack {
            Image(systemName: "checkmark").font(.largeTitle).foregroundColor(.green).border(Color.white, width: 5).animation(.linear)
            Button(action: {self.mode.wrappedValue.dismiss()}, label: {
                Text("OK").font(.title2).foregroundColor(.purple).padding(.horizontal, 20).padding().background(Color.white)
            })
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.black.opacity(0.5))
        
    }
}
struct HabitIssue: View {
    
    @State var habitIssueDetail: String = ""
    @Binding var showHabitIssue: Bool
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @ObservedObject var currentPodWrapper: PodWrapper
    @State var keyboardOpen: Bool = false
    @State var calculatedHeight: CGFloat = UIScreen.main.bounds.height * 3/10
    @Binding var showLeavingPopUp: Bool
    @Binding var activePodSheet: ActivePodSheet?
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    
    var body: some View {
        VStack {
            Button(action: {showHabitIssue = false}, label: {
                HStack(spacing: 0) {
                    
                    Image(systemName: "chevron.backward").font(.title2)
                    Text("Back")
                    
                }.padding()
            }).frame(maxWidth: .infinity, alignment: .leading)

            Text("That's Okay.")
                .foregroundColor(.black)
                .fontWeight(.bold)
                .font(.title2)
            Text("Please let us know if there is anything we can do to improve your experience on BuddyUp.")
                .foregroundColor(.black)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding()
            MessagingTextField(text: $habitIssueDetail, wantToMakeFirstResponder: $keyboardOpen, calculatedHeight: $calculatedHeight, placeHolderText: "Extra Details")
                .frame(maxWidth: UIScreen.main.bounds.width * 13/16, maxHeight: UIScreen.main.bounds.height * 2/10)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                        
                )
            
            Button(action: {
                print("LEAVING POD CLICKED")
                let complaint: Complaint = Complaint(type: "habit", complainerID: currentUserWrapper.currentUser!.ID, complainedAgainstIDs: nil, details: habitIssueDetail, associatedPod: currentPodWrapper.podID, complainerAlias: currentPodWrapper.getAliasFromUID(UID: currentUserWrapper.currentUser!.ID)!)
                currentUserWrapper.activeComplaint = complaint
                activePodSheet = nil
                withAnimation {
                    showLeavingPopUp = false
                    
                }
                
                currentUserWrapper.leftAPod = true
                print("FILED COMPLAINT, dismissing")
//                self.mode.wrappedValue.dismiss()
                
                
            }, label: {
                Text("Leave Group")
                    .foregroundColor(.red)
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.3))
                    .cornerRadius(10)
                    .padding()
            
            })
        Spacer()
        }
        .background(Color.white)
        .onTapGesture {
            UIApplication.shared.endEditing()

        }
        .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                            .onEnded({ value in

                                if value.translation.height > 0 {
                                    UIApplication.shared.endEditing()
                                }
                            }))
    }
}

//struct PodInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//
////        PodInfoView(activePodSheet: .constant(.podInfo), currentPodWrapper: PodWrapper(id: "4ff8504b-e83e-4b33-9fb7-e786768bcd35"))
////        LeavingPopUp(showLeavingPopUp: .constant(true), currentPodWrapper: PodWrapper(id: "4ff8504b-e83e-4b33-9fb7-e786768bcd35"))
////        PersonIssue(boolList: [true], aliasOfProblemPerson: [], personIssueDetail: "", showLeavingPopUp: .constant(true), showPersonIssue: .constant(true), currentPodWrapper: PodWrapper(id: "4ff8504b-e83e-4b33-9fb7-e786768bcd35"), displayAlert: false, activePodSheet: .constant(.podInfo))
//        PodInfoView(activePodSheet: .constant(nil), currentPodWrapper: PodWrapper(id: "4ff8504b-e83e-4b33-9fb7-e786768bcd35")).environmentObject(UserWrapper())
//
//    }
//}
