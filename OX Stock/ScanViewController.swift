//
//  ScanViewController.swift
//  OX Stock
//
//  Created by Tobias Lewinzon on 24/01/2020.
//  Copyright © 2020 tobiaslewinzon. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var barCodeFramePreview: UIView?
    
    let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
    AVMetadataObject.ObjectType.code39,
    AVMetadataObject.ObjectType.code39Mod43,
    AVMetadataObject.ObjectType.code93,
    AVMetadataObject.ObjectType.code128,
    AVMetadataObject.ObjectType.ean8,
    AVMetadataObject.ObjectType.ean13,
    AVMetadataObject.ObjectType.aztec,
    AVMetadataObject.ObjectType.pdf417,
    AVMetadataObject.ObjectType.itf14,
    AVMetadataObject.ObjectType.dataMatrix,
    AVMetadataObject.ObjectType.interleaved2of5,
    AVMetadataObject.ObjectType.qr]
    

    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var topBatView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        
        // Getting the back camera. Discovery Session tiene un array (.devices) de physical devices que cumplen con las condiciones dadas.
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: .video, position: .back)

        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get camera")
            return
        }
        
        // Get an instance of the AVCaptureDeviceInput
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            // Ahora que tengo el input device, lo seteo en la capture session (variable global arriba)
            captureSession?.addInput(input)
            
            //Initialize un AVCaptureMetadataOutput
            let captureMetedataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetedataOutput)
            
            //Seteo el deleagate y un array de tipos de data a identificar. Puse todos los que creo que son barcodes
            captureMetedataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetedataOutput.metadataObjectTypes = supportedCodeTypes
            
            //Initialize the video preview layer. Es una sublayer en la main view
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            captureSession?.startRunning()
            
        } catch {
            print(error)
            return
        }
        
        view.bringSubviewToFront(labelView)
        view.bringSubviewToFront(topBatView)
        
        barCodeFramePreview = UIView()
         
        if let barCodeFramePreview = barCodeFramePreview {
            barCodeFramePreview.layer.borderColor = UIColor.green.cgColor
            barCodeFramePreview.layer.borderWidth = 2
            view.addSubview(barCodeFramePreview)
            view.bringSubviewToFront(barCodeFramePreview)
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if metadataObjects.count == 0 {
        barCodeFramePreview?.frame = CGRect.zero
        messageLabel.text = "No QR code is detected"
        return
    }
    
    // Get the metadata object.
    let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
    
        if supportedCodeTypes.contains(metadataObj.type) {
        // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
        let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
        barCodeFramePreview?.frame = barCodeObject!.bounds
        
        if metadataObj.stringValue != nil {
            messageLabel.text = metadataObj.stringValue
        }
    }
    }
    
    @IBAction func exitTapped(_ sender: Any) {
        dismiss(animated: true, completion:  nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
