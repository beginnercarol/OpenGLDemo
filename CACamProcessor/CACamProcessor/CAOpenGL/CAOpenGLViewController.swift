//
//  CAOpenGLViewController.swift
//  CACamProcessor
//
//  Created by Carol on 2019/4/14.
//  Copyright © 2019 Carol. All rights reserved.
//


import GLKit
import CoreGraphics

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
    private var renderBuffer = GLuint()
    private var frameBuffer = GLuint()
    
    private var vertexShader = GLuint()
    private var fragmentShader = GLuint()
    private var shaderProgram = GLuint()
    
    var Vertices = [
        Vertex(x:  0.5, y: -0.5, z: 0, r: 1, g: 0, b: 0, a: 1, textureX: 1.0, textureY: 0.0),
        Vertex(x:  0.5, y:  0.5, z: 0, r: 0, g: 1, b: 0, a: 1, textureX: 1.0, textureY: 1.0),
        Vertex(x: -0.5, y:  0.5, z: 0, r: 0, g: 0, b: 1, a: 1, textureX: 0.0, textureY: 1.0),
        Vertex(x: -0.5, y: -0.5, z: 0, r: 0, g: 0, b: 0, a: 1, textureX: 0.0, textureY: 0.0),
    ]
    
    var squareIndices: [GLubyte] = [
        0, 1, 2,
        0, 2, 3
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
        effect = GLKBaseEffect()
        
        setupRenderBuffer()
        setupFrameBuffer()
        helloTriangle()
        
        
    }
    
    func setupRenderBuffer() {
        var buffer = GLuint()
        glGenRenderbuffers(1, &buffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), buffer)
        self.renderBuffer = buffer
        self.context?.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.eaglLayer)
    }
    
    func setupFrameBuffer() {
        var buffer = GLuint()
        glGenFramebuffers(1, &buffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), buffer)
        self.frameBuffer = buffer
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), self.frameBuffer)
    }
    
    
    
    
    func helloTriangle() {
        glGenBuffers(1, &vbo)
        
        let vertexStride = MemoryLayout<Vertex>.stride
        

        glGenVertexArraysOES(1, &vao)
        glBindVertexArrayOES(vao)
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER), Vertices.size(), Vertices, GLenum(GL_STATIC_DRAW))
        
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(vertexStride), nil)
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        
        let colorOffsetPointer = UnsafeRawPointer(bitPattern: 3*MemoryLayout<GLfloat>.stride)
        glVertexAttribPointer(GLuint(GLKVertexAttrib.color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(vertexStride), colorOffsetPointer)
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.color.rawValue))
        
        // Index
        glGenBuffers(1, &ebo)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ebo)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), squareIndices.size(), squareIndices, GLenum(GL_STATIC_DRAW))
        
        // texture pos
        let textureOffsetPointer = UnsafeRawPointer(bitPattern: 7*MemoryLayout<GLfloat>.stride)
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(vertexStride), textureOffsetPointer)
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        
        guard let vertexShaderPath = Bundle.main.path(forResource: "vertexShader", ofType: "vsh"), let fragmentShaderPath = Bundle.main.path(forResource: "fragmentShader", ofType: "fsh") else {
            NSLog("Load vertexShader failed")
            return
        }
        
        self.shaderProgram = self.loadShaders(vertexShaderPath, andFrag: fragmentShaderPath)
        
        uploadTexure(imageName: "food")
        
        // 设置 vertex shader, 获取设定的全局(uniform)属性
        var rotate = glGetUniformLocation(self.shaderProgram, "rotateMatrix")
        
        let radians: GLfloat = 10 * 3.14159 / 180.0
        let sinAng: GLfloat = sin(radians)
        let cosAng: GLfloat = cos(radians)
        
        let zRotation: [GLfloat] = [
            cosAng, -sinAng, 0, 0.2,
            sinAng, cosAng, 0, 0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0,
        ]
        
        var rotationSize = GLfloat(zRotation.size())
        
        glUniformMatrix4fv(rotate, 1, GLboolean(GL_FALSE), &rotationSize)

    }
    
    func uploadTexure(imageName name: String) {
        guard let img = UIImage(named: name)?.cgImage else {
            NSLog("Loading img failed")
            return
        }
        
        let sizeWidth: Int = img.width
        let sizeHeight: Int = img.height
        
    
        var spriteData = [GLubyte](repeating: 0, count: sizeWidth*sizeHeight)
        
        var bitmap = CGContext.init(data: &spriteData, width: sizeWidth, height: sizeHeight, bitsPerComponent: 8, bytesPerRow: sizeWidth*4, space: img.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        bitmap!.draw(img, in: CGRect(x: 0, y: 0, width: sizeWidth, height: sizeHeight))
        
        // why 0?
        
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLint(GL_RGBA), GLsizei(sizeWidth), GLsizei(sizeHeight), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), spriteData)
    }
    
    func loadShaders(_ vertex: String, andFrag frag: String?) -> GLuint {
        vertexShader = glCreateShader(GLenum(GL_VERTEX_SHADER))
        fragmentShader = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        
        compileShader(vertexShader, type: GLenum(GL_VERTEX_SHADER), file: (vertex as NSString))
        if frag != nil {
            compileShader(fragmentShader, type: GLenum(GL_FRAGMENT_SHADER), file: (frag as! NSString))
        }
        
        var program = glCreateProgram()
        glAttachShader(shaderProgram, vertexShader)
        glAttachShader(shaderProgram, fragmentShader)
        glLinkProgram(shaderProgram)
        
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
        return program
    }
    
    func compileShader(_ shader: GLuint, type: GLenum, file: NSString) {
        do {
            let content = try String(contentsOfFile: file as String)
            var contentPointer = (content as NSString).utf8String
            var contentLenght = GLint(content.count)
            glShaderSource(shader, 1, &contentPointer, &contentLenght)
            glCompileShader(shader)
        } catch let err {
            NSLog("Shader open failed")
        }
        var shaderSuccess = GLint()
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &shaderSuccess)
        if shaderSuccess == GL_FALSE {
            var infoLog = [CChar](repeating: CChar(0), count: 256)
            glGetShaderInfoLog(shader, 512, nil, &infoLog)
            let message = String.init(utf8String: infoLog)
            NSLog("glGetShaderInfoLog: \(message)")
        }
        
    }
    
    func projection() {
        
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
    
    // 
    func uploadTexture() {
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
        addObservers()
        setupGL()
        uploadTexture()
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
//        glUseProgram(shaderProgram)
        glBindVertexArray(vao)
//        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3) // 根据顶点数据渲染
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(squareIndices.size()), GLenum(GL_UNSIGNED_BYTE), nil) // 根据 索引渲染
    }
}

extension CAOpenGLViewController: GLKViewControllerDelegate {
    
    func glkViewControllerUpdate(_ controller: GLKViewController) {

    }
}
