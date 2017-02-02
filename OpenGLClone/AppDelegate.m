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
	int width = 2000;
	int height = 2000;
	int depth = 255;
	
	LPPoint eyePoint = (LPPoint) {.x = 1, .y = 1, .z = 3};
	LPPoint cameraTarget = (LPPoint) {.x = 0, .y = 0, .z = 0};
	LPVector lightVector = (LPVector) {
		.dx = 1,
		.dy = -1,
		.dz = 1
	};
	lightVector = LPVectorNormalize(lightVector);
	
	WFModel *model = [WFModel new];
	
	LPTransform cameraMove = createMoveCameraTransform(eyePoint, cameraTarget, (LPVector){ .dx = 0, .dy = 1, .dz = 0});
	LPTransform projection = LPTransformIdentity();
	projection.matrix[3][2] = -1/sqrt(pow(eyePoint.x-cameraTarget.x,2)+pow(eyePoint.y-cameraTarget.y,2)+pow(eyePoint.z-cameraTarget.z,2));
	
	LPTransform viewPort = LPTransformIdentity();
	viewPort = createViewPort((LPPoint){.x = width/8.0f,.y = height/8.0f, .z = 1}, width*0.75f, height*0.75f, depth);
	
	LPTransform transform = LPTransformMultiply(LPTransformMultiply(viewPort, projection), cameraMove);
	
	[model loadFromFile:@"/Users/igorsavelev/Xcode Projects/Others/OpenGLClone/obj/african_head.obj"];
	
	TGAImage *image = [[TGAImage alloc] initWithWidth:width height:height bytesPerPixel:TGAImageFormatRGB];
	TGAImage *texture = [[TGAImage alloc] init];
	[texture readTGAFileAtPath:@"/Users/igorsavelev/Xcode Projects/Others/OpenGLClone/obj/african_head_diffuse.tga"];
	[texture flipVertically];
	model.diffuseTexture = texture;
	
	CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
	drawModel(model, transform, lightVector, width, height, depth, image);
	NSLog(@"%f", CFAbsoluteTimeGetCurrent()-time);
	
	[image flipVertically];
	[image writeTGAFileToPath:@"/Users/igorsavelev/Desktop/output.tga" rle:YES];
	[[NSWorkspace sharedWorkspace] openFile:@"/Users/igorsavelev/Desktop/output.tga"];
	[NSApp terminate:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


@end
