// Welcome to the minimized FaceTec Device SDK code to launch User Sessions and retrieve 3D FaceScans (for further processing)!
// This file removes comment annotations, as well as networking calls,
// in an effort to demonstrate how little code is needed to get the FaceTec Device SDKs to work.

// NOTE: This example DOES NOT perform a secure Photo ID Scan.  To perform a secure Photo ID Scan, you need to actually make an API call.
// Please see the PhotoIDMatchProcessor file for a complete demonstration using the FaceTec Testing API.

import UIKit
import Foundation
import FaceTecSDK

class PhotoIDScanProcessor_min_no_networking: NSObject, FaceTecFaceScanProcessorDelegate, FaceTecIDScanProcessorDelegate {
    var fromViewController: ViewController!

    init(sampleAppViewController: UIViewController, sessionToken: String) {
        super.init()
        
        // Core FaceTec Device SDK code that starts the User Session.
        let idScanViewController = FaceTec.sdk.createSessionVC(faceScanProcessorDelegate: self, sessionToken: sessionToken)
        sampleAppViewController.present(idScanViewController, animated: true, completion: nil)
    }
    
    func processSessionWhileFaceTecSDKWaits(sessionResult: FaceTecSessionResult, faceScanResultCallback: FaceTecFaceScanResultCallback) {
        // Normally a User will complete a Session.  This checks to see if there was a cancellation, timeout, or some other non-success case.
        if sessionResult.status != FaceTecSessionStatus.sessionCompletedSuccessfully {
            faceScanResultCallback.onFaceScanResultCancel()
            return
        }
        
        // IMPORTANT:  FaceTecSDK.FaceTecSessionStatus.SessionCompletedSuccessfully DOES NOT mean the Liveness Check was Successful.
        // It simply means the User completed the Session and a 3D FaceScan was created.  You still need to perform the Liveness Check on your Servers.

        // These are the core parameters
        var parameters: [String : Any] = [:]
        parameters["faceMap"] = sessionResult.faceScanBase64

        if let auditTrail = sessionResult.auditTrailCompressedBase64 {
           parameters["auditTrailImage"] = auditTrail[0]
        }

        if let lowQualityAuditTrail = sessionResult.lowQualityAuditTrailCompressedBase64 {
           parameters["lowQualityAuditTrailImage"] = lowQualityAuditTrail[0]
        }
        parameters["sessionId"] = sessionResult.sessionId
        parameters["externalDatabaseRefID"] = fromViewController.getLatestExternalDatabaseRefID()
        
        // DEVELOPER TODOS:
        // 1.  Call your own API with the above data and pass into the Server SDK
        // 2.  If the Server SDK successfully processes the data, call onFaceScanResultProceedToNextStep(scanResultBlob), passing in the generated scanResultBlob to the parameter.
        //     If onFaceScanResultProceedToNextStep(scanResultBlob) returns as true, the FaceScan part of the Session was successful and will be proceeding to the ID Scan.
        //     If onFaceScanResultProceedToNextStep(scanResultBlob) returns as false, the Session will be proceeding to a retry of the FaceScan.
        // 3.  onFaceScanResultCancel() is provided in case you detect issues with your own API, such as errors processing and returning the scanResultBlob.
        // 4.  onFaceScanUploadProgress(yourUploadProgressFloat) is provided to control the Progress Bar.

        // faceScanResultCallback.onFaceScanResultProceedToNextStep(scanResultBlob)
        // faceScanResultCallback.onFaceScanResultCancel()
        // faceScanResultCallback.onFaceScanUploadProgress(yourUploadProgressFloat)
    }
    
    func processIDScanWhileFaceTecSDKWaits(idScanResult: FaceTecIDScanResult, idScanResultCallback: FaceTecIDScanResultCallback) {
        // Normally a User will complete a Session. This checks to see if there was a cancellation, timeout, or some other non-success case.
        if idScanResult.status != FaceTecIDScanStatus.success {
            idScanResultCallback.onIDScanResultCancel()
            return
        }
        
        // IMPORTANT: FaceTecIDScanStatus.success DOES NOT mean the ID Scan 3d-2d Matching was Successful.
        // It simply means the User completed the Session and a 3D ID Scan was created. You still need to perform the ID Scan 3d-2d Matching on your Servers.

        // These are the core parameters
        var parameters: [String : Any] = [:]
        parameters["idScan"] = idScanResult.idScanBase64
        if idScanResult.frontImagesCompressedBase64?.isEmpty == false {
            parameters["idScanFrontImage"] = idScanResult.frontImagesCompressedBase64![0]
        }
        if idScanResult.backImagesCompressedBase64?.isEmpty == false {
            parameters["idScanBackImage"] = idScanResult.backImagesCompressedBase64![0]
        }
        parameters["minMatchLevel"] = 3
        parameters["externalDatabaseRefID"] = fromViewController.getLatestExternalDatabaseRefID()

        // DEVELOPER TODOS:
        // 1.  Call your own API with the above data and pass into the Server SDK
        // 2.  If the Server SDK successfully processes the data, call onIDScanResultProceedToNextStep(scanResultBlob), passing in the generated scanResultBlob to the parameter.
        //     If onIDScanResultProceedToNextStep(scanResultBlob) returns as true, the ID Scan part of the Session was successful and onFaceTecSDKCompletelyDone() will be called next.
        //     If onIDScanResultProceedToNextStep(scanResultBlob) returns as false, the ID Scan Session is continuing to advance through the User Flow, passing back another Session Result once the next step in the User Flow is complete and ready to be processed by the Server SDK.
        // 3.  onIDScanResultCancel() is provided in case you detect issues with your own API, such as errors processing and returning the scanResultBlob.
        // 4.  onIDScanUploadProgress(yourUploadProgressFloat) is provided to control the Progress Bar.

        // idScanResultCallback.onIDScanResultProceedToNextStep(scanResultBlob)
        // idScanResultCallback.onIDScanResultCancel()
        // idScanResultCallback.onIDScanUploadProgress(yourUploadProgressFloat)
    }
    
    func onFaceTecSDKCompletelyDone() {
        // Entrypoint where FaceTec SDKs are done and you can proceed
    }
}
