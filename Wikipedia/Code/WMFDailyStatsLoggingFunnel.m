#import "WMFDailyStatsLoggingFunnel.h"
#import "Wikipedia-Swift.h"
#import "NSDate+Utilities.h"

static NSString *const kAppInstallAgeKey = @"appInstallAgeDays";
static NSString *const kAppInstallIdKey = @"appInstallID";

@implementation WMFDailyStatsLoggingFunnel

- (instancetype)init {
    // https://meta.wikimedia.org/wiki/Schema:MobileWikiAppDailyStats
    self = [super initWithSchema:@"MobileWikiAppDailyStats" version:12637385];
    if (self) {
        self.appInstallId = [self persistentUUID:@"WMFDailyStatsLoggingFunnel"];
    }
    return self;
}

- (BOOL)shouldLogInstallDays {
    NSDate *date = [[NSUserDefaults wmf_userDefaults] wmf_dateLastDailyLoggingStatsSent];
    if (date == nil) {
        return YES;
    } else if ([[NSCalendar currentCalendar] isDateInToday:date]) {
        return NO;
    } else {
        return YES;
    }
}

- (void)logAppNumberOfDaysSinceInstall {
    if (![self shouldLogInstallDays]) {
        return;
    }

    NSDate *installDate = [[NSUserDefaults wmf_userDefaults] wmf_appInstallDate];
    NSParameterAssert(installDate);
    if (!installDate) {
        return;
    }

    NSDate *currentDate = [NSDate date];
    NSInteger days = [installDate distanceInDaysToDate:currentDate];
    [self log:@{ kAppInstallAgeKey: @(days) }];
    [[NSUserDefaults wmf_userDefaults] wmf_setDateLastDailyLoggingStatsSent:currentDate];
}

- (NSDictionary *)preprocessData:(NSDictionary *)eventData {
    if (!eventData) {
        return nil;
    }
    NSMutableDictionary *dict = [eventData mutableCopy];
    dict[kAppInstallIdKey] = self.appInstallId;
    return [dict copy];
}

@end
