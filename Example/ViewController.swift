//
//  ViewController.swift
//  SVEVideoView
//
//  Created by Sérgio Estêvão on 05/10/2019.
//  Copyright © 2019 Sérgio Estêvão. All rights reserved.
//

import UIKit
import SVEVideoPlayerView
import SwiftUI

class ViewController: UIViewController, VideoPlayerViewDelegate {

    var videos = ["test-video"]

    func videoPlayerView(playerView: VideoPlayerView, didFailWithError error: Error) {
        print("Error: \(error)\n")
    }

    func videoPlayerViewStarted(playerView: VideoPlayerView) {
        print("Started\n")
    }

    func videoPlayerViewFinish(playerView: VideoPlayerView) {
        print("Finish\n")
    }

    lazy var videoView: VideoPlayerView = {
        let url = Bundle.main.url(forResource: videos.first, withExtension: "mp4")!
       let videoView = VideoPlayerView(videoURL: url)
       videoView.autoPlay = true       
       videoView.backgroundColor = .black
       videoView.showsPlaybackControls = true
       videoView.center = view.center
       videoView.delegate = self
       return videoView
    }()

    lazy var swiftButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SwiftUI", for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(showSwiftUI), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(videoView)
        videoView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        videoView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        videoView.translatesAutoresizingMaskIntoConstraints = false

        // Button to connect to SwiftUI
        view.addSubview(swiftButton)
        swiftButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        swiftButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        swiftButton.translatesAutoresizingMaskIntoConstraints = false
    }

    @objc func showSwiftUI() {
        let videoView = DemoVideoView()
        let controller = UIHostingController(rootView: videoView)        
        self.videoView.pause()
        present(controller, animated: true, completion: nil)
    }

}

