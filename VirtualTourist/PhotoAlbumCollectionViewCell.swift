//
//  PhotoAlbumCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Nicholas Park on 5/11/16.
//  Copyright © 2016 Nicholas Park. All rights reserved.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    var imageName: String = ""
    var taskToCancelIfReused: NSURLSessionTask?{
        didSet{
            if let taskToCancel = oldValue{
                taskToCancel.cancel()
            }
        }
    }
}
