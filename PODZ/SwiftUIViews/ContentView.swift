//
//  ContentView.swift
//  PODZ
//
//  Created by Nick Miller on 6/15/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import SwiftUI
import Firebase
import GoogleSignIn
import FirebaseAuth


struct ContentView: View {
    
    @EnvironmentObject var currentUserWrapper : UserWrapper
    @State var isPresentingProfileInfo = false
    @State var isPresentingEmailTabView = false
//    @EnvironmentObject var googleDelegate: GoogleDelegate
    @State var splashScreenIsActive = false
    @State var activeSheet: ActiveSheet?
    @State var tutorialStep = 0
    @State var podListSelection: String? = nil
    
    @State var finishLogoLoader: Bool = false
    @State var logoSelector: Int = Int.random(in: 0..<3)
    
    
    func getUser()  {
        currentUserWrapper.listen()
    }

    var body: some View {
        
        ZStack {
            
            
            //if we've just created a new user from google or facebook, we want to confirm user information
            if currentUserWrapper.currentUser != nil  && currentUserWrapper.showConfirmedProfileInformation && finishLogoLoader {
                
                ConfirmedProfileView( editedFirstName : currentUserWrapper.currentUser!.firstName, editedLastName : currentUserWrapper.currentUser!.lastName, editedEmail: currentUserWrapper.currentUser!.email)//.environmentObject(currentUserWrapper)
            }
                
            
            //home page that we go to once we've loaded users and begining to load group data
             else if currentUserWrapper.currentUser != nil && !currentUserWrapper.showConfirmedProfileInformation && finishLogoLoader {
                
                PodListView(activeSheet: $activeSheet, tutorialStep: $tutorialStep)
            }
            
             
             
            //If there is no currentUser and we've triedToLoad user already, then we need to bring the user to the sign in page
             else if currentUserWrapper.triedToLoadUser && finishLogoLoader {
                
                ZStack {
                    
                    SignInView(emailTabViewPresented: $isPresentingEmailTabView, activeSheet: $activeSheet)
                    
                    //loading animation that lays on top of the sign in screen
                    if currentUserWrapper.loadingFromSignIn && currentUserWrapper.startedToLoadUser {
                            ZStack {
                                Color.white.opacity(0.5)
                                PodRowLoader()
                            }
                    }
                }
             } else {
                if logoSelector == 0 {
                    LogoSpinnerLoaderView(finishLogoSpinner: $finishLogoLoader)
                } else if logoSelector == 1 {
                    LogoBounceLoaderView(finishLogoBounce: $finishLogoLoader)
                } else {
                    LogoScaleLoaderView(finishLogoScaleLoaderView: $finishLogoLoader)
                }
               
             }
            
            
            
            
        }
        .edgesIgnoringSafeArea(.all)
        .onChange(of: currentUserWrapper.notificationAction) { value in
            print("IN ContentView ON CHANGE OF currentUserWrapper.notificationAction, value = ", value ?? "none")
            if value != nil  && currentUserWrapper.currentUser != nil{
                if value == "Profile Info" {
                    activeSheet = .profileInfo
                }
            }
        }
        .onAppear() {
            currentUserWrapper.tokenDict = tokenSingleton.tokenDict
            self.getUser()
            
            
            if currentUserWrapper.notificationAction == "Profile Info" {
                activeSheet = .profileInfo
            }
            print("IN ON APPEAR OF CONTENTVIEW after reassignment currentUSERWRAPPER.notificationAction = ",  currentUserWrapper.notificationAction ?? "none")
            
        }
        .sheet(item: $activeSheet)
            { item in
            switch item {
            
            case .passwordReset:
                EmailPasswordResetPage(activeSheet: self.$activeSheet)
            case .profileInfo:
                ProfileInfoView(activeSheet: self.$activeSheet, tutorialStep: $tutorialStep).environmentObject(currentUserWrapper)
            case .email:
                EmailTabView(activeSheet: self.$activeSheet).environmentObject(currentUserWrapper)
            
                
            }
        }
        .transition(.move(edge: .top))

    }

}

class NotificationCenter: NSObject, ObservableObject {
    var dumbData: UNNotificationResponse?
    override init() {
       super.init()
       UNUserNotificationCenter.current().delegate = self
    }
}
    extension NotificationCenter: UNUserNotificationCenterDelegate  {
       func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) { }
        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    dumbData = response
    }
      func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) { }
}


    



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(UserWrapper())
//                .environmentObject(GoogleDelegate())
        }
    }
}
