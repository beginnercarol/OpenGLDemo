//
//  CAGLKView.swift
//  CACamProcessor
//
//  Created by Carol on 2019/4/19.
//  Copyright © 2019 Carol. All rights reserved.
//

import GLKit

class CAGLKView: GLKView {
    private var vao = GLuint()
    private var vbo = GLuint()
    private var ebo = GLuint()
    private var vertexShader = GLuint()
    private var frameShader = GLuint()

    private var frameBuffer = GLuint()
    private var colorRenderBuffer = GLuint()
    
    private var effect = GLKBaseEffect()
    
    private var vertices: [CAVertex] = []
    
    override class var layerClass: AnyClass {
        return CAEAGLLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
//        setupContext()
        uploadTexture(withImgName: "draw")
        render()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func setupContext() {
        guard let context = EAGLContext(api: .openGLES3) else {
            NSLog("EAGLContext init failed")
            return
        }
        self.context = context
        EAGLContext.setCurrent(self.context)
    }
    
    func setupFrameBuffer() {
        glGenFramebuffers(1, &frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        self.context.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.layer as! EAGLDrawable)
    }
    
    func setupRenderBuffer() {
        glGenRenderbuffers(1, &colorRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer)
        
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRenderBuffer)
    }
    
    func render() {
        glGenVertexArraysOES(1, &vao)
        glBindVertexArrayOES(vao)
        
        self.vertices = [
            CAVertex(x: 0.5, y: 0.0, z: 0.0, textureX: 1.0, textureY: 0.0),
            CAVertex(x: -0.5, y: 0.5, z: 0.0, textureX: 0.0, textureY: 1.0),
            CAVertex(x: -0.5, y: 0.0, z: 0.0, textureX: 0.0, textureY: 0.0),
        ]
        
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_VERTEX_ARRAY), vbo)
        
        glBufferData(GLenum(GL_VERTEX_ARRAY), vertices.size(), vertices, GLenum(GL_STATIC_DRAW))
        
        let strideOfCAVertex = MemoryLayout<CAVertex>.stride
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(strideOfCAVertex), nil)
        
        let textureOffset = 7 * MemoryLayout<GLfloat>.stride
        var textureOffsetPointer = UnsafeRawPointer(bitPattern: textureOffset)
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(strideOfCAVertex), textureOffsetPointer)
        
        glBindVertexArrayOES(0) // unbind vao
    }
    
    func uploadTexture() {
        guard let img = UIImage(named: "draw")?.cgImage else {
            return
        }
        let options = [GLKTextureLoaderOriginBottomLeft: NSNumber(value: 1)]
        if let textureInfo = try? GLKTextureLoader.texture(with: img, options: options) {
            effect.texture2d0.enabled = GLboolean(GL_TRUE)
            effect.texture2d0.name = textureInfo.name
        }
    }
    
    func uploadTexture(withImgName name: String) {
        guard let img = UIImage(named: name)?.cgImage else {
            return
        }
        
        let imgWidth: Int = img.width
        let imgHeight: Int = img.height
        
        // RGBA *4
        var imgData = [GLubyte](repeating: 0, count: imgWidth * imgHeight * 4)
        
        // 每个 component 都是 8bit=1byte, 所以 row 就是 *4
        let bitmap = CGContext.init(data: &imgData, width: imgWidth, height: imgHeight, bitsPerComponent: 8, bytesPerRow: imgWidth*4, space: img.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        // 因为core graphic 的坐标是 原点在左上, y 轴向下为正方向
        bitmap!.translateBy(x: 0, y: CGFloat(imgHeight)) // 所以第一步 向下平移
        bitmap!.scaleBy(x: 1.0, y: -1.0) // 第二步 翻转 y 轴
        
        bitmap!.draw(img, in: CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight))
        
        var texture = GLuint()
        glBindVertexArrayOES(vao)
        glGenTextures(1, &texture)
        glBindTexture(GLenum(GL_TEXTURE_2D), texture)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLint(GL_RGBA), GLsizei(imgWidth), GLsizei(imgHeight), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), &imgData)
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        glBindVertexArrayOES(0)

    }
    
    deinit {
        dealloc()
    }
    
    func clear() {
        glClearColor(0.85, 0.85, 0.85, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER_OES))
    }
    
    func dealloc() {
        EAGLContext.setCurrent(context)
        glDeleteBuffers(1, &vao)
        glDeleteBuffers(1, &vbo)
        glDeleteBuffers(1, &ebo)

        EAGLContext.setCurrent(nil)
    }
}

extension CAGLKView: GLKViewDelegate {
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        self.clear()
        uploadTexture(withImgName: "test")
        effect.prepareToDraw()
        glBindVertexArrayOES(vao)
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
        glBindVertexArrayOES(0)
    }
}

