//
//  TGAColor.h
//  OpenGLClone
//
//  Created by Игорь Савельев on 24/01/2017.
//  Copyright © 2017 MusicSense. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGAColor : NSObject

@property (nonatomic, readonly) unsigned char r;
@property (nonatomic, readonly) unsigned char g;
@property (nonatomic, readonly) unsigned char b;
@property (nonatomic, readonly) unsigned char a;

@property (nonatomic, readonly) unsigned char raw[4];


@end
