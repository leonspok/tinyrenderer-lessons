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

void drawFaceElement(WFModel *model, NSUInteger faceElementIx, id<Shader> shader, ZBuffer *zBuffer, TGAImage *image) {	
	LPTriangle tr = {};
	LP4DCoordinate coordinates[3];
	for (int i = 0; i < 3; i++) {
		coordinates[i] = [shader vertextForFaceElementAtIndex:faceElementIx part:i];
		tr.vertices[i] = LPPointFrom4DCoordinate(coordinates[i]);
	}

	LPPoint bboxmin = {
		.v = {HUGE_VALF, HUGE_VALF, 0}
	};
	LPPoint bboxmax = {
		.v = {-HUGE_VALF, -HUGE_VALF, 0}
	};
	
	for (int i = 0; i < 3; i++) {
		for (int j = 0; j < 2; j++) {
			bboxmin.v[j] = MIN(bboxmin.v[j], tr.vertices[i].v[j]);
			bboxmax.v[j] = MAX(bboxmax.v[j], tr.vertices[i].v[j]);
		}
	}
	
	for (int x = bboxmin.x; x < bboxmax.x; x++) {
		for (int y = bboxmin.y; y < bboxmax.y; y++) {
			LPBaricentricCoordinate barScreen = LPBaricentricCoordinateForPoint((LPPoint){.v = {x, y, 0}}, tr);
			LPBaricentricCoordinate barClip = {
				.x = barScreen.x/coordinates[0].v[3],
				.y = barScreen.y/coordinates[1].v[3],
				.z = barScreen.z/coordinates[2].v[3]
			};
			float barClipSum = barClip.x+barClip.y+barClip.z;
			for (int k = 0; k < 3; k++) {
				barClip.v[k] /= barClipSum;
			}
			float fragDepth = 0;
			for (int k = 0; k < 3; k++) {
				fragDepth += coordinates[k].v[2]/coordinates[k].v[3]*barClip.v[k];
			}
			if (barScreen.x < 0 || barScreen.y < 0 || barScreen.z < 0 || [zBuffer valueForX:x y:y] > fragDepth) {
				continue;
			}
			TGAColor color = TGAColorCreate();
			if (![shader fragment:barClip color:&color]) {
				[zBuffer setValue:(float)fragDepth forX:x y:y];
				[image setColor:color toX:x y:y];
			}
		}
	}
}

void drawModel(WFModel *model, id<Shader> shader, ZBuffer *zBuffer, TGAImage *image) {
	for (int i = 1; i <= model.fCount; i++) {
		if ([model faceElementForIndex:i] == NULL) {
			NSLog(@"No face element for index %d", i);
			continue;
		}
		drawFaceElement(model, i, shader, zBuffer, image);
	}
};
