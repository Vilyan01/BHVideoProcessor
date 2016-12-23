# BHVideoProcessor

## Description

This is just a simple demonstration of how you would use AVFoundation to stitch multiple videos together. In the example, add videos to the list and tap export. The stitcher will then validate that the videos exist and export the videos to a file in a temporary directory on the device. The stitched video is then saved to the photo library.

## Running

Ensure CocoaPods is installed on your system and use the following steps to run the application:

1. Clone the repo to your machine.
2. Navigate to the repo in your *Terminal* application.
3. Type `pod install` to install any dependencies.
4. Type `open BHVideoProcessor.xcworkspace` to open the project in XCode.
5. Select your device or a simulator in XCode and press run.

## Usage

To use this application, follow these steps:

1. When presented with the table view controller, press the add button in the top right.
2. Enter a URL to a video.
3. Repeat until all videos are added to the list.
4. Press export to begin the process.

*Note:* This process may take some time, depending on your connection.
