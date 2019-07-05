//
//  RNZenDeskSupport.m
//
//  Created by Patrick O'Connor on 8/30/17.
//  Modified by Ryan Kuhn on 6/11/19
//

#if __has_include(<React/RCTBridge.h>)
#import <React/RCTConvert.h>
#else
#import "RCTConvert.h"
#endif

#import "RNZenDeskSupport.h"
#import <ZendeskSDK/ZendeskSDK.h>
#import <ZendeskCoreSDK/ZendeskCoreSDK.h>
#import <sys/utsname.h>

@implementation RNZenDeskSupport

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(initialize:(NSDictionary *)config){
    NSString *appId = [RCTConvert NSString:config[@"appId"]];
    NSString *zendeskUrl = [RCTConvert NSString:config[@"zendeskUrl"]];
    NSString *clientId = [RCTConvert NSString:config[@"clientId"]];
    [ZDKZendesk initializeWithAppId:appId clientId:clientId zendeskUrl:zendeskUrl];
    [ZDKSupport initializeWithZendesk:[ZDKZendesk instance]];
}

RCT_EXPORT_METHOD(setupIdentity:(NSDictionary *)identity){
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *email = [RCTConvert NSString:identity[@"customerEmail"]];
        NSString *name = [RCTConvert NSString:identity[@"customerName"]];
        
        id<ZDKObjCIdentity> zdIdentity = [[ZDKObjCAnonymous alloc] initWithName:name email:email];
        [[ZDKZendesk instance] setIdentity:zdIdentity];
        
    });
}

RCT_EXPORT_METHOD(showHelpCenterWithOptions:(NSDictionary *)options) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        
        UIViewController *vc = [window rootViewController];
        
        UIViewController *helpCenter = [ZDKHelpCenterUi buildHelpCenterOverviewUi];
        [vc presentViewController:helpCenter animated:YES completion:nil];
    });
}

RCT_EXPORT_METHOD(showCategoriesWithOptions:(NSArray *)categories options:(NSDictionary *)options) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        
        UIViewController *vc = [window rootViewController];
        
        ZDKHelpCenterOverviewContentModel *helpCenterContentModel = [ZDKHelpCenterOverviewContentModel defaultContent];
        helpCenterContentModel.groupType = ZDKHelpCenterOverviewGroupTypeCategory;
        helpCenterContentModel.groupIds = categories;
        helpCenterContentModel.hideContactSupport = [RCTConvert BOOL:options[@"hideContactSupport"]];
        ZDKHelpCenterUiConfiguration* helpCenterUiConfig = [ZDKHelpCenterUiConfiguration new];
        if (helpCenterContentModel.hideContactSupport) {
            [helpCenterUiConfig setHideContactSupport:YES];
        }
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        
        UIViewController *helpCenter = [ZDKHelpCenterUi buildHelpCenterOverviewUiWithConfigs:@[helpCenterUiConfig]];
        [vc.navigationController pushViewController:helpCenter animated:YES];
    });
}

RCT_EXPORT_METHOD(showSectionsWithOptions:(NSArray *)sections options:(NSDictionary *)options) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        
        UIViewController *vc = [window rootViewController];
        
        ZDKHelpCenterUiConfiguration * hcConfig = [ZDKHelpCenterUiConfiguration new];
        [hcConfig setGroupType:ZDKHelpCenterOverviewGroupTypeSection];
        [hcConfig setGroupIds:@[@115000600952, @115001289432]];
        
        UIViewController *helpCenter = [ZDKHelpCenterUi buildHelpCenterOverviewUiWithConfigs:@[hcConfig]];
        [vc presentViewController:helpCenter animated:YES completion:nil];
    });
}

RCT_EXPORT_METHOD(showSection:(NSString *)section) {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        
        UIViewController *vc = [window rootViewController];
        
        UIViewController *articleController = [ZDKHelpCenterUi buildHelpCenterArticleUiWithArticleId:section andConfigs:@[]];
        [vc presentViewController:articleController animated:YES completion:nil];
    });
}

RCT_EXPORT_METHOD(showLabelsWithOptions:(NSArray *)labels options:(NSDictionary *)options) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        UIViewController *vc = [window rootViewController];
        ZDKHelpCenterOverviewContentModel *helpCenterContentModel = [ZDKHelpCenterOverviewContentModel defaultContent];
        helpCenterContentModel.labels = labels;
        helpCenterContentModel.hideContactSupport = [RCTConvert BOOL:options[@"hideContactSupport"]];
        ZDKHelpCenterUiConfiguration* helpCenterUiConfig = [ZDKHelpCenterUiConfiguration new];
        if (helpCenterContentModel.hideContactSupport) {
            [helpCenterUiConfig setHideContactSupport:YES];
        }
        vc.modalPresentationStyle = UIModalPresentationFormSheet;
        
        UIViewController *helpCenter = [ZDKHelpCenterUi buildHelpCenterOverviewUiWithConfigs:@[helpCenterUiConfig]];
        [vc.navigationController pushViewController:helpCenter animated:YES];
    });
}

RCT_EXPORT_METHOD(showHelpCenter) {
    [self showHelpCenterWithOptions:nil];
}

RCT_EXPORT_METHOD(callSupport) {
    [self callSupportWithOptions:nil];
}

RCT_EXPORT_METHOD(showCategories:(NSArray *)categories) {
    [self showCategoriesWithOptions:categories options:nil];
}

RCT_EXPORT_METHOD(showSections:(NSArray *)sections) {
    [self showSectionsWithOptions:sections options:nil];
}

RCT_EXPORT_METHOD(showLabels:(NSArray *)labels) {
    [self showLabelsWithOptions:labels options:nil];
}

ZDKHelpCenterProvider * HCprovider;
ZDKRequestProvider * RequestProvider;

RCT_EXPORT_METHOD(createHCProvider) {
    HCprovider = [ZDKHelpCenterProvider new];
}

RCT_EXPORT_METHOD(createRequestProvider) {
    RequestProvider = [ZDKRequestProvider new];
}

RCT_EXPORT_METHOD(createRequest:(NSString *)text :(NSString *)subject :(RCTResponseSenderBlock)callback) {
    ZDKCreateRequest *ticket = [[ZDKCreateRequest alloc] init];
    [ticket setSubject:subject];
    [ticket setRequestDescription:text];
    NSArray *tags = [NSArray arrayWithObjects:@"mobile", deviceName(), @"iOS", nil];
    [ticket setTags:tags];
    
    [RequestProvider createRequest:ticket withCallback:^(id result, NSError *error) {
        callback(@[[NSNull null]]);
    }];
}

RCT_EXPORT_METHOD(getUsersTickets:(RCTResponseSenderBlock)callback) {
    [RequestProvider getAllRequestsWithCallback:^(ZDKRequestsWithCommentingAgents *requestsWithCommentingAgents, NSError *error) {
        NSMutableArray *tickets = [[NSMutableArray alloc] init];
        NSArray *requests = [requestsWithCommentingAgents requests];
        for (int i = 0; i < [requests count]; i++)
        {
            NSMutableArray *ticket = [[NSMutableArray alloc] init];
            ticket[0] = [[requests objectAtIndex:i] requestId];
            ticket[1] = [[requests objectAtIndex:i] subject];
            ticket[2] = [[[requests objectAtIndex:i] lastComment] body];
            ticket[3] = [[requests objectAtIndex:i] requesterId];
            NSNull *nullValue = [NSNull new];
            ticket[4] = nullValue;
            if([[[requests objectAtIndex:i] commentingAgentsIds] count] != 0) {
                ticket[4] = @"Team Suitable";
            }
            ticket[5] = dateToString([[requests objectAtIndex:i] createdAt]);
            tickets[i] = ticket;
        }
        callback(@[[NSNull null], tickets]);
    }];
}

RCT_EXPORT_METHOD(getTicketComments:(NSString *)id :(RCTResponseSenderBlock)callback) {
    [RequestProvider getCommentsWithRequestId:id withCallback:^(NSArray<ZDKCommentWithUser *> *commentsWithUsers, NSError *error) {
        NSMutableArray *comments = [[NSMutableArray alloc] init];
        NSInteger count = [commentsWithUsers count];
        for(int i = 0; i < count; i++) {
            NSMutableArray *comment = [[NSMutableArray alloc] init];
            ZDKCommentWithUser *commentInfo = [commentsWithUsers objectAtIndex:i];
            comment[0] = [[commentInfo comment] body];
            comment[1] = [[commentInfo user] userId];
            comments[i] = comment;
        }
        NSArray* orderedComments = [[comments reverseObjectEnumerator] allObjects];
        callback(@[[NSNull null], orderedComments]);
    }];
}

RCT_EXPORT_METHOD(addComment:(NSString *)id :(NSString *)comment :(RCTResponseSenderBlock)callback) {
    [RequestProvider addComment:comment forRequestId:id withCallback:^(ZDKComment *comment, NSError *error) {
        callback(@[[NSNull null]]);
    }];
}

RCT_EXPORT_METHOD(getArticle:(NSString *)article callback:(RCTResponseSenderBlock)callback) {
    [HCprovider getArticleWithId:article withCallback:^(NSArray *items, NSError *error) {
        NSString *title = [[items objectAtIndex:0] title];
        NSString *article_url = [[items objectAtIndex:0] htmlUrl];
        NSArray *articleData = [NSArray arrayWithObjects:title, article_url, nil];
        
        callback(@[[NSNull null], articleData]);
    }];
}

RCT_EXPORT_METHOD(getSection:(NSString *)section callback:(RCTResponseSenderBlock)callback) {
    [HCprovider getArticlesWithSectionId:section withCallback:^(NSArray *items, NSError *error) {
        NSMutableArray* returnArticles = [[NSMutableArray alloc] init];
        for (int i = 0; i < [items count]; i++)
        {
            NSMutableArray *section = [[NSMutableArray alloc] init];
            section[0] = [[items objectAtIndex:i] title];
            section[1] = [[items objectAtIndex:i] identifier];
            [returnArticles addObject: section];
        }
        NSArray *articleData = [returnArticles copy];
        callback(@[[NSNull null], articleData]);
    }];
}

RCT_EXPORT_METHOD(getCategory:(NSString *)category callback:(RCTResponseSenderBlock)callback) {
    [HCprovider getSectionsWithCategoryId:category withCallback:^(NSArray *items, NSError *error) {
        NSMutableArray* returnSections = [[NSMutableArray alloc] init];
        for (int i = 0; i < [items count]; i++)
        {
            NSMutableArray *section = [[NSMutableArray alloc] init];
            section[0] = [[items objectAtIndex:i] name];
            section[1] = [[items objectAtIndex:i] identifier];
            [returnSections addObject: section];
        }
        NSArray *sectionData = [returnSections copy];
        callback(@[[NSNull null], sectionData]);
    }];
}

RCT_EXPORT_METHOD(callSupportWithOptions:(NSDictionary *)customFields) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        UIViewController *vc = [window rootViewController];
        
        ZDKRequestUiConfiguration * requestConfig = [ZDKRequestUiConfiguration new];
        requestConfig.tags = [NSArray arrayWithObjects:@"mobile", deviceName(), @"iOS", nil];
        
        UIViewController *request = [ZDKRequestUi buildRequestUiWith:@[requestConfig]];
        [vc presentViewController:request animated:YES completion:nil];
    });
}

RCT_EXPORT_METHOD(supportHistory){
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        UIViewController *vc = [window rootViewController];
        
        ZDKRequestUiConfiguration * requestConfig = [ZDKRequestUiConfiguration new];
        requestConfig.tags = [NSArray arrayWithObjects:@"mobile", deviceName(), "iOS", nil];
        
        UIViewController *requestListController = [ZDKRequestUi buildRequestListWith:@[requestConfig]];
        [vc presentViewController:requestListController animated:YES completion:nil];
    });
}

NSString* deviceName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

NSString* dateToString(NSDate *date)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *result = [formatter stringFromDate:date];
    return result;
}

@end
