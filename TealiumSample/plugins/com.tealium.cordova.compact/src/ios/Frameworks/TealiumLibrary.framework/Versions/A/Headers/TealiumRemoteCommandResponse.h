//
//  TealiumRemoteCommandResponse.h
//  UICatalog_Full_Direct
//
//  Created by Jason Koo on 12/4/14.
//
//

#import <Foundation/Foundation.h>

@protocol TealiumRemoteCommandResponseDelegate;

@interface TealiumRemoteCommandResponse : NSObject

@property (nonatomic, weak)     id <TealiumRemoteCommandResponseDelegate> delegate;
@property (nonatomic, strong)   NSString        *body;
@property (nonatomic, strong)   NSString        *commandId;
@property (nonatomic, strong)   NSError         *error;
@property (nonatomic, strong)   NSString        *responseId;
@property (nonatomic, strong)   NSDictionary    *requestPayload;
@property (nonatomic)           NSInteger       status;

typedef void (^ TealiumRemoteResponseBlock)(TealiumRemoteCommandResponse *response);

- (instancetype) initWithURLString:(NSString*)urlString completionHandler:(TealiumRemoteResponseBlock)responseBlock;
- (void) send;

@end

@protocol TealiumRemoteCommandResponseDelegate <NSObject>

- (void) tealiumRemoteCommandResponseRequestsSend:(TealiumRemoteCommandResponse*)response;

@end