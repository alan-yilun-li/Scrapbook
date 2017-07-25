//
//  SBDataManager.swift
//  Scrapbooks
//
//  Created by Dev User on 2017-07-24.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/// Abstract struct SBDataManager (Scrapbook Data Manager) contains some helpful functions for creating, retrieving, and deleting data in the Scrapbooks app).
struct SBDataManager {
    
    /// Creates and returns an Moment entity NSManagedObject.
    static func createMomentEntityWith(name: String, photoName: String, caption: String) -> NSManagedObject? {
        
        let context = CoreDataStack.shared.persistentContainer.viewContext
        if let momentEntity = NSEntityDescription.insertNewObject(forEntityName: "Moment", into:
            context) as? Moment {
            print("adding a moment")
            momentEntity.name = name
            momentEntity.photoName = photoName
            momentEntity.caption = caption
            return momentEntity
        }
        return nil
    }
    
    /// Creates and returns an Scrapbook entity NSManagedObject.
    static func createScrapbookEntityWith(title: String, coverPhotoName: String) -> NSManagedObject? {
        
        let context = CoreDataStack.shared.persistentContainer.viewContext
        if let scrapbookEntity = NSEntityDescription.insertNewObject(forEntityName: "Scrapbook", into: context) as? Scrapbook {
            
            print("adding a scrapbook")
            scrapbookEntity.title = title
            scrapbookEntity.coverPhotoName = coverPhotoName
            scrapbookEntity.moments = NSSet(array: [])
            
            return scrapbookEntity
        }
        return nil
    }
    
    /// Saves a UIImage object to disk given a name.
    /// - Important: Saves to the user's document directory. 
    /// To retrieve the image object, call retrieveFromDisk(photoWithname:)
    static func saveToDisk(photo: UIImage, withName name: String) {
        
        let documentDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first
        let fileWriteLocation = documentDirectory?.appendingPathComponent(name)
        
        do {
            try UIImagePNGRepresentation(photo)?.write(to: fileWriteLocation!, options: [.withoutOverwriting])
        } catch (let error) {
            print(String(describing: error))
        }
    }
    
    
    /// Retrieves a top-level UIImage file from the user's documents, given its name
    static func retrieveFromDisk(photoWithName photoName: String) -> UIImage? {
        
        let documentDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first
        let fileWriteLocation = documentDirectory?.appendingPathComponent(photoName)
        
        do {
            let imageData = try Data(contentsOf: fileWriteLocation!)
            return UIImage(data: imageData)!
        } catch (let error) {
            print(String(describing: error))
            return nil
        }
    }
}














