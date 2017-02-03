//
//  Shader.h
//  OpenGLClone
//
//  Created by Игорь Савельев on 02/02/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeometryHelpers.h"
#import "WFModel.h"

@protocol Shader <NSObject>

- (LP4DCoordinate)vertextForFaceElementAtIndex:(NSUInteger)faceElementIx part:(int)part;
- (BOOL)fragment:(LPBaricentricCoordinate)bar color:(TGAColor *)color;

@end
