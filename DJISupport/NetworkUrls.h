//
//  NetworkUrls.h
//  DJISupport
//
//  Created by Siyang Liu on 12/24/18.
//  Copyright © 2018 Siyang Liu. All rights reserved.
//

#ifndef NetworkUrls_h
#define NetworkUrls_h

//#define kSERVER_PREFIX @"http://128.206.20.143"
#define kSERVER_PREFIX @"http://ec2-18-219-42-111.us-east-2.compute.amazonaws.com/new_api"

#define kSAVE_GPS_INFO [kSERVER_PREFIX stringByAppendingPathComponent:@"/api/gps/upload"]

#endif /* NetworkUrls_h */
