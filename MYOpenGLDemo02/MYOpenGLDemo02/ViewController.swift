//
//  ViewController.swift
//  MYOpenGLDemo02
//
//  Created by Carol on 2019/4/21.
//  Copyright © 2019 Carol. All rights reserved.
//

import GLKit

class ViewController: GLKViewController {
    var glkView: MYOpneGLView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view = MYOpneGLView(frame: self.view.frame)
        guard let glkView = (self.view as? MYOpneGLView) else {
            NSLog("Downcast failed")
            return
        }
        self.glkView = glkView
    }
    
}

