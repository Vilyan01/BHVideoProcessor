//
//  BHVideoStitcher.swift
//  BHVideoProcessor
//
//  Created by Brian Heller on 12/21/16.
//  Copyright © 2016 Brian Heller. All rights reserved.
//

import UIKit
import AVFoundation

protocol BHVideoStitcherDelegate {
    func videoStitcher(stitcher:BHVideoStitcher, didExportVideoToUrl:URL)
    func videoStitcher(stitcher:BHVideoStitcher, didProduceError:Error)
}

class BHVideoStitcher: NSObject {
    var delegate:BHVideoStitcherDelegate?
    let dq = DispatchQueue(label: "com.reaperss.queues.export")
    
    func stitchVideos(uris:[String]) {
        dq.async {
            // build the urls from the uris
            let urls = self.buildUrls(uris: uris)
            
            // check if the urls are valid
            let validUrls = self.validateUrls(urls: urls)
            
            // create assets from URLs
            let assets = self.buildAssetsFromUrls(validUrls: validUrls)
            
            // stitch the videos
            self.stitchVideosFromAssets(assets: assets)
        }
    }

    // MARK: - Private Functions
    // Gets the path to a folder in a the documents directory that will be used to hold the videos.
    private func tempDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return paths[0].appending("/stitcher")
    }
    
    private func validateUrls(urls:[URL]) -> [URL]{
        var validUrls = [URL]()
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let validationGroup = DispatchGroup()
        for url in validUrls {
            validationGroup.enter()
            // get the head of a url to check out what it is.
            // TODO: validate content type?
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            session.dataTask(with: request, completionHandler: { (data, response, error) in
                let resp = response as! HTTPURLResponse
                if error == nil && resp.statusCode == 200 {
                    validUrls.append(url)
                }
                validationGroup.leave()
            }).resume()
        }
        validationGroup.wait()
        return validUrls
    }
    
    // simple factory function to turn strings into urls
    private func buildUrls(uris:[String]) -> [URL] {
        var urls = [URL]()
        for uri in uris {
            if let url = URL(string: uri) {
                urls.append(url)
            }
        }
        return urls
    }
    
    // factory function to build assets from valid URLs
    private func buildAssetsFromUrls(validUrls:[URL]) -> [AVURLAsset] {
        var assets = [AVURLAsset]()
        for url in validUrls {
            let asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey:true])
            assets.append(asset)
        }
        return assets
    }
    
    // perform the stitching operation
    private func stitchVideosFromAssets(assets:[AVURLAsset]) {
        var insertTime = kCMTimeZero
        let composition = AVMutableComposition()
        
        var outputUrl:URL
        
        // add assets to composition
        for asset in assets {
            let assetTimeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
            do {
                try composition.insertTimeRange(assetTimeRange, of: asset, at: insertTime)
                insertTime = CMTimeAdd(insertTime, asset.duration)
            }
            catch let error {
                if (self.delegate != nil) {
                    self.delegate!.videoStitcher(stitcher: self, didProduceError: error)
                }
            }
        }
        
        // create export session
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough)
        
        // set output file and filetype
        outputUrl = URL(fileURLWithPath: self.tempDirectory().appending("/\(UUID().uuidString).MOV"))
        exportSession?.outputURL = outputUrl
        exportSession?.outputFileType = AVFileTypeQuickTimeMovie
        
        // export the video
        exportSession?.exportAsynchronously(completionHandler: { 
            switch exportSession!.status {
            case .cancelled: break
            case .completed:
                DispatchQueue.main.async {
                    if(self.delegate != nil) {
                        self.delegate!.videoStitcher(stitcher: self, didExportVideoToUrl: outputUrl)
                    }
                }
                break
            case .exporting: break
            case .failed:
                DispatchQueue.main.async {
                    if(self.delegate != nil) {
                        self.delegate?.videoStitcher(stitcher: self, didProduceError: (exportSession?.error)!)
                    }
                }
                break
            case .unknown: break
            case .waiting: break
            }
        })
    }
}
