import Foundation
import SwiftUI

@available(iOS 13.0, *)
public struct Video: UIViewRepresentable {
    var videoURL: Binding<URL?>
    var loop: Binding<Bool>
    var showsPlaybackControls: Binding<Bool>

    public init(url: Binding<URL?>, loop: Binding<Bool> = Binding<Bool>.constant(false), showsPlaybackControls: Binding<Bool> = Binding<Bool>.constant(false)) {
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
        let newVideoURL = videoURL.wrappedValue
        if newVideoURL != uiView.videoURL {
            uiView.videoURL = newVideoURL
        }
        uiView.loop = loop.wrappedValue
        uiView.setControlToolbarHidden(hidden: !showsPlaybackControls.wrappedValue, animated: true)
    }
}
