//
//  PreImageViewController.swift
//  uPic
//
//  Created by 侯猛 on 2019/10/24.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Cocoa

class PreImageViewController: NSViewController {

    @IBOutlet weak var preImageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        preImageView.frame = view.bounds
    }
    
    func updatePreImage(url: String) {
        preImageView.kf.indicatorType = .activity
        preImageView.kf.setImage(with: URL(string: url)!)
    }
    
}
