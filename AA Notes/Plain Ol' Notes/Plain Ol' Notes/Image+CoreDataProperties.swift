//
//  Image+CoreDataProperties.swift
//  AA Notes
//
//  Created by Areum on 2017-04-09.
//  Copyright © 2017 Todd Perkins. All rights reserved.
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var image: NSData?
    @NSManaged public var image_id: String?
    @NSManaged public var locationV1: Float
    @NSManaged public var note_id: String?
    @NSManaged public var locationV2: Float
    @NSManaged public var toNote: Note?

}
