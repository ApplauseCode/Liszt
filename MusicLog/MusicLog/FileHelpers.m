//
//  FileHelpers.m
//  InstrumentLog
//
//  Created by Kyle Rosenbluth on 8/19/11.
//  Copyright 2011 __Applause Code__. All rights reserved.
//

#import "FileHelpers.h"

NSString *pathInDocumentDirectory(NSString *filename)
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:filename];
}
