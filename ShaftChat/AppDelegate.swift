//
//  AppDelegate.swift
//  ShaftChat
//
//  Created by Rodrigo Sant Ana on 03/08/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?
    
    var locationManager: CLLocationManager?
    var coordinates: CLLocationCoordinate2D?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        //Autologin
        authListener = Auth.auth().addStateDidChangeListener({ (auth, user) in
            
            //remove listener to make it work only one time
            Auth.auth().removeStateDidChangeListener(self.authListener!)
            
            if user != nil {
                
                if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil {
                    
                    DispatchQueue.main.async {
                        self.goToApp()
                    }
                    
                }
            }
        })
        
        func userDidLogin(userId: String) {
            self.startOneSignal()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(USER_DID_LOGIN_NOTIFICATION), object: nil, queue: nil) { (notification) in
            
            let userId = notification.userInfo![kUSERID] as! String
            userDefaults.setValue(userId, forKey: kUSERID)
            userDefaults.synchronize()
            userDidLogin(userId: userId)
        }
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: kONESIGNALAPPID)
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        if FUser.currentUser() != nil {
            updateCurrentUserInFirestore(withValues: [kISONLINE : true]) { (success) in
                
            }
        }
        locationManagerStart()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        if FUser.currentUser() != nil {
            updateCurrentUserInFirestore(withValues: [kISONLINE : false]) { (success) in
                
            }
        }
        
        locationManagerStop()
    }

    func goToApp(){
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID: FUser.currentId()])
        
        let mainController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        
        window?.rootViewController = mainController
    }
    
    //MARK: - Location Manager
    func locationManagerStart() {
        
        if locationManager == nil {
            
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
        }
        
        locationManager!.startUpdatingLocation()
    }
    
    func locationManagerStop() {
        
        if locationManager != nil {
            
            locationManager!.stopUpdatingLocation()
        }
    }
    
    //MARK: - Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("failed to get location")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .restricted:
            print("restricted")
        case .denied:
            locationManager = nil
            print("denied location access")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        coordinates = locations.last!.coordinate
    }
    
    //MARK: - OneSignal
    
    func startOneSignal() {
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let userId = status.subscriptionStatus.userId
        let pushToken = status.subscriptionStatus.pushToken
        
        if pushToken != nil {
            if let playerID = userId {
                userDefaults.set(playerID, forKey: kPUSHID)
            } else {
                userDefaults.removeObject(forKey: kPUSHID)
            }
            userDefaults.synchronize()
        }
        
        //update one signal ID
        updateOneSignalId()
    }
}

