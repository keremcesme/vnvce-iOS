
import SwiftUI
import AVFoundation
import UIKit
import Photos

//typealias CapturedPhoto = (image: UIImage, photoData: Data)

struct CapturedPhoto: Equatable {
    var image: UIImage
    var photoData: Data
}

enum CameraConfiguration {
    case success
    case failed
    case permissionDenied
    case permissionNotDetermined
    
    var buttonTitle: String {
        switch self {
        case .permissionDenied:
            return "Open Settings"
        case .permissionNotDetermined:
            return "Allow"
        default:
            return ""
        }
    }
}

enum BackCameraMode {
    case ultrawide
    case wide
    case telephoto
    case secondTelephoto
}

class CameraManager: NSObject, ObservableObject {
    
    public var session: AVCaptureSession = AVCaptureSession()
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    public let sessionQueue = DispatchQueue(label: "sessionQueue")
    
    private var videoDeviceInput: AVCaptureDeviceInput!
    private var photoOutput: AVCapturePhotoOutput!
    
    @Published private(set) public var configurationStatus: CameraConfiguration = .failed
    
    @Published private(set) public var sessionIsRunning: Bool = false
    
    @Published private(set) public var cameraPosition: AVCaptureDevice.Position = .back
    @Published private(set) public var backCameraMode: BackCameraMode = .wide
    
    public var backCameraType: CameraType!
    
    private var backCaptureDevice: AVCaptureDevice.DeviceType!
    private var frontCaptureDevice: AVCaptureDevice.DeviceType!
    
    public let device = UIDevice.modelName.deviceModel()
    
    @Published private(set) public var telephotoValue: TelephotoMode?
    @Published private(set) public var ultraWideIsSupported: Bool = false
    
    @Published public var flashOn = false
    
    private var wideZoomFactor: CGFloat!
    public var telephotoZoomFactor: CGFloat? = nil
    public var secondTelephotoZoomFactor: CGFloat? = nil
    
    @Published private(set) public var currentZoom: CGFloat!
    
    @Published public var focusAnimation = false
    @Published public var focusScale: CGFloat = 0.8
    @Published public var focusPosition: CGPoint = .zero
    
    @Published private(set) public var capturingPhoto: Bool = false
    
    // MARK: OUTPUT
    @Published public var image: UIImage? = nil
    @Published public var photoData: Data? = nil
    @Published public var capturedPhoto: CapturedPhoto? = nil
    
    @Published public var outputWillShowed: Bool = false
    @Published public var outputDidShowed: Bool = false
    
    override init() {
        self.backCaptureDevice = device.setCaptureDevice()
        self.backCameraType = device.setCameraType()
        self.frontCaptureDevice = device.setFrontCaptureDevice()
        self.telephotoValue = device.setTelephoto()
        self.ultraWideIsSupported = device.setUltraWide()
        super.init()
        
#if !targetEnvironment(simulator)
        self.session.sessionPreset = .photo
        self.initalizeZoomFactors()
        self.makeReadyPreviewView()
        self.attemtToConfigureSession()
        self.checkConfigurationAndStartSession()
#endif
        
    }
}

extension CameraManager {
    private func initalizeZoomFactors() {
        switch self.backCameraType {
        case .triple, .wideAndUltraWide:
            self.wideZoomFactor = 2
        default:
            self.wideZoomFactor = 1
        }
        if let telephoto = telephotoValue {
            switch telephoto {
            case let .single(factor):
                self.telephotoZoomFactor = factor
            case let .double(factor, factor2):
                self.telephotoZoomFactor = factor
                self.secondTelephotoZoomFactor = factor2
            }
        }
    }
    
    // MARK: STEP 1
    // [1] Preview View Configuration
    private func makeReadyPreviewView() {
        self.preview = AVCaptureVideoPreviewLayer(session: self.session)
        self.preview.frame.size = self.previewViewFrame()
        if UIDevice.current.hasNotch() {
            self.preview.cornerRadius = 25
            self.preview.cornerCurve = .continuous
        }
        self.preview.connection?.videoOrientation = .portrait
        self.preview.videoGravity = .resizeAspectFill
    }
    
    // [2] Preview View Frame
    public func previewViewFrame() -> CGSize {
        let width = UIScreen.main.bounds.width
        let height = width * 3 / 2
        return CGSize(width, height)
    }
    
    // MARK: STEP 2
    // [1] Attempt to Session Configuration
    private func attemtToConfigureSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.configurationStatus = .success
            self.sessionQueue.async {
                self.configureSession()
            }
        case .notDetermined:
            self.configurationStatus = .permissionNotDetermined
        case .denied:
            self.configurationStatus = .permissionDenied
        default:
            break
        }
    }
    
    public func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    // [2] Request Camera Access
    public func requestCameraAccess() {
        self.sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { authorized in
            DispatchQueue.main.async {
                if authorized {
                    self.configurationStatus = .success
                    self.sessionQueue.resume()
                    self.sessionQueue.async {
                        self.configureSession()
                        self.startSession()
                    }
                } else {
                    self.configurationStatus = .permissionDenied
                }
            }
        }
    }
    
    // [3] Session Configuration
    private func configureSession() {
        guard configurationStatus == .success else {
            return
        }
        session.beginConfiguration()
        self.addVideoDeviceInput {
            guard $0 else {
                self.session.commitConfiguration()
                self.configurationStatus = .failed
                return
            }
            
            self.addPhotoOutput {
                guard $0 else {
                    self.session.commitConfiguration()
                    self.configurationStatus = .failed
                    return
                }
                
                self.session.commitConfiguration()
                DispatchQueue.main.async {
                    self.configurationStatus = .success
                }
            }
        }
    }
    
    // [4] Set Video Device Input
    private func addVideoDeviceInput(_ completion: @escaping (Bool) -> Void) {
        guard let device = AVCaptureDevice.default(backCaptureDevice, for: .video, position: .back) else {
            return completion(false)
        }
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: device)
            
            guard session.canAddInput(videoDeviceInput) else {
                return completion(false)
            }
            
            session.addInput(videoDeviceInput)
            self.videoDeviceInput = videoDeviceInput
            
            let device = self.videoDeviceInput.device
            
            try device.lockForConfiguration()
            
            switch self.backCameraType {
            case .triple, .wideAndUltraWide:
                device.videoZoomFactor = 2
                DispatchQueue.main.async {
                    self.currentZoom = 2
                }
                
            default:
                device.videoZoomFactor = 1
                DispatchQueue.main.async {
                    self.currentZoom = 1
                }
            }
            
            
            if device.hasTorch {
                device.torchMode = .off
            }
            
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }

            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            
            device.unlockForConfiguration()
            return completion(true)
            
        } catch {
            fatalError("Cannot create video device input")
        }
    }
    
    // [5] Set Photo Output
    private func addPhotoOutput(_ completion: @escaping (Bool) -> Void) {
        let photoOutput = AVCapturePhotoOutput()
        
        guard session.canAddOutput(photoOutput) else {
            return completion(false)
        }
        
        session.addOutput(photoOutput)
        self.photoOutput = photoOutput
        return completion(true)
    }
    
    // MARK: STEP 3
    // Check Configuration and Start Session
    private func checkConfigurationAndStartSession() {
        sessionQueue.async {
            if self.configurationStatus == .success {
                self.startSession()
            }
        }
    }
    
    // MARK: Start Session
    public func startSession() {
        self.addObservers()
        sessionQueue.async {
            if !self.session.isRunning {
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.sessionIsRunning = self.session.isRunning
                }
            }
        }
    }
    
//    // MARK: Resume Session
//    public func resumeInterruptedSession(withCompletion completion: @escaping (Bool) -> ()) {
//        sessionQueue.async {
//            self.startSession()
//            DispatchQueue.main.async {
//                completion(self.sessionIsRunning)
//            }
//        }
//    }
    // MARK: Resume Session
    public func resumeInterruptedSession() {
        sessionQueue.async {
            if !self.session.isRunning {
                self.startSession()
                DispatchQueue.main.async {
                    self.sessionIsRunning = self.session.isRunning
                }
            }
        }
    }
    
    // MARK: Stop Session
    public func stopSession() {
        self.removeObservers()
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
                DispatchQueue.main.async {
                    self.sessionIsRunning = self.session.isRunning
                }
                
            }
        }
    }
}

// MARK: Camera Zoom Mods
extension CameraManager {
    public func setTelephotoMode() {
        if let factor = self.telephotoZoomFactor {
            self.backCameraMode = .telephoto
            self.setTelephoto(factor)
        }
    }
    
    public func setSecondTelephotoMode() {
        if let factor = self.secondTelephotoZoomFactor {
            self.backCameraMode = .secondTelephoto
            self.setTelephoto(factor)
        }
    }
    
    private func setTelephoto(_ factor: CGFloat) {
        let device = self.videoDeviceInput.device
        do {
            try device.lockForConfiguration()
            device.ramp(toVideoZoomFactor: self.wideZoomFactor * factor, withRate: 32)
            device.unlockForConfiguration()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func setWideMode() {
        self.backCameraMode = .wide
        let device = self.videoDeviceInput.device
        do {
            try device.lockForConfiguration()
            device.ramp(toVideoZoomFactor: self.wideZoomFactor, withRate: 32)
            device.unlockForConfiguration()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func setUltraWideMode() {
        self.backCameraMode = .ultrawide
        let device = self.videoDeviceInput.device
        do {
            try device.lockForConfiguration()
            device.ramp(toVideoZoomFactor: 1, withRate: 32)
            device.unlockForConfiguration()
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: Camera Focus
extension CameraManager {
    public func focusAction(point: CGPoint, size: CGSize) {
        let tapPoint = point
        let x = tapPoint.y / size.height
        let y = 1.0 - tapPoint.x / size.width
        let focusPoint = CGPoint(x: x, y: y)
        
        let device = videoDeviceInput.device
        
        do {
            try device.lockForConfiguration()
        } catch {
            print(error.localizedDescription)
        }
        
        if device.isFocusPointOfInterestSupported == true {
            device.focusPointOfInterest = focusPoint
            device.focusMode = .continuousAutoFocus
        }
        
        device.exposurePointOfInterest = focusPoint
        device.exposureMode = .continuousAutoExposure
        device.unlockForConfiguration()
        
    }
}

// MARK: Camera Rotate
extension CameraManager {
    public func rotateCamera() {
        let currentPosition = videoDeviceInput.device.position
        
        let newCaptureDevice: AVCaptureDevice.DeviceType
        
        switch currentPosition {
        case .back, .unspecified:
            self.cameraPosition = .front
            newCaptureDevice = self.frontCaptureDevice
        default:
            self.cameraPosition = .back
            newCaptureDevice = self.backCaptureDevice
        }
        
        guard let newDevice = AVCaptureDevice.default(newCaptureDevice, for: .video, position: self.cameraPosition) else {
            fatalError("Cannot find camera.")
        }
        
        self.sessionQueue.async {
            do {
                let newDeviceInput = try AVCaptureDeviceInput(device: newDevice)
                self.session.beginConfiguration()
                self.session.removeInput(self.videoDeviceInput)
                
                if self.session.canAddInput(newDeviceInput) {
                    self.session.addInput(newDeviceInput)
                    self.videoDeviceInput = newDeviceInput
                }
                
                let device = self.videoDeviceInput.device
                let position = device.position
                
                try device.lockForConfiguration()
                
                if position == .back {
                    device.videoZoomFactor = self.wideZoomFactor
                    DispatchQueue.main.async {
                        self.backCameraMode = .wide
                    }
                } else {
                    device.videoZoomFactor = 1
                }
                
                if device.hasTorch {
                    device.torchMode = .off
                }
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    device.focusMode = .continuousAutoFocus
                }
                if device.isExposureModeSupported(.continuousAutoExposure) {
                    device.exposureMode = .continuousAutoExposure
                }
                device.unlockForConfiguration()
                
                self.session.commitConfiguration()
            } catch {
                print("Error occurred while creating video device input: \(error.localizedDescription)")
            }
        }
        
        
        
    }
}

// MARK: Take Photo
extension CameraManager {
    
    public func capturePhoto() {
        if image == nil && !capturingPhoto && sessionIsRunning {
            self.outputWillShowed = true
            self.takePhoto()
        }
    }
    
    private func takePhoto() {
        DispatchQueue.main.async {
            guard let photoOutputConnection = self.photoOutput.connection(with: .video) else {
                return
            }
            
            self.capturingPhoto = true
            
            photoOutputConnection.isVideoMirrored = self.cameraPosition == .front
            
            let settings = AVCapturePhotoSettings()
            
            if self.videoDeviceInput.device.isFlashAvailable {
                if self.flashOn {
                    settings.flashMode = .on
                } else {
                    settings.flashMode = .off
                }
            }
            
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    public func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        defer {
            self.capturingPhoto = false
        }
        guard error == nil else {
            print("Error capturing photo [1]: \(error!.localizedDescription)")
            return
        }
        
        guard let photoData = photo.fileDataRepresentation() else {
            print("Error capturing photo [2]")
            return
        }
        
        guard let image = UIImage(data: photoData) else {
            print("Error capturing photo [3]")
            return
        }
        
        DispatchQueue.main.async {
            self.capturedPhoto = .init(image: image, photoData: photoData)
            self.outputDidShowed = true
            self.capturingPhoto = false
//            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//                self.stopSession()
//            }
        }
    }
}
