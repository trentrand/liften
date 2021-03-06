//
//  AppDelegate.swift
//  liften
//
//  Created by Trent Rand on 2/25/15.
//  Copyright (c) 2015 applies, llc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PNDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // Register Parse api key
        Parse.setApplicationId("2sVAfoU9PjJTVdTADU94RqOWqb2eelKgkz8LZ5w4", clientKey: "cwYT799fhAHAYw4HUjvP3fRrv2LRb5hAoE0EfY3g")

        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        PFFacebookUtils.initializeFacebook()
    
        let pnConfig: PNConfiguration = PNConfiguration(forOrigin: "pubsub.pubnub.com", publishKey: "pub-c-fb33efd6-47ad-4534-aaee-c4d218634c15", subscribeKey: "sub-c-94fa7b14-d74b-11e4-8301-0619f8945a4f", secretKey: "sec-c-ZGUxMDc0MzctOWMxOS00MjJhLWIyMDgtZjc5MDE1NTFiOTRj")
        PubNub.setConfiguration(pnConfig)
        PubNub.setDelegate(self)
        PubNub.connect()
        
        return true
    }
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject?) -> Bool {
            return FBAppCall.handleOpenURL(url, sourceApplication:sourceApplication,
                withSession:PFFacebookUtils.session())
    }

    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        PFFacebookUtils.session().close()
    }
    
    func pubnubClient(client: PubNub!, didConnectToOrigin origin: String!) {
        NSLog("DELEGATE: Connected to origin: \(origin)")
    }
    
    func pubnubClient(client: PubNub!, didReceiveMessage message: PNMessage!) {
        //Messages received in LiftenViewController also
        // Logic is handled there
//        NSLog("Received: \(message.message)")
    }
    
    func pubnubClient(client: PubNub!, didSubscribeOnChannels channels: [AnyObject]!) {
        NSLog("DELEGATE: Subscribed to channel: \(channels)")
    }
    
}

