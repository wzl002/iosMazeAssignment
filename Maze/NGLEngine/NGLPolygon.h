////
////  NGLPolygon.h
////  Maze
////
////  Created by Zilong Wang on 2019/3/8.
////  Copyright © 2019年 bcit. All rights reserved.
////
//
//#ifndef NGLPolygon_h
//#define NGLPolygon_h
//
//#import <OpenGLES/ES2/gl.h>
//#import <OpenGLES/ES2/glext.h>
//#import <GLKit/GLKit.h>
//
//// #import "NGLMesh.h"
//// #import "NGLMaterial.h"
//// #import "NGLShaders.h"
//
//#import "NGLProgram.h"
//#import "NGLTexture.h"
//#import "NGLFunctions.h"
//
////#import "NGLSLVariables.h"
////#import "NGLSLConstructor.h"
//
//@interface NGLPolygon : NSObject
//{
//@private
//    // Drawing Length
//    void                    *_start;
//    GLsizei                    _length;
//    GLenum                    _dataType;
//    GLenum                    _dataTypeSize;
//    
//    NGLProgram            *_program;
//    // NGLTextures            *_textures;
//    // NGLSLVariables            *_variables;
//    
//    GLKVector4                    _telemetry;
//}
//
///*!
// *                    Compiles this polygon with the current information.
// *
// *                    This method must be called once after set the parent, material, shaders and surface.
// *
// *    @param            mesh
// *                    The NGLMesh that will holds this polygon.
// *
// *    @param            location
// *                    The location in the shader to bind the Texture Object.
// */
//- (void) compilePolygon:(NGLMesh *)mesh
//               material:(NGLMaterial *)material
//                shaders:(NGLShaders *)shaders
//                surface:(NGLSurface *)surface;
//
///*!
// *                    Draw this polygon to the OpenGL ES 2 core.
// *
// *                    This method should be called once at every render cycle to update the image in the
// *                    current frame buffer.
// */
//- (void) drawPolygon;
//
//- (void) drawPolygonTelemetry:(NGLvec4)color;
//
//@end
//
//#endif /* NGLPolygon_h */
