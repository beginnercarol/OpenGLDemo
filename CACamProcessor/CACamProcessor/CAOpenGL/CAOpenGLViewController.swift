//
//  CAOpenGLViewController.swift
//  CACamProcessor
//
//  Created by Carol on 2019/4/14.
//  Copyright © 2019 Carol. All rights reserved.
//


import GLKit
extension Array {
    func size() -> Int {
        return MemoryLayout<Element>.stride * self.count
    }
}

class CAOpenGLViewController: GLKViewController {
    private var context: EAGLContext?
    private var eaglLayer: CAEAGLLayer {
        return self.view.layer as! CAEAGLLayer
    }
    private var effect = GLKBaseEffect()
    private var rotation: Float = 0.0
    private var ebo = GLuint()
    private var vbo = GLuint()
    private var vao = GLuint()
    private var buffer = GLuint()
    
    private var vertexShader = GLuint()
    private var fragmentShader = GLuint()
    
    var Vertices = [
        Vertex(x:  0.5, y: -0.5, z: 0, r: 1, g: 0, b: 0, a: 1),
        Vertex(x:  0.5, y:  0.5, z: 0, r: 0, g: 1, b: 0, a: 1),
        Vertex(x: -0.5, y:  0.5, z: 0, r: 0, g: 0, b: 1, a: 1),
//        Vertex(x: -0.5, y: -0.5, z: 0, r: 0, g: 0, b: 0, a: 1),
    ]
    
    var squareVertexData: [GLfloat] = [
        0.5, -0.5, 0.0, 1.0, 0.0,
        0.5, 0.5, -0.0, 1.0, 1.0,
        -0.5, 0.5, 0.0, 0.0, 1.0,
        -0.5, -0.5, 0.0, 0.0, 0.0,
//        0.5, -0.5, 0.0, 1.0, 0.0,
//        -0.5, 0.5, 0.0, 0.0, 1.0,
//        -0.5, -0.5, 0.0, 0.0, 0.0
    ]
    
    var squareIndices: [GLubyte] = [
        0, 1, 2,
        0, 2, 3
    ]
    
    var squareVertexDoubleData: [GLfloat] = [
        0.5, -0.5, 0.0, 1.0, 0.0,
        0.5, 0.5, -0.0, 1.0, 1.0,
        0.0, 0.5, 0.0, 0.5, 1.0,
        0.0, -0.5, 0.0, 0.5, 0.0,
        -0.5, 0.5, 0.0, 0.0, 1.0,
        -0.5, -0.5, 0.0, 0.0, 0.0
    ]
    
    var squareDoubleIndices: [GLubyte] = [
        0, 1, 2,
        2, 3, 0,
        3, 2, 4,
        4, 5, 3
    ]
    
    var squareDoubleTexture: [GLubyte] = [
        
    ]
    
    // 两张并排放置
    var squareDouble: [GLfloat] = [
        0.5, -0.5, 0.0, 1.0, 0.0,
        0.5, 0.5, -0.0, 1.0, 1.0,
        0.0, 0.5, 0.0, 0.0, 1.0,
        
        0.5, -0.5, -0.0, 1.0, 0.0,
        0.0, 0.5, 0.0, 0.0, 1.0,
        0.0, -0.5, 0.0, 0.0, 0.0,
        
        0.0, -0.5, 0.0, 1.0, 0.0,
        0.0, 0.5, 0.0, 1.0, 1.0,
        -0.5, 0.5, 0.0, 0.0, 1.0,
       
        -0.5, 0.5, 0.0, 0.0, 1.0,
        -0.5, -0.5, 0.0, 0.0, 0.0,
        0.0, -0.5, 0.0, 1.0, 0.0,
    ]
    
    
    var Indices: [GLubyte] = [
        0, 1, 2,
        2, 3, 0
    ]
    
    private func setupGL() {
        // 绑定 context 并成为当前活跃 context
        context = EAGLContext(api: .openGLES3)
        EAGLContext.setCurrent(context)
        
        if let view = self.view as? GLKView, let context = context {
            view.context = context
            delegate = self
        }
    }
    
    func helloTriangle() {
        glGenBuffers(1, &vbo)
        
        let vertexStride = MemoryLayout<GLfloat>.stride
        
//        glGenBuffers(1, &ebo)
//        glBindBuffer(Glenum(GL_), <#T##buffer: GLuint##GLuint#>)
        glGenVertexArraysOES(1, &vao)
        glBindVertexArrayOES(vao)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER), Vertices.size(), Vertices, GLenum(GL_STATIC_DRAW))
        
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(3 * vertexStride), nil)
        glEnableVertexAttribArray(0)
        
        
        
    }
    
    
    func setupShader() {
        vertexShader = glCreateShader(GLenum(GL_VERTEX_SHADER))
        guard let vertexShaderPath = Bundle.main.path(forResource: "vertexShader", ofType: "glsl"), let fragmentShaderPath = Bundle.main.path(forResource: "fragmentShader", ofType: "glsl") else {
            NSLog("Load vertexShader failed")
            return
        }
        
        do {
            let vertexShaderString = try String(contentsOfFile: vertexShaderPath)
            let vertexShaderStringPointer = UnsafeRawPointer(vertexShaderString)
            glShaderSource(vertexShader, 1, &vertexShaderStringPointer, NULL)
//            if var vertexShaderString = try? String(contentsOfFile: vertexShaderPath) {
//                glShaderSource(vertexShader, 1, &vertexShaderString, NULL)
//                glCompileShader(vertexShader)
//                var
//            }
            
            
        } catch let err {
            NSLog("Convert vertex Shader failed")
        }
        
    }
    
    func renderArrow() {
        var framebuffer = GLuint()
        var renderbuffer = GLuint()
        
        glGenRenderbuffersOES(1, &framebuffer)
        glGenRenderbuffersOES(1, &renderbuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER_OES), framebuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER_OES), renderbuffer)
        
        self.context?.renderbufferStorage(Int(GL_RENDERBUFFER_OES), from: eaglLayer)
        glFramebufferRenderbufferOES(GLenum(GL_FRAMEBUFFER_OES), GLenum(GL_COLOR_ATTACHMENT0_OES
        ), GLenum(GL_RENDERBUFFER_OES), renderbuffer)
        
        glViewport(0, 0, GLsizei(view.frame.width), GLsizei(view.frame.height))
        
    }
    
    func drawView() {
        glClearColor(0.5, 0.5, 0.5, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        self.context?.presentRenderbuffer(Int(GL_RENDERBUFFER_OES))
    }
    
    func uploadTexture() {
//        let path = Bundle.main.path(forResource: "food", ofType: "jpg")
        if let img = UIImage(named: "food"), let cgImg = img.cgImage{
            if let textureInfo = try? GLKTextureLoader.texture(with: cgImg, options: nil) {
                effect.texture2d0.enabled = GLboolean(GL_TRUE)
                effect.texture2d0.name = textureInfo.name
            }
        }
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

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGL()
        uploadTexture()
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotate(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func deviceRotate(_ notification: NSNotification) {
        NSLog("Device rotated!")
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(0.85, 0.85, 0.85, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        effect.prepareToDraw()
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), buffer)
//        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ebo)
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 12)
//        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(squareDoubleIndices.count), GLenum(GL_UNSIGNED_BYTE), nil)
//        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(Indices.count), GLenum(GL_UNSIGNED_BYTE), nil)
//        glBindVertexArrayOES(0)
    }
}

extension CAOpenGLViewController: GLKViewControllerDelegate {
    
    func glkViewControllerUpdate(_ controller: GLKViewController) {
//        let aspect = fabsf(Float(view.bounds.width)/Float(view.bounds.height))
//        let projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0), aspect, 4.0, 10.0)
//        effect.transform.projectionMatrix = projectionMatrix
//        var modelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -6.0)
//        rotation += 90*Float(timeSinceLastUpdate)
//        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(rotation), 0, 0, 1)
//        effect.transform.modelviewMatrix = modelViewMatrix
    }
}
