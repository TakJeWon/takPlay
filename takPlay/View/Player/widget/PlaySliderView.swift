//
//  playSliderView.swift
//  takPlay
//
//  Created by 탁제원 on 4/25/24.
//

import Foundation
import UIKit
import AVKit

protocol playerSliderDeletegate {
    func changePlayerValue(value: Double)
    func changePlayerStatus(by isPlaying: Bool)
}

class PlaySliderView: UIView, playerDeletegate {
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var playSlider: UISlider!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    var delegate: playerSliderDeletegate?
    var playerItem: AVPlayerItem!
    
    var isPlaying: Bool = false {
        didSet {
            let imageName = isPlaying ? "pause.fill" : "play.fill"
            let image = UIImage(systemName: imageName)?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
            self.playPauseButton.setImage(image, for: .normal)
        }
    }
    
    // MARK: - override
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initWithURL(playUrl: URL, with player: AVPlayer) {
        
        isPlaying = false
        
        // 원하는 이미지 크기와 색상으로 이미지 생성
        let originalImage = UIImage(systemName: "rectangle.portrait.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)

        // 원하는 크기로 이미지 리사이징
        let newSize = CGSize(width: 10, height: 50)
        let resizedImage = UIGraphicsImageRenderer(size: newSize).image { _ in
            originalImage?.draw(in: CGRect(origin: .zero, size: newSize))
        }
        self.playSlider.setThumbImage(resizedImage, for: .normal)
        
        self.playSlider.minimumTrackTintColor = .white
        self.playSlider.setValue(0, animated: false)
        self.playSlider.minimumValue = 0
        
        //썸네일 생성
        let asset = AVAsset(url: playUrl)
        playerItem = AVPlayerItem(asset: asset)
        
        let thumbnailTime = CMTime(seconds: 1, preferredTimescale: 1)
        generateThumbnail(for: playerItem, at: thumbnailTime, completion: { image in
            let newSize = CGSize(width: 100, height: 50)
            if let thumbnailImage = image?.resized(forHeight: 50)?.resizableImage(withCapInsets: .zero, resizingMode: .tile) {
                DispatchQueue.main.async {
                    self.playSlider.setMaximumTrackImage(thumbnailImage, for: .normal)
                    self.playSlider.setMinimumTrackImage(thumbnailImage, for: .normal)
                }
            }
        })
        
        self.playSlider.addTarget(self, action: #selector(changeValue), for: .valueChanged)
        
        let interval = CMTimeMakeWithSeconds(1, preferredTimescale: Int32(NSEC_PER_SEC))
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] elapsedSeconds in
            let elapsedTimeSecondsFloat = CMTimeGetSeconds(elapsedSeconds)
            let totalTimeSecondsFloat = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime(value: 1, timescale: 1))
            print(elapsedTimeSecondsFloat, totalTimeSecondsFloat)
            
            // 현재 시간을 표시합니다.
            let elapsedTime = CMTimeGetSeconds(player.currentTime() ?? CMTime(value: 0, timescale: 1))
            self?.currentTimeLabel.text = self?.formatTime(seconds: elapsedTime)
            
            // 슬라이더 위치를 조정합니다.
            self?.playSlider.value = Float(elapsedTime)
        })
        
    }
    
    func generateThumbnail(for playerItem: AVPlayerItem, at time: CMTime, completion: @escaping (UIImage?) -> Void) {
        let imageGenerator = AVAssetImageGenerator(asset: playerItem.asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)], completionHandler: { requestedTime, cgImage, actualTime, result, error in
            if let cgImage = cgImage {
                let thumbnailImage = UIImage(cgImage: cgImage)
                completion(thumbnailImage)
            } else {
                completion(nil)
            }
        })
    }
    
    
    // 시간을 포맷하는 메서드
    func formatTime(seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        if let formattedString = formatter.string(from: seconds) {
            // 시간이 0으로 표시되는 경우에는 시간 부분을 없애고 반환합니다.
            if formattedString.starts(with: "00:") {
                let index = formattedString.index(formattedString.startIndex, offsetBy: 3)
                return String(formattedString[index...])
            } else {
                return formattedString
            }
        } else {
            return "00:00"
        }
    }
    
    @objc private func changeValue(){
        self.delegate?.changePlayerValue(value: Double(self.playSlider.value))
    }
    

    @IBAction func onTouchedPlayButton(_ sender: Any) {
        self.delegate?.changePlayerStatus(by: isPlaying)
        isPlaying = !isPlaying
    }
    
    //MARK: playerDeletegate
    func settingSliderValue(min: Float, max: Float) {
        self.playSlider.minimumValue = min
        self.playSlider.maximumValue = max
        self.totalTimeLabel.text = formatTime(seconds: Double(max))
        
    }
}
