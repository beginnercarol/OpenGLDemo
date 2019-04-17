//
//  CACamOpenGLView.swift
//  CACamProcessor
//
//  Created by Carol on 2019/4/15.
//  Copyright © 2019 Carol. All rights reserved.
//

import GLKit

class CACamOpenGLView: GLKView {
    
    private var videoTextureCache: CVOpenGLESTextureCache!
    var lumaTexture: CVOpenGLESTexture!
    var chromaTexture: CVOpenGLESTexture!
    
    var frameBufferHandler = GLuint()
    var colorBufferHandler = GLuint()
    
    func setupGL() {
        if let context = EAGLContext(api: .openGLES3) {
            self.context = context
            EAGLContext.setCurrent(context)
        } else {
            NSLog("Context init failed")
        }
    }
    

    
    func displayPixelBuffer(pixelBuffer buffer: CVPixelBuffer?) {
        if let pixelBuffer = buffer {
            let frameWidth = CVPixelBufferGetWidth(pixelBuffer)
            let frameHeight = CVPixelBufferGetHeight(pixelBuffer)
            if EAGLContext.current() != self.context {
                EAGLContext.setCurrent(self.context)
            }
            //        self.clearsContextBeforeDrawing
            let colorAttachments = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, nil)

            glActiveTexture(GLenum(GL_TEXTURE0))
//            CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, <#T##textureCache: CVOpenGLESTextureCache##CVOpenGLESTextureCache#>, <#T##sourceImage: CVImageBuffer##CVImageBuffer#>, <#T##textureAttributes: CFDictionary?##CFDictionary?#>, <#T##target: GLenum##GLenum#>, <#T##internalFormat: GLint##GLint#>, <#T##width: GLsizei##GLsizei#>, <#T##height: GLsizei##GLsizei#>, <#T##format: GLenum##GLenum#>, <#T##type: GLenum##GLenum#>, <#T##planeIndex: Int##Int#>, <#T##textureOut: UnsafeMutablePointer<CVOpenGLESTexture?>##UnsafeMutablePointer<CVOpenGLESTexture?>#>)
        }
    }

}
