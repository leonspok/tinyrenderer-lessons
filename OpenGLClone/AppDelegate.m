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

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSImageView *imageView;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	TGAColor red = TGAColorCreateRGBA(255, 0, 0, 255);
	TGAColor white = TGAColorCreateRGBA(255, 255, 255, 255);
	
	int width = 500;
	int height = 500;
	int depth = 500;
	
	WFModel *model = [WFModel new];
	//[model loadFromFile:@"/Users/igorsavelev/Desktop/african_head.obj"];
	[model loadFromFile:@"/Users/igorsavelev/Downloads/mini_obj.obj"];
	
	LPVector lightVector = (LPVector) {
		.dx = 0,
		.dy = 0,
		.dz = 1
	};
	
	TGAImage *image = [[TGAImage alloc] initWithWidth:width height:height bytesPerPixel:TGAImageFormatRGB];
	
	for (int i = 1; i <= model.fCount; i++) {
		WFFaceElement *fePointer = [model faceElementForIndex:i];
		if (fePointer == NULL) {
			NSLog(@"No face element for index %d", i);
			continue;
		}
		WFFaceElement faceElement = *fePointer;
		LPTriangle tr;
		for (int j = 0; j < 3; j++) {
			WFVertex *vPointer = [model vertexForIndex:faceElement.parts[j].vertexIx];
			if (vPointer == NULL) {
				NSLog(@"No vertex for index %ld", (long)faceElement.parts[j].vertexIx);
				continue;
			}
			tr.vertices[j] = *vPointer;
			
			SWAP(tr.vertices[j].z, tr.vertices[j].x);
			
//			tr.vertices[j].x = (tr.vertices[j].x+1.0f)*width/2.0f;
//			tr.vertices[j].y = (tr.vertices[j].y+1.0f)*height/2.0f;
//			tr.vertices[j].z = (tr.vertices[j].z+1.0f)*depth/2.0f;
			tr.vertices[j].x = (tr.vertices[j].x+250.0f);
			tr.vertices[j].y = (tr.vertices[j].y+250.0f);
			tr.vertices[j].z = (tr.vertices[j].z+100.0f);
		}
		
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
		
		float intensity = LPVectorDotProduct(normal, lightVector);
		if (intensity <= 0) {
			continue;
		}
		uint8_t grayValue = (uint8_t)roundf(intensity*255);
		triangle(tr, image, TGAColorCreateRGBA(grayValue, grayValue, grayValue, 255));
	}
	
	[image flipVertically];
	[image writeTGAFileToPath:@"/Users/igorsavelev/Desktop/output.tga" rle:YES];
	[self.imageView setImage:[[NSImage alloc] initWithContentsOfFile:@"/Users/igorsavelev/Desktop/output.tga"]];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


@end
