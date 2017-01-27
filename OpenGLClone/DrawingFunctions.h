//
//  DrawingFunctions.h
//  OpenGLClone
//
//  Created by Игорь Савельев on 27/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import "TGAImage.h"
#import "GeometryHelpers.h"

extern void line(LPPoint p0, LPPoint p1, TGAImage *image, TGAColor color);
extern void triangle(LPTriangle triangle, TGAImage *image, TGAColor color);
