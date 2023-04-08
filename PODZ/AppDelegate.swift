//
//  AppDelegate.swift
//  PODZ
//
//  Created by Nick Miller on 6/15/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FBSDKCoreKit
import GoogleSignIn
import FirebaseFirestore
import FirebaseMessaging
import SwiftUI
import Combine
import Purchases


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // GIDSignIn's delegate is a weak property, so we have to define our GoogleDelegate outside the function to prevent it from being deallocated.
//    let googleDelegate = GoogleDelegate()
    
    
    let gcmMessageIDKey: String = "gcm.message_id"
    
    var currentUserWrapper : UserWrapper = UserWrapper()
    
    
    
    
    func application( _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

          
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "MpFhHKdwOIqOgiCbIrggQbRxNGuYtnfi")
        
        
        FirebaseApp.configure()
        
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
//        GIDSignIn.sharedInstance.clientID = FirebaseApp.app()?.options.clientID
//        GIDSignIn.sharedInstance.delegate = googleDelegate
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self


        let authOptions: UNAuthorizationOptions = [.alert,.badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: {
            allowed, error in
            
            if allowed {
                print("notifications allowed")
            } else  {
                print(error?.localizedDescription ?? "notis not allowed")
            }

          })
        
        application.registerForRemoteNotifications()

           // Define the notification type
           let chatCategory =
                 UNNotificationCategory(identifier: "chat", //category name
                 actions: [],
                 intentIdentifiers: [],
                 hiddenPreviewsBodyPlaceholder: "",
                 options: .customDismissAction)
        
            let profileInfoCategory = UNNotificationCategory(identifier: "Profile Info", //category name
                                                          actions: [],
                                                          intentIdentifiers: [],
                                                          hiddenPreviewsBodyPlaceholder: "",
                                                          options: .customDismissAction)

           // Register the notification type.
           let notificationCenter = UNUserNotificationCenter.current()
           notificationCenter.setNotificationCategories([chatCategory, profileInfoCategory])

        
        if launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] != nil {
            print("USER TAPPED NOTIFICATION TO OPEN APP THAT WAS NOT ALREADY IN BACKGROUND OR FOREGROUND")
        }
        

        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("\n\n DEVICE TOKEN", deviceToken)
        Messaging.messaging().apnsToken = deviceToken
        

        
   }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print(error.localizedDescription)
   }

    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {

        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )

        return GIDSignIn.sharedInstance.handle(url)
    }


    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
       // If you are receiving a notification message while your app is in the background,
       // this callback will not be fired till the user taps on the notification launching the application.
       // TODO: Handle data of notification
       // With swizzling disabled you must let Messaging know about the message, for Analytics
       Messaging.messaging().appDidReceiveMessage(userInfo)
       // Print message ID.
       if let messageID = userInfo[gcmMessageIDKey] {
         print("Message ID: \(messageID)")
       }

       // Print full message.
       print(userInfo)
     }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification

      // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
        
        //do something with message data here
      if let messageID = userInfo[gcmMessageIDKey] {
        print("\n\n")
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        
      let userInfo = notification.request.content.userInfo

      Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("\n\n")
        print("Message ID: \(messageID)")
      }
      // Print full message.
      print("USER INFO: ", userInfo)

        completionHandler([[.banner, .badge, .sound]])
    }

    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
      let userInfo = response.notification.request.content.userInfo
        

        let application = UIApplication.shared
        if application.applicationState == .active {
            print("USER TAPPED NOTIFICATION WHEN APP WAS ACTIVE")
            let notificationCategory = response.notification.request.content.categoryIdentifier
            
            if notificationCategory == "chat" {
                print("POD ID TO MOVE TO : ", userInfo["podID"] as! String)
                currentUserWrapper.notificationAction = userInfo["podID"] as? String
                
            } else if notificationCategory == "Profile Info" {
                currentUserWrapper.notificationAction = "Profile Info"
            }
            
        }
        
        if application.applicationState == .inactive {
            print("USER TAPPED NOTIFICATION BAR WHEN APP WAS INACTIVE")
            let notificationCategory = response.notification.request.content.categoryIdentifier
            
            if notificationCategory == "chat" {
                print("POD ID TO MOVE TO : ", userInfo["podID"] as! String)
                currentUserWrapper.notificationAction = userInfo["podID"] as? String
            } else if notificationCategory == "Profile Info" {
                currentUserWrapper.notificationAction = "Profile Info"
            }
            
        }
        
        if application.applicationState == .background {
            print("USER TAPPED NOTIFICATION BAR WHEN APP WAS IN BACKGROUND")
            let notificationCategory = response.notification.request.content.categoryIdentifier
            
            if notificationCategory == "chat" {
                print("POD ID TO MOVE TO : ", userInfo["podID"] as! String)
                currentUserWrapper.notificationAction = userInfo["podID"] as? String

                
            } else if notificationCategory == "Profile Info" {
                
                currentUserWrapper.notificationAction = "Profile Info"
            }
            
        }
//
        print("currentUserWrapper.notificationAction = ", currentUserWrapper.notificationAction ?? "none")
        
        
        if let messageID = userInfo[gcmMessageIDKey] {
          print("Message ID: \(messageID)")
        }

        Messaging.messaging().appDidReceiveMessage(userInfo)

        print("USER INFO: ", userInfo)
          


      completionHandler()
    }
    
    
    
    

}

extension AppDelegate: MessagingDelegate{
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {

        let dataDict:[String: String] = ["token": fcmToken ]
        print("\n\n")
        print(dataDict)
        tokenSingleton.tokenDict = dataDict
        currentUserWrapper.tokenDict = dataDict
        
        //STORE TOKEN IN FIRESTORE FOR EACH INDIVIDUAL USER
    }
}

class Singleton {
    var tokenDict: [String:String]?
    //var notificationAction : String?
    static let sharedInstance: Singleton = {
        let instance = Singleton()
        
        return instance
    }()
}
let tokenSingleton = Singleton()
