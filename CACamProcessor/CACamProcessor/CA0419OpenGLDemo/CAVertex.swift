//
//  CAVertex.swift
//  CACamProcessor
//
//  Created by Carol on 2019/4/20.
//  Copyright © 2019 Carol. All rights reserved.
//

struct CAVertex {
    var x: GLfloat = 0.0
    var y: GLfloat = 0.0
    var z: GLfloat = 0.0
    var r: GLfloat = 0.0
    var g: GLfloat = 0.0
    var b: GLfloat = 0.0
    var a: GLfloat = 0.0
    var textureX: GLfloat = 0.0
    var textureY: GLfloat = 0.0
    
    init(x: GLfloat, y: GLfloat, z: GLfloat, textureX: GLfloat, textureY: GLfloat) {
        self.x = x
        self.y = y
        self.z = z
        self.textureX = textureX
        self.textureY = textureY
    }
    
    init(x: GLfloat, y: GLfloat, z: GLfloat, r: GLfloat, g: GLfloat, b: GLfloat, a: GLfloat) {
        self.x = x
        self.y = y
        self.z = z
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
    
    init(x: GLfloat, y: GLfloat, z: GLfloat, r: GLfloat, g: GLfloat, b: GLfloat, a: GLfloat, textureX: GLfloat, textureY: GLfloat) {
        self.x = x
        self.y = y
        self.z = z
        self.r = r
        self.g = g
        self.b = b
        self.a = a
        self.textureX = textureX
        self.textureY = textureY
    }
}
