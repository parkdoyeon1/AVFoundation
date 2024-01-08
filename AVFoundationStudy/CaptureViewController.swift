import UIKit
import AVFoundation

class CaptureViewController: UIViewController {
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var captureOutput: AVCaptureOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .white
        captureSession = AVCaptureSession()
        
        guard let backCamera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else {
            print("후면카메라가 존재하지 않음")
            return
        }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
        } catch let error {
            print(error.localizedDescription)
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        
//        if captureSession.canAddOutput(metadataOutput) {
//            captureSession.addOutput(metadataOutput)
//        } else {
//            print("fail")
//            return
//        }
//        
        
        livePreview()
    }
    
    func livePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait

        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(videoPreviewLayer)
        videoPreviewLayer.frame = self.view.bounds
    
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
            DispatchQueue.main.async {
                self?.videoPreviewLayer.frame = self!.view.bounds
            }
        }
    }
}
