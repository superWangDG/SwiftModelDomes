//
//  VisionMainVC.swift
//  SwiftDemos
//  图片识别
//  Created by 开十二 on 2020/12/24.
//

import UIKit
import Vision
import AVKit

class VisionMainVC: UIViewController {
    
    var pathLayer: CALayer?
    var imageWidth: CGFloat = 0
    var imageHeight: CGFloat = 0
    private var imageView:UIImageView = {
        let image = UIImageView()
        image.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    var  requests  =  [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        // 添加点击事件
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickAction)))
    }
    
    @objc func clickAction() {
        promptPhoto()
    }
    
    @objc func promptPhoto() {
        
        let prompt = UIAlertController(title: "选择一个图片",
                                       message: nil,
                                       preferredStyle: .actionSheet)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        func presentCamera(_ _: UIAlertAction) {
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true)
        }
        let cameraAction = UIAlertAction(title: "相机",
                                         style: .default,
                                         handler: presentCamera)
        func presentLibrary(_ _: UIAlertAction) {
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true)
        }
        let libraryAction = UIAlertAction(title: "图片库",
                                          style: .default,
                                          handler: presentLibrary)
        
        func presentAlbums(_ _: UIAlertAction) {
            imagePicker.sourceType = .savedPhotosAlbum
            self.present(imagePicker, animated: true)
        }
        let albumsAction = UIAlertAction(title: "保存当前图片",
                                         style: .default,
                                         handler: presentAlbums)
        
        let cancelAction = UIAlertAction(title: "取消",
                                         style: .cancel,
                                         handler: nil)
        
        //        prompt.addAction(cameraAction)
        prompt.addAction(libraryAction)
        //        prompt.addAction(albumsAction)
        prompt.addAction(cancelAction)
        
        self.present(prompt, animated: true, completion: nil)
    }
}

extension VisionMainVC : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss picker, returning to original root viewController.
        dismiss(animated: true, completion: nil)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController,
                                        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Extract chosen image.
        let originalImage: UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        // 图片缩放比例
        show(originalImage)
        
        if imageView.image != nil {
            imageRecognition(image: imageView.image!)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func show(_ image: UIImage) {
        // Remove previous paths & image
        pathLayer?.removeFromSuperlayer()
        pathLayer = nil
        imageView.image = nil
        
        // Account for image orientation by transforming view.
        let correctedImage = scaleAndOrient(image: image)
        
        // Place photo inside imageView.
        imageView.image = correctedImage
        
        // Transform image to fit screen.
        guard let cgImage = correctedImage.cgImage else {
            print("Trying to show an image not backed by CGImage!")
            return
        }
        
        let fullImageWidth = CGFloat(cgImage.width)
        let fullImageHeight = CGFloat(cgImage.height)
        
        let imageFrame = imageView.frame
        let widthRatio = fullImageWidth / imageFrame.width
        let heightRatio = fullImageHeight / imageFrame.height
        
        // ScaleAspectFit: The image will be scaled down according to the stricter dimension.
        let scaleDownRatio = max(widthRatio, heightRatio)
        
        // Cache image dimensions to reference when drawing CALayer paths.
        imageWidth = fullImageWidth / scaleDownRatio
        imageHeight = fullImageHeight / scaleDownRatio
        
        // Prepare pathLayer to hold Vision results.
        let xLayer = (imageFrame.width - imageWidth) / 2
        let yLayer = imageView.frame.minY + (imageFrame.height - imageHeight) / 2
        let drawingLayer = CALayer()
        drawingLayer.bounds = CGRect(x: xLayer, y: yLayer, width: imageWidth, height: imageHeight)
        drawingLayer.anchorPoint = CGPoint.zero
        drawingLayer.position = CGPoint(x: xLayer, y: yLayer)
        drawingLayer.opacity = 0.5
        pathLayer = drawingLayer
        self.view.layer.addSublayer(pathLayer!)
    }
    
    // MARK: - Helper Methods
    
    /// - Tag: PreprocessImage
    func scaleAndOrient(image: UIImage) -> UIImage {
        
        // Set a default value for limiting image size.
        let maxResolution: CGFloat = UIScreen.main.bounds.width
        
        guard let cgImage = image.cgImage else {
            print("UIImage has no CGImage backing it!")
            return image
        }
        
        // Compute parameters for transform.
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        var transform = CGAffineTransform.identity
        
        var bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        if width > maxResolution ||
            height > maxResolution {
            let ratio = width / height
            if width > height {
                bounds.size.width = maxResolution
                bounds.size.height = round(maxResolution / ratio)
            } else {
                bounds.size.width = round(maxResolution * ratio)
                bounds.size.height = maxResolution
            }
        }
        
        let scaleRatio = bounds.size.width / width
        let orientation = image.imageOrientation
        switch orientation {
        case .up:
            transform = .identity
        case .down:
            transform = CGAffineTransform(translationX: width, y: height).rotated(by: .pi)
        case .left:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(translationX: 0, y: width).rotated(by: 3.0 * .pi / 2.0)
        case .right:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(translationX: height, y: 0).rotated(by: .pi / 2.0)
        case .upMirrored:
            transform = CGAffineTransform(translationX: width, y: 0).scaledBy(x: -1, y: 1)
        case .downMirrored:
            transform = CGAffineTransform(translationX: 0, y: height).scaledBy(x: 1, y: -1)
        case .leftMirrored:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(translationX: height, y: width).scaledBy(x: -1, y: 1).rotated(by: 3.0 * .pi / 2.0)
        case .rightMirrored:
            let boundsHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundsHeight
            transform = CGAffineTransform(scaleX: -1, y: 1).rotated(by: .pi / 2.0)
        default:
            transform = .identity
        }
        
        return UIGraphicsImageRenderer(size: bounds.size).image { rendererContext in
            let context = rendererContext.cgContext
            
            if orientation == .right || orientation == .left {
                context.scaleBy(x: -scaleRatio, y: scaleRatio)
                context.translateBy(x: -height, y: 0)
            } else {
                context.scaleBy(x: scaleRatio, y: -scaleRatio)
                context.translateBy(x: 0, y: -height)
            }
            context.concatenate(transform)
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
    }
    
    
    //MARK:- 图片识别功能
    func imageRecognition(image:UIImage) {
        
        guard let cgImage = image.cgImage else {
            return
        }
        //        let opt = VNImageOption(rawValue: "")
        //        VNImageOption.
        //        let session = AVCaptureSession()
        //        session.sessionPreset = .photo
        //        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        //        let deviceInput = try! AVCaptureDeviceInput(device:  captureDevice!)
        //        let  deviceOutput  =  AVCaptureVideoDataOutput()
        //        deviceOutput.videoSettings  =  [kCVPixelBufferPixelFormatTypeKey as  String:  Int(kCVPixelFormatType_32BGRA)]
        //
        //        //        deviceOutput.setSampleBufferDelegate(<#T##sampleBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?##AVCaptureVideoDataOutputSampleBufferDelegate?#>, queue: DispatchQueue.global(qos:  DispatchQoS.QoSClass.default))
        //        deviceOutput.setSampleBufferDelegate(self,  queue:  DispatchQueue.global(qos:  DispatchQoS.QoSClass.default))
        //        session.addInput(deviceInput)
        //        session.addOutput(deviceOutput)
        
        
        //        let req = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        let  textRequest  =  VNDetectTextRectanglesRequest { (request, error) in
            guard let  observations  =  request.results  else  {
                print("没有返回任何结果")
                return
            }
            let  result  =  observations.map({$0  as?  VNTextObservation})
            
            for res in result {
                
            }
            DispatchQueue.main.async()  {
                
            }
            
        }
        textRequest.reportCharacterBoxes  =  true
        self.requests  =  [textRequest]
        let imageReq = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do  {
            try  imageReq.perform(self.requests)
        }  catch  {
            print(error)
        }
    }
    
}

extension VisionMainVC : AVCaptureVideoDataOutputSampleBufferDelegate {
    
}
