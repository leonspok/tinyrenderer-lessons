//
//  GeometryHelpers.m
//  OpenGLClone
//
//  Created by Игорь Савельев on 27/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import "GeometryHelpers.h"
#import "HelpFunctions.h"

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

LPVector interpolateVector(LPVector from, LPVector to, float coef) {
	LPVector vector = { .v = {0, 0, 0} };
	for (int i = 0; i < 3; i++) {
		vector.v[i] = from.v[i]+(to.v[i]-from.v[i])*coef;
	}
	return vector;
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

LPPoint interpolatePoint(LPPoint from, LPPoint to, float coef) {
	LPPoint point = { .v = {0, 0, 0} };
	for (int i = 0; i < 3; i++) {
		point.v[i] = from.v[i]+(to.v[i]-from.v[i])*coef;
	}
	return point;
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

float computeMinor(LPTransform tr, int i, int j) {
	float matrix[3][3];
	int ix = 0;
	for (int u = 0; u < 4; u++) {
		if (u == i) {
			continue;
		}
		int jx = 0;
		for (int v = 0; v < 4; v++) {
			if (v == j) {
				continue;
			}
			matrix[ix][jx] = tr.matrix[u][v];
			jx++;
		}
		ix++;
	}
	float def = 0;
	for (int u = 0; u < 6; u++) {
		bool secondPart = u >= 3;
		float d = 1.0f;
		for (int v = 0; v < 3; v++) {
			if (secondPart) {
				d *= matrix[(u-v)%3][v];
			} else {
				d *= matrix[(u+v)%3][v];
			}
		}
		if (secondPart) {
			def -= d;
		} else {
			def += d;
		}
	}
	return def*powf(-1, i+j);
}

LPTransform LPTranformInverseTranspose(LPTransform tr) {
	float addMatrix[4][4];
	float def = 0;
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			addMatrix[i][j] = computeMinor(tr, i, j);
		}
		def += tr.matrix[0][i]*addMatrix[0][i];
	}
	for (int i = 0; i < 4; i++) {
		for (int j = i+1; j < 4; j++) {
			SWAP(addMatrix[i][j], addMatrix[j][i]);
		}
	}
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			addMatrix[i][j] /= def;
		}
	}
	LPTransform inversedTransposed = {};
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			inversedTransposed.matrix[i][j] = addMatrix[j][i];
		}
	}
	return inversedTransposed;
}

LPVector LPVectorApplyTransform(LPVector originalVector, LPTransform transform) {
	LP4DCoordinate coordinate = {
		.v = {
			originalVector.dx,
			originalVector.dy,
			originalVector.dz,
			0
		}
	};
	LP4DCoordinate output = LP4DCoordinateApplyTransform(coordinate, transform);
	return LPVectorFrom4DCoordinate(output);
}

LPPoint LPPointApplyTransform(LPPoint originalPoint, LPTransform transform) {
	LP4DCoordinate coordinate = {
		.v = {
			originalPoint.x,
			originalPoint.y,
			originalPoint.z,
			1
		}
	};
	LP4DCoordinate output = LP4DCoordinateApplyTransform(coordinate, transform);
	return LPPointFrom4DCoordinate(output);
}

LP4DCoordinate LP4DCoordinateApplyTransform(LP4DCoordinate originalCoordinate, LPTransform transform) {
	LP4DCoordinate output = {
		.v = {0,0,0,0}
	};
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			output.v[i] += originalCoordinate.v[j]*transform.matrix[i][j];
		}
	}
	return output;
}

LPPoint LPPointFrom4DCoordinate(LP4DCoordinate coordinate) {
	return (LPPoint) {
		.v = {
			coordinate.v[0]/coordinate.v[3],
			coordinate.v[1]/coordinate.v[3],
			coordinate.v[2]/coordinate.v[3]
		}
	};
}

LPVector LPVectorFrom4DCoordinate(LP4DCoordinate coordinate) {
	return (LPVector) {
		.v = {coordinate.v[0], coordinate.v[1], coordinate.v[2]}
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

LPBaricentricCoordinate LPBaricentricCoordinateForPoint(LPPoint point, LPTriangle triangle) {
	LPVector s[2];
	for (int i = 0; i < 2; i++) {
		s[i].v[0] = triangle.vertices[2].v[i]-triangle.vertices[0].v[i];
		s[i].v[1] = triangle.vertices[1].v[i]-triangle.vertices[0].v[i];
		s[i].v[2] = triangle.vertices[0].v[i]-point.v[i];
	}
	LPVector u = LPVectorNormalize(LPVectorsNormal(s[0], s[1]));
	if (ABS(u.v[2]) > FLT_EPSILON) {
		return (LPBaricentricCoordinate) {
			.v = { (1.0f-(u.dx+u.dy)/u.dz), u.dy/u.dz, u.dx/u.dz }
		};
	}
	return (LPBaricentricCoordinate) {
		.v = { -1, 1, 1}
	};
}
