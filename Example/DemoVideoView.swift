import SwiftUI
import SVEVideoPlayerView

struct DemoVideoView: View {
    @State var videoURL: URL? = Bundle.main.url(forResource: "test-video", withExtension: "mp4")!
    @State var loop: Bool = true
    @State var showsPlaybackControls: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Video(url: $videoURL, loop: $loop, showsPlaybackControls: $showsPlaybackControls)
            Divider()
            Button(action: { () in self.showsPlaybackControls.toggle() }) {
                Text("Toggle Controls")
            }
        }
    }
}

struct DemoVideoView_Previews: PreviewProvider {
    static var previews: some View {
        DemoVideoView()
    }
}

