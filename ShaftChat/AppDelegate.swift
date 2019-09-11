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
import PushKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, SINClientDelegate, SINCallClientDelegate, SINManagedPushDelegate {
    
    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?
    
    var locationManager: CLLocationManager?
    var coordinates: CLLocationCoordinate2D?
    
    var _client: SINClient!
    var push: SINManagedPush!
    var callKitProvider: SINCallKitProvider!

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
        
        push = Sinch.managedPush(with: .development)
        push.delegate = self
        push.setDesiredPushTypeAutomatically()
        
        func userDidLogin(userId: String) {
            push.registerUserNotificationSettings()
            initSinchWithUserId(userId: userId)
            startOneSignal()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(USER_DID_LOGIN_NOTIFICATION), object: nil, queue: nil) { (notification) in
            
            let userId = notification.userInfo![kUSERID] as! String
            userDefaults.setValue(userId, forKey: kUSERID)
            userDefaults.synchronize()
            userDidLogin(userId: userId)
        }
        
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound], completionHandler: { (granted, error) in
            })
            application.registerForRemoteNotifications()
        } else {
            let types: UIUserNotificationType = [.alert, .badge, .sound]
            let settings = UIUserNotificationSettings(types: types, categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: kONESIGNALAPPID, handleNotificationAction: nil, settings: [kOSSettingsKeyInAppAlerts : false])
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        var top = self.window?.rootViewController
        while (top?.presentedViewController != nil) {
            top = top?.presentedViewController
        }
        
        if top! is UITabBarController {
            setBadges(controller: top as! UITabBarController)
        }
        
        if FUser.currentUser() != nil {
            updateCurrentUserInFirestore(withValues: [kISONLINE : true]) { (success) in
                
            }
        }
        locationManagerStart()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        recentBadgeHandler?.remove()
        
        if FUser.currentUser() != nil {
            updateCurrentUserInFirestore(withValues: [kISONLINE : false]) { (success) in
                
            }
        }
        
        locationManagerStop()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if callKitProvider != nil {
            let call = callKitProvider.currentEstablishedCall()
            
            if call != nil {
                var top = self.window?.rootViewController
                
                while (top?.presentedViewController != nil) {
                    top = top?.presentedViewController
                }
                
                
                if !(top! is CallViewController) {
                    let callVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "callView") as! CallViewController
                    
                    callVC._call = call
                    
                    top?.present(callVC, animated: true, completion: nil)
                }
            }
        }
        // If there is one established call, show the callView of the current call when the App is brought to foreground.
        // This is mainly to handle the UI transition when clicking the App icon on the lockscreen CallKit UI.

    }

    func goToApp(){
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID: FUser.currentId()])
        
        let mainController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        
        window?.rootViewController = mainController
    }
    
    //MARK: PushNotification functions
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.sandbox)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let firebaseAuth = Auth.auth()
        if firebaseAuth.canHandleNotification(userInfo) {
            return
        } else {
//            push.application(application, didReceiveRemoteNotification: userInfo)
        }
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
    
    //MARK: Sinch
    
    func initSinchWithUserId(userId: String) {
        if _client == nil {
            _client = Sinch.client(withApplicationKey: kSINCHKEY, applicationSecret: kSINCHSECRET, environmentHost: "sandbox.sinch.com", userId: userId)
            _client.delegate = self
            _client.call()?.delegate = self
            _client.setSupportCalling(true)
            _client.enableManagedPushNotifications()
            _client.start()
            _client.startListeningOnActiveConnection()
            
            callKitProvider = SINCallKitProvider(withClient: _client)
        }
    }
    
    //MARK: - SinchManagedPushDelegate
    
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable : Any]!, forType pushType: String!) {
        
        if pushType == "PKPushTypeVoIP" {
            self.handleRemoteNotification(userInfo: payload as NSDictionary)
        }
    }
    
    func handleRemoteNotification(userInfo: NSDictionary) {
        if _client == nil {
            let userId = userDefaults.object(forKey: kUSERID)
            if userId != nil {
                initSinchWithUserId(userId: userId as! String)
            }
        }
        
        let result = _client.relayRemotePushNotification(userInfo as! [AnyHashable : Any])
        if result!.isCall() {
            print(" handle call notification")
        }
        
        if result!.isCall() && result!.call()!.isCallCanceled {
            missedCallNotificationWithRemoteUserId(userId: result!.call()!.callId)
        }
    }
    
    func missedCallNotificationWithRemoteUserId(userId: String) {
        if UIApplication.shared.applicationState == .background {
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "Missed Call"
            content.body = "From \(userId)"
            content.sound = UNNotificationSound.default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "ContentIdentifier", content: content, trigger: trigger)
            
            center.add(request) { (error) in
                if error != nil {
                    print("Error presenting notification: => \(error?.localizedDescription)")
                }
            }
        }
    }
    
    //MARK: - SinchCallClientDelegate
    func client(_ client: SINCallClient!, willReceiveIncomingCall call: SINCall!) {
        print("will receive incoming call")
        callKitProvider.reportNewIncomingCall(call: call)
}
    
    func client(_ client: SINCallClient!, didReceiveIncomingCall call: SINCall!) {
        print("did receive incoming call")
        //present call view
        var top = window?.rootViewController
        while (top?.presentedViewController != nil) {
            top = top?.presentedViewController
        }
        
        let callViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "callView") as! CallViewController
        callViewController._call = call
        top?.present(callViewController, animated: true, completion: nil)
    }
    
    //MARK: SinchClientDelegate
    
    func clientDidStart(_ client: SINClient!) {
        print("client did start")
    }
    
    func clientDidStop(_ client: SINClient!) {
        print("client did stop")
    }
    
    func clientDidFail(_ client: SINClient!, error: Error!) {
        print("client did fail: =>  \(error.localizedDescription)")
    }
    
}

