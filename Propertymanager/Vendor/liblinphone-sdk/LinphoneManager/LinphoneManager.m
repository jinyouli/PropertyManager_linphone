
/* LinphoneManager.h
 *
 * Copyright (C) 2011  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <sys/sysctl.h>

#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreTelephony/CTCallCenter.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "LinphoneManager.h"

#include "linphone/linphonecore_utils.h"
#include "linphone/lpconfig.h"
#include "mediastreamer2/mscommon.h"

#import <VideoToolbox/VideoToolbox.h>

#define LINPHONE_LOGS_MAX_ENTRY 5000

static void audioRouteChangeListenerCallback (
                                              void                   *inUserData,                                 // 1
                                              AudioSessionPropertyID inPropertyID,                                // 2
                                              UInt32                 inPropertyValueSize,                         // 3
                                              const void             *inPropertyValue                             // 4
);
static LinphoneCore* theLinphoneCore = nil;
static LinphoneManager* theLinphoneManager = nil;

const char *const LINPHONERC_APPLICATION_KEY = "app";

//NSString *const kSYLinphoneCoreUpdate = @"SYLinphoneCoreUpdate";
NSString *const kLinphoneDisplayStatusUpdate = @"LinphoneDisplayStatusUpdate";
NSString *const kLinphoneTextReceived = @"LinphoneTextReceived";
NSString *const kLinphoneTextComposeEvent = @"LinphoneTextComposeStarted";
//NSString *const kSYLinphoneCallUpdate = @"SYLinphoneCallUpdate";
//NSString *const kSYLinphoneRegistrationUpdate = @"SYLinphoneRegistrationUpdate";
NSString *const kLinphoneAddressBookUpdate = @"LinphoneAddressBookUpdate";
NSString *const kLinphoneMainViewChange = @"LinphoneMainViewChange";
NSString *const kLinphoneLogsUpdate = @"LinphoneLogsUpdate";
NSString *const kLinphoneSettingsUpdate = @"LinphoneSettingsUpdate";
NSString *const kLinphoneBluetoothAvailabilityUpdate = @"LinphoneBluetoothAvailabilityUpdate";
NSString *const kLinphoneConfiguringStateUpdate = @"LinphoneConfiguringStateUpdate";
NSString *const kLinphoneGlobalStateUpdate = @"LinphoneGlobalStateUpdate";
NSString *const kLinphoneNotifyReceived = @"LinphoneNotifyReceived";
NSString *const kLinphoneMessageReceived = @"LinphoneMessageReceived";

const int kLinphoneAudioVbrCodecDefaultBitrate=36; /*you can override this from linphonerc or linphonerc-factory*/

//extern void libmsilbc_init(void);
extern void libmsamr_init(void);
extern void libmsx264_init(void);
extern void libmsopenh264_init(void);
extern void libmssilk_init(void);
extern void libmsbcg729_init(void);

//extern void libmsamr_init(MSFactory *factory);
//extern void libmsx264_init(MSFactory *factory);
//extern void libmsopenh264_init(MSFactory *factory);
//extern void libmssilk_init(MSFactory *factory);
//extern void libmsbcg729_init(MSFactory *factory);
//extern void libmswebrtc_init(MSFactory *factory);

#define FRONT_CAM_NAME "AV Capture: com.apple.avfoundation.avcapturedevice.built-in_video:1" /*"AV Capture: Front Camera"*/
#define BACK_CAM_NAME "AV Capture: com.apple.avfoundation.avcapturedevice.built-in_video:0" /*"AV Capture: Back Camera"*/


NSString *const kLinphoneOldChatDBFilename      = @"chat_database.sqlite";
NSString *const kLinphoneInternalChatDBFilename = @"linphone_chats.db";

@implementation LinphoneCallAppData
- (id)init {
    if ((self = [super init])) {
        self->batteryWarningShown = FALSE;
        self->notification = nil;
        self->videoRequested = FALSE;
        self->userInfos = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self->userInfos release];
    [super dealloc];
}
@end


@interface LinphoneManager ()<UIAlertViewDelegate>{
    dispatch_source_t timer;
}
@property (retain, nonatomic) AVAudioPlayer* messagePlayer;
@property (nonatomic,assign) BOOL isTwoCallComing;  //监控门口机时，有门口机打过来，播放铃声
@property (nonatomic,assign) BOOL isCallComing;  //是否有门口机打过来（有2个门口机打过来时，要禁掉第二个）
@end

@implementation LinphoneManager

@synthesize connectivity;
@synthesize network;
@synthesize frontCamId;
@synthesize backCamId;
@synthesize database;
//@synthesize fastAddressBook;
@synthesize pushNotificationToken;
@synthesize sounds;
@synthesize logs;
@synthesize speakerEnabled;
@synthesize bluetoothAvailable;
@synthesize bluetoothEnabled;
@synthesize photoLibrary;
@synthesize tunnelMode;
@synthesize silentPushCompletion;
@synthesize wasRemoteProvisioned;
@synthesize configDb;
@synthesize ipv6Enabled;
@synthesize videoEnable;
@synthesize nExpires;

struct codec_name_pref_table{
    const char *name;
    int rate;
    NSString *prefname;
};

struct codec_name_pref_table codec_pref_table[]={
    { "speex", 8000, @"speex_8k_preference" },
    { "speex", 16000, @"speex_16k_preference" },
    { "silk", 24000, @"silk_24k_preference" },
    { "silk", 16000, @"silk_16k_preference" },
    { "amr", 8000, @"amr_preference" },
    { "gsm", 8000, @"gsm_preference" },
    { "ilbc", 8000, @"ilbc_preference"},
    { "pcmu", 8000, @"pcmu_preference"},
    { "pcma", 8000, @"pcma_preference"},
    { "g722", 8000, @"g722_preference"},
    { "g729", 8000, @"g729_preference"},
    { "mp4v-es", 90000, @"mp4v-es_preference"},
    { "h264", 90000, @"h264_preference"},
    { "vp8", 90000, @"vp8_preference"},
    { "mpeg4-generic", 16000, @"aaceld_16k_preference"},
    { "mpeg4-generic", 22050, @"aaceld_22k_preference"},
    { "mpeg4-generic", 32000, @"aaceld_32k_preference"},
    { "mpeg4-generic", 44100, @"aaceld_44k_preference"},
    { "mpeg4-generic", 48000, @"aaceld_48k_preference"},
    { "opus", 48000, @"opus_preference"},
    { NULL,0,Nil }
};

+ (NSString *)getPreferenceForCodec: (const char*) name withRate: (int) rate{
    int i;
    for(i=0;codec_pref_table[i].name!=NULL;++i){
        if (strcasecmp(codec_pref_table[i].name,name)==0 && codec_pref_table[i].rate==rate)
            return codec_pref_table[i].prefname;
    }
    return Nil;
}

+ (NSSet *)unsupportedCodecs {
    NSMutableSet *set = [NSMutableSet set];
    for(int i=0;codec_pref_table[i].name!=NULL;++i) {
        PayloadType* available = linphone_core_find_payload_type(theLinphoneCore,
                                                                 codec_pref_table[i].name,
                                                                 codec_pref_table[i].rate,
                                                                 LINPHONE_FIND_PAYLOAD_IGNORE_CHANNELS);
        if( (available == NULL)
           // these two codecs should not be hidden, even if not supported
           && ![codec_pref_table[i].prefname isEqualToString:@"h264_preference"]
           && ![codec_pref_table[i].prefname isEqualToString:@"mp4v-es_preference"]
           )
        {
            [set addObject:codec_pref_table[i].prefname];
        }
    }
    return set;
}

+ (BOOL)isCodecSupported: (const char *)codecName {
    return (codecName != NULL) &&
    (NULL != linphone_core_find_payload_type(theLinphoneCore, codecName,
                                             LINPHONE_FIND_PAYLOAD_IGNORE_RATE,
                                             LINPHONE_FIND_PAYLOAD_IGNORE_CHANNELS));
}

+ (BOOL)runningOnIpad {
#ifdef UI_USER_INTERFACE_IDIOM
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
    return NO;
#endif
}

+ (BOOL)isRunningTests {
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *injectBundle = environment[@"XCInjectBundle"];
    return [[injectBundle pathExtension] isEqualToString:@"xctest"];
}

+ (BOOL)isNotIphone3G
{
    static BOOL done=FALSE;
    static BOOL result;
    if (!done){
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        NSString *platform = [[NSString alloc ] initWithUTF8String:machine];
        free(machine);
        
        result = ![platform isEqualToString:@"iPhone1,2"];
        
        [platform release];
        done=TRUE;
    }
    return result;
}

+ (NSString *)getUserAgent {
    return [NSString stringWithFormat:@"LinphoneIphone/%@ (Linphone/%s; Apple %@/%@)",
            [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey],
            linphone_core_get_version(),
            [UIDevice currentDevice].systemName,
            [UIDevice currentDevice].systemVersion];
}

+ (LinphoneManager*)instance {
    if(theLinphoneManager == nil) {
        theLinphoneManager = [LinphoneManager alloc];
        [theLinphoneManager init];
    }
    return theLinphoneManager;
}

#ifdef DEBUG
+ (void)instanceRelease {
    if(theLinphoneManager != nil) {
        [theLinphoneManager release];
        theLinphoneManager = nil;
    }
}
#endif

+ (BOOL)langageDirectionIsRTL {
    static NSLocaleLanguageDirection dir = NSLocaleLanguageDirectionLeftToRight;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dir = [NSLocale characterDirectionForLanguage:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]];
    });
    return dir == NSLocaleLanguageDirectionRightToLeft;
}

#pragma mark - Lifecycle Functions

- (id)init {
    if ((self = [super init])) {
        AudioSessionInitialize(NULL, NULL, NULL, NULL);
        OSStatus lStatus = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback, self);
        if (lStatus) {
            [LinphoneLogger logc:LinphoneLoggerError format:"cannot register route change handler [%ld]",lStatus];
        }
        
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"msg" ofType:@"wav"];
        self.messagePlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:path] error:nil] autorelease];

        sounds.vibrate = kSystemSoundID_Vibrate;

        logs = [[NSMutableArray alloc] init];
        database = NULL;
        speakerEnabled = FALSE;
        bluetoothEnabled = FALSE;
        tunnelMode = FALSE;
        [self copyDefaultSettings];
        pushCallIDs = [[NSMutableArray alloc] init ];
        photoLibrary = [[ALAssetsLibrary alloc] init];
        self->_isTesting = [LinphoneManager isRunningTests];
        
        NSString* factoryConfig = [LinphoneManager bundleFile:[LinphoneManager runningOnIpad]?@"linphonerc-factory~ipad":@"linphonerc-factory"];
        NSString *confiFileName = [LinphoneManager documentFile:@".linphonerc"];
        configDb=lp_config_new_with_factory([confiFileName cStringUsingEncoding:[NSString defaultCStringEncoding]] , [factoryConfig cStringUsingEncoding:[NSString defaultCStringEncoding]]);
        
        //set default values for first boot
        if (lp_config_get_string(configDb,LINPHONERC_APPLICATION_KEY,"debugenable_preference",NULL)==NULL){
#ifdef DEBUG
            [self lpConfigSetBool:TRUE forKey:@"debugenable_preference"];
#else
            [self lpConfigSetBool:FALSE forKey:@"debugenable_preference"];
#endif
        }
        
        [self migrateFromUserPrefs];
    }
    return self;
}

- (void)dealloc {
    //	[fastAddressBook release];
    [logs release];
    
    OSStatus lStatus = AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback, self);
    if (lStatus) {
        [LinphoneLogger logc:LinphoneLoggerError format:"cannot un register route change handler [%ld]", lStatus];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kLinphoneGlobalStateUpdate];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kLinphoneConfiguringStateUpdate];
    
    
    [photoLibrary release];
    [pushCallIDs release];
    [super dealloc];
}

- (void)silentPushFailed:(NSTimer*)timer
{
    if( silentPushCompletion ){
        [LinphoneLogger log:LinphoneLoggerLog format:@"silentPush failed, silentPushCompletion block: %p", silentPushCompletion ];
        silentPushCompletion(UIBackgroundFetchResultNoData);
        silentPushCompletion = nil;
    }
}

#pragma mark - Database Functions

static int check_should_migrate_images(void* data ,int argc,char** argv,char** cnames){
    *((BOOL*)data) = TRUE;
    return 0;
}

- (BOOL)migrateChatDBIfNeeded:(LinphoneCore*)lc {
    sqlite3* newDb;
    char *errMsg;
    NSError* error;
    NSString *oldDbPath = [LinphoneManager documentFile:kLinphoneOldChatDBFilename];
    NSString *newDbPath = [LinphoneManager documentFile:kLinphoneInternalChatDBFilename];
    BOOL shouldMigrate  = [[NSFileManager defaultManager] fileExistsAtPath:oldDbPath];
    BOOL shouldMigrateImages = FALSE;
    LinphoneProxyConfig* default_proxy;
    const char* identity = NULL;
    BOOL migrated = FALSE;
    char* attach_stmt = NULL;
    
    linphone_core_get_default_proxy(lc, &default_proxy);
    
    
    if( sqlite3_open([newDbPath UTF8String], &newDb) != SQLITE_OK) {
        [LinphoneLogger log:LinphoneLoggerError format:@"Can't open \"%@\" sqlite3 database.", newDbPath];
        return FALSE;
    }
    
    const char* check_appdata = "SELECT url,message FROM history WHERE url LIKE 'assets-library%' OR message LIKE 'assets-library%' LIMIT 1;";
    // will set "needToMigrateImages to TRUE if a result comes by
    sqlite3_exec(newDb, check_appdata, check_should_migrate_images, &shouldMigrateImages, NULL);
    if( !shouldMigrate && !shouldMigrateImages ) {
        sqlite3_close(newDb);
        return FALSE;
    }
    
    
    [LinphoneLogger logc:LinphoneLoggerLog format:"Starting migration procedure"];
    
    if( shouldMigrate ){
        
        // attach old database to the new one:
        attach_stmt = sqlite3_mprintf("ATTACH DATABASE %Q AS oldchats", [oldDbPath UTF8String]);
        if( sqlite3_exec(newDb, attach_stmt, NULL, NULL, &errMsg) != SQLITE_OK ){
            [LinphoneLogger logc:LinphoneLoggerError format:"Can't attach old chat table, error[%s] ", errMsg];
            sqlite3_free(errMsg);
            goto exit_dbmigration;
        }
        
        
        // migrate old chats to the new db. The iOS stores timestamp in UTC already, so we can directly put it in the 'utc' field and set 'time' to -1
        const char* migration_statement = "INSERT INTO history (localContact,remoteContact,direction,message,utc,read,status,time) "
        "SELECT localContact,remoteContact,direction,message,time,read,state,'-1' FROM oldchats.chat";
        
        if( sqlite3_exec(newDb, migration_statement, NULL, NULL, &errMsg) != SQLITE_OK ){
            [LinphoneLogger logc:LinphoneLoggerError format:"DB migration failed, error[%s] ", errMsg];
            sqlite3_free(errMsg);
            goto exit_dbmigration;
        }
        
        // invert direction of old messages, because iOS was storing the direction flag incorrectly
        const char* invert_direction = "UPDATE history SET direction = NOT direction";
        if( sqlite3_exec(newDb, invert_direction, NULL, NULL, &errMsg) != SQLITE_OK){
            [LinphoneLogger log: LinphoneLoggerError format:@"Inverting direction failed, error[%s]", errMsg];
            sqlite3_free(errMsg);
            goto exit_dbmigration;
        }
        
        // replace empty from: or to: by the current identity.
        if( default_proxy ){
            identity = linphone_proxy_config_get_identity(default_proxy);
        }
        if( !identity ){
            identity = "sip:unknown@sip.linphone.org";
        }
        
        char* from_conversion = sqlite3_mprintf("UPDATE history SET localContact = %Q WHERE localContact = ''", identity);
        if( sqlite3_exec(newDb, from_conversion, NULL, NULL, &errMsg) != SQLITE_OK ){
            [LinphoneLogger logc:LinphoneLoggerError format:"FROM conversion failed, error[%s] ", errMsg];
            sqlite3_free(errMsg);
        }
        sqlite3_free(from_conversion);
        
        char* to_conversion = sqlite3_mprintf("UPDATE history SET remoteContact = %Q WHERE remoteContact = ''", identity);
        if( sqlite3_exec(newDb, to_conversion, NULL, NULL, &errMsg) != SQLITE_OK ){
            [LinphoneLogger logc:LinphoneLoggerError format:"DB migration failed, error[%s] ", errMsg];
            sqlite3_free(errMsg);
        }
        sqlite3_free(to_conversion);
        
    }
    
    // local image paths were stored in the 'message' field historically. They were
    // very temporarily stored in the 'url' field, and now we migrated them to a JSON-
    // encoded field. These are the migration steps to migrate them.
    
    // move already stored images from the messages to the appdata JSON field
    const char* assetslib_migration = "UPDATE history SET appdata='{\"localimage\":\"'||message||'\"}' , message='' WHERE message LIKE 'assets-library%'";
    if( sqlite3_exec(newDb, assetslib_migration, NULL, NULL, &errMsg) != SQLITE_OK ){
        [LinphoneLogger logc:LinphoneLoggerError format:"Assets-history migration for MESSAGE failed, error[%s] ", errMsg];
        sqlite3_free(errMsg);
    }
    
    // move already stored images from the url to the appdata JSON field
    const char* assetslib_migration_fromurl = "UPDATE history SET appdata='{\"localimage\":\"'||url||'\"}' , url='' WHERE url LIKE 'assets-library%'";
    if( sqlite3_exec(newDb, assetslib_migration_fromurl, NULL, NULL, &errMsg) != SQLITE_OK ){
        [LinphoneLogger logc:LinphoneLoggerError format:"Assets-history migration for URL failed, error[%s] ", errMsg];
        sqlite3_free(errMsg);
    }
    
    // We will lose received messages with remote url, they will be displayed in plain. We can't do much for them..
    migrated = TRUE;
    
exit_dbmigration:
    
    if( attach_stmt ) sqlite3_free(attach_stmt);
    
    sqlite3_close(newDb);
    
    // in any case, we should remove the old chat db
    if( shouldMigrate && ![[NSFileManager defaultManager] removeItemAtPath:oldDbPath error:&error] ){
        [LinphoneLogger logc:LinphoneLoggerError format:"Could not remove old chat DB: %@", error];
    }
    
    [LinphoneLogger log:LinphoneLoggerLog format:@"Message storage migration finished: success = %@", migrated ? @"TRUE":@"FALSE"];
    return migrated;
}

- (void)migrateFromUserPrefs {
    static const char* migration_flag = "userpref_migration_done";
    
    if( configDb == nil ) return;
    
    if( lp_config_get_int(configDb, LINPHONERC_APPLICATION_KEY, migration_flag, 0) ){
        Linphone_log(@"UserPrefs migration already performed, skip");
        return;
    }
    
    NSDictionary* defaults = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    NSArray* defaults_keys = [defaults allKeys];
    NSDictionary* values   = @{@"backgroundmode_preference" :@YES,
                               @"debugenable_preference"    :@NO,
                               @"start_at_boot_preference"  :@YES};
    BOOL shouldSync        = FALSE;
    
    Linphone_log(@"%lu user prefs", (unsigned long)[defaults_keys count]);
    
    for( NSString* userpref in values ){
        if( [defaults_keys containsObject:userpref] ){
            Linphone_log(@"Migrating %@ from user preferences: %d", userpref, [[defaults objectForKey:userpref] boolValue]);
            lp_config_set_int(configDb, LINPHONERC_APPLICATION_KEY, [userpref UTF8String], [[defaults objectForKey:userpref] boolValue]);
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:userpref];
            shouldSync = TRUE;
        } else if ( lp_config_get_string(configDb, LINPHONERC_APPLICATION_KEY, [userpref UTF8String], NULL) == NULL ){
            // no default value found in our linphonerc, we need to add them
            lp_config_set_int(configDb, LINPHONERC_APPLICATION_KEY, [userpref UTF8String], [[values objectForKey:userpref] boolValue]);
        }
    }
    
    if( shouldSync ){
        Linphone_log(@"Synchronizing...");
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    // don't get back here in the future
    lp_config_set_int(configDb, LINPHONERC_APPLICATION_KEY, migration_flag, 1);
}


#pragma mark - Linphone Core Functions

+ (LinphoneCore*)getLc {
    if (theLinphoneCore==nil) {
        //		@throw([NSException exceptionWithName:@"LinphoneCoreException" reason:@"Linphone core not initialized yet" userInfo:nil]);
    }
    return theLinphoneCore;
}

+ (BOOL)isLcReady {
    return theLinphoneCore != nil;
}

#pragma mark Debug functions

struct _entry_data {
    const LpConfig* conf;
    const char* section;
};

static void dump_entry(const char* entry, void*data) {
    struct _entry_data *d = (struct _entry_data*)data;
    const char* value = lp_config_get_string(d->conf, d->section, entry, "");
    [LinphoneLogger log:LinphoneLoggerLog format:@"%s=%s", entry, value];
}

static void dump_section(const char* section, void* data){
    [LinphoneLogger log:LinphoneLoggerLog format:@"[%s]", section ];
    struct _entry_data d = {(const LpConfig*)data, section};
    lp_config_for_each_entry((const LpConfig*)data, section, dump_entry, &d);
}

+ (void)dumpLCConfig {
    if (theLinphoneCore ){
        LpConfig *conf=[LinphoneManager instance].configDb;
        lp_config_for_each_section(conf, dump_section, conf);
    }
}


#pragma mark - Logs Functions

//generic log handler for debug version
void linphone_iphone_log_handler(int lev, const char *fmt, va_list args){
    if (!fmt) {
        return;
    }
    //	NSString* format = [[NSString alloc] initWithUTF8String:fmt];
    //	NSLogv(format, args);
    //	NSString* formatedString = [[NSString alloc] initWithFormat:format arguments:args];
    //
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        if([[LinphoneManager instance].logs count] >= LINPHONE_LOGS_MAX_ENTRY) {
    //            [[LinphoneManager instance].logs removeObjectAtIndex:0];
    //        }
    //        [[LinphoneManager instance].logs addObject:formatedString];
    //
    //        // Post event
    //        NSDictionary *dict = [NSDictionary dictionaryWithObject:formatedString forKey:@"log"];
    //        [[NSNotificationCenter defaultCenter] postNotificationName:kLinphoneLogsUpdate object:[LinphoneManager instance] userInfo:dict];
    //    });
    //
    //	[formatedString release];
    //	[format release];
}

//Error/warning log handler
static void linphone_iphone_log(struct _LinphoneCore * lc, const char * message) {
//    NSString* log = [NSString stringWithCString:message encoding:[NSString defaultCStringEncoding]];
    //	NSLog(log, NULL);
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        if([[LinphoneManager instance].logs count] >= LINPHONE_LOGS_MAX_ENTRY) {
    //            [[LinphoneManager instance].logs removeObjectAtIndex:0];
    //        }
    //        [[LinphoneManager instance].logs addObject:log];
    //
    //        // Post event
    //        NSDictionary *dict = [NSDictionary dictionaryWithObject:log forKey:@"log"];
    //        [[NSNotificationCenter defaultCenter] postNotificationName:kLinphoneLogsUpdate object:[LinphoneManager instance] userInfo:dict];
    //    });
}


#pragma mark - Display Status Functions

- (void)displayStatus:(NSString*) message {
    // Post event
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          message, @"message",
                          nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLinphoneDisplayStatusUpdate object:self userInfo:dict];
}


static void linphone_iphone_display_status(struct _LinphoneCore * lc, const char * message) {
    NSString* status = [[NSString alloc] initWithCString:message encoding:[NSString defaultCStringEncoding]];
    [(LinphoneManager*)linphone_core_get_user_data(lc)  displayStatus:status];
    [status release];
}


#pragma mark - Call State Functions

- (void)localNotifContinue:(NSTimer*) timer {
    UILocalNotification* notif = [timer userInfo];
    if (notif){
        [LinphoneLogger log:LinphoneLoggerLog format:@"cancelling/presenting local notif"];
        [[UIApplication sharedApplication] cancelLocalNotification:notif];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notif];
    }
}

- (void)onCall:(LinphoneCall*)call StateChanged:(LinphoneCallState)state withMessage:(const char *)message {
 
    // Handling wrapper
    LinphoneCallAppData* data=(LinphoneCallAppData*)linphone_call_get_user_pointer(call);
    if (!data) {
        data = [[LinphoneCallAppData alloc] init];
        linphone_call_set_user_pointer(call, data);
    }
    
    if (silentPushCompletion) {
        
        // we were woken up by a silent push. Call the completion handler with NEWDATA
        // so that the push is notified to the user
        [LinphoneLogger log:LinphoneLoggerLog format:@"onCall - handler %p", silentPushCompletion];
        silentPushCompletion(UIBackgroundFetchResultNewData);
        silentPushCompletion = nil;
    }
    
    const LinphoneAddress *addr = linphone_call_get_remote_address(call);
    NSString* address = nil;
    if(addr != NULL) {
        BOOL useLinphoneAddress = true;

        if(useLinphoneAddress) {
            const char* lDisplayName = linphone_address_get_display_name(addr);
            const char* lUserName = linphone_address_get_username(addr);
            if (lDisplayName)
                address = [NSString stringWithUTF8String:lDisplayName];
            else if(lUserName)
                address = [NSString stringWithUTF8String:lUserName];
        }
    }
    if(address == nil) {
        address = NSLocalizedString(@"Unknown", nil);
    }
    
    //门口机拨打过来的名字
    NSMutableString *displayName = [[NSMutableString alloc] initWithString:@""];

    if ([address rangeOfString:@","].location == NSNotFound) {
         [displayName appendString:address];
    } else {
        NSArray * codeArr = [address componentsSeparatedByString:@","];
        
        for (int i = 0; i < codeArr.count - 1; i ++) {
            NSString * codeStr = codeArr[i];
            unichar theChar = [codeStr intValue];
            [displayName appendFormat:@"%@", [NSString stringWithFormat:@"%C",theChar]];
        }
    }

    if (state == LinphoneCallIncomingReceived) {
        if (self.isCallComing) {
            return;
        }

        self.isCallComing = YES;
        /*first step is to re-enable ctcall center*/
        CTCallCenter* lCTCallCenter = [[CTCallCenter alloc] init];
        
        /*should we reject this call ?*/
        if ([lCTCallCenter currentCalls]!=nil) {
            char *tmp=linphone_call_get_remote_address_as_string(call);
            if (tmp) {
                [LinphoneLogger logc:LinphoneLoggerLog format:"Mobile call ongoing... rejecting call from [%s]",tmp];
                ms_free(tmp);
            }
            linphone_core_decline_call(theLinphoneCore, call,LinphoneReasonBusy);
            [lCTCallCenter release];
            return;
        }
        [lCTCallCenter release];
        
        if(	[UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            
            LinphoneCallLog* callLog=linphone_call_get_call_log(call);
            NSString* callId=[NSString stringWithUTF8String:linphone_call_log_get_call_id(callLog)];
            
            if (![[LinphoneManager instance] popPushCallID:callId]){
                // case where a remote notification is not already received
                // Create a new local notification
                data->notification = [[UILocalNotification alloc] init];
                if (data->notification) {
                    
                    // iOS8 doesn't need the timer trick for the local notification.
                    if( [[UIDevice currentDevice].systemVersion floatValue] >= 8){
                        
//                        if ([Common playRing]) {
//                            data->notification.soundName = @"ring.caf";
//                        }
                        data->notification.soundName = @"ring.caf";
                        data->notification.category = @"incoming_call";
                    } else {
                        
//                        if ([Common playRing]) {
//                            data->notification.soundName = @"shortring.caf";
//                        }
                        data->notification.soundName = @"shortring.caf";
                        data->timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(localNotifContinue:) userInfo:data->notification repeats:TRUE];
                    }
                    
                    data->notification.repeatInterval = 0;
                    
                    //					data->notification.alertBody =[NSString  stringWithFormat:NSLocalizedString(@"IC_MSG",nil), address];
                    
                    data->notification.alertBody = [NSString stringWithFormat:@"%@ 视频来电",displayName];
                    data->notification.alertAction = NSLocalizedString(@"Answer", nil);
                    data->notification.userInfo = @{@"callId": callId, @"timer":[NSNumber numberWithInt:1], @"LinphoneCallState":[NSNumber numberWithInt:state]};
                    data->notification.applicationIconBadgeNumber = data->notification.applicationIconBadgeNumber + 1;
                    
                    [[UIApplication sharedApplication] presentLocalNotificationNow:data->notification];
                    
                    if (!incallBgTask){
                        incallBgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: ^{
                            [LinphoneLogger log:LinphoneLoggerWarning format:@"Call cannot ring any more, too late"];
                            [[UIApplication sharedApplication] endBackgroundTask:incallBgTask];
                            incallBgTask=0;
                        }];
                        
                        if( data->timer ){
                            [[NSRunLoop currentRunLoop] addTimer:data->timer forMode:NSRunLoopCommonModes];
                        }
                    }
                }
            }
        }
        else{
//            if ([Common playRing]) {
//                [self playMessageSound];
//            }
        }
    }

    // we keep the speaker auto-enabled state in this static so that we don't
    // force-enable it on ICE re-invite if the user disabled it.
    static BOOL speaker_already_enabled = FALSE;
    
    // Disable speaker when no more call
    if ((state == LinphoneCallEnd || state == LinphoneCallError)) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"endVideoCall" object:nil];
        speaker_already_enabled = FALSE;
        self.isCallComing = NO;
        if(linphone_core_get_calls_nb(theLinphoneCore) == 0) {
            [self setSpeakerEnabled:FALSE];
            [self removeCTCallCenterCb];
            bluetoothAvailable = FALSE;
            bluetoothEnabled = FALSE;
            /*IOS specific*/
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                linphone_core_stop_dtmf_stream(theLinphoneCore);
            }else{
                linphone_core_start_dtmf_stream(theLinphoneCore);
            }
        }
        if (incallBgTask) {
            [[UIApplication sharedApplication]  endBackgroundTask:incallBgTask];
            incallBgTask=0;
        }
        if(data != nil && data->notification != nil) {
            LinphoneCallLog *log = linphone_call_get_call_log(call);
            
            // cancel local notif if needed
            if( data->timer ){
                [data->timer invalidate];
                data->timer = nil;
            }
            [[UIApplication sharedApplication] cancelLocalNotification:data->notification];
            
            [data->notification release];
            data->notification = nil;
            
            if(log == NULL || linphone_call_log_get_status(log) == LinphoneCallMissed) {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                if( [[UIDevice currentDevice].systemVersion floatValue] >= 8){
                    notification.soundName = @"ring.caf";
                    notification.category = @"incoming_call";
                } else {
                    notification.soundName = @"shortring.caf";
                }
                
                notification.repeatInterval = 0;
                notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"未接来电 %@", nil), displayName];
                notification.alertAction = NSLocalizedString(@"Show", nil);
                notification.alertLaunchImage = @"Default";
                //				notification.userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithUTF8String:linphone_call_log_get_call_id(log)] forKey:@"callLog"];
                notification.userInfo = @{@"callLog": [NSString stringWithUTF8String:linphone_call_log_get_call_id(log)], @"LinphoneCallState":[NSNumber numberWithInt:state] };
                notification.applicationIconBadgeNumber = notification.applicationIconBadgeNumber + 1;
                [self cancelLocalNotificationWithKey:@"LinphoneCallState"];
                
                //[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                [notification release];
            }
            
        }
        
        if (!self.isTwoCallComing) {
            [self stopMessageSound];
        }
        self.isTwoCallComing = NO;
    }
    
    if(state == LinphoneCallReleased) {
        if(data != NULL) {
            [data release];
            linphone_call_set_user_pointer(call, NULL);
        }
    }
    
    // Enable speaker when video
    if(state == LinphoneCallIncomingReceived ||
       state == LinphoneCallOutgoingInit ||
       state == LinphoneCallConnected ||
       state == LinphoneCallStreamsRunning) {
        if (linphone_call_params_video_enabled(linphone_call_get_current_params(call)) && !speaker_already_enabled) {
            [self setSpeakerEnabled:speakerEnabled];
            speaker_already_enabled = TRUE;
        }
    }
    
    if (state == LinphoneCallConnected && !mCallCenter) {
        /*only register CT call center CB for connected call*/
        [self setupGSMInteraction];
    }
    // Post event
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSValue valueWithPointer:call], @"call",
                          [NSNumber numberWithInt:state], @"state",
                          [NSString stringWithUTF8String:message], @"message", nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kSYLinphoneCallUpdate object:nil userInfo:dict];
    });
    
    // 回调message参数
    NSDictionary *msgDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:message], @"message", [[SYLinphoneManager instance] getRemoteAddress:call], @"remote_address", nil];
    
    if ([SYLinphoneManager instance].delegate) {
        
        // 通话状态更新回调
        switch (state) {
            case SYLinphoneCallOutgoingInit:{
                if ([[SYLinphoneManager instance].delegate respondsToSelector:@selector(onOutgoingCall:withState:withMessage:)]) {
                    [[SYLinphoneManager instance].delegate onOutgoingCall:call withState:state withMessage:msgDic];
                }
                break;
            }
                
            case SYLinphoneCallIncomingReceived: {
                msgDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:message], @"message", [[SYLinphoneManager instance] getRemoteAddress:call], @"remote_address", [NSString stringWithUTF8String:linphone_core_get_identity([LinphoneManager getLc])], @"called_address", nil];
                //是否是视频来电
                const LinphoneCallParams *lcallParams = linphone_call_get_remote_params(call);
                BOOL videoBool = linphone_call_params_video_enabled(lcallParams);
                
                if ([[SYLinphoneManager instance].delegate respondsToSelector:@selector(onIncomingCall:withState:withMessage:withIsVideo:)]) {
                    [[SYLinphoneManager instance].delegate onIncomingCall:call withState:state withMessage:msgDic withIsVideo:videoBool];
                }
                break;
            }
                
            case SYLinphoneCallConnected: {
                if ([[SYLinphoneManager instance].delegate respondsToSelector:@selector(onAnswer:withState:withMessage:)]) {
                    [[SYLinphoneManager instance].delegate onAnswer:call withState:state withMessage:msgDic];
                    //[[SYLinphoneManager instance] hangUpCall];
                }
//                [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
                self.isTwoCallComing = NO;
                self.isCallComing = NO;
                [self stopMessageSound];
                break;
            }
                
//            case SYLinphoneCallEnd:
            case SYLinphoneCallReleased: {
                if ([[SYLinphoneManager instance].delegate respondsToSelector:@selector(onHangUp:withState:withMessage:)]) {
                    [[SYLinphoneManager instance].delegate onHangUp:call withState:state withMessage:msgDic];
                }
                //[[SYLinphoneManager instance] hangUpCall];
                break;
            }
            case LinphoneCallPaused: {
                if ([[SYLinphoneManager instance].delegate respondsToSelector:@selector(onPaused:withState:withMessage:)]) {
                    [[SYLinphoneManager instance].delegate onPaused:call withState:state withMessage:msgDic];
                }
                
//                if ([[SYLinphoneManager instance].delegate respondsToSelector:@selector(onHangUp:withState:withMessage:)]) {
//                    [[SYLinphoneManager instance].delegate onHangUp:call withState:state withMessage:msgDic];
//                }
                
                break;
            }
            case LinphoneCallEnd: {
                [[SYLinphoneManager instance] hangUpCall];
                
                break;
            }
                
            default:
                break;
        }
    }
    
    NSLog(@"linphoneState = %i   message = %@",state, [NSString stringWithUTF8String:message]);
}

static void linphone_iphone_call_state(LinphoneCore *lc, LinphoneCall* call, LinphoneCallState state,const char* message) {
    [(LinphoneManager*)linphone_core_get_user_data(lc) onCall:call StateChanged: state withMessage:  message];
}


#pragma mark - Transfert State Functions

static void linphone_iphone_transfer_state_changed(LinphoneCore* lc, LinphoneCall* call, LinphoneCallState state) {
}

#pragma mark - Global state change

static void linphone_iphone_global_state_changed(LinphoneCore *lc, LinphoneGlobalState gstate, const char *message) {
    [(LinphoneManager*)linphone_core_get_user_data(lc) onGlobalStateChanged:gstate withMessage:message];
}

-(void)onGlobalStateChanged:(LinphoneGlobalState)state withMessage:(const char*)message {
    [LinphoneLogger log:LinphoneLoggerLog format:@"onGlobalStateChanged: %d (message: %s)", state, message];
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:state], @"state",
                          [NSString stringWithUTF8String:message?message:""], @"message",
                          nil];
    
    // dispatch the notification asynchronously
//    dispatch_async(dispatch_get_main_queue(), ^(void){
        [[NSNotificationCenter defaultCenter] postNotificationName:kLinphoneGlobalStateUpdate object:self userInfo:dict];
//    });
}


-(void)globalStateChangedNotificationHandler:(NSNotification*)notif {
    if( (LinphoneGlobalState)[[[notif userInfo] valueForKey:@"state"] integerValue] == LinphoneGlobalOn){
        [self finishCoreConfiguration];
    }
}


#pragma mark - Configuring status changed

static void linphone_iphone_configuring_status_changed(LinphoneCore *lc, LinphoneConfiguringState status, const char *message) {
    [(LinphoneManager*)linphone_core_get_user_data(lc) onConfiguringStatusChanged:status withMessage:message];
}

-(void)onConfiguringStatusChanged:(LinphoneConfiguringState)status withMessage:(const char*)message {
    [LinphoneLogger log:LinphoneLoggerLog format:@"onConfiguringStatusChanged: %d (message: %s)", status, message];
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:status], @"state",
                          [NSString stringWithUTF8String:message?message:""], @"message",
                          nil];
    
    // dispatch the notification asynchronously
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [[NSNotificationCenter defaultCenter] postNotificationName:kLinphoneConfiguringStateUpdate object:self userInfo:dict];
    });
}


-(void)configuringStateChangedNotificationHandler:(NSNotification*)notif {
    if( (LinphoneConfiguringState)[[[notif userInfo] valueForKey:@"state"] integerValue] == LinphoneConfiguringSuccessful){
        wasRemoteProvisioned = TRUE;
    } else {
        wasRemoteProvisioned = FALSE;
    }
}


#pragma mark - Registration State Functions

- (void)onRegister:(LinphoneCore *)lc cfg:(LinphoneProxyConfig*) cfg state:(LinphoneRegistrationState) state message:(const char*) message {
    [LinphoneLogger logc:LinphoneLoggerLog format:"NEW REGISTRATION STATE: '%s' (message: '%s')", linphone_registration_state_to_string(state), message];
    
    // Post event
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:state], @"state",
                          [NSValue valueWithPointer:cfg], @"cfg",
                          [NSString stringWithUTF8String:message], @"message",
                          nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSYLinphoneRegistrationUpdate object:nil userInfo:dict];

    // 处理回调
    if ([SYLinphoneManager instance].delegate  && [[SYLinphoneManager instance].delegate respondsToSelector:@selector(onRegisterStateChange:message:)]) {
        return [[SYLinphoneManager instance].delegate onRegisterStateChange:state message:message];
        
    }
}

static void linphone_iphone_registration_state(LinphoneCore *lc, LinphoneProxyConfig* cfg, LinphoneRegistrationState state,const char* message) {
    [(LinphoneManager*)linphone_core_get_user_data(lc) onRegister:lc cfg:cfg state:state message:message];
}

- (NSString *)TextMessageForChat:(LinphoneChatMessage *)message {
    const char *url = linphone_chat_message_get_external_body_url(message);
    const LinphoneContent *last_content = linphone_chat_message_get_file_transfer_information(message);
    // Last message was a file transfer (image) so display a picture...
    if (url || last_content) {
        return @"🗻";
    } else {
        const char *text = linphone_chat_message_get_text(message) ?: "";
        return [NSString stringWithUTF8String:text] ?: [NSString stringWithCString:text encoding:NSASCIIStringEncoding]
        ?: NSLocalizedString(@"(invalid string)", nil);
    }
}

- (NSString *)timeToString:(time_t)time{
    NSDate *todayDate = [[NSDate alloc] init];
    NSDate *messageDate = (time == 0) ? todayDate : [NSDate dateWithTimeIntervalSince1970:time];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    return [dateFormatter stringFromDate:messageDate];
}

#pragma mark - Text Received Functions

- (void)onMessageReceived:(LinphoneCore *)lc room:(LinphoneChatRoom *)room message:(LinphoneChatMessage *)msg {

    NSString *content = [self TextMessageForChat:msg];
    NSString *time = [self timeToString:linphone_chat_message_get_time(msg)];

    const LinphoneAddress *peer = linphone_chat_room_get_peer_address(room);
    const char *username = linphone_address_get_username(peer);
    NSLog(@"用户名==%s",username);
    
    NSDictionary *dict = @{
                           @"user" : [self getSipAdress:linphone_chat_message_get_from_address(msg)],
                           @"time" : time,
                           @"message" : content,
                           @"state" : [NSNumber numberWithInt:2],
                           @"sipNumber" : @"12"
                           };
    
    [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneMessageReceived object:self userInfo:dict];
}

static void linphone_iphone_message_received(LinphoneCore *lc, LinphoneChatRoom *room, LinphoneChatMessage *message) {
    [(LinphoneManager*)linphone_core_get_user_data(lc) onMessageReceived:lc room:room message:message];
}

- (void)onNotifyReceived:(LinphoneCore *)lc event:(LinphoneEvent *)lev notifyEvent:(const char *)notified_event content:(const LinphoneContent *)body {
    // Post event
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSValue valueWithPointer:lev] forKey:@"event"];
    [dict setObject:[NSString stringWithUTF8String:notified_event] forKey:@"notified_event"];
    if (body != NULL) {
        [dict setObject:[NSValue valueWithPointer:body] forKey:@"content"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kLinphoneNotifyReceived object:self userInfo:dict];
    
}

static void linphone_iphone_notify_received(LinphoneCore *lc, LinphoneEvent *lev, const char *notified_event, const LinphoneContent *body) {
    [(LinphoneManager*)linphone_core_get_user_data(lc) onNotifyReceived:lc event:lev notifyEvent:notified_event content:body];
}

#pragma mark - Message composition start

- (void)onMessageComposeReceived:(LinphoneCore*)core forRoom:(LinphoneChatRoom*)room {
    [[NSNotificationCenter defaultCenter] postNotificationName:kLinphoneTextComposeEvent
                                                        object:self
                                                      userInfo:@{@"room":[NSValue valueWithPointer:room]}];
}

static void linphone_iphone_is_composing_received(LinphoneCore *lc, LinphoneChatRoom *room){
    [(LinphoneManager*)linphone_core_get_user_data(lc) onMessageComposeReceived:lc forRoom:room];
}



#pragma mark - Network Functions

- (SCNetworkReachabilityRef) getProxyReachability {
    return proxyReachability;
}

+ (void)kickOffNetworkConnection {
    static BOOL in_progress = FALSE;
    if( in_progress ){
        Linphone_warn(@"Connection kickoff already in progress");
        return;
    }
    in_progress = TRUE;
    /* start a new thread to avoid blocking the main ui in case of peer host failure */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static int sleep_us = 10000;
        static int timeout_s = 5;
        BOOL timeout_reached = FALSE;
        int loop = 0;
        CFWriteStreamRef writeStream;
        CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"192.168.0.200"/*"linphone.org"*/, 15000, nil, &writeStream);
        BOOL res = CFWriteStreamOpen (writeStream);
        const char* buff="hello";
        time_t start = time(NULL);
        time_t loop_time;
        
        if( res == FALSE ){
            Linphone_log(@"Could not open write stream, backing off");
            CFRelease(writeStream);
            in_progress = FALSE;
            return;
        }
        
        // check stream status and handle timeout
        CFStreamStatus status = CFWriteStreamGetStatus(writeStream);
        while (status != kCFStreamStatusOpen && status != kCFStreamStatusError ) {
            usleep(sleep_us);
            status = CFWriteStreamGetStatus(writeStream);
            loop_time = time(NULL);
            if( loop_time - start >= timeout_s){
                timeout_reached = TRUE;
                break;
            }
            loop++;
        }
        
        
        if (status == kCFStreamStatusOpen ) {
            CFWriteStreamWrite (writeStream,(const UInt8*)buff,strlen(buff));
        } else if( !timeout_reached ){
            CFErrorRef error = CFWriteStreamCopyError(writeStream);
            Linphone_dbg(@"CFStreamError: %@", error);
            CFRelease(error);
        } else if( timeout_reached ){
            Linphone_log(@"CFStream timeout reached");
        }
        CFWriteStreamClose (writeStream);
        CFRelease(writeStream);
        in_progress = FALSE;
    });
}

+ (NSString*)getCurrentWifiSSID {
#if TARGET_IPHONE_SIMULATOR
    return @"Sim_err_SSID_NotSupported";
#else
    NSString *data = nil;
    CFDictionaryRef dict = CNCopyCurrentNetworkInfo((CFStringRef)@"en0");
    if(dict) {
        [LinphoneLogger log:LinphoneLoggerDebug format:@"AP Wifi: %@", dict];
        data = [NSString stringWithString:(NSString*) CFDictionaryGetValue(dict, @"SSID")];
        CFRelease(dict);
    }
    return data;
#endif
}

static void showNetworkFlags(SCNetworkReachabilityFlags flags){
    [LinphoneLogger logc:LinphoneLoggerLog format:"Network connection flags:"];
    if (flags==0) [LinphoneLogger logc:LinphoneLoggerLog format:"no flags."];
    if (flags & kSCNetworkReachabilityFlagsTransientConnection)
        [LinphoneLogger logc:LinphoneLoggerLog format:"kSCNetworkReachabilityFlagsTransientConnection"];
    if (flags & kSCNetworkReachabilityFlagsReachable)
        [LinphoneLogger logc:LinphoneLoggerLog format:"kSCNetworkReachabilityFlagsReachable"];
    if (flags & kSCNetworkReachabilityFlagsConnectionRequired)
        [LinphoneLogger logc:LinphoneLoggerLog format:"kSCNetworkReachabilityFlagsConnectionRequired"];
    if (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)
        [LinphoneLogger logc:LinphoneLoggerLog format:"kSCNetworkReachabilityFlagsConnectionOnTraffic"];
    if (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)
        [LinphoneLogger logc:LinphoneLoggerLog format:"kSCNetworkReachabilityFlagsConnectionOnDemand"];
    if (flags & kSCNetworkReachabilityFlagsIsLocalAddress)
        [LinphoneLogger logc:LinphoneLoggerLog format:"kSCNetworkReachabilityFlagsIsLocalAddress"];
    if (flags & kSCNetworkReachabilityFlagsIsDirect)
        [LinphoneLogger logc:LinphoneLoggerLog format:"kSCNetworkReachabilityFlagsIsDirect"];
    if (flags & kSCNetworkReachabilityFlagsIsWWAN)
        [LinphoneLogger logc:LinphoneLoggerLog format:"kSCNetworkReachabilityFlagsIsWWAN"];
}

static void networkReachabilityNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    LinphoneManager *mgr = [LinphoneManager instance];
    SCNetworkReachabilityFlags flags;
    
    // for an unknown reason, we are receiving multiple time the notification, so
    // we will skip each time the SSID did not change
    NSString *newSSID = [LinphoneManager getCurrentWifiSSID];
    if ([newSSID compare:mgr.SSID] == NSOrderedSame) return;
    
    mgr.SSID = newSSID;
    
    if (SCNetworkReachabilityGetFlags([mgr getProxyReachability], &flags)) {
        networkReachabilityCallBack([mgr getProxyReachability],flags,nil);
    }
}

void networkReachabilityCallBack(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* nilCtx){
    showNetworkFlags(flags);
    LinphoneManager* lLinphoneMgr = [LinphoneManager instance];
    SCNetworkReachabilityFlags networkDownFlags=kSCNetworkReachabilityFlagsConnectionRequired |kSCNetworkReachabilityFlagsConnectionOnTraffic | kSCNetworkReachabilityFlagsConnectionOnDemand;
    
    if (theLinphoneCore != nil) {
        LinphoneProxyConfig* proxy;
        linphone_core_get_default_proxy(theLinphoneCore, &proxy);
        
        struct NetworkReachabilityContext* ctx = nilCtx ? ((struct NetworkReachabilityContext*)nilCtx) : 0;
        if ((flags == 0) || (flags & networkDownFlags)) {
            linphone_core_set_network_reachable(theLinphoneCore, false);
            lLinphoneMgr.connectivity = none;
            [LinphoneManager kickOffNetworkConnection];
        } else {
            LinphoneTunnel *tunnel = linphone_core_get_tunnel([LinphoneManager getLc]);
            Connectivity  newConnectivity;
            BOOL isWifiOnly = lp_config_get_int(lLinphoneMgr.configDb, LINPHONERC_APPLICATION_KEY, "wifi_only_preference",FALSE);
            if (!ctx || ctx->testWWan)
                newConnectivity = flags & kSCNetworkReachabilityFlagsIsWWAN ? wwan:wifi;
            else
                newConnectivity = wifi;
            
            if (newConnectivity == wwan
                && proxy
                && isWifiOnly
                && (lLinphoneMgr.connectivity == newConnectivity || lLinphoneMgr.connectivity == none)) {
                linphone_proxy_config_expires(proxy, [LinphoneManager instance].nExpires);
            } else if (proxy){
                //				NSInteger defaultExpire = [[LinphoneManager instance] lpConfigIntForKey:@"default_expires"];
                //				if (defaultExpire>=0)
                linphone_proxy_config_expires(proxy, [LinphoneManager instance].nExpires);
                //else keep default value from linphonecore
            }
            
            if (lLinphoneMgr.connectivity != newConnectivity) {
                if (tunnel) linphone_tunnel_reconnect(tunnel);
                // connectivity has changed
                linphone_core_set_network_reachable(theLinphoneCore,false);
                if (newConnectivity == wwan && proxy && isWifiOnly) {
                    linphone_proxy_config_expires(proxy, [LinphoneManager instance].nExpires);
                }
                linphone_core_set_network_reachable(theLinphoneCore,true);
                linphone_core_iterate(theLinphoneCore);
                [LinphoneLogger logc:LinphoneLoggerLog format:"Network connectivity changed to type [%s]",(newConnectivity==wifi?"wifi":"wwan")];
            }
            lLinphoneMgr.connectivity=newConnectivity;
            switch (lLinphoneMgr.tunnelMode) {
                case tunnel_wwan:
                    linphone_tunnel_enable(tunnel,lLinphoneMgr.connectivity == wwan);
                    break;
                case tunnel_auto:
                    linphone_tunnel_auto_detect(tunnel);
                    break;
                default:
                    //nothing to do
                    break;
            }
        }
        if (ctx && ctx->networkStateChanged) {
            (*ctx->networkStateChanged)(lLinphoneMgr.connectivity);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_NetworkStateChanged object:nil userInfo:[NSDictionary dictionaryWithObject:@(lLinphoneMgr.connectivity) forKey:@"NetWorkType"]];
        });
    }
}

- (void)setupNetworkReachabilityCallback {
    SCNetworkReachabilityContext *ctx=NULL;
    //any internet cnx
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    if (proxyReachability) {
        [LinphoneLogger logc:LinphoneLoggerLog format:"Cancelling old network reachability"];
        SCNetworkReachabilityUnscheduleFromRunLoop(proxyReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFRelease(proxyReachability);
        proxyReachability = nil;
    }
    
    // This notification is used to detect SSID change (switch of Wifi network). The ReachabilityCallback is
    // not triggered when switching between 2 private Wifi...
    // Since we cannot be sure we were already observer, remove ourself each time... to be improved
    _SSID = [[LinphoneManager getCurrentWifiSSID] retain];
    CFNotificationCenterRemoveObserver(
                                       CFNotificationCenterGetDarwinNotifyCenter(),
                                       self,
                                       CFSTR("com.apple.system.config.network_change"),
                                       NULL);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    self,
                                    networkReachabilityNotification,
                                    CFSTR("com.apple.system.config.network_change"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    proxyReachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    
    if (!SCNetworkReachabilitySetCallback(proxyReachability, (SCNetworkReachabilityCallBack)networkReachabilityCallBack, ctx)){
        [LinphoneLogger logc:LinphoneLoggerError format:"Cannot register reachability cb: %s", SCErrorString(SCError())];
        return;
    }
    if(!SCNetworkReachabilityScheduleWithRunLoop(proxyReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)){
        [LinphoneLogger logc:LinphoneLoggerError format:"Cannot register schedule reachability cb: %s", SCErrorString(SCError())];
        return;
    }
    
    // this check is to know network connectivity right now without waiting for a change. Don'nt remove it unless you have good reason. Jehan
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(proxyReachability, &flags)) {
        networkReachabilityCallBack(proxyReachability,flags,nil);
    }
}

- (NetworkType)network {
    if( [[[UIDevice currentDevice] systemVersion] floatValue] < 7 ){
        UIApplication *app = [UIApplication sharedApplication];
        NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"]    subviews];
        NSNumber *dataNetworkItemView = nil;
        
        for (id subview in subviews) {
            if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
                dataNetworkItemView = subview;
                break;
            }
        }
        
        NSNumber *number = (NSNumber*)[dataNetworkItemView valueForKey:@"dataNetworkType"];
        return [number intValue];
    } else {
        CTTelephonyNetworkInfo* info = [[CTTelephonyNetworkInfo alloc] init];
        NSString* currentRadio = info.currentRadioAccessTechnology;
        if( [currentRadio isEqualToString:CTRadioAccessTechnologyEdge]){
            return network_2g;
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyLTE]){
            return network_4g;
        }
        return network_3g;
    }
}


#pragma mark -

static LinphoneCoreVTable linphonec_vtable = {
    .call_state_changed = (LinphoneCoreCallStateChangedCb)linphone_iphone_call_state,
    .registration_state_changed = linphone_iphone_registration_state,
    //    .notify_presence_received_for_uri_or_tel = linphone_iphone_notify_presence_received_for_uri_or_tel,
    //	.auth_info_requested = linphone_iphone_popup_password_request,
    .message_received = linphone_iphone_message_received,
    //	.message_received_unable_decrypt = linphone_iphone_message_received_unable_decrypt,
    .transfer_state_changed = linphone_iphone_transfer_state_changed,
    .is_composing_received = linphone_iphone_is_composing_received,
    .configuring_status = linphone_iphone_configuring_status_changed,
    .global_state_changed = linphone_iphone_global_state_changed,
    .notify_received = linphone_iphone_notify_received,
    //    .call_encryption_changed = linphone_iphone_call_encryption_changed,
};

//scheduling loop
- (void)iterate {
    linphone_core_iterate(theLinphoneCore);
}

- (void)audioSessionInterrupted:(NSNotification *)notification
{
    int interruptionType = [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (interruptionType == AVAudioSessionInterruptionTypeBegan) {
        [self beginInterruption];
    } else if (interruptionType == AVAudioSessionInterruptionTypeEnded) {
        //[self endInterruption];
    }
}

/** Should be called once per linphone_core_new() */
- (void)finishCoreConfiguration {
    
    //get default config from bundle
    NSString *zrtpSecretsFileName = [LinphoneManager documentFile:@"zrtp_secrets"];
    NSString *chatDBFileName      = [LinphoneManager documentFile:kLinphoneInternalChatDBFilename];
    const char* lRootCa           = [[LinphoneManager bundleFile:@"rootca.pem"] cStringUsingEncoding:[NSString defaultCStringEncoding]];
    
    linphone_core_set_user_agent(theLinphoneCore, [[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] stringByAppendingString:@"Iphone"] UTF8String], @"");
    
    [_contactSipField release];
    _contactSipField = [[self lpConfigStringForKey:@"contact_im_type_value" withDefault:@"SIP"] retain];
    
    
    //	fastAddressBook = [[FastAddressBook alloc] init];
    
    linphone_core_set_root_ca(theLinphoneCore, lRootCa);
    // Set audio assets
    const char* lRing = [[LinphoneManager bundleFile:@"ring.wav"] cStringUsingEncoding:[NSString defaultCStringEncoding]];
    linphone_core_set_ring(theLinphoneCore, lRing);
    const char* lRingBack = [[LinphoneManager bundleFile:@"ringback.wav"] cStringUsingEncoding:[NSString defaultCStringEncoding]];
    linphone_core_set_ringback(theLinphoneCore, lRingBack);
    const char* lPlay = [[LinphoneManager bundleFile:@"hold.wav"] cStringUsingEncoding:[NSString defaultCStringEncoding]];
    linphone_core_set_play_file(theLinphoneCore, lPlay);
    
    linphone_core_set_zrtp_secrets_file(theLinphoneCore, [zrtpSecretsFileName cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    linphone_core_set_chat_database_path(theLinphoneCore, [chatDBFileName cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    
    // we need to proceed to the migration *after* the chat database was opened, so that we know it is in consistent state
    BOOL migrated = [self migrateChatDBIfNeeded:theLinphoneCore];
    if( migrated ){
        // if a migration was performed, we should reinitialize the chat database
        linphone_core_set_chat_database_path(theLinphoneCore, [chatDBFileName cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    }
    
    /* AVPF migration */
    if( [self lpConfigBoolForKey:@"avpf_migration_done" forSection:@"app"] == FALSE ){
        const MSList* proxies = linphone_core_get_proxy_config_list(theLinphoneCore);
        while(proxies){
            LinphoneProxyConfig* proxy = (LinphoneProxyConfig*)proxies->data;
            const char* addr = linphone_proxy_config_get_addr(proxy);
            // we want to enable AVPF for the proxies
            if( addr && strstr(addr, "sip.linphone.org") != 0 ){
                Linphone_log(@"Migrating proxy config to use AVPF");
                linphone_proxy_config_enable_avpf(proxy, TRUE);
            }
            proxies = proxies->next;
        }
        [self lpConfigSetBool:TRUE forKey:@"avpf_migration_done"];
    }
    /* Quality Reporting migration */
    if( [self lpConfigBoolForKey:@"quality_report_migration_done" forSection:@"app"] == FALSE ){
        const MSList* proxies = linphone_core_get_proxy_config_list(theLinphoneCore);
        while(proxies){
            LinphoneProxyConfig* proxy = (LinphoneProxyConfig*)proxies->data;
            const char* addr = linphone_proxy_config_get_addr(proxy);
            // we want to enable quality reporting for the proxies that are on linphone.org
            if( addr && strstr(addr, "sip.linphone.org") != 0 ){
                Linphone_log(@"Migrating proxy config to send quality report");
                linphone_proxy_config_set_quality_reporting_collector(proxy, "sip:voip-metrics@sip.linphone.org");
                linphone_proxy_config_set_quality_reporting_interval(proxy, 180);
                linphone_proxy_config_enable_quality_reporting(proxy, TRUE);
            }
            proxies = proxies->next;
        }
        [self lpConfigSetBool:TRUE forKey:@"quality_report_migration_done"];
    }
    
    [self setupNetworkReachabilityCallback];
    
//    NSString* path = [LinphoneManager bundleFile:@"nowebcamCIF.jpg"];
//    if (path) {
//        const char* imagePath = [path cStringUsingEncoding:[NSString defaultCStringEncoding]];
//        [LinphoneLogger logc:LinphoneLoggerLog format:"Using '%s' as source image for no webcam", imagePath];
//        linphone_core_set_static_picture(theLinphoneCore, imagePath);
//    }
    
    /*DETECT cameras*/
//    frontCamId= backCamId=nil;
//    char** camlist = (char**)linphone_core_get_video_devices(theLinphoneCore);
//    for (char* cam = *camlist;*camlist!=NULL;cam=*++camlist) {
//        if (strcmp(FRONT_CAM_NAME, cam)==0) {
//            frontCamId = cam;
//            //great set default cam to front
//            linphone_core_set_video_device(theLinphoneCore, cam);
//        }
//        if (strcmp(BACK_CAM_NAME, cam)==0) {
//            backCamId = cam;
//        }
//        
//    }

    if (![LinphoneManager isNotIphone3G]){
        PayloadType *pt=linphone_core_find_payload_type(theLinphoneCore,"SILK",24000,-1);
        if (pt) {
            linphone_core_enable_payload_type(theLinphoneCore,pt,FALSE);
            [LinphoneLogger logc:LinphoneLoggerWarning format:"SILK/24000 and video disabled on old iPhone 3G"];
        }
        linphone_core_enable_video(theLinphoneCore, FALSE, FALSE);
    }
    
    //========
    //视频格式 用vp8才能看到门口机的视频
    [self synchronizeCodecs:linphone_core_get_video_codecs(theLinphoneCore)];
    //=========
    
    [LinphoneLogger logc:LinphoneLoggerWarning format:"Linphone [%s]  started on [%s]", linphone_core_get_version(), [[UIDevice currentDevice].model cStringUsingEncoding:[NSString defaultCStringEncoding]]];
    
    
    // Post event
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSValue valueWithPointer:theLinphoneCore]
                                                     forKey:@"core"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSYLinphoneCoreUpdate
                                                        object:[LinphoneManager instance]
                                                      userInfo:dict];
    
}

- (void)changeFrontCamera
{
    /*DETECT cameras*/
        frontCamId= backCamId=nil;
        char** camlist = (char**)linphone_core_get_video_devices(theLinphoneCore);
        for (char* cam = *camlist;*camlist!=NULL;cam=*++camlist) {
            if (strcmp(FRONT_CAM_NAME, cam)==0) {
                frontCamId = cam;
                //great set default cam to front
                linphone_core_set_video_device(theLinphoneCore, cam);
            }
            if (strcmp(BACK_CAM_NAME, cam)==0) {
                backCamId = cam;
            }
    
        }
}

static BOOL libStarted = FALSE;

- (void)startLibLinphone {
    
    if ( libStarted ) {
        [LinphoneLogger logc:LinphoneLoggerError format:"Liblinphone is already initialized!"];
        return;
    }
    
    libStarted = TRUE;
    
    connectivity = none;
    signal(SIGPIPE, SIG_IGN);
    
    
    // create linphone core
    [self createLinphoneCore];
    linphone_core_migrate_to_multi_transport(theLinphoneCore);
    
    // init audio session (just getting the instance will init)
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    BOOL bAudioInputAvailable= audioSession.inputAvailable;

    NSError* err;
    if( ![audioSession setActive:NO error: &err] && err ){
        //        NSLog(@"audioSession setActive failed: %@", [err description]);
    }
    if(!bAudioInputAvailable){
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No microphone",nil)
                                                        message:NSLocalizedString(@"You need to plug a microphone to your device to use this application.",nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Ok",nil)
                                              otherButtonTitles:nil ,nil];
        [error show];
        [error release];
    }
    
    if ([UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground) {
        //go directly to bg mode
        [self enterBackgroundMode];
    }
}

- (void)resumeCall:(LinphoneCall *)call{
    if (call) {
        linphone_core_resume_call(theLinphoneCore, call);
    }
}

- (void)createLinphoneCore {
    
    if (theLinphoneCore != nil) {
        [LinphoneLogger logc:LinphoneLoggerLog format:"linphonecore is already created"];
        return;
    }
    [LinphoneLogger logc:LinphoneLoggerLog format:"Create linphonecore"];
    
    connectivity=none;
    
    ms_init(); // Need to initialize mediastreamer2 before loading the plugins
    //    ms_factory_new_with_voip();
    
    //libmsilbc_init();
#if defined (HAVE_SILK)
    libmssilk_init();
#endif
#ifdef HAVE_AMR
    libmsamr_init(); //load amr plugin if present from the liblinphone sdk
#endif
#ifdef HAVE_X264
    libmsx264_init(); //load x264 plugin if present from the liblinphone sdk
#endif
#ifdef HAVE_OPENH264
    libmsopenh264_init(); //load openh264 plugin if present from the liblinphone sdk
#endif
    
#if HAVE_G729
    libmsbcg729_init(); // load g729 plugin
#endif
    
    /*to make sure we don't loose debug trace*/
    if ([self lpConfigBoolForKey:@"debugenable_preference"]) {
        linphone_core_enable_logs_with_cb((OrtpLogFunc)linphone_iphone_log_handler);
        //ortp_set_log_level_mask(ORTP_DEBUG|ORTP_MESSAGE|ORTP_WARNING|ORTP_ERROR|ORTP_FATAL);
        ortp_set_log_level_mask("60.12.105.221", ORTP_DEBUG|ORTP_MESSAGE|ORTP_WARNING|ORTP_ERROR|ORTP_FATAL);
        /*must be done before creating linphone core to get its traces too*/
    }
    linphone_core_set_log_collection_path([[LinphoneManager cacheDirectory] UTF8String]);
    linphone_core_enable_log_collection([self lpConfigBoolForKey:@"debugenable_preference"]);

    theLinphoneCore = linphone_core_new_with_config (&linphonec_vtable
                                                     ,configDb
                                                     ,self /* user_data */);
    
    /* set the CA file no matter what, since the remote provisioning could be hitting an HTTPS server */
    const char* lRootCa = [[LinphoneManager bundleFile:@"rootca.pem"] cStringUsingEncoding:[NSString defaultCStringEncoding]];
    linphone_core_set_root_ca(theLinphoneCore, lRootCa);
    
    /* The core will call the linphone_iphone_configuring_status_changed callback when the remote provisioning is loaded (or skipped).
     Wait for this to finish the code configuration */
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(globalStateChangedNotificationHandler:) name:kLinphoneGlobalStateUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configuringStateChangedNotificationHandler:) name:kLinphoneConfiguringStateUpdate object:nil];
    
    /*call iterate once immediately in order to initiate background connections with sip server or remote provisioning grab, if any */
    linphone_core_iterate(theLinphoneCore);
    
    linphone_core_enable_ipv6(theLinphoneCore, ipv6Enabled);/***************启动IPV6*****************/
    
    // start scheduler
    mIterateTimer = [NSTimer scheduledTimerWithTimeInterval:0.02
                                                     target:self
                                                   selector:@selector(iterate)
                                                   userInfo:nil
                                                    repeats:YES];

//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
//    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
//    dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0), 0.02 * NSEC_PER_SEC, 0); //每秒执行
//    dispatch_source_set_event_handler(timer, ^{
//
//        linphone_core_iterate(theLinphoneCore);
//    });
//    dispatch_resume(timer);
}

- (void)destroyLibLinphone {
    [mIterateTimer invalidate];
    //just in case
    [self removeCTCallCenterCb];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (theLinphoneCore != nil) { //just in case application terminate before linphone core initialization
        [LinphoneLogger logc:LinphoneLoggerLog format:"Destroy linphonecore"];
        linphone_core_destroy(theLinphoneCore);
        theLinphoneCore = nil;
        ms_exit(); // Uninitialize mediastreamer2
        
        // Post event
        NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSValue valueWithPointer:theLinphoneCore] forKey:@"core"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSYLinphoneCoreUpdate object:[LinphoneManager instance] userInfo:dict];
        
        SCNetworkReachabilityUnscheduleFromRunLoop(proxyReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        if (proxyReachability)
            CFRelease(proxyReachability);
        proxyReachability=nil;
        
    }
    libStarted  = FALSE;
}

- (void) resetLinphoneCore {
    [self destroyLibLinphone];
    [self createLinphoneCore];
    
    // reset network state to trigger a new network connectivity assessment
    linphone_core_set_network_reachable(theLinphoneCore, FALSE);
}

static int comp_call_id(const LinphoneCall* call , const char *callid) {
    if (linphone_call_log_get_call_id(linphone_call_get_call_log(call)) == nil) {
        ms_error ("no callid for call [%p]", call);
        return 1;
    }
    return strcmp(linphone_call_log_get_call_id(linphone_call_get_call_log(call)), callid);
}

- (void)cancelLocalNotifTimerForCallId:(NSString*)callid {
    //first, make sure this callid is not already involved in a call
    MSList* calls = (MSList*)linphone_core_get_calls(theLinphoneCore);
    MSList* call = ms_list_find_custom(calls, (MSCompareFunc)comp_call_id, [callid UTF8String]);
    if (call != NULL) {
        LinphoneCallAppData* data = linphone_call_get_user_pointer((LinphoneCall*)call->data);
        if ( data->timer )
            [data->timer invalidate];
        data->timer = nil;
        return;
    }
}

- (void)acceptCallForCallId:(NSString*)callid {
    //first, make sure this callid is not already involved in a call
    MSList* calls = (MSList*)linphone_core_get_calls(theLinphoneCore);
    MSList* call = ms_list_find_custom(calls, (MSCompareFunc)comp_call_id, [callid UTF8String]);
    if (call != NULL) {
        [self acceptCall:(LinphoneCall*)call->data];
        return;
    };
}

- (void)addPushCallId:(NSString*) callid {
    //first, make sure this callid is not already involved in a call
    MSList* calls = (MSList*)linphone_core_get_calls(theLinphoneCore);
    if (ms_list_find_custom(calls, (MSCompareFunc)comp_call_id, [callid UTF8String])) {
        Linphone_warn(@"Call id [%@] already handled",callid);
        return;
    };
    if ([pushCallIDs count] > 10 /*max number of pending notif*/)
        [pushCallIDs removeObjectAtIndex:0];
    
    [pushCallIDs addObject:callid];
}

- (BOOL)popPushCallID:(NSString*) callId {
    for (NSString* pendingNotif in pushCallIDs) {
        if ([pendingNotif  compare:callId] == NSOrderedSame) {
            [pushCallIDs removeObject:pendingNotif];
            return TRUE;
        }
    }
    return FALSE;
}

- (BOOL)resignActive {
    linphone_core_stop_dtmf_stream(theLinphoneCore);
    
    return YES;
}

- (void)playMessageSound {
//    BOOL success = [self.messagePlayer play];
//    if( !success ){
//        Linphone_err(@"Could not play the message sound");
//    }
    
    //调用AudioServicePlaySystemSound函数或者AudioServicePlayAlertSound（调用系统振动功能）。
    return;
    NSURL *voiceURL = [[NSBundle mainBundle] URLForResource:@"notes_of_the_optimistic" withExtension:@"caf"];
    // 2. 注册音频文件（第一个参数是音频文件的URL 第二个参数是音频文件的SystemSoundID）
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(voiceURL),&sounds);
    AudioServicesPlaySystemSound([LinphoneManager instance].sounds.vibrate);
}

-(void)stopMessageSound {
    return;
    AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate);
    AudioServicesDisposeSystemSoundID([LinphoneManager instance].sounds.vibrate);
    AudioServicesRemoveSystemSoundCompletion([LinphoneManager instance].sounds.vibrate);
}

static int comp_call_state_paused  (const LinphoneCall* call, const void* param) {
    return linphone_call_get_state(call) != LinphoneCallPaused;
}

- (void) startCallPausedLongRunningTask {
    pausedCallBgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: ^{
        [LinphoneLogger log:LinphoneLoggerWarning format:@"Call cannot be paused any more, too late"];
        [[UIApplication sharedApplication] endBackgroundTask:pausedCallBgTask];
    }];
    [LinphoneLogger log:LinphoneLoggerLog format:@"Long running task started, remaining [%g s] because at least one call is paused"
     ,[[UIApplication  sharedApplication] backgroundTimeRemaining]];
}
- (BOOL)enterBackgroundMode {
    LinphoneProxyConfig* proxyCfg;
    linphone_core_get_default_proxy(theLinphoneCore, &proxyCfg);
    BOOL shouldEnterBgMode=FALSE;
    
    //handle proxy config if any
    if (proxyCfg) {
        if ([[LinphoneManager instance] lpConfigBoolForKey:@"backgroundmode_preference"] ||
            [[LinphoneManager instance] lpConfigBoolForKey:@"pushnotification_preference"]) {
            
            //For registration register
            [self refreshRegisters];
        }
        
        if ([[LinphoneManager instance] lpConfigBoolForKey:@"backgroundmode_preference"]) {
            
            //register keepalive
            if ([[UIApplication sharedApplication] setKeepAliveTimeout:600/*(NSTimeInterval)linphone_proxy_config_get_expires(proxyCfg)*/
                                                               handler:^{
                                                                   [LinphoneLogger logc:LinphoneLoggerWarning format:"keepalive handler"];
                                                                   if (mLastKeepAliveDate)
                                                                       [mLastKeepAliveDate release];
                                                                   mLastKeepAliveDate=[NSDate date];
                                                                   [mLastKeepAliveDate retain];
                                                                   if (theLinphoneCore == nil) {
                                                                       [LinphoneLogger logc:LinphoneLoggerWarning format:"It seems that Linphone BG mode was deactivated, just skipping"];
                                                                       return;
                                                                   }
                                                                   //kick up network cnx, just in case
                                                                   [self refreshRegisters];
                                                                   linphone_core_iterate(theLinphoneCore);
                                                               }
                 ]) {
                
                
                [LinphoneLogger logc:LinphoneLoggerLog format:"keepalive handler succesfully registered"];
            } else {
                [LinphoneLogger logc:LinphoneLoggerLog format:"keepalive handler cannot be registered"];
            }
            shouldEnterBgMode=TRUE;
        }
    }
    
    LinphoneCall* currentCall = linphone_core_get_current_call(theLinphoneCore);
    const MSList* callList = linphone_core_get_calls(theLinphoneCore);
    if (!currentCall //no active call
        && callList // at least one call in a non active state
        && ms_list_find_custom((MSList*)callList, (MSCompareFunc) comp_call_state_paused, NULL)) {
        [self startCallPausedLongRunningTask];
    }
    if (callList){
        /*if at least one call exist, enter normal bg mode */
        shouldEnterBgMode=TRUE;
    }
    /*stop the video preview*/
    if (theLinphoneCore){
        linphone_core_enable_video_preview(theLinphoneCore, FALSE);
        linphone_core_iterate(theLinphoneCore);
    }
    linphone_core_stop_dtmf_stream(theLinphoneCore);
    
    [LinphoneLogger logc:LinphoneLoggerLog format:"Entering [%s] bg mode",shouldEnterBgMode?"normal":"lite"];
    
    if (!shouldEnterBgMode ) {
        if([[LinphoneManager instance] lpConfigBoolForKey:@"pushnotification_preference"]) {
            [LinphoneLogger logc:LinphoneLoggerLog format:"Keeping lc core to handle push"];
            /*destroy voip socket if any and reset connectivity mode*/
            connectivity=none;
            linphone_core_set_network_reachable(theLinphoneCore, FALSE);
            return YES;
        }
        return NO;
        
    } else
        return YES;
}

- (void)becomeActive {
    [self refreshRegisters];
    if (pausedCallBgTask) {
        [[UIApplication sharedApplication]  endBackgroundTask:pausedCallBgTask];
        pausedCallBgTask=0;
    }
    if (incallBgTask) {
        [[UIApplication sharedApplication]  endBackgroundTask:incallBgTask];
        incallBgTask=0;
    }
    
    /*IOS specific*/
    linphone_core_start_dtmf_stream(theLinphoneCore);
    
    /*start the video preview in case we are in the main view*/
    if ([LinphoneManager runningOnIpad]  && linphone_core_video_enabled(theLinphoneCore) && [self lpConfigBoolForKey:@"preview_preference"]){
        linphone_core_enable_video_preview(theLinphoneCore, TRUE);
    }
    /*check last keepalive handler date*/
    if (mLastKeepAliveDate!=Nil){
        NSDate *current=[NSDate date];
        if ([current timeIntervalSinceDate:mLastKeepAliveDate]>700){
            NSString *datestr=[mLastKeepAliveDate description];
            [LinphoneLogger logc:LinphoneLoggerWarning format:"keepalive handler was called for the last time at %@",datestr];
        }
    }
}

- (void)beginInterruption {
    LinphoneCall* c = linphone_core_get_current_call(theLinphoneCore);
    [LinphoneLogger logc:LinphoneLoggerLog format:"Sound interruption detected!"];
    if (c && linphone_call_get_state(c) == LinphoneCallStreamsRunning) {
        linphone_core_pause_call(theLinphoneCore, c);
    }
}

- (void)endInterruption {
    [LinphoneLogger logc:LinphoneLoggerLog format:"Sound interruption ended!"];
}

- (void)refreshRegisters{
    if (connectivity==none){
        //don't trust ios when he says there is no network. Create a new reachability context, the previous one might be mis-functionning.
        [self setupNetworkReachabilityCallback];
    }
    linphone_core_refresh_registers(theLinphoneCore);//just to make sure REGISTRATION is up to date
}


- (void)copyDefaultSettings {
    NSString *src = [LinphoneManager bundleFile:[LinphoneManager runningOnIpad]?@"linphonerc~ipad":@"linphonerc"];
    NSString *dst = [LinphoneManager documentFile:@".linphonerc"];
    [LinphoneManager copyFile:src destination:dst override:FALSE];
}


#pragma mark - Audio route Functions

- (bool)allowSpeaker {
    bool notallow = false;
    CFStringRef lNewRoute = CFSTR("Unknown");
    UInt32 lNewRouteSize = sizeof(lNewRoute);
    OSStatus lStatus = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &lNewRouteSize, &lNewRoute);
    if (!lStatus && lNewRouteSize > 0) {
        NSString *route = (NSString *) lNewRoute;
        notallow = [route isEqualToString: @"Headset"] ||
        [route isEqualToString: @"Headphone"] ||
        [route isEqualToString: @"HeadphonesAndMicrophone"] ||
        [route isEqualToString: @"HeadsetInOut"] ||
        [route isEqualToString: @"Lineout"] ||
        [LinphoneManager runningOnIpad];
        CFRelease(lNewRoute);
    }
    return !notallow;
}

static void audioRouteChangeListenerCallback (
                                              void                   *inUserData,                                 // 1
                                              AudioSessionPropertyID inPropertyID,                                // 2
                                              UInt32                 inPropertyValueSize,                         // 3
                                              const void             *inPropertyValue                             // 4
) {
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return; // 5
    LinphoneManager* lm = (LinphoneManager*)inUserData;
    
    bool speakerEnabled = false;
    CFStringRef lNewRoute = CFSTR("Unknown");
    UInt32 lNewRouteSize = sizeof(lNewRoute);
    OSStatus lStatus = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &lNewRouteSize, &lNewRoute);
    if (!lStatus && lNewRouteSize > 0) {
        NSString *route = (NSString *) lNewRoute;
        [LinphoneLogger logc:LinphoneLoggerLog format:"Current audio route is [%s]", [route cStringUsingEncoding:[NSString defaultCStringEncoding]]];
        
        speakerEnabled = [route isEqualToString: @"Speaker"] ||
        [route isEqualToString: @"SpeakerAndMicrophone"];
        if (![LinphoneManager runningOnIpad] && [route isEqualToString:@"HeadsetBT"] && !speakerEnabled) {
            lm.bluetoothEnabled = TRUE;
            lm.bluetoothAvailable = TRUE;
            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:lm.bluetoothAvailable], @"available", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLinphoneBluetoothAvailabilityUpdate object:lm userInfo:dict];
        } else {
            lm.bluetoothEnabled = FALSE;
        }
        CFRelease(lNewRoute);
    }
    
    if(speakerEnabled != lm.speakerEnabled) { // Reforce value
        lm.speakerEnabled = lm.speakerEnabled;
    }
}

- (void)setSpeakerEnabled:(BOOL)enable {
    speakerEnabled = enable;
    
    if(enable && [self allowSpeaker]) {
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute
                                 , sizeof (audioRouteOverride)
                                 , &audioRouteOverride);
        bluetoothEnabled = FALSE;
    } else {
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute
                                 , sizeof (audioRouteOverride)
                                 , &audioRouteOverride);
    }
    
    if (bluetoothAvailable) {
        UInt32 bluetoothInputOverride = bluetoothEnabled;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryEnableBluetoothInput, sizeof(bluetoothInputOverride), &bluetoothInputOverride);
    }
}

- (void)setBluetoothEnabled:(BOOL)enable {
    if (bluetoothAvailable) {
        // The change of route will be done in setSpeakerEnabled
        bluetoothEnabled = enable;
        if (bluetoothEnabled) {
            [self setSpeakerEnabled:FALSE];
        } else {
            [self setSpeakerEnabled:speakerEnabled];
        }
    }
}

#pragma mark - Call Functions

- (void)acceptCall:(LinphoneCall *)call{
    if (call == NULL){
        return;
    }
    LinphoneCallParams* lcallParams = linphone_core_create_call_params(theLinphoneCore,call);
    if (!lcallParams) {
        NSLog(@"====linphone_core_create_call_params为NULL====");
        return;
    }
    if([self lpConfigBoolForKey:@"edge_opt_preference"]) {
        bool low_bandwidth = self.network == network_2g;
        if(low_bandwidth) {
            [LinphoneLogger log:LinphoneLoggerLog format:@"Low bandwidth mode"];
        }
        linphone_call_params_enable_low_bandwidth(lcallParams, low_bandwidth);
    }
    
    //视频开启
    linphone_call_params_enable_video(lcallParams, videoEnable);
    
    linphone_core_accept_call_with_params(theLinphoneCore,call, lcallParams);
}

- (void)call:(NSString *)address displayName:(NSString*)displayName transfer:(BOOL)transfer {
    if (!linphone_core_is_network_reachable(theLinphoneCore)) {
        UIAlertView* error = [[UIAlertView alloc]	initWithTitle:NSLocalizedString(@"提示",nil)
                                                        message:NSLocalizedString(@"网络连接失败",nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"确定",nil)
                                              otherButtonTitles:nil];
        [error show];
        [error release];
        return;
    }
    
    CTCallCenter* callCenter = [[CTCallCenter alloc] init];
    if ([callCenter currentCalls]!=nil) {
        [LinphoneLogger logc:LinphoneLoggerError format:"GSM call in progress, cancelling outgoing SIP call request"];
        UIAlertView* error = [[UIAlertView alloc]	initWithTitle:NSLocalizedString(@"Cannot make call",nil)
                                                        message:NSLocalizedString(@"Please terminate GSM call",nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"YES",nil)
                                              otherButtonTitles:nil];
        [error show];
        [error release];
        [callCenter release];
        return;
    }
    [callCenter release];
    
    //	LinphoneProxyConfig* proxyCfg;
    //get default proxy
    linphone_core_get_default_proxy_config(theLinphoneCore);
    //	linphone_core_get_default_proxy(theLinphoneCore,&proxyCfg);
    //	LinphoneCallParams* lcallParams = linphone_core_create_default_call_parameters(theLinphoneCore);
    LinphoneCallParams* lcallParams = linphone_core_create_call_params(theLinphoneCore, NULL);
    if([self lpConfigBoolForKey:@"edge_opt_preference"]) {
        bool low_bandwidth = self.network == network_2g;
        if(low_bandwidth) {
            [LinphoneLogger log:LinphoneLoggerLog format:@"Low bandwidth mode"];
        }
        linphone_call_params_enable_low_bandwidth(lcallParams, low_bandwidth);
    }
    
    //视频开启
    linphone_call_params_enable_video(lcallParams, videoEnable);
    
    LinphoneCall* call=NULL;
    
    BOOL addressIsASCII = [address canBeConvertedToEncoding:[NSString defaultCStringEncoding]];
    
    if ([address length] == 0) return; //just return
    if( !addressIsASCII ){
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid SIP address",nil)
                                                        message:NSLocalizedString(@"The address should only contain ASCII data",nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Continue",nil)
                                              otherButtonTitles:nil];
        [error show];
        [error release];
        
    }
    //	LinphoneAddress* linphoneAddress = linphone_core_interpret_url(theLinphoneCore, [address cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    LinphoneAddress* linphoneAddress = [self normalizeSipOrPhoneAddress:address];
    if (linphoneAddress) {
        
        if(displayName!=nil) {
            //            char *display_name =[displayName cStringUsingEncoding:[NSString defaultCStringEncoding]];
            linphone_address_set_display_name(linphoneAddress,  displayName.UTF8String);
        }
        if ([[LinphoneManager instance] lpConfigBoolForKey:@"override_domain_with_default_one"])
            //			linphone_address_set_domain(linphoneAddress, [[[LinphoneManager instance] lpConfigStringForKey:@"domain" forSection:@"wizard"] cStringUsingEncoding:[NSString defaultCStringEncoding]]);
            linphone_address_set_domain(linphoneAddress,[[LinphoneManager instance] lpConfigStringForKey:@"domain" forSection:@"wizard"].UTF8String);
        if(transfer) {
            //			linphone_core_transfer_call(theLinphoneCore, linphone_core_get_current_call(theLinphoneCore), [address cStringUsingEncoding:[NSString defaultCStringEncoding]]);
            linphone_core_transfer_call(theLinphoneCore, linphone_core_get_current_call(theLinphoneCore), address.UTF8String);
        } else {
            call=linphone_core_invite_address_with_params(theLinphoneCore, linphoneAddress, lcallParams);
        }
        linphone_address_destroy(linphoneAddress);
        
        
    } else {
        
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid SIP address",nil)
                                                        message:NSLocalizedString(@"Either configure a SIP proxy server from settings prior to place a call or use a valid SIP address (I.E sip:john@example.net)",nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Continue",nil)
                                              otherButtonTitles:nil];
        [error show];
        [error release];
        
    }
    
    
    if (call) {
        // The LinphoneCallAppData object should be set on call creation with callback
        // - (void)onCall:StateChanged:withMessage:. If not, we are in big trouble and expect it to crash
        // We are NOT responsible for creating the AppData.
        LinphoneCallAppData* data=(LinphoneCallAppData*)linphone_call_get_user_pointer(call);
        if (data==nil)
            [LinphoneLogger log:LinphoneLoggerError format:@"New call instanciated but app data was not set. Expect it to crash."];
        /* will be used later to notify user if video was not activated because of the linphone core*/
        data->videoRequested = linphone_call_params_video_enabled(lcallParams);
    }
    linphone_call_params_destroy(lcallParams);
}

- (void)changeVideoSize:(int)videoSize
{
//    // video section
//    {
//        [self synchronizeCodecs:linphone_core_get_video_codecs(LC)];
//        
//        LinphoneVideoPolicy policy;
//        policy.automatically_initiate = [self boolForKey:@"start_video_preference"];
//        policy.automatically_accept = [self boolForKey:@"accept_video_preference"];
//        linphone_core_set_video_policy(LC, &policy);
//        linphone_core_enable_self_view(LC, [self boolForKey:@"self_video_preference"]);
//        BOOL preview_preference = IPAD && [self boolForKey:@"preview_preference"];
//        [lm lpConfigSetInt:preview_preference forKey:@"preview_preference"];
//        
//        NSString *videoPreset = [self stringForKey:@"video_preset_preference"];
//        linphone_core_set_video_preset(LC, [videoPreset UTF8String]);
//        int bw;
//        MSVideoSize vsize;
//        switch ([self integerForKey:@"video_preferred_size_preference"]) {
//            case 0:
//                MS_VIDEO_SIZE_ASSIGN(vsize, 720P);
//                // 128 = margin for audio, the BW includes both video and audio
//                bw = 1024 + 128;
//                break;
//            case 1:
//                MS_VIDEO_SIZE_ASSIGN(vsize, VGA);
//                // no margin for VGA or QVGA, because video encoders can encode the
//                // target resulution in less than the asked bandwidth
//                bw = 660;
//                break;
//            case 2:
//            default:
//                MS_VIDEO_SIZE_ASSIGN(vsize, QVGA);
//                bw = 380;
//                break;
//        }
//        linphone_core_set_preferred_video_size(LC, vsize);
//        if (![videoPreset isEqualToString:@"custom"]) {
//            [self setInteger:0 forKey:@"video_preferred_fps_preference"];
//            [self setInteger:bw forKey:@"download_bandwidth_preference"];
//        }
//        linphone_core_set_preferred_framerate(LC, [self integerForKey:@"video_preferred_fps_preference"]);
//        linphone_core_set_download_bandwidth(LC, [self integerForKey:@"download_bandwidth_preference"]);
//        linphone_core_set_upload_bandwidth(LC, [self integerForKey:@"download_bandwidth_preference"]);
//    }
    
    const LinphoneVideoPolicy *pol;
    pol = linphone_core_get_video_policy(LC);
    
    LinphoneVideoPolicy policy;
    policy.automatically_initiate = (pol->automatically_initiate);
    policy.automatically_accept = (pol->automatically_accept);
    linphone_core_set_video_policy(LC, &policy);
    linphone_core_enable_self_view(LC, linphone_core_self_view_enabled(LC));
    BOOL preview_preference = YES;
    [LinphoneManager.instance lpConfigSetInt:preview_preference forKey:@"preview_preference"];
    
    const char *preset = linphone_core_get_video_preset(LC);
    NSString *videoPreset = preset ? [[NSString alloc] initWithCString:preset encoding:NSUTF8StringEncoding] : @"default";
    linphone_core_set_video_preset(LC, [videoPreset UTF8String]);
    
    
    int bandwidth = 512;
    MSVideoSize vsize;
    switch (videoSize) {
        case 0:
            vsize = ms_video_size_make(352,288);
            linphone_core_set_preview_video_size_by_name(LC,"cif");
//            MS_VIDEO_SIZE_ASSIGN(vsize, 720P);
//            // 128 = margin for audio, the BW includes both video and audio
            bandwidth = 1024 + 128;
            break;
        case 1:
            vsize = ms_video_size_make(176,144);
            linphone_core_set_preview_video_size_by_name(LC,"qcif");
//            MS_VIDEO_SIZE_ASSIGN(vsize, VGA);
//            // no margin for VGA or QVGA, because video encoders can encode the
//            // target resulution in less than the asked bandwidth
            bandwidth = 256;
            break;
        default:
            vsize = ms_video_size_make(352,288);
//            MS_VIDEO_SIZE_ASSIGN(vsize, QVGA);
            bandwidth = 1024 + 128;
            break;
    }
    
    linphone_core_set_preferred_video_size(LC, vsize);
    linphone_core_set_preview_video_size(LC, vsize);
    
    linphone_core_set_preferred_framerate(LC, 0);
    linphone_core_set_download_bandwidth(LC,bandwidth);
    linphone_core_set_upload_bandwidth(LC,bandwidth);
    
    
    if ([SYLinphoneManager instance].currentCall) {
        const LinphoneCallParams *params = linphone_call_get_current_params([SYLinphoneManager instance].currentCall);
        //linphone_call_params_enable_audio(params,TRUE);
        linphone_core_update_call(LC, [SYLinphoneManager instance].currentCall, params);

    }
    return;
    
    //linphone_core_enable_video_preview(LC, TRUE);
    LinphoneCall* currentCall = linphone_core_get_current_call(theLinphoneCore);
    
    //linphone_core_pause_call(LC,currentCall);

    linphone_core_set_preferred_video_size(LC, vsize);


    linphone_core_update_call(LC, currentCall, linphone_core_create_call_params(LC,currentCall));
    linphone_core_set_preferred_video_size(LC, vsize);
    
    
    
    //const LinphoneCallParams *params = linphone_call_get_current_params(currentCall);
    
    //LinphoneCallParams *params =
    //linphone_core_create_call_params(LC,currentCall);
    // stop video
//    linphone_call_params_enable_video(params, FALSE);
//    
//    
//    
//    LinphoneCallParams *call_params = linphone_call_get_current_params(currentCall);
    //linphone_call_params_enable_video(linphone_call_get_current_params(currentCall), TRUE);
    
    //linphone_call_params_enable_video(params, FALSE);
    
    
    //linphone_core_update_call(LinphoneCore *lc, LinphoneCall *call, const LinphoneCallParams *params);
    
    //linphone_core_enable_video_preview(LC, FALSE);
    //linphone_core_iterate(LC);
    //toggle_video_preview(lc,FALSE);
}

#pragma mark - Property Functions

- (void)setPushNotificationToken:(NSData *)apushNotificationToken {
    if(apushNotificationToken == pushNotificationToken) {
        return;
    }
    if(pushNotificationToken != nil) {
        [pushNotificationToken release];
        pushNotificationToken = nil;
    }
    
    if(apushNotificationToken != nil) {
        pushNotificationToken = [apushNotificationToken retain];
    }
    LinphoneProxyConfig *cfg=nil;
    linphone_core_get_default_proxy(theLinphoneCore, &cfg);
    if (cfg ) {
        linphone_proxy_config_edit(cfg);
        [self configurePushTokenForProxyConfig: cfg];
        linphone_proxy_config_done(cfg);
    }
}

- (void)configurePushTokenForProxyConfig:(LinphoneProxyConfig*)proxyCfg{
    NSData *tokenData =  pushNotificationToken;
    if(tokenData != nil && [self lpConfigBoolForKey:@"pushnotification_preference"]) {
        const unsigned char *tokenBuffer = [tokenData bytes];
        NSMutableString *tokenString = [NSMutableString stringWithCapacity:[tokenData length]*2];
        for(int i = 0; i < [tokenData length]; ++i) {
            [tokenString appendFormat:@"%02X", (unsigned int)tokenBuffer[i]];
        }
        // NSLocalizedString(@"IC_MSG", nil); // Fake for genstrings
        // NSLocalizedString(@"IM_MSG", nil); // Fake for genstrings
#ifdef DEBUG
#define APPMODE_SUFFIX @"dev"
#else
#define APPMODE_SUFFIX @"prod"
#endif
        NSString *params = [NSString stringWithFormat:@"app-id=%@.%@;pn-type=apple;pn-tok=%@;pn-msg-str=IM_MSG;pn-call-str=IC_MSG;pn-call-snd=ring.caf;pn-msg-snd=msg.caf", [[NSBundle mainBundle] bundleIdentifier],APPMODE_SUFFIX,tokenString];
        
        linphone_proxy_config_set_contact_uri_parameters(proxyCfg, [params UTF8String]);
        linphone_proxy_config_set_contact_parameters(proxyCfg, NULL);
    } else {
        // no push token:
        linphone_proxy_config_set_contact_uri_parameters(proxyCfg, NULL);
        linphone_proxy_config_set_contact_parameters(proxyCfg, NULL);
    }
}



#pragma mark - Misc Functions

+ (NSString*)bundleFile:(NSString*)file {
    return [[NSBundle mainBundle] pathForResource:[file stringByDeletingPathExtension] ofType:[file pathExtension]];
}

+ (NSString*)documentFile:(NSString*)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:file];
}

+ (NSString*)cacheDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    BOOL isDir = NO;
    NSError *error;
    // cache directory must be created if not existing
    if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    return cachePath;
}

+ (int)unreadMessageCount {
    int count = 0;
    MSList* rooms = linphone_core_get_chat_rooms([LinphoneManager getLc]);
    MSList* item = rooms;
    while (item) {
        LinphoneChatRoom* room = (LinphoneChatRoom*)item->data;
        if( room ){
            count += linphone_chat_room_get_unread_messages_count(room);
        }
        item = item->next;
    }
    
    return count;
}

+ (BOOL)copyFile:(NSString*)src destination:(NSString*)dst override:(BOOL)override {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:dst] == YES) {
        if(override) {
            [fileManager removeItemAtPath:dst error:&error];
            if(error != nil) {
                [LinphoneLogger log:LinphoneLoggerError format:@"Can't remove \"%@\": %@", dst, [error localizedDescription]];
                return FALSE;
            }
        } else {
            [LinphoneLogger log:LinphoneLoggerWarning format:@"\"%@\" already exists", dst];
            return FALSE;
        }
    }
    if ([fileManager fileExistsAtPath:src] == NO) {
        [LinphoneLogger log:LinphoneLoggerError format:@"Can't find \"%@\": %@", src, [error localizedDescription]];
        return FALSE;
    }
    [fileManager copyItemAtPath:src toPath:dst error:&error];
    if(error != nil) {
        [LinphoneLogger log:LinphoneLoggerError format:@"Can't copy \"%@\" to \"%@\": %@", src, dst, [error localizedDescription]];
        return FALSE;
    }
    return TRUE;
}

- (void)configureVbrCodecs{
    PayloadType *pt;
    int bitrate=lp_config_get_int(configDb,"audio","codec_bitrate_limit",kLinphoneAudioVbrCodecDefaultBitrate);/*default value is in linphonerc or linphonerc-factory*/
    const MSList *audio_codecs = linphone_core_get_audio_codecs(theLinphoneCore);
    const MSList* codec = audio_codecs;
    while (codec) {
        pt = codec->data;
        if( linphone_core_payload_type_is_vbr(theLinphoneCore, pt) ) {
            linphone_core_set_payload_type_bitrate(theLinphoneCore, pt, bitrate);
        }
        
        codec = codec->next;
    }
}

-(void)setLogsEnabled:(BOOL)enabled {
    if (enabled) {
        linphone_core_enable_logs_with_cb((OrtpLogFunc)linphone_iphone_log_handler);
        ortp_set_log_level_mask("", ORTP_DEBUG|ORTP_MESSAGE|ORTP_WARNING|ORTP_ERROR|ORTP_FATAL);
        linphone_core_enable_log_collection(enabled);
    } else {
        linphone_core_enable_log_collection(enabled);
        linphone_core_disable_logs();
    }
}

+(id)getMessageAppDataForKey:(NSString*)key inMessage:(LinphoneChatMessage*)msg {
    
    if(msg == nil ) return nil;
    
    id value = nil;
    const char* appData = linphone_chat_message_get_appdata(msg);
    if( appData) {
        NSDictionary* appDataDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:appData length:strlen(appData)] options:0 error:nil];
        value = [appDataDict objectForKey:key];
    }
    return value;
}

+(void)setValueInMessageAppData:(id)value forKey:(NSString*)key inMessage:(LinphoneChatMessage*)msg {
    
    NSMutableDictionary* appDataDict = [NSMutableDictionary dictionary];
    const char* appData = linphone_chat_message_get_appdata(msg);
    if( appData) {
        appDataDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:appData length:strlen(appData)] options:NSJSONReadingMutableContainers error:nil];
    }
    
    [appDataDict setValue:value forKey:key];
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:appDataDict options:0 error:nil];
    NSString* appdataJSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    linphone_chat_message_set_appdata(msg, [appdataJSON UTF8String]);
    [appdataJSON release];
}

#pragma mark - LPConfig Functions

- (void)lpConfigSetString:(NSString*)value forKey:(NSString*)key {
    [self lpConfigSetString:value forKey:key forSection:[NSString stringWithUTF8String:LINPHONERC_APPLICATION_KEY]];
}

- (void)lpConfigSetString:(NSString*)value forKey:(NSString*)key forSection:(NSString *)section {
    if (!key) return;
    lp_config_set_string(configDb, [section UTF8String], [key UTF8String], value?[value UTF8String]:NULL);
}

- (NSString*)lpConfigStringForKey:(NSString*)key {
    return [self lpConfigStringForKey:key forSection:[NSString stringWithUTF8String:LINPHONERC_APPLICATION_KEY]];
}
- (NSString*)lpConfigStringForKey:(NSString*)key withDefault:(NSString*)defaultValue {
    NSString* value = [self lpConfigStringForKey:key];
    return value?value:defaultValue;
}

- (NSString*)lpConfigStringForKey:(NSString*)key forSection:(NSString *)section {
    if (!key) return nil;
    const char* value = lp_config_get_string(configDb, [section UTF8String], [key UTF8String], NULL);
    if (value)
        return [NSString stringWithUTF8String:value];
    else
        return nil;
}

- (void)lpConfigSetInt:(NSInteger)value forKey:(NSString*)key {
    [self lpConfigSetInt:value forKey:key forSection:[NSString stringWithUTF8String:LINPHONERC_APPLICATION_KEY]];
}

- (void)lpConfigSetInt:(NSInteger)value forKey:(NSString*)key forSection:(NSString *)section {
    if (!key) return;
    lp_config_set_int(configDb, [section UTF8String], [key UTF8String], (int)value );
}

- (NSInteger)lpConfigIntForKey:(NSString*)key {
    return [self lpConfigIntForKey:key forSection:[NSString stringWithUTF8String:LINPHONERC_APPLICATION_KEY]];
}

- (NSInteger)lpConfigIntForKey:(NSString*)key forSection:(NSString *)section {
    if (!key) return -1;
    return lp_config_get_int(configDb, [section UTF8String], [key UTF8String], -1);
}

- (void)lpConfigSetBool:(BOOL)value forKey:(NSString*)key {
    [self lpConfigSetBool:value forKey:key forSection:[NSString stringWithUTF8String:LINPHONERC_APPLICATION_KEY]];
}

- (void)lpConfigSetBool:(BOOL)value forKey:(NSString*)key forSection:(NSString *)section {
    return [self lpConfigSetInt:(NSInteger)(value == TRUE) forKey:key forSection:section];
}

- (BOOL)lpConfigBoolForKey:(NSString*)key {
    return [self lpConfigBoolForKey:key forSection:[NSString stringWithUTF8String:LINPHONERC_APPLICATION_KEY]];
}

- (BOOL)lpConfigBoolForKey:(NSString*)key forSection:(NSString *)section {
    return [self lpConfigIntForKey:key forSection:section] == 1;
}

#pragma mark - GSM management

-(void) removeCTCallCenterCb {
    if (mCallCenter != nil) {
        [LinphoneLogger log:LinphoneLoggerLog format:@"Removing CT call center listener [%p]",mCallCenter];
        mCallCenter.callEventHandler=NULL;
        [mCallCenter release];
    }
    mCallCenter=nil;
}

- (void)setupGSMInteraction {
    
    [self removeCTCallCenterCb];
    mCallCenter = [[CTCallCenter alloc] init];
    [LinphoneLogger log:LinphoneLoggerLog format:@"Adding CT call center listener [%p]",mCallCenter];
    mCallCenter.callEventHandler = ^(CTCall* call) {
        // post on main thread
        [self performSelectorOnMainThread:@selector(handleGSMCallInteration:)
                               withObject:mCallCenter
                            waitUntilDone:YES];
    };
    
}

- (void)handleGSMCallInteration: (id) cCenter {
    CTCallCenter* ct = (CTCallCenter*) cCenter;
    /* pause current call, if any */
    LinphoneCall* call = linphone_core_get_current_call(theLinphoneCore);
    if ([ct currentCalls]!=nil) {
        if (call) {
            [LinphoneLogger log:LinphoneLoggerLog format:@"Pausing SIP call because GSM call"];
            linphone_core_pause_call(theLinphoneCore, call);
            [self startCallPausedLongRunningTask];
        } else if (linphone_core_is_in_conference(theLinphoneCore)) {
            [LinphoneLogger log:LinphoneLoggerLog format:@"Leaving conference call because GSM call"];
            linphone_core_leave_conference(theLinphoneCore);
            [self startCallPausedLongRunningTask];
        }
    } //else nop, keep call in paused state
}

-(NSString*) contactFilter {
    NSString* filter=@"*";
    if ( [self lpConfigBoolForKey:@"contact_filter_on_default_domain"]) {
        LinphoneProxyConfig* proxy_cfg;
        linphone_core_get_default_proxy(theLinphoneCore, &proxy_cfg);
        if (proxy_cfg && linphone_proxy_config_get_addr(proxy_cfg)) {
            return [NSString stringWithCString:linphone_proxy_config_get_domain(proxy_cfg)
                                      encoding:[NSString defaultCStringEncoding]];
        }
    }
    return filter;
}

#pragma Tunnel

- (void)setTunnelMode:(TunnelMode)atunnelMode {
    LinphoneTunnel *tunnel = linphone_core_get_tunnel(theLinphoneCore);
    tunnelMode = atunnelMode;
    switch (tunnelMode) {
        case tunnel_off:
            linphone_tunnel_enable(tunnel, false);
            break;
        case tunnel_on:
            linphone_tunnel_enable(tunnel, true);
            break;
        case tunnel_wwan:
            if (connectivity != wwan) {
                linphone_tunnel_enable(tunnel, false);
            } else {
                linphone_tunnel_enable(tunnel, true);
            }
            break;
        case tunnel_auto:
            linphone_tunnel_auto_detect(tunnel);
            break;
            
    }
}



#pragma mark - ---------自己加的---
//h264视频格式不要，不然显示不了门口机视频
- (void)synchronizeCodecs:(const MSList *)codecs {
    PayloadType *pt;
    const MSList *elem;
    
    for (elem = codecs; elem != NULL; elem = elem->next) {
        pt = (PayloadType *)elem->data;
        NSString *pref = [LinphoneManager getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
        if ([pref isEqualToString:@"h264_preference"]) {
            linphone_core_enable_payload_type(theLinphoneCore, pt, FALSE);
        }else if ([pref isEqualToString:@"vp8_preference"]) {
            linphone_core_enable_payload_type(theLinphoneCore, pt, TRUE);
        }
    }
}

- (NSString *)getSipAdress:(LinphoneAddress *)address{
    
    NSString *phoneNumber = @"";
    LinphoneProxyConfig *cfg = linphone_core_get_default_proxy_config([LinphoneManager getLc]);
 
    const LinphoneAddress *identity = linphone_proxy_config_get_identity_address(cfg);
    if (identity) {
        phoneNumber = [NSString stringWithUTF8String:linphone_address_get_username(identity)];
    }
    
    //NSString *address2 = [NSString stringWithUTF8String:linphone_proxy_config_get_server_addr(cfg)];
    
    return phoneNumber;
}

- (LinphoneAddress *)normalizeSipOrPhoneAddress:(NSString *)value {
    if (!value) {
        return NULL;
    }

    LinphoneProxyConfig *cfg = linphone_core_get_default_proxy_config([LinphoneManager getLc]);
    const char * normvalue;
    if (linphone_proxy_config_is_phone_number(cfg, value.UTF8String)) {
        normvalue = linphone_proxy_config_normalize_phone_number(cfg, value.UTF8String);
    } else {
        normvalue = value.UTF8String;
    }
    LinphoneAddress *addr = linphone_proxy_config_normalize_sip_uri(cfg, normvalue);
    if (!addr){
        return NULL;
    }
    // since user wants to escape plus, we assume it expects to have phone numbers by default
    if (addr && cfg && (linphone_proxy_config_get_dial_escape_plus(cfg))) {
        linphone_address_set_username(addr, normvalue);
    } else {
        linphone_address_set_username(addr, value.UTF8String);
    }
    
    return addr;
}


//收回某个本地推送
- (void)cancelLocalNotificationWithKey:(NSString *)key
{
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    
    for (UILocalNotification *notification in localNotifications){
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            // 根据设置通知参数时指定的key来获取通知参数
            NSNumber *state = userInfo[key];
            
            // 对方打电话过来，又挂掉后，就删除已经推送的来电提醒通知
            if ([state intValue] == LinphoneCallIncomingReceived){
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                if(notification.applicationIconBadgeNumber > 0){
                    notification.applicationIconBadgeNumber = notification.applicationIconBadgeNumber - 1;
                }
                break;
            }
        }
    }
}


- (BOOL)sendMessage:(NSString *)message withExterlBodyUrl:(NSURL *)externalUrl withInternalURL:(NSURL *)internalUrl Address:(NSString *)sipNumber{
    
    LinphoneAddress *addr =  [self normalizeSipOrPhoneAddress:sipNumber];
    if (addr == NULL)
        return NO;
    
    LinphoneChatRoom *room = linphone_core_get_chat_room([LinphoneManager getLc], addr);
    LinphoneChatMessage *msg = linphone_chat_room_create_message(room, [message UTF8String]);
    if (externalUrl) {
        linphone_chat_message_set_external_body_url(msg, [[externalUrl absoluteString] UTF8String]);
    }
    
    if (internalUrl) {
        // internal url is saved in the appdata for display and later save
        [LinphoneManager setValueInMessageAppData:[internalUrl absoluteString] forKey:@"localimage" inMessage:msg];
    }
    
    // we must ref & unref message because in case of error, it will be destroy otherwise
    linphone_chat_room_send_chat_message(room, linphone_chat_message_ref(msg));
    linphone_chat_message_unref(msg);
    
    NSString *content = [self TextMessageForChat:msg];
    NSString *time = [self timeToString:linphone_chat_message_get_time(msg)];
    // Post event
    
    LinphoneChatMessageState state = linphone_chat_message_get_state(msg);
    NSDictionary *dict = @{
                           @"user" : [self getSipAdress:linphone_chat_message_get_from_address(msg)],
                           @"time" : time,
                           @"message" : content,
                           @"state" : [NSNumber numberWithInt:1]
                           };
    
    [NSNotificationCenter.defaultCenter postNotificationName:kLinphoneMessageReceived object:self userInfo:dict];
    
    return TRUE;
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //[[NSNotificationCenter defaultCenter] postNotificationName:SYNOTICE_Close_SYGuardMonitorViewController object:nil];
}


- (LinphoneCall *)callByCallId:(NSString *)call_id {
    const bctbx_list_t *calls = linphone_core_get_calls(theLinphoneCore);
    if (!calls) {
        return NULL;
    }
    bctbx_list_t *call_tmp = bctbx_list_find_custom(calls, (bctbx_compare_func)comp_call_id, [call_id UTF8String]);
    if (!call_tmp) {
        return NULL;
    }
    LinphoneCall *call = (LinphoneCall *)call_tmp->data;
    return call;
}
@end
