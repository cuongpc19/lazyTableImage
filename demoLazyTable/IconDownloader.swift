//
//  IconDownloader.swift
//  demoLazyTable
//
//  Created by AgribankCard on 3/22/17.
//  Copyright © 2017 cuongpc. All rights reserved.
//

import UIKit
private let kAppIconSize : CGFloat = 48
class IconDownloader : NSObject, NSURLConnectionDataDelegate {

    var appRecord: AppRecord?
    var completionHandler: (() -> Void)?
    private var sessionTask: URLSessionDataTask?
    
    func startDownload() {
        let request = URLRequest(url: URL(string: self.appRecord!.imageURLString!)!)
        
        // create an session data task to obtain and download the app icon
        sessionTask = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            // in case we want to know the response status code
            //let httpStatusCode = (response as! HTTPURLResponse).statusCode
            
            if let actualError = error as NSError? {
                if #available(iOS 9.0, *) {
                    if actualError.code == NSURLErrorAppTransportSecurityRequiresSecureConnection {
                                              abort()
                    }
                }
            }
            OperationQueue.main.addOperation{
                // Set appIcon and clear temporary data/image
                let image = UIImage(data: data!)!
                
                if image.size.width != kAppIconSize || image.size.height != kAppIconSize {
                    let itemSize = CGSize(width: kAppIconSize, height: kAppIconSize)
                    UIGraphicsBeginImageContextWithOptions(itemSize, false, 0.0)
                    let imageRect = CGRect(x: 0.0, y: 0.0, width: itemSize.width, height: itemSize.height)
                    image.draw(in: imageRect)
                    self.appRecord!.appIcon = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                } else {
                    self.appRecord!.appIcon = image
                }
                self.completionHandler?()
            }
        })
        
        self.sessionTask?.resume()
    }
    func cancelDownload() {
        self.sessionTask?.cancel()
        sessionTask = nil
    }
    
}
