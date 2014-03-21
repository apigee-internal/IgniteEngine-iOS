//
//  IXConstants.h
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/9/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IX_dispatch_main_sync_safe(block)\
    if ([NSThread isMainThread])\
    {\
        block();\
    }\
    else\
    {\
        dispatch_sync(dispatch_get_main_queue(), block);\
    }

// SPECIAL
extern NSString* const kIX_CONTROL_CLASS_NAME_FORMAT;
extern NSString* const kIX_DATA_PROVIDER_CLASS_NAME_FORMAT;
extern NSString* const kIX_ACTION_CLASS_NAME_FORMAT;
extern NSString* const kIX_SHORTCODE_CLASS_NAME_FORMAT;
extern NSString* const kIX_DUMMY_DATA_MODEL_ENTITY_NAME;
extern NSString* const kIX_DEBUG;
extern NSString* const kIX_RELEASE;

extern NSString* const kIX_ID;
extern NSString* const kIX_APP;
extern NSString* const kIX_STYLE;
extern NSString* const kIX_TARGET;
extern NSString* const kIX_TYPE;
extern NSString* const kIX_SESSION;
extern NSString* const kIX_VIEW;
extern NSString* const kIX_CONTROLS;
extern NSString* const kIX_ACTIONS;
extern NSString* const kIX_ATTRIBUTES;
extern NSString* const kIX_DATA_PROVIDERS;
extern NSString* const kIX_VALUE;
extern NSString* const kIX_ORIENTATION;
extern NSString* const kIX_IF;
extern NSString* const kIX_ENABLED;
extern NSString* const kIX_ON;
extern NSString* const kIX_DELAY;
extern NSString* const kIX_REPEAT_DELAY;
extern NSString* const kIX_TRUE;
extern NSString* const kIX_FALSE;
extern NSString* const kIX_EMPTY_STRING;
extern NSString* const kIX_COMMA_SEPERATOR;
extern NSString* const kIX_PERIOD_SEPERATOR;
extern NSString* const kIX_COLON_SEPERATOR;
extern NSString* const kIX_EVAL_BRACKETS;

// GLOBAL EVENT NAMES
extern NSString* const kIX_ERROR;
extern NSString* const kIX_FAILED;
extern NSString* const kIX_FINISHED;
extern NSString* const kIX_SUCCESS;

// DATA PROVIDER SPECIFIC NODES
extern NSString* const kIX_DP_PARAMETERS;
extern NSString* const kIX_DP_HEADERS;
extern NSString* const kIX_DP_ATTACHMENTS;
extern NSString* const kIX_DP_ENTITY;

// ACTION TYPES
extern NSString* const kIX_ALERT;
extern NSString* const kIX_MODIFY;
extern NSString* const kIX_REFRESH;
extern NSString* const kIX_LOAD;
extern NSString* const kIX_SET;
extern NSString* const kIX_FUNCTION;

// RANDOMS
extern NSString* const kIX_ANIMATED;
extern NSString* const kIX_TITLE;
extern NSString* const kIX_SUB_TITLE;
extern NSString* const kIX_OK;
extern NSString* const kIX_CANCEL;
extern NSString* const kIX_TOUCH;
extern NSString* const kIX_GIF_EXTENSION;
extern NSString* const kIX_DEFAULT;

