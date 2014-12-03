//
//  PhotoCollectionViewCell.swift
//  LookInside
//
//  Created by Herryanto Siatono on 2/12/14.
//  Copyright (c) 2014 Demo. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var image: UIImage! {
        get {
            return self.imageView.image
        }
        
        set {
            self.imageView.image = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView = UIImageView()
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.imageView.backgroundColor = UIColor.blueColor()
        
        self.backgroundColor = UIColor.greenColor()
        
        self.contentView.addSubview(self.imageView)
        self.contentView.clipsToBounds = true
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.contentView.bounds
    }
}
