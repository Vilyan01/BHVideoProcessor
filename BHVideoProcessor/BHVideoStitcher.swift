//
//  BHVideoStitcher.swift
//  BHVideoProcessor
//
//  Created by Brian Heller on 12/21/16.
//  Copyright © 2016 Brian Heller. All rights reserved.
//

import UIKit

protocol BHVideoStitcherDelegate {
    func videoStitcher(stitcher:BHVideoStitcher, didExportVideoToUrl:NSURL)
    func videoStitcher(stitcher:BHVideoStitcher, didProduceError:Error)
}

class BHVideoStitcher: NSObject {
    var delegate:BHVideoStitcherDelegate?
}

// MARK: - Private Functions
extension BHVideoStitcher {
    // Gets the path to a folder in a the documents directory that will be used to hold the videos.
    private func tempDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0].appending("/stitcher")
    }
    
    private func validateUrls(urls:[NSURL]) -> [NSURL]{
        var validUrls = [NSURL]()
        
        return validUrls
    }
}
