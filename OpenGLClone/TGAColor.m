//
//  TGAColor.m
//  OpenGLClone
//
//  Created by Игорь Савельев on 24/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import "TGAColor.h"

TGAColor TGAColorCreate() {
	TGAColor color;
	color.val = 0;
	color.bytespp = 1;
	return color;
}

TGAColor TGAColorCreateRGBA(uint8_t r, uint8_t g, uint8_t b, uint8_t a) {
	TGAColor color;
	color.r = r;
	color.g = g;
	color.b = b;
	color.a = a;
	color.bytespp = 4;
	return color;
}

TGAColor TGAColorCreateWithValue(uint32_t value, int bytespp) {
	TGAColor color;
	color.val = value;
	color.bytespp = bytespp;
	return color;
}

TGAColor TGAColorCopy(TGAColor color) {
	TGAColor newColor;
	newColor.val = color.val;
	newColor.bytespp = color.bytespp;
	return newColor;
}

TGAColor TGAColorCreateWithComponents(uint8_t *p, int bytespp) {
	TGAColor color;
	for (int i = 0; i < bytespp; i++) {
		color.raw[i] = p[i];
	}
	color.bytespp = bytespp;
	return color;
}

void TGAColorCopyValues(TGAColor from, TGAColor to) {
	to.val = from.val;
	to.bytespp = from.bytespp;
}
