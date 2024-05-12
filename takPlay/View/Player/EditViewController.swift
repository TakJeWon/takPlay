//
//  player.swift
//  takPlay
//
//  Created by 탁제원 on 4/15/24.
//

import UIKit
import AVKit
import AVFoundation
import Photos

enum EditType {
    case image
    case video
}

protocol EditViewControllerDeletegate {
    func settingSliderValue(min: Float, max: Float)
}

class EditViewController: UIViewController, PlayerSliderDeletegate, FilterSelectDelegate, AVPlayerItemOutputPullDelegate  {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var videoToolButton: UIButton!
    @IBOutlet weak var adjustToolButton: UIButton!
    @IBOutlet weak var filtersToolButton: UIButton!
    @IBOutlet weak var cropToolButton: UIButton!
    
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var filterView: UIView!
    
    var player = AVPlayer()
    var videoUrl: URL?
    var playerItem: AVPlayerItem?
    
    var editType: EditType?
    
    var image: UIImage?
    var imageView = UIImageView()
    
    var delegate: EditViewControllerDeletegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingView()
        
        if (self.editType == EditType.video){
            setVideoEditView()
        } else if (self.editType == EditType.image){
            setImageEditView()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.player.pause()
    }
    
    func settingView(){
        
        if (self.editType == EditType.video){
            
            //재생 컨트롤 view 추가
            guard let loadedNib = Bundle.main.loadNibNamed("PlaySliderView", owner: self, options: nil),
                  let playSliderView = loadedNib.first as? PlaySliderView else {
                return
            }
            
            playSliderView.initWithURL(playUrl: self.videoUrl!, with: self.player)
            playSliderView.delegate = self
            self.delegate = playSliderView.self
            self.toolView.addSubview(playSliderView)
        }
        
        //필터 선택 view 추가
        guard let loadedNib = Bundle.main.loadNibNamed("FilterSelectView", owner: self, options: nil),
              let filterSelectView = loadedNib.first as? FilterSelectView else {
            return
        }
        
        filterSelectView.delegate = self
        self.filterView.addSubview(filterSelectView)
        
        
        if (self.editType == EditType.video){

            let videoSelectedImage = UIImage(systemName: "video.fill")?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
            let videoUnSelectedImage = UIImage(systemName: "video.fill")?
                .withTintColor(.darkGray, renderingMode: .alwaysOriginal)
            self.videoToolButton.setImage(videoSelectedImage, for: .selected)
            self.videoToolButton.setImage(videoUnSelectedImage, for: .normal)
            self.videoToolButton.isSelected = true
            
            self.toolView.isHidden = false
            
        } else if (self.editType == EditType.image){
            
            self.videoToolButton.isHidden = true
            self.adjustToolButton.isSelected = true
            
            self.toolView.isHidden = true
        }
        
        self.filterView.isHidden = true
        
        let adjustSelectedImage = UIImage(systemName: "slider.horizontal.3")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        let adjustUnSelectedImage = UIImage(systemName: "slider.horizontal.3")?
            .withTintColor(.darkGray, renderingMode: .alwaysOriginal)
        self.adjustToolButton.setImage(adjustSelectedImage, for: .selected)
        self.adjustToolButton.setImage(adjustUnSelectedImage, for: .normal)
        
        let filterSelectedImage = UIImage(systemName: "camera.filters")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        let filterUnSelectedImage = UIImage(systemName: "camera.filters")?
            .withTintColor(.darkGray, renderingMode: .alwaysOriginal)
        self.filtersToolButton.setImage(filterSelectedImage, for: .selected)
        self.filtersToolButton.setImage(filterUnSelectedImage, for: .normal)
        
        let cropSelectedImage = UIImage(systemName: "crop.rotate")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        let cropUnSelectedImage = UIImage(systemName: "crop.rotate")?
            .withTintColor(.darkGray, renderingMode: .alwaysOriginal)
        self.cropToolButton.setImage(cropSelectedImage, for: .selected)
        self.cropToolButton.setImage(cropUnSelectedImage, for: .normal)
    }
    
    func setVideoEditView(){
        let defaultUrl = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        
        playerItem = AVPlayerItem(url: videoUrl ?? defaultUrl!)
        self.player.replaceCurrentItem(with: playerItem)
        
        let playerLayer = AVPlayerLayer(player: self.player)
        playerLayer.frame = self.editView.bounds
        playerLayer.videoGravity = .resizeAspect
        self.editView.layer.addSublayer(playerLayer)
    
        // 재생 상태를 확인하고, 재생 가능한 상태가 되면 재생 시간을 설정합니다.
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new], context: nil)
    }
    
    func setImageEditView(){
        imageView = UIImageView(image: self.image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: self.editView.frame.width, height: self.editView.frame.height)
        
        self.editView.addSubview(imageView)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status) {
            if let statusNumber = change?[.newKey] as? Int {
                let status = AVPlayerItem.Status(rawValue: statusNumber)
                if status == .readyToPlay {
                    if let item = self.player.currentItem {
                        self.delegate?.settingSliderValue(min: 0, max: Float(CMTimeGetSeconds(item.duration)))
                    }
                }
            }
        }
    }
    
    //MARK: PlayerSliderDeletegate
    
    func changePlayerValue(value: Double) {
        self.player.seek(to: CMTime(seconds: value, preferredTimescale: Int32(NSEC_PER_SEC)), completionHandler: { _ in
            
        })
    }
    
    func changePlayerStatus(by isPlaying: Bool) {
        print("isPlaying ? \(isPlaying)")
        if (isPlaying){
            self.player.pause()
        } else {
            self.player.play()
        }
    }
    
    
    //MARK: FilterSelectDelegate
    
    func didSelectFilter(by type: FilterType) {
        switch type {
        case FilterType.standard:
            if (self.editType == EditType.video){
                
                print("filter standard clicked!")
                let filter = CIFilter(name: "CIGaussianBlur")!
                playerItem?.videoComposition = AVVideoComposition(asset: playerItem?.asset ?? AVAsset(), applyingCIFiltersWithHandler: { request in

                  // Clamp to avoid blurring transparent pixels at the image edges
                  let source = request.sourceImage.clampedToExtent()
                  filter.setValue(source, forKey: kCIInputImageKey)

                  // Vary filter parameters based on video timing
                  let seconds = CMTimeGetSeconds(request.compositionTime)
                  filter.setValue(seconds * 10.0, forKey: kCIInputRadiusKey)

                  // Crop the blurred output to the bounds of the original image
                  let output = filter.outputImage!.cropped(to: request.sourceImage.extent)

                  // Provide the filter output to the composition
                  request.finish(with: output, context: nil)
                })
            } else if (self.editType == EditType.image) {
                let originalImage = CIImage(image: image!) ?? CIImage()
                let sepiaCIImage = sepiaFilter(originalImage, intensity:0.2)
                self.imageView.image = UIImage(ciImage: sepiaCIImage!)
            }
        case FilterType.filter1: 
            if (self.editType == EditType.image) {
                let originalImage = CIImage(image: image!) ?? CIImage()
                let sepiaCIImage = luminanceFilter(originalImage, sharpness:4.0)
                self.imageView.image = UIImage(ciImage: sepiaCIImage!)
            }
        case FilterType.filter2:
            if (self.editType == EditType.image) {
                let originalImage = CIImage(image: image!) ?? CIImage()
                let noirCIImage = noirFilter(originalImage)
                self.imageView.image = UIImage(ciImage: noirCIImage!)
            }
            
        default: break
        }
    }
    
    func sepiaFilter(_ input: CIImage, intensity: Double) -> CIImage?
    {
        let sepiaFilter = CIFilter(name:"CISepiaTone")
        sepiaFilter?.setValue(input, forKey: kCIInputImageKey)
        sepiaFilter?.setValue(intensity, forKey: kCIInputIntensityKey)
        guard let outputImage = sepiaFilter?.outputImage else {
            return nil
        }

        // Adjust the orientation of the output image to match the input image's orientation
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return CIImage(cgImage: cgImage, options: [CIImageOption.applyOrientationProperty: true])
        } else {
            return nil
        }
    }
    
    
    func luminanceFilter(_ input: CIImage, sharpness: Double) -> CIImage?
    {
        let luminanceFilter = CIFilter(name:"CISharpenLuminance")
        luminanceFilter?.setValue(input, forKey: kCIInputImageKey)
        luminanceFilter?.setValue(sharpness, forKey: kCIInputSharpnessKey)
        guard let outputImage = luminanceFilter?.outputImage else {
            return nil
        }

        // Adjust the orientation of the output image to match the input image's orientation
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return CIImage(cgImage: cgImage, options: [CIImageOption.applyOrientationProperty: true])
        } else {
            return nil
        }
    }
    
    func noirFilter(_ input: CIImage) -> CIImage?
    {
        let noirFilter = CIFilter(name:"CIPhotoEffectNoir")
        noirFilter?.setValue(input, forKey: kCIInputImageKey)
        guard let outputImage = noirFilter?.outputImage else {
            return nil
        }

        // Adjust the orientation of the output image to match the input image's orientation
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return CIImage(cgImage: cgImage, options: [CIImageOption.applyOrientationProperty: true])
        } else {
            return nil
        }
    }
    
    //MARK: IBAction
    
    @IBAction func onTapBackButton(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
    @IBAction func onTapVideoButton(_ sender: Any) {
        self.videoToolButton.isSelected = true
        self.adjustToolButton.isSelected = false
        self.filtersToolButton.isSelected = false
        self.cropToolButton.isSelected = false
        
        self.toolView.isHidden = false
        self.filterView.isHidden = true
    }
    
    
    @IBAction func onTapAdjustButton(_ sender: Any) {
        self.videoToolButton.isSelected = false
        self.adjustToolButton.isSelected = true
        self.filtersToolButton.isSelected = false
        self.cropToolButton.isSelected = false
        
        self.toolView.isHidden = true
        self.filterView.isHidden = true
    }
    
    
    @IBAction func onTapFilterButton(_ sender: Any) {
        self.videoToolButton.isSelected = false
        self.adjustToolButton.isSelected = false
        self.filtersToolButton.isSelected = true
        self.cropToolButton.isSelected = false
        
        self.toolView.isHidden = true
        self.filterView.isHidden = false
    }
    
    
    @IBAction func onTapCropButton(_ sender: Any) {
        self.videoToolButton.isSelected = false
        self.adjustToolButton.isSelected = false
        self.filtersToolButton.isSelected = false
        self.cropToolButton.isSelected = true
        
        self.toolView.isHidden = true
        self.filterView.isHidden = true
    }
    
    @IBAction func onTapSaveButton(_ sender: Any) {
        
        self.saveButton.isEnabled = false

        if (self.editType == EditType.video) {
            guard let urlAsset = player.currentItem?.asset as? AVURLAsset else { return }
            
            let videoURL = urlAsset.url
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            }) { (success, error) in
                
                DispatchQueue.main.async {

                    self.saveButton.isEnabled = true
                    if success {
                        self.showPopup(title: "성공", message: "영상 저장에 성공하였습니다.")
                        print("Video saved to photo library.")
                    } else {
                        print("Error saving video: \(error?.localizedDescription ?? "")")
                    }
                }
            }
        } else if (self.editType == EditType.image){

            if let pickedImage = imageView.image {
                UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        self.saveButton.isEnabled = true
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
            self.showPopup(title: "오류", message: "이미지를 저장하는 동안 오류가 발생했습니다.")
        } else {
            print("Image saved successfully.")
            self.showPopup(title: "성공", message: "이미지가 사진 앨범에 저장되었습니다.")
        }
    }
    
    //MARK: functions
    
    func captureCurrentFrame(){
        
        // Capture current frame
        guard let currentItem = player.currentItem else {
            return
        }
        
        let imageGenerator = AVAssetImageGenerator(asset: currentItem.asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        // Get current time of the video
        let currentTime = CMTimeGetSeconds(player.currentTime())
        
        // Capture frame at the current time
        do {
            let imageRef = try imageGenerator.copyCGImage(at: CMTime(seconds: currentTime, preferredTimescale: 1), actualTime: nil)
            let image = UIImage(cgImage: imageRef)
            
            // Save image to photo library
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { (success, error) in
                
                if success {
                    print("Image saved to photo library.")
                } else {
                    print("Error saving image: \(error?.localizedDescription ?? "")")
                }
            }
        } catch {
            print("Error capturing frame: \(error.localizedDescription)")
        }
    }
    
    func showPopup(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // 액션 추가 (확인 버튼)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // 팝업 표시
        present(alertController, animated: true, completion: nil)
    }
    
}
