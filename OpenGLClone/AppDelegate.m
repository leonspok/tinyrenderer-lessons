//
//  AppDelegate.m
//  OpenGLClone
//
//  Created by Игорь Савельев on 24/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import "AppDelegate.h"
#import "TGAImage.h"
#import "WFModel.h"
#import "DrawingFunctions.h"
#import "HelpFunctions.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	TGAColor red = TGAColorCreateRGBA(255, 0, 0, 255);
	TGAColor white = TGAColorCreateRGBA(255, 255, 255, 255);
	
	int width = 2000;
	int height = 2000;
	int depth = 2000;
	
	WFModel *model = [WFModel new];
	
	LPTransform transform = LPTransformIdentity();
	transform.matrix[3][2] = -1/(10.0f);
	
	[model loadFromFile:@"/Users/igorsavelev/Desktop/african_head.obj"];
	[model applyTransform:transform];
	//[model loadFromFile:@"/Users/igorsavelev/Downloads/mini_obj.obj"];
	
	LPVector lightVector = (LPVector) {
		.dx = 0,
		.dy = 0,
		.dz = 1
	};
	
	TGAImage *image = [[TGAImage alloc] initWithWidth:width height:height bytesPerPixel:TGAImageFormatRGB];
	TGAImage *texture = [[TGAImage alloc] init];
	[texture readTGAFileAtPath:@"/Users/igorsavelev/Desktop/african_head_diffuse.tga"];
	[texture flipVertically];
	
	drawModel(model, texture, lightVector, width, height, depth, image);
	
	[image flipVertically];
	[image writeTGAFileToPath:@"/Users/igorsavelev/Desktop/output.tga" rle:YES];
	[[NSWorkspace sharedWorkspace] openFile:@"/Users/igorsavelev/Desktop/output.tga"];
	[NSApp terminate:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


@end
