//
//  AppDelegate.swift
//  BluelipsDemo
//
//  Created by Dario on 12/11/2021.
//

import UIKit
import SwiftyBeaver

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        setupSwiftyBeaverLog()

        SwiftyBeaver.info("========== Application didFinishLaunchingWithOptions ====================")

        return true
    }


    func applicationDidBecomeActive(_ application: UIApplication) {
        SwiftyBeaver.info(">>----->> Application applicationDidBecomeActive >>----->> ")
    }


    func applicationWillResignActive(_ application: UIApplication) {
        SwiftyBeaver.info("<<-----<< Application applicationWillResignActive <<-----<< ")
    }


    func applicationWillTerminate(_ application: UIApplication) {
        SwiftyBeaver.info("<<-----<< Application applicationWillTerminate <<-----<<")
    }


    func applicationWillEnterForeground(_ application: UIApplication) {
        SwiftyBeaver.info(">>----->> Application applicationWillEnterForeground >>----->>")
    }


    func applicationDidEnterBackground(_ application: UIApplication) {
        SwiftyBeaver.info("<<-----<< Application applicationDidEnterBackground <<-----<<")
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


    // MARK: - Private Section -
    private func setupSwiftyBeaverLog() {
        let logger = SwiftyBeaver.self

        // add at least one log destination
        let console = ConsoleDestination() // log to Xcode Console
        let file = FileDestination() // log to default swiftybeaver.log file

        // custom format: short time, log level & message
        console.format = "$DHH:mm:ss$d $L $M"

        logger.addDestination(console)
        logger.addDestination(file)
        // Uncomment to get remote logging
/*
        let platform = SBPlatformDestination(appID: "0G8N31", appSecret: "Axzoyiua9TqzkubcpeXAfz0dpc5tzk4d", encryptionKey: "fq0wduvbtvfvodasivfgxrDaohlkh2tn")

        logger.addDestination(platform)
 */
    }

}
