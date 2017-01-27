//
//  GeometryHelpers.m
//  OpenGLClone
//
//  Created by Игорь Савельев on 27/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import "GeometryHelpers.h"

float LPVectorCrossProduct(LPVector v0, LPVector v1) {
	return v0.dy*v1.dz+v0.dz*v1.dx+v0.dx*v1.dy-v0.dy*v1.dx-v0.dx*v1.dz-v0.dz*v1.dy;
}

LPVector LPVectorsNormal(LPVector v1, LPVector v2) {
	return (LPVector) {
		.dx = (v1.dy*v2.dz-v1.dz*v2.dy),
		.dy = (v1.dz*v2.dx-v1.dx*v2.dz),
		.dz = (v1.dx*v2.dy-v1.dy*v2.dx)
	};
}

LPVector LPVectorNormalize(LPVector v) {
	float divider = sqrt(v.dx*v.dx+v.dy*v.dy+v.dz*v.dz);
	if (divider == 0) {
		return v;
	}
	return (LPVector) {
		.dx = v.dx/divider,
		.dy = v.dy/divider,
		.dz = v.dz/divider
	};
}

float LPVectorDotProduct(LPVector v1, LPVector v2) {
	v1 = LPVectorNormalize(v1);
	v2 = LPVectorNormalize(v2);
	return v1.dx*v2.dx+v1.dy*v2.dy+v1.dz*v2.dz;
}

BOOL LPTriangleContainsPoint2D(LPTriangle triangle, LPPoint point) {
	bool signs[3];
	for (int i = 0; i < 3; i++) {
		LPVector vt = (LPVector){
			.dx = (triangle.vertices[(i+1)%3].x-triangle.vertices[i].x),
			.dy = (triangle.vertices[(i+1)%3].y-triangle.vertices[i].y),
			.dz = 0
		};
		LPVector vp = (LPVector){
			.dx = (point.x-triangle.vertices[i].x),
			.dy = (point.y-triangle.vertices[i].y),
			.dz = 0
		};
		
		signs[i] = LPVectorCrossProduct(vt, vp);
	}
	for (int i = 0; i < 3; i++) {
		if (signs[i] != signs[(i+1)%3]) {
			return NO;
		}
	}
	return YES;
}
