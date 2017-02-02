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

LPTransform LPTransformIdentity() {
	return (LPTransform){
		.matrix = {1, 0, 0, 0,
				   0, 1, 0, 0,
				   0, 0, 1, 0,
				   0, 0, 0, 1}
	};
}

LPTransform LPTransformMultiply(LPTransform tr1, LPTransform tr2) {
	LPTransform tr = {};
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			float val = 0;
			for (int t = 0; t < 4; t++) {
				val += tr1.matrix[i][t]*tr2.matrix[t][j];
			}
			tr.matrix[i][j] = val;
		}
	}
	return tr;
}

LPVector LPVectorApplyTransform(LPVector originalVector, LPTransform transform) {
	float vector[4] = {
		originalVector.dx,
		originalVector.dy,
		originalVector.dz,
		0
	};
	float output[4] = {0,0,0,0};
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			output[i] += vector[j]*transform.matrix[i][j];
		}
	}
	return (LPVector) {
		.dx = output[0],
		.dy = output[1],
		.dz = output[2]
	};
}

LPPoint LPPointApplyTransform(LPPoint originalPoint, LPTransform transform) {
	float point[4] = {
		originalPoint.x,
		originalPoint.y,
		originalPoint.z,
		1
	};
	float output[4] = {0,0,0,0};
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			output[i] += point[j]*transform.matrix[i][j];
		}
	}
	for (int i = 0; i < 3; i++) {
		output[i] /= output[3];
	}
	return (LPPoint) {
		.x = output[0],
		.y = output[1],
		.z = output[2]
	};
}

LPTransform createMoveCameraTransform(LPPoint eyePoint, LPPoint cameraTarget, LPVector vertical) {
	LPVector z = (LPVector) {
		.dx = eyePoint.x-cameraTarget.x,
		.dy = eyePoint.y-cameraTarget.y,
		.dz = eyePoint.z-cameraTarget.z
	};
	z = LPVectorNormalize(z);
	
	LPVector x = LPVectorNormalize(LPVectorsNormal(vertical, z));
	LPVector y = LPVectorNormalize(LPVectorsNormal(z, x));
	
	LPTransform res = LPTransformIdentity();
	for (int i = 0; i < 3; i++) {
		res.matrix[0][i] = x.v[i];
		res.matrix[1][i] = y.v[i];
		res.matrix[2][i] = z.v[i];
		res.matrix[i][3] = -cameraTarget.v[i];
	}
	return res;
}

LPTransform createViewPort(LPPoint point, int width, int height, int depth) {
	LPTransform transform = LPTransformIdentity();
	transform.matrix[0][3] = point.x+width/2.0f;
	transform.matrix[1][3] = point.y+height/2.0f;
	transform.matrix[2][3] = depth/2.0f;
	
	transform.matrix[0][0] = width/2.0f;
	transform.matrix[1][1] = height/2.0f;
	transform.matrix[2][2] = depth/2.0f;
	return transform;
}
