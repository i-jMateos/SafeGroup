#import <Foundation/Foundation.h>

#if TARGET_OS_IOS
    #import <UIKit/UIKit.h>
#endif


@class DLEdge;

DLEdge* DLMakeEdge(NSUInteger i, NSUInteger j);

@interface DLEdge : NSObject <NSCopying>

@property (nonatomic, assign, readonly) NSUInteger i;
@property (nonatomic, assign, readonly) NSUInteger j;

@property (nonatomic) CGFloat repulsion;
@property (nonatomic) CGFloat attraction;

@property (nonatomic) BOOL unknownConnection;
@property (nonatomic) BOOL immediateConnection;

+(instancetype)edgeWithI:(NSUInteger)i J:(NSUInteger)j;

@end
