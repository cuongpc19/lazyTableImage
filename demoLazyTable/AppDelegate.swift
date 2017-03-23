//
//  AppDelegate.swift
//  demoLazyTable
//
//  Created by AgribankCard on 3/22/17.
//  Copyright © 2017 cuongpc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NSURLConnectionDataDelegate {

    var window: UIWindow?
    final let TopPaidAppsFeed =
    "http://phobos.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/toppaidapplications/limit=75/xml"
    private var queue: OperationQueue?
    
    // the NSOperation driving the parsing of the RSS feed
    private var parser: ParseOperation!

    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let request = URLRequest(url: URL(string: TopPaidAppsFeed)!)
        
        // create an session data task to obtain and the XML feed
        let sessionTask = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            // in case we want to know the response status code
            //let HTTPStatusCode = (response as! NSHTTPURLResponse).statusCode
            
            if let actualError = error as NSError? {
                OperationQueue.main.addOperation {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    var isATSError: Bool = false
                    if #available(iOS 9.0, *) {
                        isATSError = actualError.code == NSURLErrorAppTransportSecurityRequiresSecureConnection
                    }
                    if isATSError {
                        // if you get error NSURLErrorAppTransportSecurityRequiresSecureConnection (-1022),
                        // then your Info.plist has not been properly configured to match the target server.
                        //
                        abort()
                    } else {
                        self.handleError(actualError)
                    }
                }
            } else {
                // create the queue to run our ParseOperation
                self.queue = OperationQueue()
                // create an ParseOperation (NSOperation subclass) to parse the RSS feed data so that the UI is not blocked
                self.parser = ParseOperation(data: data!)
                self.parser.errorHandler = {parseError in
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.handleError(parseError)
                    }
                }
                // referencing parser from within its completionBlock would create a retain cycle
                self.parser.completionBlock = {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let recordList = self.parser.appRecordList {
                        self.performUIUpdatesOnMain {
                            let rootViewController =
                                (self.window!.rootViewController as! UINavigationController?)?.topViewController as! RootViewController?
                            rootViewController?.entries = recordList
                            rootViewController?.tableView.reloadData()
                        }
                    }
                    // we are finished with the queue and our ParseOperation
                    self.queue = nil
                }
                // Code apple: self.queue?.addOperation(self.parser)
                //cuongpc modify (khong hieu sao khong dung cai nay, khai bao queue them de lam gi
                OperationQueue.main.addOperation(self.parser)
            }
        })
        sessionTask.resume()
        // show in the status bar that network activity is starting
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        return true
    }
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func handleError(_ error: Error) {
        let errorMessage = error.localizedDescription
        
        // alert user that our current record was deleted, and then we leave this view controller
        //
        let alert = UIAlertController(title: "Cannot Show Top Paid Apps",
                                      message: errorMessage,
                                      preferredStyle: .actionSheet)
        let OKAction = UIAlertAction(title: "OK", style: .default) {action in
            // dissmissal of alert completed
        }
        
        alert.addAction(OKAction)
        
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }


}

