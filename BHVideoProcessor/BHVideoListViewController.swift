//
//  BHVideoListViewController.swift
//  BHVideoProcessor
//
//  Created by Brian Heller on 12/21/16.
//  Copyright © 2016 Brian Heller. All rights reserved.
//

import UIKit
import Photos
import SVProgressHUD

class BHVideoListViewController: UITableViewController {
    
    var assetUrls:[String]!
    
    var stitcher:BHVideoStitcher!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the array of strings
        if(assetUrls == nil) {
            assetUrls = [String]()
        }
        
        if(stitcher == nil) {
            stitcher = BHVideoStitcher()
            stitcher.delegate = self
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assetUrls.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = assetUrls[indexPath.row]
        return cell
    }
    @IBAction func addItem(_ sender: Any) {
        var tf:UITextField?
        // display alert with text box to add to list
        let controller = UIAlertController(title: "Add URL", message: "Type a URL to a video to add to the list.", preferredStyle: .alert)
        controller.addTextField { (textField) in
            tf = textField
        }
        
        controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            if tf != nil {
                self.assetUrls.append(tf!.text!)
                self.tableView.reloadData()
            }
        }))
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func exportVideos(_ sender: Any) {
        SVProgressHUD.show()
        stitcher.stitchVideos(uris: self.assetUrls)
    }
}

extension BHVideoListViewController : BHVideoStitcherDelegate {
    func videoStitcher(stitcher: BHVideoStitcher, didProduceError error: Error) {
        SVProgressHUD.dismiss()
        print("Got error: \(error.localizedDescription)")
    }
    
    func videoStitcher(stitcher: BHVideoStitcher, didExportVideoToUrl url:URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { (success, error) in
            SVProgressHUD.dismiss()
            if error == nil && success {
                print("Exported video to photo library.")
            }
            else {
                print("Error saving video to library: \(error?.localizedDescription)")
            }
        }
    }
}
