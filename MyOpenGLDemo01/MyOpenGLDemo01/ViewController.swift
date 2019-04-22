//
//  ViewController.swift
//  MyOpenGLDemo01
//
//  Created by Carol on 2019/4/22.
//  Copyright © 2019 Carol. All rights reserved.
//

import GLKit

class ViewController: GLKViewController {
    private var context: EAGLContext?
    private var effect = GLKBaseEffect()
    
    var Vertices = [
        Vertex(x: 0.5, y: -0.5, z: 0.0, r: 1, g: 0, b: 0, a: 1.0, textureX: 1.0, textureY: 0.0),
        Vertex(x: 0.5, y: 0.5, z: 0.0, r: 0, g: 0, b: 1, a: 1.0,textureX: 1.0, textureY: 1.0),
        Vertex(x: -0.5, y: 0.5, z: 0.0, r: 0, g: 1, b: 0, a: 1.0,textureX: 0.0, textureY: 1.0),
        Vertex(x: -0.5, y: -0.5, z: 0.0, r: 0, g: 0, b: 1, a: 1.0,textureX: 0.0, textureY: 0.0),
        ]
    
    
    var Indices: [GLubyte] = [
        0, 1, 2,
        2, 3, 0
    ]
    
    
    private var vao = GLuint()
    private var vbo = GLuint()
    private var ebo = GLuint()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupGL()
    }
    
    private func setupGL() {
        context = EAGLContext(api: .openGLES3)
        EAGLContext.setCurrent(context)
        
        if let view = self.view as? GLKView, let context = context {
            view.context = context
            delegate = self
        }
        render()
    }
    
    
    func render() {
        let vertexSize = MemoryLayout<Vertex>.stride
        let colorOffset = MemoryLayout<GLfloat>.stride * 3
        let colorOffsetPointer = UnsafeRawPointer(bitPattern: colorOffset)
        
        
        glGenVertexArraysOES(1, &vao)
        glBindVertexArrayOES(vao)
        
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER), self.Vertices.size(), self.Vertices, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(vertexSize), nil)
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.color.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(vertexSize), colorOffsetPointer)
        
        glGenBuffers(1, &ebo)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ebo)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), self.Indices.size(), self.Indices, GLenum(GL_STATIC_DRAW))
        
        
        glBindVertexArrayOES(0)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        
        // why not release GL_ELEMENT_ARRAY_BUFFER ?
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        
        
    }
    
    private func tearDownGL() {
        EAGLContext.setCurrent(context)
        
        glDeleteBuffers(1, &vao)
        glDeleteBuffers(1, &vbo)
        glDeleteBuffers(1, &ebo)
        
        EAGLContext.setCurrent(nil)
        
        context = nil
    }
    
    deinit {
        tearDownGL()
    }

    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        // why here
        glClearColor(0.85, 0.85, 0.85, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        effect.prepareToDraw()
        glBindVertexArrayOES(vao)
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
//        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(self.Indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
        glBindVertexArrayOES(0)
    }

}

extension ViewController: GLKViewControllerDelegate {
    func glkViewControllerUpdate(_ controller: GLKViewController) {
        
    }
    
    
}

