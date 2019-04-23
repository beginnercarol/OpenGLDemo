attribute vec4 position;
attribute vec2 textCoordinate;
uniform mat4 rotateMatrix;
out varying lowp vec2 varyTextCoord;



void main() {
    varytextCoord = textCoordinate;
    vec4 vPos = position;
    vPos = vPos * rotateMatrix;
    
    gl_Position = vPos;
}
