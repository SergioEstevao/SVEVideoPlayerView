//
//  ViewController.swift
//  SVEVideoView
//
//  Created by Sérgio Estêvão on 05/10/2019.
//  Copyright © 2019 Sérgio Estêvão. All rights reserved.
//

import UIKit
import SVEVideoPlayerView

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


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let url = Bundle.main.url(forResource: videos.first, withExtension: "mp4")!
        let videoView = VideoPlayerView(videoURL: url)
        videoView.autoPlay = true
        view.addSubview(videoView)
        videoView.play()
        videoView.backgroundColor = .black
        videoView.showsPlaybackControls = true
        videoView.center = view.center
        videoView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        videoView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.delegate = self
    }


}

