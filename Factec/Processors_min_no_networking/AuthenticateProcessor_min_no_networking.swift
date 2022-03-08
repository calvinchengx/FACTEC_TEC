// Welcome to the minimized FaceTec Device SDK code to launch User Sessions and retrieve 3D FaceScans (for further processing)!
// This file removes comment annotations, as well as networking calls,
// in an effort to demonstrate how little code is needed to get the FaceTec Device SDKs to work.

// NOTE: This example DOES NOT perform a secure Authentication. To perform a secure Authentication, you need to actually make an API call.
// Please see the AuthenticateProcessor file for a complete demonstration using the FaceTec Testing API.

import UIKit
import Foundation
import FaceTecSDK

class AuthenticateProcessor_min_no_networking: NSObject, FaceTecFaceScanProcessorDelegate {
    var fromViewController: ViewController!

    init(fromViewController: UIViewController, sessionToken: String) {
        super.init()

        // Core FaceTec Device SDK code that starts the User Session.
        let authenticateSessionViewController = FaceTec.sdk.createSessionVC(faceScanProcessorDelegate: self, sessionToken: sessionToken)
        fromViewController.present(authenticateSessionViewController, animated: true, completion: nil)
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
        parameters["faceScan"] = sessionResult.faceScanBase64
        parameters["auditTrailImage"] = sessionResult.auditTrailCompressedBase64![0]
        parameters["lowQualityAuditTrailImage"] = sessionResult.lowQualityAuditTrailCompressedBase64![0]
        parameters["externalDatabaseRefID"] = fromViewController.getLatestExternalDatabaseRefID()

        // DEVELOPER TODOS:
        // 1.  Call your own API with the above data and pass into the Server SDK
        // 2.  If the Server SDK successfully processes the data, call onFaceScanResultProceedToNextStep(scanResultBlob), passing in the generated scanResultBlob to the parameter.
        //     If onFaceScanResultProceedToNextStep(scanResultBlob) returns as true, the Session was successful and onFaceTecSDKCompletelyDone() will be called next.
        //     If onFaceScanResultProceedToNextStep(scanResultBlob) returns as false, the Session will be proceeding to a retry of the FaceScan.
        // 3.  onFaceScanResultCancel() is provided in case you detect issues with your own API, such as errors processing and returning the scanResultBlob.
        // 4.  onFaceScanUploadProgress(yourUploadProgressFloat) is provided to control the Progress Bar.

        // faceScanResultCallback.onFaceScanResultProceedToNextStep(scanResultBlob)
        // faceScanResultCallback.onFaceScanResultCancel()
        // faceScanResultCallback.onFaceScanUploadProgress(yourUploadProgressFloat)
    }

    func onFaceTecSDKCompletelyDone() {
        // Entrypoint where FaceTec SDKs are done and you can proceed
    }
}
