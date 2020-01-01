//
//  QRCodeView.swift
//  Modules
//
//  Created by Lam Le V. on 12/5/19.
//  Copyright © 2019 Lam Le V. All rights reserved.
//

import UIKit
import AVFoundation

final class QRCodeView: UIView {

    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var completion: Completion?
    typealias Completion = (String) -> Void

    func startRunning() {
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }

    func stopRunning() {
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
        }
    }

    func scanQRCode(completion: @escaping Completion) {
        self.completion = completion
        captureSession = AVCaptureSession()
        guard let avCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            return
        }

        guard let avCaptureInput = try? AVCaptureDeviceInput(device: avCaptureDevice) else {
            return
        }

        let avCaptureMetaDataOutput = AVCaptureMetadataOutput()
        avCaptureMetaDataOutput.setMetadataObjectsDelegate(self, queue: .main)

        captureSession?.addInput(avCaptureInput)
        captureSession?.addOutput(avCaptureMetaDataOutput)

        avCaptureMetaDataOutput.metadataObjectTypes = [.qr]

        let avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avCaptureVideoPreviewLayer.connection?.videoOrientation = iPhone ? .portrait: .landscapeRight

        avCaptureVideoPreviewLayer.frame = bounds
        layer.addSublayer(avCaptureVideoPreviewLayer)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRCodeView: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if !metadataObjects.isEmpty {
            let machineReadableCode = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
            if machineReadableCode?.type == AVMetadataObject.ObjectType.qr, let string = machineReadableCode?.stringValue {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                completion?(string)
            }
        }
    }
}
