//
//  CA0419ViewController.swift
//  CACamProcessor
//
//  Created by Carol on 2019/4/19.
//  Copyright © 2019 Carol. All rights reserved.
//

import UIKit
import GLKit

class CA0419ViewController: GLKViewController {
//    private var context: EAGLContext?
    private var caGLKView: CAGLKView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = CAGLKView(frame: self.view.frame)
        self.caGLKView = self.view as? CAGLKView
        setupContext()
        // Do any additional setup after loading the view.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setupContext() {
        //        EAGLContext.setCurrent(nil)
        guard let context = EAGLContext(api: .openGLES3) else {
            NSLog("EAGLContext init failed")
            return
        }
        self.caGLKView?.context = context
        EAGLContext.setCurrent(self.caGLKView?.context)
    }

}
