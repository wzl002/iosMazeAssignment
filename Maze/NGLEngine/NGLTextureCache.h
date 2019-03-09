//
//  NGLTexture.h
//  Maze
//
//  Created by Zilong Wang on 2019/3/8.
//  Copyright © 2019 bcit. All rights reserved.
//

#ifndef NGLTextureCache_h
#define NGLTextureCache_h

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "NGLTexture.h"
#import "NGLFunctions.h"


// #import "NGLRuntime.h"
// #import "NGLError.h"
// #import "NGLGlobal.h"
// #import "NGLTexture.h"
// #import "NGLMaterial.h"
// #import "NGLParserImage.h"


@interface NGLTextureCache : NSObject
{
@private
    // Textures
    NSMutableArray            *_fileNames;
    GLuint                    *_textures;
    int                        _tCount;
}

/*!
 *                    Loads, parses and constructs a texture map based on a #NGLTexture#.
 */
- (void) addTexture:(NGLTexture *) texture;


/*!
 *                    Gets the reserved texture unit to the last added texture.
 */
- (int) getLastUnit;

/*!
 *                    Binds an OpenGL ES 2 texture to a location.
 */
- (void) bindUnit:(GLint)unit toLocation:(GLint)location;

/*!
 *                    Unbinds all texture object.
 */
+ (void) unbindAll;

/*!
 *                    Returns the maximum number of textures supported.
 */
+ (int) maxTextures;

@end
#endif /* NGLTextureCache_h */
