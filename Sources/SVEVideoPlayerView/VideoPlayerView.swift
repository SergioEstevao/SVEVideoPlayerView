//
//  VideoPlayerView.swift
//  SVEVideoView
//
//  Created by Sérgio Estêvão on 05/10/2019.
//  Copyright © 2019 Sérgio Estêvão. All rights reserved.
//

import Foundation
#if !os(macOS)
import UIKit
#endif
import AVFoundation;

public protocol VideoPlayerViewDelegate {
    func videoPlayerView(playerView: VideoPlayerView,  didFailWithError error: Error)
    func videoPlayerViewStarted(playerView: VideoPlayerView)
    func videoPlayerViewFinish(playerView: VideoPlayerView)
}

open class VideoPlayerView: UIView {

    /// If true video loops when it gets to the end. Default value is false
    public var loop = false

    public var delegate: VideoPlayerViewDelegate?

    /// If true video starts to play automattically when set, by default value is false.
    public var autoPlay = false

    let player: AVPlayer = AVPlayer()
    private lazy var playerLayer: AVPlayerLayer = {
        return AVPlayerLayer(player: player)
    }()
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?

    static let tracksKey = "tracks"
    static let timeFormatString = "%@ / %@"
    static let toolbarHeight: CGFloat = 44
    var playerItemContext = "ItemStatusContext"

    convenience public init(videoURL: URL) {
        self.init(frame: .zero)
        commonInit()
        self.videoURL = videoURL
        self.asset = AVURLAsset(url: videoURL)
        setupPlayerItem()
        if let track = asset?.tracks(withMediaType: .video).first {
            let size = track.naturalSize.applying(track.preferredTransform)
            frame = CGRect(origin: .zero, size: size)
        }
    }

    open override var intrinsicContentSize: CGSize {
        if let track = asset?.tracks(withMediaType: .video).first {
            let size = track.naturalSize.applying(track.preferredTransform)
            return size
        } else {
            return .zero
        }
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        layer.addSublayer(playerLayer)
        addSubview(controlToolbar)
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 4), queue: nil, using: { [weak self](time) in
            self?.updateVideoDuration()
        })

        accessibilityIgnoresInvertColors = true
        clipsToBounds = true
        self.updateControlToolbar()
    }

    deinit {
        removeObservers()
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
        }
        player.pause()
    }

    private func removeObservers() {
        playerItem?.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self)
    }

    private func addObservers() {
        playerItem?.addObserver(self, forKeyPath: "status",
                               options: [.new, .old],
                               context:&playerItemContext)
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(playerItemDidReachEnd),
                                               name:.AVPlayerItemDidPlayToEndTime,
                                           object:self.playerItem)
    }

    override public func layoutSubviews() {
        playerLayer.frame = bounds
        updateControlToolbarPosition(hidden: !showsPlaybackControls)
    }

    private lazy var controlToolbar: UIToolbar = {
        let controlToolbar = UIToolbar()
        controlToolbar.isHidden = true
        controlToolbar.tintColor = .white
        controlToolbar.barStyle = .black;
        controlToolbar.isTranslucent = true
        return controlToolbar
    }()

    private lazy var videoDurationButton: UIBarButtonItem = {
        let videoDurationButton = UIBarButtonItem(customView: self.videoDurationLabel)
        videoDurationButton.isEnabled = false
        return videoDurationButton;
    }()

    private lazy var videoDurationLabel: UILabel = {
        let videoDurationLabel = UILabel()
        videoDurationLabel.textColor = .white;
        videoDurationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14.0, weight: .bold)
        videoDurationLabel.adjustsFontSizeToFitWidth = false
        videoDurationLabel.textAlignment = .right;
        videoDurationLabel.lineBreakMode = .byTruncatingTail;

        // Fix the label to the widest size we want to show, so it doesn't
        // resize itself and move around as we update the content
        videoDurationLabel.text = "0:00:00 / 0:00:00"
        videoDurationLabel.sizeToFit()

        return videoDurationLabel
    }()

    public var videoURL: URL? {
        didSet {
            guard let url = videoURL else {
                asset = nil
                return
            }
            asset = AVURLAsset(url: url)
        }
    }

    public var asset: AVAsset? {
        didSet {
            removeObservers()
            setupPlayerItem()
        }
    }

    private func setupPlayerItem() {
        guard let asset = asset else {
            playerLayer.isHidden = true
            player.replaceCurrentItem(with: nil)
            return
        }
        playerItem = AVPlayerItem(asset: asset)
        addObservers()
        player.replaceCurrentItem(with: self.playerItem)
        playerLayer.isHidden = false
        if autoPlay {
            play()
        }
    }

    @objc
    func playerItemDidReachEnd(playerItem: AVPlayerItem) {
        if self.loop {
            player.seek(to: .zero)
            player.play()
        }
        delegate?.videoPlayerViewFinish(playerView: self)
        updateControlToolbar(videoEnded: !loop)
    }

    /// Start the play of the video.
    public func play() {
        player.play()
        updateControlToolbar()
        updateVideoDuration()
    }

    /// Pause the video.
    public func pause() {
        player.pause()
        updateControlToolbar()
    }

    /// Toggles between the play and pause state of the video
    @objc
    public func togglePlayPause() {
        if player.timeControlStatus == .paused {
            if let currentTime = player.currentItem?.currentTime(),
                let duration = player.currentItem?.duration,
                CMTimeCompare(currentTime,duration) == 0 {
                player.seek(to: .zero)
            }
            play()
        } else {
            pause()
        }
    }

    public var showsPlaybackControls: Bool {
        get {
            return !self.controlToolbar.isHidden;
        }

        set {
            self.setControlToolbarHidden(hidden: !newValue, animated: false)
        }
    }

    public func setControlToolbarHidden(hidden: Bool, animated:Bool) {
        setControlToolbarHidden(hidden: hidden, animated:animated, completion: nil)
    }

    public func setControlToolbarHidden(hidden: Bool, animated:Bool, completion: (() -> ())?) {

        let updateBlock = { [weak self]() -> Void in
            self?.updateControlToolbarPosition(hidden: hidden)
        }


        let completionBlock = { [weak self]() in
            self?.controlToolbar.isHidden = hidden
            completion?()
        };

        if !animated {
            updateBlock();
            completionBlock();
            return
        }

        if !hidden {
            // Unhide before animating appearance
            controlToolbar.isHidden = hidden
        }

        let animationDuration: CGFloat = animated ? UINavigationController.hideShowBarDuration : 0
        UIView.animate(withDuration: TimeInterval(animationDuration), animations: updateBlock) { (finished) in
            completionBlock()
        }
    }

    private func updateControlToolbarPosition(hidden: Bool) {
        var height: CGFloat = Self.toolbarHeight
        height += safeAreaInsets.bottom

        let position: CGFloat = hidden ? 0 : height
        controlToolbar.frame = CGRect(x: 0, y: self.frame.size.height - position, width: self.frame.size.width, height: Self.toolbarHeight);
    }

    private func updateControlToolbar() {
        updateControlToolbar(videoEnded: false)
    }

    private func updateControlToolbar(videoEnded: Bool) {
        let playPauseButton: UIBarButtonItem.SystemItem = player.timeControlStatus == .paused || videoEnded ? .play : .pause;

        controlToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem:playPauseButton, target:self, action:#selector(togglePlayPause)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            videoDurationButton,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        ]
    }

    private func updateVideoDuration() {
        guard let playerItem = player.currentItem, playerItem.status == .readyToPlay else {
            return;
        }
        let totalSeconds = CMTimeGetSeconds(playerItem.duration);
        let currentSeconds = CMTimeGetSeconds(playerItem.currentTime());
        videoDurationLabel.text = "\(Self.sharedDateComponentsFormatter.string(from: currentSeconds)!) / \(Self.sharedDateComponentsFormatter.string(from: totalSeconds)!)"
    }

    private static var sharedDateComponentsFormatter: DateComponentsFormatter = {
        let sharedDateComponentsFormatter = DateComponentsFormatter()
        sharedDateComponentsFormatter.zeroFormattingBehavior = .pad;
        sharedDateComponentsFormatter.allowedUnits = [.minute, .second];
        return sharedDateComponentsFormatter
    }()

    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        // Only handle observations for the playerItemContext
        guard context == &(playerItemContext), keyPath == "status" else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return;
        }

        // Get the status change from the change dictionary
        let status: AVPlayerItem.Status
        if let statusNumber = change?[.newKey] as? NSNumber, let statusValue = AVPlayerItem.Status(rawValue: statusNumber.intValue) {
            status = statusValue
        } else {
            status = .unknown;
        }

        // Switch over the status
        switch status {
        case .readyToPlay:
            // Player item is ready to play.
            delegate?.videoPlayerViewStarted(playerView: self)
            DispatchQueue.main.async { [weak self] () in
                self?.updateVideoDuration()
            }
        case .failed:
                // Player item failed. See error.
            if let error = self.playerItem?.error {
                delegate?.videoPlayerView(playerView: self, didFailWithError: error)
            }
        default:
            // Player item is not yet ready.
            return;
        }
    }

}

