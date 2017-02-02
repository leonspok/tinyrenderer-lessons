//
//  DrawingFunctions.m
//  OpenGLClone
//
//  Created by Игорь Савельев on 27/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import "DrawingFunctions.h"
#import "HelpFunctions.h"
#import "GeometryHelpers.h"

void drawLine(LPPoint p0, LPPoint p1, TGAImage *image, TGAColor color) {
	int x0 = (int)roundf(p0.x);
	int y0 = (int)roundf(p0.y);
	int x1 = (int)roundf(p1.x);
	int y1 = (int)roundf(p1.y);
	
	BOOL steep = NO;
	if (ABS(x0-x1) < ABS(y0-y1)) {
		SWAP(x0, y0);
		SWAP(x1, y1);
		steep = YES;
	}
	if (x0 > x1) {
		SWAP(x0, x1);
		SWAP(y0, y1);
	}
	
	int dx = x1-x0;
	int dx2 = dx<<1;
	int dy = y1-y0;
	int derror = ABS(dy)<<1;
	int error = 0;
	int y = y0;
	
	for (int x = x0; x <= x1; x++) {
		if (steep) {
			[image setColor:color toX:y y:x];
		} else {
			[image setColor:color toX:x y:y];
		}
		
		error += derror;
		
		if (error > dx) {
			y += (y1 > y0)? 1: -1;
			error -= dx2;
		}
	}
};

void drawTriangle(LPTriangle tr, TGAImage *image, TGAColor color, ZBuffer *zBuffer) {
	for (int i = 0; i < 3; i++) {
		tr.vertices[i].x = roundf(tr.vertices[i].x);
		tr.vertices[i].y = roundf(tr.vertices[i].y);
		tr.vertices[i].z = roundf(tr.vertices[i].z);
	}
	if (tr.vertices[0].y > tr.vertices[1].y) {
		SWAP(tr.vertices[0], tr.vertices[1]);
	}
	if (tr.vertices[0].y > tr.vertices[2].y) {
		SWAP(tr.vertices[0], tr.vertices[2]);
	}
	if (tr.vertices[1].y > tr.vertices[2].y) {
		SWAP(tr.vertices[1], tr.vertices[2]);
	}
	
	int totalHeight = (int)roundf(tr.vertices[2].y-tr.vertices[0].y);
	if (totalHeight == 0) {
		return;
	}
	int verticalThreshold = (int)roundf(tr.vertices[1].y-tr.vertices[0].y);
	BOOL horizontalBottomLine = (int)roundf(tr.vertices[1].y) == (int)roundf(tr.vertices[0].y);
	int segmentHeights[2] = { verticalThreshold, (int)roundf(tr.vertices[2].y-tr.vertices[1].y)};
	for (int i = 0; i < totalHeight; i++) {
		BOOL secondHalf = horizontalBottomLine || i > verticalThreshold;
		int segmentHeight = segmentHeights[(int)secondHalf];
		float alphaCoef = (float)i/totalHeight;
		float betaCoef = 1;
		if (segmentHeight > 0) {
			if (secondHalf) {
				betaCoef = (float)(i - (tr.vertices[1].y-tr.vertices[0].y))/segmentHeight;
			} else {
				betaCoef = (float)(i)/segmentHeight;
			}
		}
		LPPoint pA = {
			.x = tr.vertices[0].x + (tr.vertices[2].x-tr.vertices[0].x)*alphaCoef,
			.y = tr.vertices[0].y + (tr.vertices[2].y-tr.vertices[0].y)*alphaCoef,
			.z = 0
		};
		LPPoint pB;
		if (secondHalf) {
			pB = (LPPoint){
				.x = tr.vertices[1].x + (tr.vertices[2].x-tr.vertices[1].x)*betaCoef,
				.y = tr.vertices[1].y + (tr.vertices[2].y-tr.vertices[1].y)*betaCoef,
				.z = 0
			};
		} else {
			pB = (LPPoint){
				.x = tr.vertices[0].x + (tr.vertices[1].x-tr.vertices[0].x)*betaCoef,
				.y = tr.vertices[0].y + (tr.vertices[1].y-tr.vertices[0].y)*betaCoef,
				.z = 0
			};
		}
		
		if (pA.x > pB.x) {
			SWAP(pA, pB);
		}
		int st = (int)roundf(pA.x), fn = (int)roundf(pB.x);
		int baseY = (int)roundf(tr.vertices[0].y);
		for (int j = st; j <= fn; j++) {
			float phi;
			if (fn == st) {
				phi = 1.0f;
			} else {
				phi = (j-st)/(float)(fn-st);
			}
			
			float zValue = pA.z+(pB.z-pA.z)*phi;
			
			int x = j, y = baseY+i;
			if ([zBuffer valueForX:x y:y] < zValue) {
				[zBuffer setValue:zValue forX:x y:y];
				[image setColor:color toX:x y:y];
			} else if (!zBuffer) {
				[image setColor:color toX:x y:y];
			}
		}
	}
};

float computeIntesity(LPVector lightDirection, LPVector normal) {
	float intensity = LPVectorDotProduct(normal, lightDirection);
	if (intensity <= 0) {
		return 0;
	}
	return intensity;
}

LPPoint interpolatePoint(LPPoint from, LPPoint to, float coef) {
	LPPoint point = { .v = {0, 0, 0} };
	for (int i = 0; i < 3; i++) {
		point.v[i] = from.v[i]+(to.v[i]-from.v[i])*coef;
	}
	return point;
}

LPVector interpolateVector(LPVector from, LPVector to, float coef) {
	LPVector vector = { .v = {0, 0, 0} };
	for (int i = 0; i < 3; i++) {
		vector.v[i] = from.v[i]+(to.v[i]-from.v[i])*coef;
	}
	return vector;
}

void drawFaceElement(WFModel *model, LPTransform transform, WFFaceElement faceElement, LPVector lightDirection, int width, int height, int depth, ZBuffer *zBuffer, TGAImage *image) {
	
	LPTriangle tr;
	LPTriangle textureTriangle;
	LPVector normals[3];
	float intesities[3];
	for (int i = 0; i < 3; i++) {
		WFVertex *vPointer = [model vertexForIndex:faceElement.parts[i].vertexIx];
		if (vPointer == NULL) {
			NSLog(@"No vertex for index %ld", (long)faceElement.parts[i].vertexIx);
			continue;
		}
		tr.vertices[i] = *vPointer;
		tr.vertices[i] = LPPointApplyTransform(tr.vertices[i], transform);
		for (int j = 0; j < 3; j++) {
			tr.vertices[i].v[j] = roundf(tr.vertices[i].v[j]);
		}
		
		WFTextureCoordinate *cPointer = [model textureCoordinateForIndex:faceElement.parts[i].textureCoordinateIx];
		if (cPointer == NULL) {
			NSLog(@"No vertex for index %ld", (long)faceElement.parts[i].textureCoordinateIx);
			continue;
		}
		if (model.diffuseTexture != NULL) {
			textureTriangle.vertices[i] = (LPPoint) {
				.x = roundf(((*cPointer).u)*[model.diffuseTexture getWidth]),
				.y = roundf(((*cPointer).v)*[model.diffuseTexture getHeight]),
				.z = 1
			};
		}
		
		WFNormal *nPointer = [model normalForIndex:faceElement.parts[i].normalIx];
		if (nPointer == NULL) {
			NSLog(@"No normal for index %ld", (long)faceElement.parts[i].normalIx);
			continue;
		}
		normals[i] = *nPointer;
		
		intesities[i] = computeIntesity(lightDirection, normals[i]);
	}

	if (tr.vertices[0].y > tr.vertices[1].y) {
		SWAP(tr.vertices[0], tr.vertices[1]);
		SWAP(textureTriangle.vertices[0], textureTriangle.vertices[1]);
		SWAP(normals[0], normals[1]);
		SWAP(intesities[0], intesities[1]);
	}
	if (tr.vertices[0].y > tr.vertices[2].y) {
		SWAP(tr.vertices[0], tr.vertices[2]);
		SWAP(textureTriangle.vertices[0], textureTriangle.vertices[2]);
		SWAP(normals[0], normals[2]);
		SWAP(intesities[0], intesities[2]);
	}
	if (tr.vertices[1].y > tr.vertices[2].y) {
		SWAP(tr.vertices[1], tr.vertices[2]);
		SWAP(textureTriangle.vertices[1], textureTriangle.vertices[2]);
		SWAP(normals[1], normals[2]);
		SWAP(intesities[1], intesities[2]);
	}

	int totalHeight = (int)roundf(tr.vertices[2].y-tr.vertices[0].y);
	if (totalHeight == 0) {
		return;
	}
	int verticalThreshold = (int)roundf(tr.vertices[1].y-tr.vertices[0].y);
	BOOL horizontalBottomLine = (int)roundf(tr.vertices[1].y) == (int)roundf(tr.vertices[0].y);
	int segmentHeights[2] = { verticalThreshold, (int)roundf(tr.vertices[2].y-tr.vertices[1].y)};
	for (int i = 0; i < totalHeight; i++) {
		BOOL secondHalf = horizontalBottomLine || i > verticalThreshold;
		int segmentHeight = segmentHeights[(int)secondHalf];
		float alphaCoef = (float)i/totalHeight;
		float betaCoef = 1;
		if (segmentHeight > 0) {
			if (secondHalf) {
				betaCoef = (float)(i - (tr.vertices[1].y-tr.vertices[0].y))/segmentHeight;
			} else {
				betaCoef = (float)(i)/segmentHeight;
			}
		}
		LPPoint pA = interpolatePoint(tr.vertices[0], tr.vertices[2], alphaCoef);
		LPPoint ptA = interpolatePoint(textureTriangle.vertices[0], textureTriangle.vertices[2], alphaCoef);
		float intA = intesities[0]+(intesities[2]-intesities[0])*alphaCoef;
		LPPoint pB, ptB;
		float intB;
		if (secondHalf) {
			pB = interpolatePoint(tr.vertices[1], tr.vertices[2], betaCoef);
			ptB = interpolatePoint(textureTriangle.vertices[1], textureTriangle.vertices[2], betaCoef);
			intB = intesities[1]+(intesities[2]-intesities[1])*betaCoef;
		} else {
			pB = interpolatePoint(tr.vertices[0], tr.vertices[1], betaCoef);
			ptB = interpolatePoint(textureTriangle.vertices[0], textureTriangle.vertices[1], betaCoef);
			intB = intesities[0]+(intesities[1]-intesities[0])*betaCoef;
		}
		
		if (pA.x > pB.x) {
			SWAP(pA, pB);
			SWAP(ptA, ptB);
			SWAP(intA, intB);
		}
		int st = (int)roundf(pA.x), fn = (int)roundf(pB.x);
		int baseY = (int)roundf(tr.vertices[0].y);
		for (int j = st; j <= fn; j++) {
			float phi;
			if (fn == st) {
				phi = 1.0f;
			} else {
				phi = (j-st)/(float)(fn-st);
			}
			
			LPPoint p = interpolatePoint(pA, pB, phi);
			float zValue = p.z;
			int x = j, y = baseY+i;
			
			LPPoint pt = interpolatePoint(ptA, ptB, phi);
			int u = (int)roundf(pt.x);
			int v = (int)roundf(pt.y);
			
			
			float intensity = intA+(intB-intA)*phi;
			uint8_t grayValue = (uint8_t)roundf(intensity*255);
			TGAColor fillColor = TGAColorCreateRGBA(grayValue, grayValue, grayValue, 255);
			
			if ([zBuffer valueForX:x y:y] < zValue) {
				[zBuffer setValue:zValue forX:x y:y];
				if (model.diffuseTexture != NULL) {
					fillColor = [model.diffuseTexture getColorAtX:u y:v];
					fillColor.r *= intensity;
					fillColor.g *= intensity;
					fillColor.b *= intensity;
				}
				[image setColor:fillColor toX:x y:y];
			}
		}
	}
}

void drawModel(WFModel *model, LPTransform transform, LPVector lightDirection, int width, int height, int depth, TGAImage *image) {
	ZBuffer *zBuffer = [[ZBuffer alloc] initWithWidth:width height:height];
	for (int i = 1; i <= model.fCount; i++) {
		WFFaceElement *fePointer = [model faceElementForIndex:i];
		if (fePointer == NULL) {
			NSLog(@"No face element for index %d", i);
			continue;
		}
		WFFaceElement faceElement = *fePointer;
		drawFaceElement(model, transform, faceElement, lightDirection, width, height, depth, zBuffer, image);
	}
};
