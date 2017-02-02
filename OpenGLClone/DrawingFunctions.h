//
//  DrawingFunctions.h
//  OpenGLClone
//
//  Created by Игорь Савельев on 27/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import "TGAImage.h"
#import "GeometryHelpers.h"
#import "ZBuffer.h"
#import "WFModel.h"

extern void drawLine(LPPoint p0, LPPoint p1, TGAImage *image, TGAColor color);
extern void drawTriangle(LPTriangle triangle, TGAImage *image, TGAColor color, ZBuffer *zBuffer);

extern void drawModel(WFModel *model, LPTransform transform, LPVector lightDirection, int width, int height, int depth, TGAImage *image);
