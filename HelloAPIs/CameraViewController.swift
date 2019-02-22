//
//  CameraViewController.swift
//  HelloAPIs
//
//  Created by Yuuki Nishiyama on 2019/02/19.
//  Copyright © 2019 Yuuki Nishiyama. All rights reserved.
//

/**
 * https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/
 * NSCameraUsageDescription
 * NSMicrophoneUsageDescription
 */

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var imageOverlaySwitch: UISwitch!
    @IBOutlet weak var previewView: UIView!
    var previewLayer:AVCaptureVideoPreviewLayer?
    
    var qrcodeFrameView:UIView?
    var faceFrameView:UIView?
    var imageOverlayView:UIImageView?
    
    private let captureSession = AVCaptureSession()
    private let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)
    private let photoOutput = AVCapturePhotoOutput()
    private let captureMetadataOutput = AVCaptureMetadataOutput()
    
    var qrcodeViewHideTimer = Timer()
    var faceViewHideTimer = Timer()
    var imageOverlayHideTimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        qrcodeFrameView = UIView(frame: CGRect.zero)
        if let qrcodeFrameView = qrcodeFrameView {
            qrcodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrcodeFrameView.layer.borderWidth = 2
            qrcodeFrameView.layer.cornerRadius = 8
            self.view.addSubview(qrcodeFrameView)
            self.view.bringSubviewToFront(qrcodeFrameView)
        }

        faceFrameView = UIView(frame: CGRect.zero)
        if let faceFrameView = faceFrameView {
            faceFrameView.layer.borderColor = UIColor.yellow.cgColor
            faceFrameView.layer.borderWidth = 2
            faceFrameView.layer.cornerRadius = 8
            self.view.addSubview(faceFrameView)
            self.view.bringSubviewToFront(faceFrameView)
        }
        
        imageOverlayView = UIImageView(frame: CGRect.zero)
        if let imageOverlayView = imageOverlayView{
            self.view.addSubview(imageOverlayView )
            self.view.bringSubviewToFront(imageOverlayView )
            imageOverlayView.image = UIImage.init(imageLiteralResourceName: "oulu")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        switch AVCaptureDevice.authorizationStatus(for: .video ) {
        case .authorized: // The user has previously granted access to the camera.
            DispatchQueue.main.async {
                self.setupCaptureSession()
            }
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                }
            }
        case .denied: // The user has previously denied access.
            return
        case .restricted: // The user can't grant access due to restrictions.
            return
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        captureSession.stopRunning()
        
        for output in captureSession.outputs {
            //session.removeOutput((output as? AVCaptureOutput)!)
            captureSession.removeOutput(output)
        }
        
        for input in captureSession.inputs {
            //session.removeInput((input as? AVCaptureInput)!)
            captureSession.removeInput(input)
        }
    }
    
    func setupCaptureSession(){
        // https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/setting_up_a_capture_session
        // https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/avcam_building_a_camera_app#//apple_ref/doc/uid/DTS40010112
        captureSession.beginConfiguration()
        
        guard
            let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            captureSession.canAddInput(videoDeviceInput)
            else { return }
        captureSession.addInput(videoDeviceInput)
        
        if captureSession.canSetSessionPreset(.hd4K3840x2160){
            captureSession.sessionPreset = .hd4K3840x2160
        }
        
        guard captureSession.canAddOutput(photoOutput) else { return }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        captureSession.addOutput(captureMetadataOutput)
        captureMetadataOutput.metadataObjectTypes = [.qr, .face]

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.frame = previewView.layer.bounds
        previewView.layer.addSublayer(previewLayer!)
        
        captureSession.commitConfiguration()
        
        captureSession.startRunning()
    }
    
    @IBAction func didPushCaptureButton(_ sender: UIButton) {
        let photoSetting = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSetting, delegate: self)
    }
    
    @IBAction func didPushPhotosButton(_ sender: UIButton) {
        let alert = UIAlertController.init(title: "Open Photos App?", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        let move = UIAlertAction.init(title: "Open", style: .default) { (action) in
            let url = URL(string: "photos-redirect://")!
            if UIApplication.shared.canOpenURL(url) {
                // UIApplication.shared.openURL(url)
                UIApplication.shared.open(url,
                                          options: [:],
                                          completionHandler: nil)
            }
        }
        alert.addAction(cancel)
        alert.addAction(move)
        self.present(alert, animated: true, completion: nil)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/capturing_still_and_live_photos/saving_captured_photos
        guard error == nil else { print("Error capturing photo: \(error!)"); return }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                // Add the captured photo's file data as the main resource for the Photos asset.
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.addResource(with: .photo, data: photo.fileDataRepresentation()!, options: nil)
            }, completionHandler: nil)
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        for object in metadataObjects {
            switch object.type {
            case .qr:
                if let qrObject = previewLayer?.transformedMetadataObject(for: object) as? AVMetadataMachineReadableCodeObject {
                    qrcodeFrameView?.frame = qrObject.bounds
                    qrcodeFrameView?.isHidden = false
                    qrcodeViewHideTimer.invalidate()
                    qrcodeViewHideTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
                        self.qrcodeFrameView?.isHidden = true
                    }
                }
                break
            case .face:
                if let faceObject = previewLayer?.transformedMetadataObject(for: object) as? AVMetadataFaceObject {
                    self.faceFrameView?.frame = faceObject.bounds
                    self.faceFrameView?.isHidden = false
                    faceViewHideTimer.invalidate()
                    faceViewHideTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
                        self.faceFrameView?.isHidden = true
                    }
                    
                    if self.imageOverlaySwitch.isOn {
                        self.imageOverlayView?.frame = faceObject.bounds
                        self.imageOverlayView?.isHidden = false
                        imageOverlayHideTimer.invalidate()
                        imageOverlayHideTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
                            self.imageOverlayView?.isHidden = true
                        }
                    }
                }
                break
            default: break
                
            }

        }
    }
    
}
