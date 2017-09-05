//
//  FileSystemHelper.swift
//  Scrapbooks
//
//  Created by Dev User on 2017-07-24.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/// Abstract struct FileSystemHelper contains some helpful functions for creating, retrieving, and deleting data from the file system in the Scrapbooks app.
struct FileSystemHelper {
    
    /// Saves a UIImage object to disk given a name and the scrapbook object it belongs to
    /// - Important: Saves to the user's document directory and a subfolder pertaining to the scrapbook.
    /// To retrieve the image object, call retrieveFromDisk(photoWithname:forScrapbook:)
    static func saveToDisk(photo: UIImage, withName name: String, forScrapbook scrapbook: Scrapbook) {
        
        let documentDirectory = scrapbook.fileDirectory
        // NOTE: isDirectory must be false because the overall URL we are using is not supposed to be a URL, although the specific path we are constructing with the initializer is.
        let fileWriteLocation = URL(fileURLWithPath: documentDirectory).appendingPathComponent("\(name).jpg")
        
        do {
            try UIImageJPEGRepresentation(photo, 1.0)?.write(to: fileWriteLocation, options: [.atomic])
        } catch (let error) {
            print("Save to disk failed: \(String(describing: error))")
        }
    }
    
    
    /// Retrieves an image file from its scrapbook's subfolder in the user's documents, given its name and the scrapbook it belongs to.
    static func retrieveFromDisk(photoWithName photoName: String, forScrapbook scrapbook: Scrapbook) -> UIImage? {
        
        let documentDirectory = scrapbook.fileDirectory
        
        // NOTE: isDirectory must be false because the overall URL we are using is not supposed to be a URL, although the specific path we are constructing with the initializer is.
        let fileWriteLocation = URL(fileURLWithPath: documentDirectory).appendingPathComponent("\(photoName).jpg")
        
        do {
            let imageData = try Data(contentsOf: fileWriteLocation)
            return UIImage(data: imageData)!
        } catch (let error) {
            print("Retrieve from disk failed: \(String(describing: error))")
            return nil
        }
    }
    
    
    /// Removes an image file from a scrapbook's subfolder in the user's documents, given its name and the scrapbook.
    static func removeFromDisk(photoWithName photoName: String, forScrapbook scrapbook: Scrapbook) {
        
        // NOTE: isDirectory must be false because the overall URL we are using is not supposed to be a URL, although the specific path we are constructing with the initializer is.
        let targetURL = URL(fileURLWithPath: scrapbook.fileDirectory, isDirectory: false).appendingPathComponent("\(photoName).jpg")
        do {
            try FileManager().removeItem(at: targetURL)
        } catch (let error) {
            print("Remove from disk failed: \(String(describing: error))")
        }
    }
}














