//
//  Renderer.h
//  mtlstorage
//
//  Created by Bulcsu Andrasi on 2019. 12. 12..
//  Copyright © 2019. Bulcsu Andrasi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Renderer : NSObject <MTKViewDelegate>

@property (nonatomic, weak) IBOutlet MTKView* view;

@end

NS_ASSUME_NONNULL_END
