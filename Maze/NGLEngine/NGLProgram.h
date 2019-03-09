//
//  NGLProgram.h
//  Maze
//
//  Created by Zilong Wang on 2019/3/7.
//  Copyright © 2019年 bcit. All rights reserved.
//

#ifndef NGLProgram_h
#define NGLProgram_h

#import <GLKit/GLKit.h>

@interface NGLProgram : NSObject
{
    @private
        GLuint                    _name;
}

/*!
 *                    Compiles a new Shader Program based on a Vertex and a Fragment Shaders.
 */
- (void) setVertexString:(NSString *)vertex fragmentString:(NSString *)fragment;

/*!
 *                    Compiles a new Shader Program based on a Vertex and a Fragment Shaders.
 *
 */
- (void) setVertexFile:(NSString *)vertexPath fragmentFile:(NSString *)fragmentPath;

/*!
 *                    Returns the locations of an attribute.
 *
 */
- (GLint) attributeLocation:(NSString *)nameInShader;

/*!
 *                    Returns the locations of an uniform.
 */
- (GLint) uniformLocation:(NSString *)nameInShader;

/*!
 *                    Makes use of its own compiled Shader Program.
 */
- (void) use;

@end

#endif /* NGLProgram_h */
