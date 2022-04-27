//
//  ProfileInfoView.swift
//  
//
//  Created by Nick Miller on 9/15/20.
//

import SwiftUI
import Combine
import FirebaseFirestore




struct ProfileInfoView: View {
    
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @Binding var activeSheet: ActiveSheet?

//    var dummyFriends : [String] = ["make a pod with a friend","all my friends are dead", "push me to the edge", "johnny", "amy"]
//    var dummyContacts : [String] = ["1","1","1","1","1","1","1","1", "jack and jill","some are on the app", "those on the app can be friended","new word for friend maybe"," not on the app email invited"]
    
    @State var searchedUser: User?
    @State var searchText = ""
    @State var isSearching = false
    @Binding var tutorialStep: Int
    
    

    
    var actionSheet: ActionSheet {
        ActionSheet(
            title: Text("Are you sure you want to log out?").font(.system(size: 22)),
            buttons: [
                .default(Text("Log Out").foregroundColor(.red), action: {
                    //activeSheet = nil
                    print("loggin out/n")
                    currentUserWrapper.signOut()
            }),
            .cancel()
            ]
        )
    }
    
    var alert: Alert {
        Alert(title: Text("Are you sure you want to log out?"), message: nil, primaryButton: .default(Text("Log Out").foregroundColor(.red),action: {
            activeSheet = nil
            print("loggin out/n")
            //currentUserWrapper.currentUser = nil
            currentUserWrapper.signOut()
        }), secondaryButton: .cancel())
    }
    
    @State var showActionSheet = false
    @State var showProfileEditPopUp = false
    
    @State var searchByEmail: Bool = true
    @State var phoneNumber = ""
    @State var phoneNumberTooShort = false
    @State var phoneNumberConfirmedPress = false
    @State var troubleAddingPhoneNumber = false

    var body: some View {
        
        
            ZStack {


                VStack(alignment: .leading, spacing: 0) {
                
            



            HStack {

                Text((currentUserWrapper.currentUser?.firstName == nil ? "UnknownName" : currentUserWrapper.currentUser!.firstName) + " " + (currentUserWrapper.currentUser?.lastName == nil ? "UnknownName" : currentUserWrapper.currentUser!.lastName))
                    .foregroundColor(.white)
                    .bold()
                    .font(.system(size: 24))
                    .lineLimit(1)
                    .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 1))

                Spacer()

                Button {
                    showProfileEditPopUp = true
                } label: {
                    Text("Edit")
                        .foregroundColor(.purple)
                        .padding(5).background(Color.white)
                        .cornerRadius(10)
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 5))
                }

            }
            .padding(.top, 15).padding(.bottom, 15)
            .background(Color.purple)
            .padding(.bottom, 25)

                HStack {
                    Spacer()
                    Button {
                        
                        searchByEmail = true
                        
                    } label: {
                        
                        Text("Search By Email")
                            .font(.system(size: searchByEmail ? 20 : 15, weight: searchByEmail ? .bold : .medium, design: .default))
                            .foregroundColor(.black)
                            .opacity(searchByEmail ? 1 : 0.5)


                            
                    }
                    Spacer()
                    
                    Button {
                        
                        searchByEmail = false
                        
                    } label: {
                        
                        Text("Find in Contacts")

                        
                            .font(.system(size: searchByEmail ? 15 : 20, weight: searchByEmail ? .medium : .bold, design: .default))
                            .foregroundColor(.black)
                            .opacity(searchByEmail ? 0.5 : 1)
                    }
                    Spacer()

                }.padding(.bottom, 20)
                    

                
                if searchByEmail {
                    
                        
                    SearchAndResults(searchBarWrapper: SearchBarWrapper(searchText: searchText, isSearching: isSearching, searchedResult: searchedUser), searchTextBinding: $searchText, isSearchingBinding: $isSearching).environmentObject(currentUserWrapper)


                    ScrollView {
                            VStack {
                                
                                
                                Text("FRIEND REQUESTS")
                                    .foregroundColor(.white)
                                    .font(.system(size: 22))
                                    .bold()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(5)
                                    .background(Color.purple)
                                
                                if currentUserWrapper.userIncomingFriendRequests.count == 0 {
                                    
                                    VStack(alignment: .center) {
                                        Text("No incoming friend requests")

                                    }.padding(5)
                                    
                                } else {
                                    

                                    ForEach(currentUserWrapper.userIncomingFriendRequests, id: \.id) { friend in

                                        friendCell(user: friend, isFriendRequest: true, nonUserEmail: nil, isFriend: false)
                                            .frame(maxHeight: 70)
                                    }
                                }

                                Text("YOUR FRIENDS")
                                    .foregroundColor(.white)
                                    .font(.system(size: 22))
                                    .bold()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(5)
                                    .background(Color.purple)

                                if currentUserWrapper.userFriends.count == 0 {
                                    
                                    VStack(alignment: .center) {
                                        Text("You have no friends on BuddyUp.")
                                        Text("You can search for friends by email. or by contacts.")
                                        Text("Or find them in your phone contacts.")
                                    }
                                    .padding(5)
                                    
                                } else {
                                    
                                    ForEach(currentUserWrapper.userFriends, id: \.id) { friend in

                                        friendCell(user: friend, isFriendRequest: false, nonUserEmail: nil, isFriend: true)
                                            .frame(maxHeight: 70)
                                        Color.gray.frame(maxWidth: .infinity, maxHeight: 2).padding(.leading, 10).padding(.trailing, 10).padding(1)
                                    }
                                }

                        }
                        .frame(maxHeight: UIScreen.main.bounds.height * 3/7, alignment: .top)
                        .padding()
                    }
                } else {
                    
                    if currentUserWrapper.currentUser!.phoneNumber != nil {
                        
                        ScrollView {
                            if currentUserWrapper.contactsMatchedToUsers.count == 0 {
                                VStack {
                                    
                                    Text("No BuddyUp users found :( ")
                                    Text("You can change that by telling your friends!")

                                }.padding(.top, 20).frame(maxWidth: .infinity, alignment: .center)
                            }
                            ForEach(currentUserWrapper.contactsMatchedToUsers, id: \.id) { matchedUser in
                                
                                Color.gray.frame(maxWidth: .infinity, maxHeight: 2).padding(.leading, 10).padding(.trailing, 10).padding(1)
                                friendCell(user: matchedUser, isFriendRequest: false, nonUserEmail: nil, isFriend: currentUserWrapper.userFriends.contains(matchedUser))
                                    .frame(maxHeight: 70)
                            }
                            
                        }.padding(.horizontal, 10)

                        
                    } else {
                        VStack(alignment: .center) {
                            
                            if phoneNumberTooShort  {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text("This number is too short. It can't be right")
                                        .foregroundColor(Color.red)
                                }
                            }
                            if troubleAddingPhoneNumber {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text("We are having trouble connecting. Try Again.")
                                        .foregroundColor(Color.red)
                                }
                            }
                            
                            TextField("Enter Phone Number", text: $phoneNumber)
                                .keyboardType(.numberPad)
                                .onReceive(Just(phoneNumber)) { newValue in
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    if filtered != newValue {
                                        self.phoneNumber = filtered
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(10)
                                .padding()

                            Text("Note: No Country Codes.").font(.caption).foregroundColor(.gray)
                            Text("Example: For the USA, ").font(.caption).foregroundColor(.gray)
                            HStack {
                               
                                Text("NO 19998887777.").font(.caption).foregroundColor(.red).bold()
                                Text("YES 9998887777.").font(.caption).foregroundColor(.green).bold()
                                
                            }
                            
                            Button {
                                if phoneNumber.count < 7 {
                                    phoneNumberTooShort = true

                                } else {
                                    phoneNumberTooShort = false
                                    phoneNumberConfirmedPress = true
                                    currentUserWrapper.addPhoneNumber(phoneNumber: phoneNumber) { res in
                                        if res {
                                            currentUserWrapper.fetchContacts()

                                        } else {
                                            troubleAddingPhoneNumber = true
                                            phoneNumberConfirmedPress = false
                                        }
                                    }
                                }

                            } label: {
                                VStack {
                                    if phoneNumberConfirmedPress {
                                        PodRowLoader()
                                    } else {
                                        Text("Confirm")
                                            .font(.title3)
                                            .foregroundColor(.white)

                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(10)
                                .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 5))
                                .disabled(phoneNumberConfirmedPress)
                            }

                            Spacer()
                        }
                    }
                }
                
                //
//                if currentUserWrapper.userIncomingFriendRequests.count + currentUserWrapper.userFriends.count > 6 {
//
//                    Button(action: {print("See full list")}, label: {
//                        Text("SEE FULL LIST").foregroundColor(.blue)
//                            .font(.system(size: 22))
//                            .bold()
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                            .padding()
//                            .background(Color.blue.opacity(0.5))
//                    })
//                }
            
            //TODO: implement friends list

            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
//            .gesture(DragGesture(minimumDistance: 8, coordinateSpace: .local)
//                                    .onChanged({ value in
//
//                                        if value.translation.height > 8 && value.translation.height > abs(value.translation.width) {
//                                            UIApplication.shared.endEditing()
//                                        }
//                                    }))
            .alert(isPresented: $showActionSheet, content: {
                alert
            })

            if showProfileEditPopUp {

                Color.black.opacity(0.4)
                if currentUserWrapper.currentUser != nil {
                    
                        
                    ProfileEditPopUp(showProfileEditPopup: $showProfileEditPopUp, editedFirstName: currentUserWrapper.currentUser!.firstName, editedLastName: currentUserWrapper.currentUser!.lastName, showActionSheet: $showActionSheet)
                        .frame(width: UIScreen.main.bounds.width * 4/5, height: UIScreen.main.bounds.height * 7/10, alignment: .center)
                        .cornerRadius(7)
                        .offset(y: -50)
                        .shadow(radius: 20)
                }
            }

        }
        .onAppear {
            currentUserWrapper.fetchContacts()
            print("FETCHING CONTACTS")
        }
        .ignoresSafeArea(.keyboard)
        .animation(.default)

    }
}

struct SearchAndResults: View {
    @ObservedObject var searchBarWrapper: SearchBarWrapper
    @Binding var searchTextBinding: String
    @Binding var isSearchingBinding: Bool
    @EnvironmentObject var currentUserWrapper: UserWrapper
    
    
    var body: some View {
        
        SearchBar(searchText: $searchTextBinding, isSearching: $isSearchingBinding)
            .padding(.horizontal)
            .padding(.bottom)

        if searchBarWrapper.searchResult != nil {
            
            friendCell(user: searchBarWrapper.searchResult, isFriendRequest: false, nonUserEmail: nil, isFriend: currentUserWrapper.userFriends.contains(searchBarWrapper.searchResult!)).frame(maxHeight: 70)
                .padding(3)
        } else {
            if searchBarWrapper.searchText == "" {

            } else if searchBarWrapper.isSearching {
                PodRowLoader().padding(.leading)
            } else {
                Text("User Not Found").padding(.leading)
            }
        }
    }
}

struct ProfileEditPopUp: View {
    @Binding var showProfileEditPopup: Bool
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @State var editedFirstName: String
    @State var editedLastName: String
    @Binding var showActionSheet: Bool
    @State var makeFirstResonder = false
    @State var calculatedHeight : CGFloat = 37.5
    var body: some View {
        
        ZStack {
            VStack {
                
                Button {
                    showProfileEditPopup = false
                } label: {
                    Image(systemName: "xmark.circle.fill").font(.title2).foregroundColor(.gray).frame(alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                .padding(5)

                Text("Edit Profile")
                    .foregroundColor(.black)
                    .bold()
                    .font(.title2)
                    .padding(3)
                    .padding(.bottom, 5)

//                Text("First Name: ")
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(EdgeInsets(top: 10, leading: 5, bottom: 0, trailing: 0))
//
//                TextField("First Name", text: $editedUserInformation.firstName)
//                    .padding(EdgeInsets(top: 10, leading: 7, bottom: 3, trailing: 0))
//                    .background(Color.gray.opacity(0.1))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 5)
//                            .stroke(Color.gray, lineWidth: 1)
//                    )
//                    .padding(EdgeInsets(top: 0, leading: 5, bottom: 10, trailing: 50))
//                Text("Last Name:")
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 0))
                
                Text(currentUserWrapper.currentUser?.email ?? "")
                    .font(.title3)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 5)
                    .padding(5)
                
                MessagingTextField(text: $editedFirstName, wantToMakeFirstResponder: $makeFirstResonder, calculatedHeight: $calculatedHeight, placeHolderText: "")
                    .frame(height: 40)
                    .cornerRadius(5)
                    .foregroundColor(Color.gray.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(EdgeInsets(top: 0, leading: 5, bottom: 20, trailing: 50))
                MessagingTextField(text: $editedLastName, wantToMakeFirstResponder: $makeFirstResonder, calculatedHeight: $calculatedHeight, placeHolderText: "")
                    .frame(height: 40)
                    .cornerRadius(5)
                    .foregroundColor(Color.gray.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(EdgeInsets(top: 0, leading: 5, bottom: 20, trailing: 50))

                    
                
//                TextField("LastName", text: $editedUserInformation.lastName)
//                    .padding(EdgeInsets(top: 10, leading: 7, bottom: 3, trailing: 0))
//                    .background(Color.gray.opacity(0.1))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 5)
//                            .stroke(Color.gray, lineWidth: 1)
//                    )
//                    .padding(EdgeInsets(top: 0, leading: 5, bottom: 20, trailing: 50))
                HStack{
                    Button {
                        currentUserWrapper.updateFirstAndLastName(newFirstName: editedFirstName, newLastName: editedLastName)
                        showProfileEditPopup = false
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
                    Button(action: {
                            showProfileEditPopup = false
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
                Spacer()
                Button(action: {
                    print("logout clicked")
                    self.showActionSheet = true
                    
                }){
                    Text("Log Out").foregroundColor(Color.red).bold().font(.title3).frame(maxWidth: .infinity, maxHeight: 40, alignment: .center).background(Color.red.opacity(0.6))
                }.padding(.top, 15)
            }
            .background(Color.white)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .ignoresSafeArea(.keyboard)
            //.shadow(radius: 30)
        }
        
    }
}

struct friendCell: View {
    
    @EnvironmentObject var currentUserWrapper: UserWrapper
    var user: User?
    var isFriendRequest: Bool
    var nonUserEmail: String?
    var isFriend: Bool
    @State var friendRequestSentSuccessfully = false
    @State var friendRequestAcceptedSuccessfully = false
    @State var friendRequestDeniedSuccessfully = false
    @State var friendRequestAlreadySent = false
    
    var body: some View {
        
        VStack {
            HStack {
                Text(user!.firstName + " " + user!.lastName).font(.system(size: 20)).padding(3).lineLimit(1)
                Spacer()

                if isFriendRequest {

                    if friendRequestAcceptedSuccessfully {

                        Text("Request Accepted").padding(7).foregroundColor(.white).frame(maxHeight: .infinity)
                            .background(Color.purple)
                            .cornerRadius(5)
                    }

                    else if friendRequestDeniedSuccessfully {

                        Text("Request Denied").padding(7).foregroundColor(.white).frame(maxHeight: .infinity)
                            .background(Color.purple)
                            .cornerRadius(5)

                    }

                    else if !isFriend{

                        HStack{

                            Button(action: {
                                currentUserWrapper.removeIncomingFriendRequest(friendUID: user!.ID)
                                currentUserWrapper.addFriend(friendUID: user!.ID)
                                currentUserWrapper.addUserToFriendList(friendUID: user!.ID)
                                friendRequestAcceptedSuccessfully = true
                                currentUserWrapper.cloudFunctionsOnFriendRequestAccepted(friendID: user!.ID)

                            }, label: {

                                Image(systemName: "checkmark")
                                    .padding(7)
                                    .foregroundColor(.white).frame(maxHeight: .infinity)
                                    .background(Color.purple)
                                    .cornerRadius(5)

                            })

                            Button(action: {
                                currentUserWrapper.removeIncomingFriendRequest(friendUID: user!.ID)

                            }, label: {
                                Image(systemName: "xmark")
                                    .padding(7)
                                    .foregroundColor(.black)
                                    .frame(maxHeight: .infinity)
                                    .background(Color.gray.opacity(0.5))
                                    .cornerRadius(5)
                            })
                        }

                    }
                }
               else if user != nil && !isFriend {


                    if user!.pendingSentFriendRequestsIDs.contains(currentUserWrapper.currentUser!.ID) {
                        Text("Request Pending").padding(7).foregroundColor(.black).frame(maxHeight: .infinity)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(5)
                    }

                    else if currentUserWrapper.currentUser!.pendingSentFriendRequestsIDs.contains(user!.ID) {
                        
                        Text("Request Sent").padding(7).foregroundColor(.black).frame(maxHeight: .infinity)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(5)
                    }
                    else {
                        Button(action: {
                            currentUserWrapper.sendFriendRequest(friendUID: user!.ID)
                            currentUserWrapper.cloudFunctionsOnFriendRequestSent(recieverID: user!.ID)
                            friendRequestSentSuccessfully = true

                        }, label: {
                            HStack{
                                Text("Add Friend").padding(2).foregroundColor(Color.white)
                                Image(systemName: "plus").padding(2).foregroundColor(.white)
                            }.frame(maxHeight: .infinity).padding(2).background(Color.purple).cornerRadius(5)
                        })
                    }

                } else if user == nil{

                    Text(nonUserEmail!).padding(3).lineLimit(1)
                    Spacer()
                    HStack{
                        Button(action: {print("invite")}, label: {
                            Text("Invite").padding(2).foregroundColor(.white)
                            Image(systemName: "envelope").padding(2).foregroundColor(Color.white).cornerRadius(5)
                        })

                    }.padding(2).background(Color.purple).cornerRadius(7.0)
                }
            
            }
            .padding(10)
                
        }
        
    }
}

class SearchBarWrapper: ObservableObject {
    private var worker: AnyCancellable? = nil
    @Published var searchResult: User?
    @Published var searchText: String
    @Published var isSearching: Bool
    
    init(searchText: String, isSearching: Bool, searchedResult: User?) {
        self.isSearching = isSearching
        self.searchText = searchText.lowercased()
        worker = AnyCancellable(
            $searchText
                .debounce(for: 1, scheduler: DispatchQueue.main)
                .removeDuplicates()
                .sink(receiveValue: { (searchText) in
                    
                    if searchText == "" {
                        return
                    }

                    searchForUser(email: searchText) { (searchedUser) in
                        print("IN SEARCH COMPLETION")
                        self.isSearching = false
                        self.searchResult = searchedUser
                    }
                })
        )
    }
    

}

func searchForUser(email:String, completion: @escaping (User?) -> ()) {
    let db = Firestore.firestore()
    print("searching with text " + email)
    
    db.collection("users").whereField("email", isEqualTo: email).getDocuments { (snapshot, error) in
        if error != nil {
            print("error retrieving document: " + error.debugDescription)
            completion(nil)
        }
        else {
            if snapshot!.documents.isEmpty {
                print("NO USER WITH EMAIL: " + email)
                completion(nil)
            } else {
                let result = Result {
                    try snapshot?.documents[0].data(as: User.self)
                }
                    switch result {
                    case .success(let user):
                        if let user = user {
                            print("SEARCH SUCCESS")
                           completion(user)
                        } else {
                            print("WEIRD. USER DOES NOT EXIST")
                            completion(nil)
                        }
                      case .failure(let error):
                        print("error decoding document: \(error)")
                            completion(nil)
                }
            }
        }
    }
}


struct SearchBar: View {
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @Binding var searchText: String
    @Binding var isSearching: Bool
    
    var body: some View {

            HStack{
                HStack{
                    Image(systemName: "magnifyingglass")
                        .padding(.leading, 10)
                        .foregroundColor(.gray)
                    TextField("Search Users by Email", text: $searchText)
                        .padding()
                        .background(Color(.systemGray5))

                }.onTapGesture {
                    isSearching = true
                }
                    
                Button(action: {
                    searchText = ""
                    UIApplication.shared.endEditing()
                    
                }, label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                })
            }
            .padding(.trailing, 10)
            .background(Color(.systemGray5))
            .cornerRadius(10)
        //            if isSearching {
//                Button(action: {
//                    UIApplication.shared.endEditing()
//                    isSearching = false
//
//                }, label: {
//                    Text("Cancel")
//                })
//                .transition(.move(edge: .trailing))
//                .animation(.spring())
//
//            }
    }
}

struct ProfileInfoView_Previews: PreviewProvider {
    static var previews: some View {

        ProfileEditPopUp(showProfileEditPopup: .constant(true), editedFirstName: "DUMMY", editedLastName: "dfafd", showActionSheet: .constant(true))

    }
}
