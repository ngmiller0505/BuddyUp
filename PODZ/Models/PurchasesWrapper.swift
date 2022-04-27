//
//  PurchasesWrapper.swift
//  PODZ
//
//  Created by Nick Miller on 8/10/21.
//  Copyright © 2021 Nick Miller. All rights reserved.
//

import Foundation
import Purchases

class PurchasesWrapper: ObservableObject {
    
    @Published var isPremium : Bool = false
    @Published var packages: [Purchases.Package]?
    @Published var purchaseStatus: String?
    
    
    init() {
        print("INITIALIZING purchasesWRAPPER")
        self.getPackages() { packagesResult in
            
            self.packages = packagesResult
            
        }
        self.checkIfPremium() { isPremium in
            self.isPremium = isPremium
        }
        
        
    }
    
    
    
    func checkIfPremium(completion : @escaping ((Bool) -> ())){
        
        print("checking if premium")
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if error == nil {
                if purchaserInfo!.entitlements.active["unlimited"]?.isActive != nil {
                    
                    print("successfully checked if premium. purchaserInfo!.entitlements.active[unlimited]!.isActive = ", purchaserInfo!.entitlements.active["unlimited"]!.isActive)
                    completion(purchaserInfo!.entitlements.active["unlimited"]!.isActive)
                } else {
                    print("purchaserInfo!.entitlements.active[unlimited]?.isActive == nil")
                    completion(false)
                }
            } else {
                print("ERROR CHECKING IF PREMIUM: ", error!.localizedDescription)
                completion(false)
            }
        }

    }
    
    func purchaseSubscription(packageToPurchase: Purchases.Package) {
        
        //        let db = Firestore.firestore()

        Purchases.shared.purchasePackage(packageToPurchase) { (transaction, purchaserInfo, err, userCancelled) in
            
            if purchaserInfo?.entitlements.all["unlimited"]?.isActive == true {
                self.isPremium = true
                print("SUBSCRIPTION PURCHASE SUCCESSFUL FOR " + packageToPurchase.identifier)
                self.purchaseStatus = "Purchase Sucessful"
                
//                        db.collection("users").document(self.currentUser!.ID).updateData(["isPaid" : true]) { err in
//                            if err != nil {
//                                print("Database error with purchase. Please try again or contact support at NickBuddyUp@gmail.com")
//                                completion("Database error with purchase. Please try again or contact support at NickBuddyUp@gmail.com")
//                            } else {
//                                print("Purchase Successful")
//                                completion("Purchase Successful")
//                            }
//                        }
                
            } else if userCancelled {
                print("User Cancelled Payment")
                self.purchaseStatus = "User Cancelled Payment"
            } else if err != nil {
                
                print(err!.localizedDescription)
                self.purchaseStatus = "Error making payment. Please try again or contact support at NickBuddyUp@gmail.com"
                
                
            } else if transaction?.error != nil {
               
                switch  Purchases.ErrorCode(_nsError: (transaction?.error!)! as NSError).code {
                case .purchaseNotAllowedError:
                    print("Purchases not allowed on this device. Please try again or contact support at NickBuddyUp@gmail.com")
                    self.purchaseStatus = "Purchases not allowed on this device. Please try again or contact support at NickBuddyUp@gmail.com"
                case .purchaseInvalidError:
                    print("Purchase invalid, check payment source. Please try again or contact support at NickBuddyUp@gmail.com")
                    self.purchaseStatus = "Purchase invalid, check payment source. Please try again or contact support at NickBuddyUp@gmail.com"
                default:
                    print("_________ default transaction error __________")
                    self.purchaseStatus = "Transaction Error. Please try again or contact support at NickBuddyUp@gmail.com"
                    break
                }
            }
        }
    }
    
    
    func getPackages(completion : @escaping (([Purchases.Package]?) -> ()))  {
        print("\n\n getting packages")
        Purchases.shared.offerings { (offerings, error) in
            if let packages = offerings?.current?.availablePackages {
                
                
//                let basicMonthlyProSubscriptionPackage = packages[0]
//                let product = basicMonthlyProSubscriptionPackage.product
//                let title = product.localizedTitle
//                let price = product.price
//                let identifier = product.productIdentifier
//                let subscriptionPeriod = product.subscriptionPeriod
//                var duration = ""
//
//                switch subscriptionPeriod!.unit {
//
//                case SKProduct.PeriodUnit.month:
//                    duration = "\(subscriptionPeriod!.numberOfUnits) Month"
//
//                case SKProduct.PeriodUnit.year:
//                    duration = "\(subscriptionPeriod!.numberOfUnits) Year"
//
//                default:
//                    duration = ""
//                }
                print("__________")
                print("SUCCESSFULLY GOT PACKAGES")
                print("__________")

                completion(packages)

            } else if error != nil {
                print("__________")

                print("GOT ERROR RETRIEVING PACKAGES: ", error!.localizedDescription)
                print("__________")

                completion(nil)
                
            } else {
                print("WEIRD ERROR RETRIEVING PACKAGES")
                print("offerings.debugDescription = ", offerings.debugDescription, offerings ?? "nil")
                print("offerings.current = ", offerings?.current ?? "nil")
                print("offerings?.current?.availablePackages = ", offerings?.current?.availablePackages ?? "nil")
                completion(nil)
            }
            
        }
        
        

    }
    func formPackageDisplayString(package: Purchases.Package) -> String {
                let product = package.product
                let title = product.localizedTitle
                let price = product.price
                let subscriptionPeriod = product.subscriptionPeriod
                var duration = ""
                print(title)

                switch subscriptionPeriod!.unit {

                case SKProduct.PeriodUnit.month:
                    duration = "\(subscriptionPeriod!.numberOfUnits) Month"

                case SKProduct.PeriodUnit.year:
                    duration = "\(subscriptionPeriod!.numberOfUnits) Year"

                default:
                    duration = ""
                }
        return (product.priceLocale.currencySymbol ?? "") + price.stringValue + " / " + duration
    }
    
}
