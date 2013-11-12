//
//  TMEngine.m
//  Teemo
//
//  Created by Wu Kevin on 11/5/13.
//  Copyright (c) 2013 xbcx. All rights reserved.
//

#import "TMEngine.h"

#include <iostream>

#include <gloox/client.h>
#include <gloox/messagehandler.h>
#include <gloox/message.h>
#include <gloox/connectiontcpclient.h>

#import "TMCommon.h"



//#import "TMMessageHandler.h"
//#import "TMMessageSessionHandler.h"
//
//#import "TMStatisticsHandler.h"
//
//#import "TMSubscriptionHandler.h"

using namespace std;
using namespace gloox;


static TMEngine *CurrentEngine = nil;


@implementation TMEngine

+ (TMEngine *)sharedEngine
{
  return CurrentEngine;
}

+ (void)storeEngine:(TMEngine *)engine
{
  CurrentEngine = engine;
}

+ (void)clearStoredEngine
{
  CurrentEngine = nil;
}



- (void)setUpWithUID:(NSString *)uid password:(NSString *)password
{
  NSAssert([uid length]>0, @"uid error");
  
  _cancelled = NO;
  
  string jid = string( [TMJIDFromUID(uid) UTF8String] );
  string pwd = string( [password UTF8String] );
  string svr = string( [TMXMPPServerHost UTF8String] );
  int prt = [TMXMPPServerPort intValue];
  
  _client = new Client( JID( jid ), pwd );
  _client->setServer( svr );
  _client->setPort( prt );
  
  _vcardManager = new VCardManager( _client );
  
  
  _connectionHandler = new TMConnectionHandler;
  _client->registerConnectionListener( _connectionHandler );
  
  _presenceHandler = new TMPresenceHandler;
  _client->registerPresenceHandler( _presenceHandler );
  
  _rosterHandler = new TMRosterHandler;
  _client->rosterManager()->registerRosterListener( _rosterHandler );
  
  
  
//  TMMessageSessionHandler *messageSessionHandler = new TMMessageSessionHandler;
//  _client->registerMessageSessionHandler( messageSessionHandler );
//  
//  
//  TMStatisticsHandler *statisticsHandler = new TMStatisticsHandler;
//  _client->registerStatisticsHandler( statisticsHandler );
//  
//  TMSubscriptionHandler *subscriptionHandler = new TMSubscriptionHandler;
//  _client->registerSubscriptionHandler( subscriptionHandler );
  
  
  
  
}

- (BOOL)connect
{
  if ( _cancelled ) {
    return NO;
  }
  
  if ( ! (_client->connect( false )) ) {
    return NO;
  }
  
  [self performSelector:@selector(monitorClient:)
               onThread:[[self class] engineThread]
             withObject:[NSValue valueWithPointer:_client]
          waitUntilDone:NO
                  modes:@[ NSRunLoopCommonModes ]];
  
  
  return YES;
}

- (void)disconnect
{
  _cancelled = YES;
  
  _client = NULL;
  
}



- (Client *)client
{
  return _client;
}

- (VCardManager *)vcardManager
{
  return _vcardManager;
}


- (TMConnectionHandler *)connectionHandler
{
  return _connectionHandler;
}

- (TMPresenceHandler *)presenceHandler
{
  return _presenceHandler;
}

- (TMVCardHandler *)vcardHandler
{
  return _vcardHandler;
}

- (RosterManager *)rosterManager
{
  return _client->rosterManager();
}




- (void)monitorClient:(NSValue *)value
{
  @autoreleasepool {
    
    Client *client = (Client *)[value pointerValue];
    
    while ( !_cancelled ) {
      client->recv( 1000000 );
    }
    
    client->disconnect();
    
  }
}



+ (NSThread *)engineThread
{
  static NSThread *thread = nil;
  
  static dispatch_once_t token;
  dispatch_once(&token, ^{
    thread = [[NSThread alloc] initWithTarget:self
                                     selector:@selector(threadBody:)
                                       object:nil];
    [thread start];
  });
  
  return thread;
}

+ (void)threadBody:(id)object
{
  while ( YES ) {
    @autoreleasepool {
      [[NSRunLoop currentRunLoop] run];
    }
  }
}

@end
