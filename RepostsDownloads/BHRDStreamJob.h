#import <Foundation/Foundation.h>
@class MediaInformation;
@interface BHRDStreamJob : NSObject
+ (instancetype)probeURL:(NSURL *)url completion:(void (^)(MediaInformation *info, NSError *error))completion;
+ (void)downloadURL:(NSURL *)url resolution:(NSString *)resolution;
- (void)cancel;
@end
