//
//  AGPointManager.m
//  AirGif
//
//  Created by Zane Claes on 5/17/14.
//  Copyright (c) 2014 inZania. All rights reserved.
//

#import "AGPointManager.h"
#import "AGAnalytics.h"
#import "AGSettings.h"
#import <StoreKit/StoreKit.h>

static NSString * const kKeyPoints = @"points";

@interface AGPointManager () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (nonatomic, strong) NSMutableDictionary *products;
@property (nonatomic, strong) SKProductsRequest *productsRequest;
@end

@implementation AGPointManager

/************************************************************************************************
 * Credits
 ************************************************************************************************/
- (NSInteger)points {
  return [[NSUserDefaults standardUserDefaults] integerForKey:kKeyPoints];
}

- (void)earn:(NSInteger)amount reason:(NSString*)reason {
  [[NSUserDefaults standardUserDefaults] setObject:@(self.points + amount) forKey:kKeyPoints];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [AGAnalytics trackTransaction:@"earn" label:reason value:@(amount)];
}

- (BOOL)spend:(NSInteger)amount reason:(NSString*)reason {
  if(self.points < amount) {
    return NO;
  }
  [[NSUserDefaults standardUserDefaults] setObject:@(self.points - amount) forKey:kKeyPoints];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [AGAnalytics trackTransaction:@"spend" label:reason value:@(-amount)];
  return YES;
}

- (BOOL)hasProducts {
  return self.products.allKeys.count > 0;
}

/************************************************************************************************
 * Store Purchase
 ************************************************************************************************/

- (void)_applyPoints:(SKPaymentTransaction*)transaction {
  NSInteger dollars = [[[transaction.payment.productIdentifier componentsSeparatedByString:@"."] lastObject] integerValue];
  NSInteger points = [AGSettings sharedSettings].pointsPerUSD * dollars;
  [self earn:points reason:@"iap"];
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
  [[NSNotificationCenter defaultCenter] postNotificationName:kPurchaseCompleteNotification object:@(points) userInfo:nil];
}

- (void)failedTransaction:(SKPaymentTransaction*)transaction {
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

// Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate.
- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
  for (SKPaymentTransaction * transaction in transactions) {
    switch (transaction.transactionState)
    {
      case SKPaymentTransactionStatePurchased:
        [self _applyPoints:transaction];
        break;
      case SKPaymentTransactionStateFailed:
        [self failedTransaction:transaction];
        break;
      case SKPaymentTransactionStateRestored:
      default:
        break;
    }
  }
}

// Sent when transactions are removed from the queue (via finishTransaction:).
- (void) paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
  NSLog(@"REMOVED: %@",transactions);
}

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
  NSLog(@"ERROR: %@",error);
  
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
  NSLog(@"RESTORE FINISHED");
  
}

// Sent when the download state has changed.
- (void) paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads {
  
}

- (void)purchase {
  SKPayment * payment = [SKPayment paymentWithProduct:[[self.products allValues] firstObject]];
  [[SKPaymentQueue defaultQueue] addPayment:payment];
}
/************************************************************************************************
 * Load Products
 ************************************************************************************************/

- (void)loadProducts {
#if TARGET_IPHONE_SIMULATOR
#else
  NSArray *ids = [AGSettings sharedSettings].products;
  self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:ids]];
  self.productsRequest.delegate = self;
  [self.productsRequest start];
#endif
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
  self.productsRequest = nil;
  self.products = [NSMutableDictionary new];
  for(SKProduct *product in response.products) {
    self.products[product.productIdentifier] = product;
  }
  DLog(@"Products: %@",self.products.allKeys);
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
  self.productsRequest = nil;
}

/************************************************************************************************
 * Main
 ************************************************************************************************/


- (id)init {
  if((self = [super init])) {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [self loadProducts];
  }
  return self;
}

+ (AGPointManager*)sharedManager {
  static AGPointManager *_point_manager = nil;
  static dispatch_once_t onceToken = 0;
  dispatch_once(&onceToken, ^{
    _point_manager = [[AGPointManager alloc] init];
  });
  return _point_manager;
}

@end
