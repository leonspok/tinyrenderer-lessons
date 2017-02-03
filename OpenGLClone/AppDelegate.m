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
#import "GouraudShader.h"
#import "TextureShader.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	int width = 800;
	int height = 800;
	int depth = 255;
	
	LPPoint eyePoint = (LPPoint) {.x = 1, .y = 1, .z = 3};
	LPPoint cameraTarget = (LPPoint) {.x = 0, .y = 0, .z = 0};
	LPVector lightVector = (LPVector) {
		.dx = 1,
		.dy = 1,
		.dz = 1
	};
	lightVector = LPVectorNormalize(lightVector);
	LPVector up = (LPVector){ .dx = 0, .dy = 1, .dz = 0};

	LPTransform cameraMove = createMoveCameraTransform(eyePoint, cameraTarget, up);
	LPTransform projection = LPTransformIdentity();
	projection.matrix[3][2] = -1/sqrt(pow(eyePoint.x-cameraTarget.x,2)+pow(eyePoint.y-cameraTarget.y,2)+pow(eyePoint.z-cameraTarget.z,2));
	
	LPTransform viewPort = LPTransformIdentity();
	viewPort = createViewPort((LPPoint){.x = width/8.0f,.y = height/8.0f, .z = 1}, width*0.75f, height*0.75f, depth);
	
	CFAbsoluteTime time;
	TGAImage *image = [[TGAImage alloc] initWithWidth:width height:height bytesPerPixel:TGAImageFormatRGB];
	ZBuffer *zBuffer = [[ZBuffer alloc] initWithWidth:width height:height];
	
	WFModel *floorModel = [WFModel new];
	[floorModel loadFromFile:@"/Users/igorsavelev/Downloads/tinyrenderer-e30ff353121460557e29dced5708652171dbc7d2/obj/floor.obj"];
	floorModel.diffuseTexture = [TGAImage new];
	[floorModel.diffuseTexture readTGAFileAtPath:@"/Users/igorsavelev/Downloads/tinyrenderer-e30ff353121460557e29dced5708652171dbc7d2/obj/floor_diffuse.tga"];
	[floorModel.diffuseTexture flipVertically];
	floorModel.normalMap = [TGAImage new];
	[floorModel.normalMap readTGAFileAtPath:@"/Users/igorsavelev/Downloads/tinyrenderer-e30ff353121460557e29dced5708652171dbc7d2/obj/floor_nm_tangent.tga"];
	[floorModel.normalMap flipVertically];
	
	id<Shader> floorShader = [[TextureShader alloc] initWithModel:floorModel projection:projection viewPort:viewPort modelView:cameraMove lightDirection:lightVector];
	
	time = CFAbsoluteTimeGetCurrent();
	drawModel(floorModel, floorShader, zBuffer, image);
	NSLog(@"%f", CFAbsoluteTimeGetCurrent()-time);
	
	
	WFModel *eyeOuterModel = [WFModel new];
	[eyeOuterModel loadFromFile:@"/Users/igorsavelev/Xcode Projects/Others/OpenGLClone/obj/african_head/african_head_eye_outer.obj"];
	eyeOuterModel.diffuseTexture = [TGAImage new];
	[eyeOuterModel.diffuseTexture readTGAFileAtPath:@"/Users/igorsavelev/Xcode Projects/Others/OpenGLClone/obj/african_head/african_head_eye_outer_diffuse.tga"];
	[eyeOuterModel.diffuseTexture flipVertically];
	eyeOuterModel.normalMap = [TGAImage new];
	[eyeOuterModel.normalMap readTGAFileAtPath:@"/Users/igorsavelev/Xcode Projects/Others/OpenGLClone/obj/african_head/african_head_eye_outer_nm.tga"];
	[eyeOuterModel.normalMap flipVertically];
	
	id<Shader> eyeOuterTextureShader = [[TextureShader alloc] initWithModel:eyeOuterModel projection:projection viewPort:viewPort modelView:cameraMove lightDirection:lightVector];
	
	time = CFAbsoluteTimeGetCurrent();
	//drawModel(eyeOuterModel, eyeOuterTextureShader, zBuffer, image);
	NSLog(@"%f", CFAbsoluteTimeGetCurrent()-time);
	
	
	
	WFModel *eyeInnerModel = [WFModel new];
	[eyeInnerModel loadFromFile:@"/Users/igorsavelev/Xcode Projects/Others/OpenGLClone/obj/african_head/african_head_eye_inner.obj"];
	eyeInnerModel.diffuseTexture = [TGAImage new];
	[eyeInnerModel.diffuseTexture readTGAFileAtPath:@"/Users/igorsavelev/Xcode Projects/Others/OpenGLClone/obj/african_head/african_head_eye_inner_diffuse.tga"];
	[eyeInnerModel.diffuseTexture flipVertically];
	eyeInnerModel.normalMap = [TGAImage new];
	[eyeInnerModel.normalMap readTGAFileAtPath:@"/Users/igorsavelev/Xcode Projects/Others/OpenGLClone/obj/african_head/african_head_eye_inner_nm.tga"];
	[eyeInnerModel.normalMap flipVertically];
	
	id<Shader> eyeInnerTextureShader = [[TextureShader alloc] initWithModel:eyeInnerModel projection:projection viewPort:viewPort modelView:cameraMove lightDirection:lightVector];
	
	time = CFAbsoluteTimeGetCurrent();
	drawModel(eyeInnerModel, eyeInnerTextureShader, zBuffer, image);
	NSLog(@"%f", CFAbsoluteTimeGetCurrent()-time);
	
	
	
	WFModel *headModel = [WFModel new];
	[headModel loadFromFile:@"/Users/igorsavelev/Xcode Projects/Others/OpenGLClone/obj/african_head/african_head.obj"];
	TGAImage *headTexture = [[TGAImage alloc] init];
	[headTexture readTGAFileAtPath:@"/Users/igorsavelev/Xcode Projects/Others/OpenGLClone/obj/african_head/african_head_diffuse.tga"];
	[headTexture flipVertically];
	headModel.diffuseTexture = headTexture;
	TGAImage *headNormalMap = [[TGAImage alloc] init];
	[headNormalMap readTGAFileAtPath:@"/Users/igorsavelev/Xcode Projects/Others/OpenGLClone/obj/african_head/african_head_nm.tga"];
	[headNormalMap flipVertically];
	headModel.normalMap = headNormalMap;
	
	//id<Shader> shader = [[GouraudShader alloc] initWithModel:model transform:transform lightDirection:lightVector];
	id<Shader> headTextureShader = [[TextureShader alloc] initWithModel:headModel projection:projection viewPort:viewPort modelView:cameraMove lightDirection:lightVector];
	
	time = CFAbsoluteTimeGetCurrent();
	drawModel(headModel, headTextureShader, zBuffer, image);
	NSLog(@"%f", CFAbsoluteTimeGetCurrent()-time);
	
	
	LPTransform tr = LPTransformMultiply(viewPort, LPTransformMultiply(projection, cameraMove));
	LPPoint p = {.x = 0, .y = 0.5, .z = 0.5};
	LPPoint p1 = { .x = p.x+lightVector.dx, .y = p.y+lightVector.dy, .z = p.z+lightVector.dz};
	p = LPPointApplyTransform(p, tr);
	p1 = LPPointApplyTransform(p1, tr);
	drawLine(p, p1, image, TGAColorCreateRGBA(255, 255, 255, 255));
	[image setColor:TGAColorCreateRGBA(255, 0, 0, 255) toX:p1.x y:p1.y];
	
	
	[image flipVertically];
	[image writeTGAFileToPath:@"/Users/igorsavelev/Desktop/output.tga" rle:YES];
	[[NSWorkspace sharedWorkspace] openFile:@"/Users/igorsavelev/Desktop/output.tga"];
	[NSApp terminate:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}


@end
