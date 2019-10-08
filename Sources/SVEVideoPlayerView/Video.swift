import Foundation
import SwiftUI

@available(iOS 13.0, *)
public struct Video: UIViewRepresentable {
    var videoURL: URL?
    var loop: Bool
    var showsPlaybackControls: Bool

    public init(url: URL?, loop: Bool = false, showsPlaybackControls: Bool = false) {
        videoURL = url
        self.loop = loop
        self.showsPlaybackControls = showsPlaybackControls
    }

    public func makeUIView(context: Context) -> VideoPlayerView {
        let videoView = VideoPlayerView()
        videoView.play()
        return videoView
    }

    public func updateUIView(_ uiView: VideoPlayerView, context: Context) {
        let newVideoURL = videoURL
        if newVideoURL != uiView.videoURL {
            uiView.videoURL = newVideoURL
        }
        uiView.loop = loop
        uiView.setControlToolbarHidden(hidden: !showsPlaybackControls, animated: true)
    }
}
