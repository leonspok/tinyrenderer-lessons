//
//  TGAImage.m
//  OpenGLClone
//
//  Created by Игорь Савельев on 24/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import "TGAImage.h"

@implementation TGAImage

- (id)initWithWidth:(int)w height:(int)h bytesPerPixel:(int)bytesPerPixel {
	self = [self init];
	if (self) {
		self->bytespp = bytesPerPixel;
		self->width = w;
		self->height = h;
		unsigned long nbytes = w*h*bytesPerPixel;
		self->data = malloc(nbytes * sizeof(unsigned char));
		memset(self->data, 0, nbytes);
	}
	return self;
}

- (id)initWithTGAImage:(TGAImage *)image {
	self = [self initWithWidth:[image getWidth] height:[image getHeight] bytesPerPixel:[image getBytesPerPixel]];
	if (self) {
		unsigned long nbytes = self->width*self->height*self->bytespp;
		memcpy(self->data, image->data, nbytes);
	}
	return self;
}

- (void)dealloc {
	if (data != NULL) {
		free(data);
	}
}

#pragma mark Drawing

- (TGAColor)getColorAtX:(int)x y:(int)y {
	if (data == NULL || x < 0 || y < 0 || x >= self->width || y >= self->height) {
		return TGAColorCreate();
	}
	return TGAColorCreateWithComponents(self->data+(x+y*self->width)*self->bytespp, self->bytespp);
}

- (BOOL)setColor:(TGAColor)color toX:(int)x y:(int)y {
	if (data == NULL || x < 0 || y < 0 || x >= self->width || y >= self->height) {
		return NO;
	}
	memcpy(self->data+(x+y*self->width)*self->bytespp, color.raw, self->bytespp);
	return YES;
}

#pragma mark Transformations

- (BOOL)flipHorizontally {
	if (self->data == NULL) {
		return NO;
	}
	int half = self->width>>1;
	for (int i = 0; i < half; i++) {
		for (int j = 0; j < height; j++) {
			TGAColor c1 = [self getColorAtX:i y:j];
			TGAColor c2 = [self getColorAtX:(self->width-1-i) y:j];
			[self setColor:c2 toX:i y:j];
			[self setColor:c1 toX:(self->width-1-i) y:j];
		}
	}
	return YES;
}

- (BOOL)flipVertically {
	if (self->data == NULL) {
		return NO;
	}
	unsigned long bytesPerLine = self->width*self->bytespp;
	unsigned char *line = malloc(bytesPerLine*sizeof(unsigned char));
	int half = height>>1;
	for (int j = 0; j < half; j++) {
		unsigned long l1 = j*bytesPerLine;
		unsigned long l2 = (self->height-1-j)*bytesPerLine;
		memmove(line, self->data+l1, bytesPerLine);
		memmove(self->data+l1, self->data+l2, bytesPerLine);
		memmove(self->data+l2, line, bytesPerLine);
	}
	free(line);
	return YES;
}

- (BOOL)scaleToWidth:(int)w height:(int)h {
	if (w <= 0 || h <= 0 || self->data == NULL) {
		return NO;
	}
	unsigned char *tdata = malloc(w*h*self->bytespp);
	int nscanline = 0;
	int oscanline = 0;
	int erry = 0;
	unsigned long nlineBytes = w*self->bytespp;
	unsigned long olineBytes = h*self->bytespp;
	for (int j = 0; j < height; j++) {
		int errx = self->width - w;
		int nx = -self->bytespp;
		int ox = -self->bytespp;
		for (int i = 0; i < self->width; i++) {
			ox += self->bytespp;
			errx += w;
			while (errx >= (int)self->width) {
				errx -= self->width;
				nx += self->bytespp;
				memcpy(tdata+nscanline+nx, data+oscanline+ox, self->bytespp);
			}
		}
		erry += h;
		oscanline += olineBytes;
		while (erry >= (int)self->height) {
			if (erry >= (int)self->height<<1) {
				memcpy(tdata+nscanline+nlineBytes, tdata+nscanline, self->bytespp);
			}
			erry -= self->height;
			nscanline += nlineBytes;
		}
	}
	free(self->data);
	self->data = tdata;
	self->width = w;
	self->height = h;
	return YES;
}

#pragma mark Public Getters

- (int)getWidth {
	return self->width;
}

- (int)getHeight {
	return self->height;
}

- (int)getBytesPerPixel {
	return self->bytespp;
}

- (unsigned char *)getBuffer {
	return self->data;
}

@end
