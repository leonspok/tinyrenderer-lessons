//
//  GeometryHelpers.h
//  OpenGLClone
//
//  Created by Игорь Савельев on 27/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	float x, y, z;
} LPPoint;

typedef struct {
	float dx, dy, dz;
} LPVector;

typedef struct {
	LPPoint vertices[3];
} LPTriangle;

extern float LPVectorCrossProduct(LPVector v1, LPVector v2);
extern LPVector LPVectorsNormal(LPVector v1, LPVector v2);
extern LPVector LPVectorNormalize(LPVector v);
extern float LPVectorDotProduct(LPVector v1, LPVector v2);

extern BOOL LPTriangleContainsPoint2D(LPTriangle triangle, LPPoint point);
