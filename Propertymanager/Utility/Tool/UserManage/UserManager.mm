//
//  UserManager.m
//  PropertyManage
//
//  Created by Momo on 16/6/15.
//  Copyright © 2016年 Momo. All rights reserved.
//
#import "UserManager.h"

@implementation UserManager

+(UserManager *)manager {
    static UserManager * _manager;
    if (_manager == nil) {
        _manager = [[UserManager alloc]init];
    }
    
    return _manager;
}

+(void) cancelManage{
  
    [UserManager manager].department_id = nil;
    [UserManager manager].worker_name = nil;
    [UserManager manager].department_name = nil;
    [UserManager manager].username = nil;
    [UserManager manager].token = nil;
    [UserManager manager].worker_id = nil;
    [UserManager manager].power_type = nil;
    [UserManager manager].user_sip = nil;
    [UserManager manager].user_password = nil;
    [UserManager manager].register_yet = NULL;
    [UserManager manager].sip_host_addr = nil;
    [UserManager manager].sip_host_port = nil;
    [UserManager manager].registrationTimeout = nil;
    [UserManager manager].transport = nil;
    [UserManager manager].token_timeout = NULL;

}



+ (instancetype)userManagerWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}



- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        
        if (![PMTools isNullOrEmpty:dict[@"department_id"]]) {
            self.department_id = dict[@"department_id"];
        }
        else{
            self.department_id = @"";
        }
        
        if (![PMTools isNullOrEmpty:dict[@"worker_name"]]) {
            self.worker_name = dict[@"worker_name"];
        }
        else{
            self.worker_name = @"";
        }
        
        if (![PMTools isNullOrEmpty:dict[@"department_name"]]) {
            self.department_name = dict[@"department_name"];
        }
        else{
            self.department_name = @"";
        }
        
        if (![PMTools isNullOrEmpty:dict[@"username"]]) {
            self.username = dict[@"username"];
        }
        else{
            self.username = @"";
        }
        
        if (![PMTools isNullOrEmpty:dict[@"token"]]) {
            self.token = dict[@"token"];
        }
        else{
            self.token = @"";
        }
        
        if (![PMTools isNullOrEmpty:dict[@"worker_id"]]) {
            self.worker_id = dict[@"worker_id"];
        }
        else{
            self.worker_id = @"";
        }
        
        if (![PMTools isNullOrEmpty:dict[@"power_type"]]) {
            self.power_type = dict[@"power_type"];
        }
        else{
            self.power_type = @"";
        }
        
        if (![PMTools isNullOrEmpty:dict[@"user_sip"]]) {
            self.user_sip = dict[@"user_sip"];
        }
        else{
            self.user_sip = @"";
        }
        
        if (![PMTools isNullOrEmpty:dict[@"user_password"]]) {
            self.user_password = dict[@"user_password"];
        }
        else{
            self.user_password = @"";
        }
        
        if (![PMTools isNullOrEmpty:dict[@"register_yet"]]) {
            self.register_yet = [dict[@"register_yet"] boolValue];
        }
        else{
            self.register_yet = NO;
        }
        
        
        if (![PMTools isNullOrEmpty:dict[@"sip_host_addr"]]) {
            self.sip_host_addr = dict[@"sip_host_addr"];
        }
        else{
            self.sip_host_addr = @"";
        }
        if (![PMTools isNullOrEmpty:dict[@"sip_host_port"]]) {
            self.sip_host_port = dict[@"sip_host_port"];
        }
        else{
            self.sip_host_port = @"";
        }
        if (![PMTools isNullOrEmpty:dict[@"registrationTimeout"]]) {
            self.registrationTimeout = dict[@"registrationTimeout"];
        }
        else{
            self.registrationTimeout = @"";
        }
        if (![PMTools isNullOrEmpty:dict[@"transport"]]) {
            self.transport = dict[@"transport"];
        }
        else{
            self.transport = @"";
        }
        
        if (![PMTools isNullOrEmpty:dict[@"token_timeout"]]) {
            NSNumber * timeout = dict[@"token_timeout"];
            self.token_timeout = [timeout integerValue];
        }
        else{
            self.token_timeout = 0;
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{

    
    [encoder encodeObject:self.department_id forKey:@"department_id"];
    [encoder encodeObject:self.worker_name forKey:@"worker_name"];
    [encoder encodeObject:self.department_name forKey:@"department_name"];
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.token forKey:@"token"];
    [encoder encodeObject:self.worker_id forKey:@"worker_id"];
    [encoder encodeObject:self.power_type forKey:@"power_type"];
    [encoder encodeObject:self.user_sip forKey:@"user_sip"];
    [encoder encodeObject:self.user_password forKey:@"user_password"];
    [encoder encodeBool:self.register_yet forKey:@"register_yet"];
    
    [encoder encodeObject:self.sip_host_addr forKey:@"sip_host_addr"];
    [encoder encodeObject:self.sip_host_port forKey:@"sip_host_port"];
    [encoder encodeObject:self.registrationTimeout forKey:@"registrationTimeout"];
    [encoder encodeObject:self.transport forKey:@"transport"];
    
    [encoder encodeInteger:self.token_timeout forKey:@"token_timeout"];
    
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        
        self.department_id = [decoder decodeObjectForKey:@"department_id"];
        self.worker_name = [decoder decodeObjectForKey:@"worker_name"];
        self.department_name = [decoder decodeObjectForKey:@"department_name"];
        self.username = [decoder decodeObjectForKey:@"username"];
        self.token = [decoder decodeObjectForKey:@"token"];
        self.worker_id = [decoder decodeObjectForKey:@"worker_id"];
        self.power_type = [decoder decodeObjectForKey:@"power_type"];
        self.user_sip = [decoder decodeObjectForKey:@"user_sip"];
        self.user_password = [decoder decodeObjectForKey:@"user_password"];
        self.register_yet = [decoder decodeBoolForKey:@"register_yet"];
        
        self.sip_host_addr = [decoder decodeObjectForKey:@"sip_host_addr"];
        self.sip_host_port = [decoder decodeObjectForKey:@"sip_host_port"];
        self.registrationTimeout = [decoder decodeObjectForKey:@"registrationTimeout"];
        self.transport = [decoder decodeObjectForKey:@"transport"];
        
        self.token_timeout = [decoder decodeIntegerForKey:@"token_timeout"];
    }
    
    return self;
}

@end
