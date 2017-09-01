//
//  SocialMediaManager.swift
//  Scrapbooks
//
//  Created by Alan Li on 2017-09-01.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import Social


private let socialMediaTypes = [SLServiceTypeFacebook, SLServiceTypeTwitter, SLServiceTypeSinaWeibo, SLServiceTypeTencentWeibo]

// Class for handling sharing of data. 
class SocialMediaManager {
    
    let controller: UIViewController
    let moment: Moment
    
    init(forController controller: UIViewController, forSharing moment: Moment) {
        self.controller = controller
        self.moment = moment
    }
    
    func bringUpSharingOptions() {
        
        var supportedPlatforms: [String] = []
        
        for platform in socialMediaTypes {
            if SLComposeViewController.isAvailable(forServiceType: platform) {
                supportedPlatforms.append(platform)
            }
        }
        
        let optionController = UIAlertController(title: "Share Your Scrapbook", message: "Which platform would you like to share to?", preferredStyle: .actionSheet)
        
        
        for platform in supportedPlatforms {
            
            let action = UIAlertAction(title: platform, style: .default, handler: { [unowned self] (action: UIAlertAction) in
                self.share(toPlatform: platform)
            })
            optionController.addAction(action)
        }
        
        optionController.addAction(UIAlertAction(title: "General Sharing", style: .default, handler: { _ in
            self.shareToGeneralMedia()
        }))
        
        optionController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        controller.present(optionController, animated: true)
        
    }
    
    
    func share(toPlatform platform: String) {
        
        let shareController = SLComposeViewController(forServiceType: platform)
        shareController?.setInitialText(moment.name + " -- " + moment.caption)
        shareController?.add(moment.photo)
        
        controller.present(shareController!, animated: true)
    }
    
    func shareToGeneralMedia() {
    
        let shareController = UIActivityViewController(activityItems: [moment.name, moment.photo, moment.caption], applicationActivities: nil)
        controller.present(shareController, animated: true)
    }
    
}























