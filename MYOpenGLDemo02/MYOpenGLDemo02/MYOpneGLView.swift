//
//  MYOpneGLView.swift
//  MYOpenGLDemo02
//
//  Created by Carol on 2019/4/21.
//  Copyright © 2019 Carol. All rights reserved.
//

import GLKit
import Promises

class MYOpneGLView: GLKView {
    private var vertices: [Vertex]!
    private var indices: [GLubyte]!
    
    private var vao = GLuint()
    private var vbo = GLuint()
    private var ebo = GLuint()
    private var textureBuffer = GLuint()
    
    private var texture0Info = GLKTextureInfo()
    private var texture1Info = GLKTextureInfo()
    
    private var effect = GLKBaseEffect()
    
    private var shaderProgram = GLuint()
    
    
    
//    private var
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
//        setupContext()
//        render()
        
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
//        self.clear()
    }
    
    func render() {
        glGenVertexArraysOES(1, &vao)
        glBindVertexArrayOES(vao)
        
        self.vertices = [
            Vertex(x: 0.5, y: -0.5, z: 0.0, r: 1, g: 0, b: 0, a: 1.0, textureX: 1.0, textureY: 0.0),
            Vertex(x: 0.5, y: 0.5, z: 0.0, r: 0, g: 0, b: 1, a: 1.0,textureX: 1.0, textureY: 1.0),
            Vertex(x: -0.5, y: 0.5, z: 0.0, r: 0, g: 1, b: 0, a: 1.0,textureX: 0.0, textureY: 1.0),
            Vertex(x: -0.5, y: -0.5, z: 0.0, r: 0, g: 0, b: 1, a: 1.0,textureX: 0.0, textureY: 0.0),
        ]
        
        
        self.indices = [
            0, 1, 2,
            2, 3, 0
        ]
        
        glGenBuffers(1, &vbo)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
        glBufferData(GLenum(GL_ARRAY_BUFFER), self.vertices.size(), self.vertices, GLenum(GL_STATIC_DRAW))
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        //        let strideOfVertex = self.vertices.size() // 有问题
        let strideOfVertex = MemoryLayout<Vertex>.stride // 长度算错了
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(strideOfVertex), nil)
        let coordOffset = 7*MemoryLayout<GLfloat>.stride
        var coordOffsetPointer = UnsafeRawPointer(bitPattern: coordOffset)
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(strideOfVertex), coordOffsetPointer)
        
        let colorOffsetPointer = UnsafeRawPointer(bitPattern: 3*MemoryLayout<GLfloat>.stride)
//        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.color.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.color.rawValue), 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(strideOfVertex), coordOffsetPointer)
        
        // 怎么 ebo 注释了也能画????
        glGenBuffers(1, &ebo)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), ebo)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), self.indices.size(), self.indices, GLenum(GL_STATIC_DRAW))
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0)
        glBindVertexArrayOES(0)
        
        setupShader()
        glLinkProgram(self.shaderProgram)
        var linkSuccess = GLint()
        glGetProgramiv(self.shaderProgram, GLenum(GL_LINK_STATUS), &linkSuccess)
        
        if linkSuccess == GL_FALSE {
            var message = [CChar](repeating: CChar(0), count: 256)
            glGetProgramInfoLog(self.shaderProgram, GLsizei(message.count), nil, &message)
            let infoMsg = String.init(utf8String: message)
            NSLog("Link program failed: \(infoMsg)")
        }
    }
    
    
    
    override func layoutSubviews() {
        self.setupContext()
        self.render()
//        self.blendTextures()
    }
    
    // - MARK: set up views and buttons
    func setupViews() {
        
    }
    
    
    func uploadTexture() {
        guard let ciImg = UIImage(named: "talk")?.cgImage else {
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
    
    // 仅仅为了演示 opengl core graphics 交互 实际上使用 loader 就可以了
    func uploadTexture(withName name: String) {
        guard let img = UIImage(named: name)?.cgImage else {
            return
        }
        
        let imgWidth: Int = img.width
        let imgHeight: Int = img.height
        
        var imgData = [GLubyte](repeating: 0, count: imgWidth*imgHeight*4)
        guard let bitmap = CGContext.init(data: &imgData, width: imgWidth, height: imgHeight, bitsPerComponent: 8, bytesPerRow: imgWidth*4, space: img.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            NSLog("Bitmap init failed")
            return
        }
        
        //因为core graphic 的坐标是 原点在左上, y 轴向下为正方向
        bitmap.translateBy(x: 0, y: CGFloat(imgHeight)) // 所以第一步 向下平移
        bitmap.scaleBy(x: 1.0, y: -1.0) // 第二步 翻转 y 轴
        
        
        bitmap.draw(img, in: CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight))

        glGenTextures(1, &textureBuffer)
        glBindTexture(GLenum(GL_TEXTURE_2D), textureBuffer)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT)
        
         glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GLint(GL_RGBA), GLsizei(imgWidth), GLsizei(imgHeight), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), &imgData)
        
        // 针对 这个函数 切记 只是为了演示
        effect.texture2d0.enabled = GLboolean(GL_TRUE)
        effect.texture2d0.name = textureBuffer
        effect.texture2d0.target = GLKTextureTarget(rawValue: GLenum(GL_TEXTURE_2D))!
        
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
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
    
    // - MARK: Shaders
    func setupShader() {
        guard let vertexShaderPath = Bundle.main.path(forResource: "vertexShader", ofType: "vsh"), let fragmentShaderPath = Bundle.main.path(forResource: "fragmentShader", ofType: "fsh") else {
            NSLog("Load vertexShader failed")
            return
        }
        
        self.shaderProgram = self.loadShaders(vertexShaderPath, andFrag: fragmentShaderPath)
        
    }
    
    func loadShaders(_ vertex: String, andFrag frag: String?) -> GLuint {
        var vertexShader = glCreateShader(GLenum(GL_VERTEX_SHADER))
        var fragmentShader = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        
        compileShader(vertexShader, type: GLenum(GL_VERTEX_SHADER), file: (vertex as NSString))
        if frag != nil {
            compileShader(fragmentShader, type: GLenum(GL_FRAGMENT_SHADER), file: (frag as! NSString))
        }
        
        var program = glCreateProgram()
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        
        // vertex shader 的 attribute 绑定
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.position.rawValue), "position")
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.texCoord0.rawValue), "textCoordinate")
        
        glLinkProgram(program)
        
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
    
    
    
    // - MARK: Blend
    func blendTextures() {
        
        let options = [GLKTextureLoaderOriginBottomLeft: NSNumber(value: 1)]
        guard let ciImgBase = UIImage(named: "leaves.gif")?.cgImage, let ciImageBlend = UIImage(named: "beetle.png")?.cgImage else {
            NSLog("CIImage load failed.")
            return
        }
        do {
            self.texture0Info = try GLKTextureLoader.texture(with: ciImgBase, options: options)
            
            self.texture1Info = try GLKTextureLoader.texture(with: ciImageBlend, options: options)
            
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
            glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
            
            glEnable(GLenum(GL_BLEND))
            glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))
        } catch let err {
            NSLog("Texture Failed: \(err)")
        }
    }
}

extension MYOpneGLView: GLKViewDelegate {
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glClearColor(0.85, 0.85, 0.85, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
//        drawBlendTexture()
//        drawWithTexture()
        drawWithProgram()
    }
    
    func drawWithTexture() {
        uploadTexture(withName: "talk")
        effect.prepareToDraw()
        glBindVertexArrayOES(vao)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(self.indices.count), GLenum(GL_UNSIGNED_BYTE), self.indices)
        // 这句话啥意思? 将当前 render buffer 上的内容 呈现在屏幕上.
        //        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
        glBindVertexArrayOES(0)
    }
    
    func drawBlendTexture() {
        effect.texture2d0.name = self.texture0Info.name
        effect.texture2d0.target = GLKTextureTarget(rawValue: self.texture0Info.target)!
        effect.prepareToDraw()
        
        glBindVertexArrayOES(vao)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(self.indices.count), GLenum(GL_UNSIGNED_BYTE), self.indices)
        glBindVertexArrayOES(0)
        effect.texture2d0.name = self.texture1Info.name
        effect.texture2d0.target = GLKTextureTarget(rawValue: self.texture1Info.target)!
        effect.prepareToDraw()
        glBindVertexArrayOES(vao)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(self.indices.count), GLenum(GL_UNSIGNED_BYTE), self.indices)
        glBindVertexArrayOES(0)
    }
    
    func drawWithProgram() {
        glUseProgram(self.shaderProgram)
        uniformOfShaders()
        effect.prepareToDraw()
        glBindVertexArrayOES(vao)
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(self.indices.count), GLenum(GL_UNSIGNED_BYTE), self.indices)
        glBindVertexArrayOES(0)
    }
    // 传入 shader 中的 uniform 参数
    func uniformOfShaders() {
        
        var rotate = glGetUniformLocation(self.shaderProgram, "rotateMatrix")
        let radians: GLfloat = 90 * 3.14159 / 180.0
        let sinAng: GLfloat = sin(radians)
        let cosAng: GLfloat = cos(radians)
        
        let zRotation: [GLfloat] = [
            cosAng, -sinAng, 0, 0.2,
            sinAng, cosAng, 0, 0,
            0, 0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0,
            ]
        var rotationSize = GLfloat(zRotation.size())
        glUniformMatrix4fv(rotate, 1, GLboolean(GL_FALSE), zRotation)
        
        
        var colorMap = glGetUniformLocation(self.shaderProgram, "colorMap")
        
        self.uploadTexture(withName: "leaves.gif")
        
        glUniform1i(colorMap, GLint(self.textureBuffer))
    }
}
