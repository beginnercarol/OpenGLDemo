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
    
    var context: EAGLContext?
    
    private var vertices: [Vertex]!
    private var vao = GLuint()
    private var vbo = GLuint()
    private var ebo = GLuint()
    private var textureBuffer = GLuint()
    
    private var effect = GLKBaseEffect()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        self.view = MYOpneGLView(frame: self.view.frame)
//        guard let glkView = (self.view as? MYOpneGLView) else {
//            NSLog("Downcast failed")
//            return
//        }
//        self.glkView = glkView
        self.setupContext()
        self.render()
    }
    
    func setupContext() {
        guard let ctx = EAGLContext(api: .openGLES3) else {
            fatalError("Context int failed")
        }
        if let view = self.view as? GLKView{
            view.context = ctx
            self.context = ctx
//            delegate = self
        }
        
        EAGLContext.setCurrent(ctx)
//        self.clear()
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
    
    func uploadTexture(withName img: String) {
        
    }
    
    func clear() {
        glClearColor(0.85, 0.85, 0.85, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        self.context?.presentRenderbuffer(Int(GL_RENDERBUFFER_OES))
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
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        self.clear()
//        uploadTexture()
//        effect.prepareToDraw()
        glBindVertexArrayOES(vao)
        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(self.vertices.count))
        glBindVertexArrayOES(0)
    }
    
}

//extension GLKViewController: GLK {
//
//}

