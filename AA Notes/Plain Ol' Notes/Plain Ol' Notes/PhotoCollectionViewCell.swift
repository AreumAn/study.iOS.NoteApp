//
//  PhotoCollectionViewCell.swift
//  AA Notes
//
//  Created by AA Group on 2017-04-05.
//  Copyright © 2017 Todd Perkins. All rights reserved.
//
// description: collection view cell

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    func setThumbnailImage(_ thumbnailImage: UIImage){
        self.imgView.image = thumbnailImage
    }
    
}
