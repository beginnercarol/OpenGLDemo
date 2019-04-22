//
//  MYOpneGLView.swift
//  MYOpenGLDemo02
//
//  Created by Carol on 2019/4/21.
//  Copyright © 2019 Carol. All rights reserved.
//

import GLKit

class MYOpneGLView: GLKView {
    private var vertices: [Vertex]!
    private var vao = GLuint()
    private var vbo = GLuint()
    private var ebo = GLuint()
    private var textureBuffer = GLuint()
    
    private var effect = GLKBaseEffect()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        setupContext()
        render()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupContext() {
        guard let ctx = EAGLContext(api: .openGLES3) else {
            fatalError("Context int failed")
        }
        self.context = ctx
        EAGLContext.setCurrent(self.context)
        self.clear()
    }
    
    func render() {
        glGenVertexArraysOES(1, &vao)
        glBindVertexArrayOES(vao)
        
        self.vertices = [
            Vertex(x: 0.5, y: 0.0, z: 0.0, r: 1, g: 0, b: 0, a: 1.0, textureX: 1.0, textureY: 0.0),
            Vertex(x: -0.5, y: 0.5, z: 0.0, r: 0, g: 1, b: 0, a: 1.0,textureX: 0.0, textureY: 1.0),
            Vertex(x: -0.5, y: 0.0, z: 0.0, r: 0, g: 0, b: 1, a: 1.0,textureX: 0.0, textureY: 0.0),
        ]
        
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER), self.vertices.size(), self.vertices, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        let strideOfVertex = self.vertices.size()
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(strideOfVertex), nil)
        let coordOffset = 7*MemoryLayout<GLfloat>.stride
        var coordOffsetPointer = UnsafeRawPointer(bitPattern: coordOffset)

        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(strideOfVertex), coordOffsetPointer)
        
        let colorOffsetPointer = UnsafeRawPointer(bitPattern: 3*MemoryLayout<GLfloat>.stride)
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.color.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(strideOfVertex), coordOffsetPointer)
        
        
        glBindVertexArrayOES(0)
    }
    
    func uploadTexture() {
        guard let ciImg = UIImage(named: "test")?.cgImage else {
            NSLog("Loading texture failed")
            return 
        }
        
        let options = [GLKTextureLoaderOriginBottomLeft: NSNumber(value: 1)]
        
        do {
            let textureInfo = try GLKTextureLoader.texture(with: ciImg, options: options)
            effect.texture2d0.enabled = GLboolean(GL_TRUE)
            effect.texture2d0.name = textureInfo.name
            effect.texture2d0.target = GLKTextureTarget(rawValue: textureInfo.target)!
        } catch let err {
            NSLog("Error occured when load texture: \(err)")
        }
  
    }
    
    func uploadTexture(withName name: String) {
        guard let img = UIImage(named: name)?.cgImage else {
            return
        }
        
        let imgWidth: Int = img.width
        let imgHeight: Int = img.height
        
        var imgData = [GLubyte](repeating: 0, count: imgWidth*imgHeight)
        guard let bitmap = CGContext.init(data: &imgData, width: imgWidth, height: imgHeight, bitsPerComponent: 8, bytesPerRow: imgWidth*4, space: img.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            NSLog("Bitmap init failed")
            return
        }
        
        // 因为core graphic 的坐标是 原点在左上, y 轴向下为正方向
        bitmap.translateBy(x: 0, y: CGFloat(imgHeight)) // 所以第一步 向下平移
        bitmap.scaleBy(x: 1.0, y: -1.0) // 第二步 翻转 y 轴
        
        bitmap.draw(img, in: CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight))
        
        var texture = GLuint()
//        glBindVertexArrayOES(vao)
        glGenTextures(1, &texture)
        glBindTexture(GLenum(GL_TEXTURE_2D), texture)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLint(GL_RGBA), GLsizei(imgWidth), GLsizei(imgHeight), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), &imgData)
//        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
//        glBindVertexArrayOES(0)
        
    }
    
    func clear() {
        glClearColor(0.85, 0.85, 0.85, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER_OES))
    }
    
    func dealloc() {
        EAGLContext.setCurrent(self.context)
        glDeleteBuffers(1, &vao)
        glDeleteBuffers(1, &vbo)
        glDeleteBuffers(1, &ebo)
        glDeleteBuffers(1, &textureBuffer)
        EAGLContext.setCurrent(nil)
    }
    deinit {
        dealloc()
    }
    
}

extension MYOpneGLView: GLKViewDelegate {
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        clear()
        uploadTexture(withName: "test")
        effect.prepareToDraw()
        glBindVertexArrayOES(vao)
        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(self.vertices.count))
        glBindVertexArrayOES(0)
    }
}
