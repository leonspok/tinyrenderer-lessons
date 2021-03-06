//
//  GeometryHelpers.h
//  OpenGLClone
//
//  Created by Игорь Савельев on 27/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	union {
		struct {
			float x, y, z;
		};
		float v[3];
	};
} LPPoint;

typedef LPPoint LPBaricentricCoordinate;

typedef struct {
	float v[4];
} LP4DCoordinate;

typedef struct {
	union {
		struct {
			float dx, dy, dz;
		};
		float v[3];
	};
} LPVector;

typedef struct {
	LPPoint vertices[3];
} LPTriangle;

typedef struct {
	float matrix[4][4];
} LPTransform;

extern LPPoint interpolatePoint(LPPoint from, LPPoint to, float coef);

extern float LPVectorCrossProduct(LPVector v1, LPVector v2);
extern LPVector LPVectorsNormal(LPVector v1, LPVector v2);
extern LPVector LPVectorNormalize(LPVector v);
extern float LPVectorDotProduct(LPVector v1, LPVector v2);
extern LPVector interpolateVector(LPVector from, LPVector to, float coef);

extern BOOL LPTriangleContainsPoint2D(LPTriangle triangle, LPPoint point);

extern LPTransform LPTransformIdentity();
extern LPTransform LPTransformMultiply(LPTransform tr1, LPTransform tr2);
extern LPTransform LPTranformInverseTranspose(LPTransform tr);

extern LPVector LPVectorApplyTransform(LPVector originalVector, LPTransform transform);
extern LPPoint LPPointApplyTransform(LPPoint originalPoint, LPTransform transform);
extern LP4DCoordinate LP4DCoordinateApplyTransform(LP4DCoordinate originalCoordinate, LPTransform transform);

extern LPPoint LPPointFrom4DCoordinate(LP4DCoordinate);
extern LPVector LPVectorFrom4DCoordinate(LP4DCoordinate);

extern LPTransform createMoveCameraTransform(LPPoint eyePoint, LPPoint cameraTarget, LPVector vertical);
extern LPTransform createViewPort(LPPoint point, int width, int height, int depth);

extern LPBaricentricCoordinate LPBaricentricCoordinateForPoint(LPPoint point, LPTriangle triangle);
