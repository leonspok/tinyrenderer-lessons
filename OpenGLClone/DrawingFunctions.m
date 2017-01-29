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
			}
		}
	}
};

void drawFaceElement(WFModel *model, WFFaceElement faceElement, TGAImage *diffuseTexture, LPVector lightDirection, int width, int height, int depth, ZBuffer *zBuffer, TGAImage *image) {
	
	LPTriangle tr;
	LPTriangle textureTriangle;
	for (int j = 0; j < 3; j++) {
		WFVertex *vPointer = [model vertexForIndex:faceElement.parts[j].vertexIx];
		if (vPointer == NULL) {
			NSLog(@"No vertex for index %ld", (long)faceElement.parts[j].vertexIx);
			continue;
		}
		tr.vertices[j] = *vPointer;
		tr.vertices[j].x = (tr.vertices[j].x+1.0f)*width/2.0f;
		tr.vertices[j].y = (tr.vertices[j].y+1.0f)*height/2.0f;
		tr.vertices[j].z = (tr.vertices[j].z+1.0f)*depth/2.0f;
		
		WFTextureCoordinate *cPointer = [model textureCoordinateForIndex:faceElement.parts[j].textureCoordinateIx];
		if (cPointer == NULL) {
			NSLog(@"No vertex for index %ld", (long)faceElement.parts[j].textureCoordinateIx);
			continue;
		}
		if (diffuseTexture == NULL) {
			textureTriangle.vertices[j] = (LPPoint) {
				.x = ((*cPointer).u)*width/2.0f,
				.y = ((*cPointer).v)*height/2.0f,
				.z = 0
			};
		} else {
			textureTriangle.vertices[j] = (LPPoint) {
				.x = ((*cPointer).u)*[diffuseTexture getWidth],
				.y = ((*cPointer).v)*[diffuseTexture getHeight],
				.z = 0
			};
		}
	}
	
	TGAColor defaultFillColor = TGAColorCreate();
	LPVector normal = LPVectorsNormal((LPVector){
		.dx = (tr.vertices[1].x-tr.vertices[0].x),
		.dy = (tr.vertices[1].y-tr.vertices[0].y),
		.dz = (tr.vertices[1].z-tr.vertices[0].z)
	}, (LPVector){
		.dx = (tr.vertices[2].x-tr.vertices[0].x),
		.dy = (tr.vertices[2].y-tr.vertices[0].y),
		.dz = (tr.vertices[2].z-tr.vertices[0].z)
	});
	normal = LPVectorNormalize(normal);
	
	float intensity = LPVectorDotProduct(normal, lightDirection);
	if (intensity <= 0) {
		return;
	}
	uint8_t grayValue = (uint8_t)roundf(intensity*255);
	defaultFillColor = TGAColorCreateRGBA(grayValue, grayValue, grayValue, 255);
	
	for (int i = 0; i < 3; i++) {
		tr.vertices[i].x = roundf(tr.vertices[i].x);
		tr.vertices[i].y = roundf(tr.vertices[i].y);
		tr.vertices[i].z = roundf(tr.vertices[i].z);
	}
	if (tr.vertices[0].y > tr.vertices[1].y) {
		SWAP(tr.vertices[0], tr.vertices[1]);
		SWAP(textureTriangle.vertices[0], textureTriangle.vertices[1]);
	}
	if (tr.vertices[0].y > tr.vertices[2].y) {
		SWAP(tr.vertices[0], tr.vertices[2]);
		SWAP(textureTriangle.vertices[0], textureTriangle.vertices[2]);
	}
	if (tr.vertices[1].y > tr.vertices[2].y) {
		SWAP(tr.vertices[1], tr.vertices[2]);
		SWAP(textureTriangle.vertices[1], textureTriangle.vertices[2]);
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
		LPPoint ptA = {
			.x = textureTriangle.vertices[0].x + (textureTriangle.vertices[2].x-textureTriangle.vertices[0].x)*alphaCoef,
			.y = textureTriangle.vertices[0].y + (textureTriangle.vertices[2].y-textureTriangle.vertices[0].y)*alphaCoef,
			.z = 0
		};
		LPPoint pB, ptB;
		if (secondHalf) {
			pB = (LPPoint){
				.x = tr.vertices[1].x + (tr.vertices[2].x-tr.vertices[1].x)*betaCoef,
				.y = tr.vertices[1].y + (tr.vertices[2].y-tr.vertices[1].y)*betaCoef,
				.z = 0
			};
			ptB = (LPPoint){
				.x = textureTriangle.vertices[1].x + (textureTriangle.vertices[2].x-textureTriangle.vertices[1].x)*betaCoef,
				.y = textureTriangle.vertices[1].y + (textureTriangle.vertices[2].y-textureTriangle.vertices[1].y)*betaCoef,
				.z = 0
			};
		} else {
			pB = (LPPoint){
				.x = tr.vertices[0].x + (tr.vertices[1].x-tr.vertices[0].x)*betaCoef,
				.y = tr.vertices[0].y + (tr.vertices[1].y-tr.vertices[0].y)*betaCoef,
				.z = 0
			};
			ptB = (LPPoint){
				.x = textureTriangle.vertices[0].x + (textureTriangle.vertices[1].x-textureTriangle.vertices[0].x)*betaCoef,
				.y = textureTriangle.vertices[0].y + (textureTriangle.vertices[1].y-textureTriangle.vertices[0].y)*betaCoef,
				.z = 0
			};
		}
		
		if (pA.x > pB.x) {
			SWAP(pA, pB);
			SWAP(ptA, ptB);
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
			int u = (int)roundf(ptA.x+(ptB.x-ptA.x)*phi);
			int v = (int)roundf(ptA.y+(ptB.y-ptA.y)*phi);
			if ([zBuffer valueForX:x y:y] < zValue) {
				[zBuffer setValue:zValue forX:x y:y];
				TGAColor color = defaultFillColor;
				if (diffuseTexture != NULL) {
					color = [diffuseTexture getColorAtX:u y:v];
					color.r *= intensity;
					color.g *= intensity;
					color.b *= intensity;
				}
				[image setColor:color toX:x y:y];
			}
		}
	}
}

void drawModel(WFModel *model, TGAImage *diffuseTexture, LPVector lightDirection, int width, int height, int depth, TGAImage *image) {
	ZBuffer *zBuffer = [[ZBuffer alloc] initWithWidth:width height:height];
	for (int i = 1; i <= model.fCount; i++) {
		WFFaceElement *fePointer = [model faceElementForIndex:i];
		if (fePointer == NULL) {
			NSLog(@"No face element for index %d", i);
			continue;
		}
		WFFaceElement faceElement = *fePointer;
		drawFaceElement(model, faceElement, diffuseTexture, lightDirection, width, height, depth, zBuffer, image);
	}
};
