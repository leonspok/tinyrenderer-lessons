//
//  TGAImage.h
//  OpenGLClone
//
//  Created by Игорь Савельев on 24/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	union {
		struct {
			unsigned char b, g, r, a;
		};
		unsigned char raw[4];
		unsigned int val;
	};
	int bytespp;
} TGAColor;

TGAColor TGAColorCreate() {
	TGAColor color;
	color.val = 0;
	color.bytespp = 1;
	return color;
}

TGAColor TGAColorCreateRGBA(unsigned char r, unsigned char g, unsigned char b, unsigned char a) {
	TGAColor color;
	color.r = r;
	color.g = g;
	color.b = b;
	color.a = a;
	color.bytespp = 4;
	return color;
}

TGAColor TGAColorCreateWithValue(unsigned int value, int bytespp) {
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

TGAColor TGAColorCreateWithComponents(unsigned char *p, int bytespp) {
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

typedef enum {
	GRAYSCALE	= 1,
	RGB			= 3,
	RGBA		= 4
} TGAImageFormat;

@interface TGAImage : NSObject <NSCopying> {
	unsigned char *data;
	int width;
	int height;
	int bytespp;
}

@property (nonatomic, readonly) CGImageRef cgImage;

- (id)initWithWidth:(int)width height:(int)height bytesPerPixel:(int)bytesPerPixel;
- (id)initWithTGAImage:(TGAImage *)image;

- (BOOL)readTGAFileAtPath:(NSString *)path;
- (BOOL)writeTGAFileToPath:(NSString *)path rle:(BOOL)rle;
- (BOOL)flipHorizontally;
- (BOOL)flipVertically;
- (BOOL)scaleToWidth:(int)width height:(int)height;
- (TGAColor)getColorAtX:(int)x y:(int)y;
- (BOOL)setColor:(TGAColor)color toX:(int)x y:(int)y;
- (int)getWidth;
- (int)getHeight;
- (int)getBytesPerPixel;
- (unsigned char *)getBuffer;
- (void)clear;

@end
