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

void line(LPPoint p0, LPPoint p1, TGAImage *image, TGAColor color) {
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

void triangle(LPTriangle inputTriangle, TGAImage *image, TGAColor color) {
	LPTriangle tr = inputTriangle;
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
			[image setColor:color toX:j y:baseY+i];
		}
	}
};
