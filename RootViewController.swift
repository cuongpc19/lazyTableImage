//
//  RootViewController.swift
//  demoLazyTable
//
//  Created by AgribankCard on 3/22/17.
//  Copyright © 2017 cuongpc. All rights reserved.
//

import UIKit

class RootViewController: UITableViewController {

    
    var entries : [AppRecord] = []
    
    let kCustomRowCount = 7
    
    let CellIdentifier = "LazyTableCell"
    let PlaceHolderCellIdentifier = "PlaceholderCell"
    
    private var imageDownloadsInProgress: [IndexPath: IconDownloader] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageDownloadsInProgress = [:]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let count = self.entries.count
        
        // if there's no data yet, return enough rows to fill the screen
        if count == 0 {
            return 1
        }
        return count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        
        let nodeCount = self.entries.count
        
        if nodeCount == 0 && indexPath.row == 0 {
            // add a placeholder cell while waiting on table data
            cell = tableView.dequeueReusableCell(withIdentifier: PlaceHolderCellIdentifier, for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
            
            // Leave cells empty if there's no data yet
            if nodeCount > 0 {
                // Set up the cell representing the app
                let appRecord = self.entries[indexPath.row]
                
                cell!.textLabel!.text = appRecord.appName
                cell!.detailTextLabel?.text = appRecord.artist
                
                // Only load cached images; defer new downloads until scrolling ends
                if appRecord.appIcon == nil {
                    if !self.tableView.isDragging && !self.tableView.isDecelerating {
                        self.startIconDownload(appRecord, forIndexPath: indexPath)
                    }
                    // if a download is deferred or in progress, return a placeholder image
                    cell!.imageView!.image = UIImage(named: "Placeholder.png")!
                } else {
                    cell!.imageView!.image = appRecord.appIcon
                }
            }
        }
        
        return cell!
    }
    private func startIconDownload(_ appRecord: AppRecord, forIndexPath indexPath: IndexPath) {
        var iconDownloader = self.imageDownloadsInProgress[indexPath]
        if iconDownloader == nil {
            iconDownloader = IconDownloader()
            iconDownloader!.appRecord = appRecord
            iconDownloader!.completionHandler = {
                
                let cell = self.tableView.cellForRow(at: indexPath)
                
                // Display the newly loaded image
                cell?.imageView?.image = appRecord.appIcon
                
                // Remove the IconDownloader from the in progress list.
                // This will result in it being deallocated.
                self.imageDownloadsInProgress.removeValue(forKey: indexPath)
                
            }
            self.imageDownloadsInProgress[indexPath] = iconDownloader
            iconDownloader!.startDownload()
        }
    }

    private func loadImagesForOnscreenRows() {
        if !self.entries.isEmpty {
            let visiblePaths = self.tableView.indexPathsForVisibleRows!
            for indexPath in visiblePaths {
                let appRecord = entries[indexPath.row]
                
                // Avoid the app icon download if the app already has an icon
                if appRecord.appIcon == nil {
                    self.startIconDownload(appRecord, forIndexPath: indexPath)
                }
            }
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.loadImagesForOnscreenRows()
        }
    }
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.loadImagesForOnscreenRows()
    }
    
}
