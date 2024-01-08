import UIKit
import AVFoundation

class QRViewController: UIViewController {

    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
        }

        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]

        livePreview()
    }
    
}

extension QRViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
          if let metadataObject = metadataObjects.first {
                                                            //메타데이터 캡처 출력에서 ​​감지된 바코드 정보
              guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
              guard let stringValue = readableObject.stringValue else { return }
              AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate)) // 진동 알림 AVFoundation의 AudioToolbox api에 있음
              print("asd")
              found(code: stringValue)
          }
      }

      func found(code: String?) {
          let alert = UIAlertController(title: "찾음", message: code, preferredStyle: .alert)
          present(alert, animated: true)
      }


    func livePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspect

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
