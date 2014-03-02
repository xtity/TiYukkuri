/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "ComXtityModTiYukkuriModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#include <sys/stat.h>

@implementation ComXtityModTiYukkuriModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"c88299ac-83d4-45a0-b17c-f32e07a1e6d2";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.xtity.mod.TiYukkuri";
}


///// custom /////
void * file_load(const char * file, int * psize) {
    FILE *fp;
    char *data;
    struct stat st;
    *psize = 0;
    if( stat(file, &st)!=0) return NULL;
    if((data=(char *)malloc(st.st_size))==NULL){
        fprintf(stderr,"can not alloc memory(file_load)\n");
        return NULL;
    }
    if((fp=fopen(file,"rb"))==NULL) {
        free(data);
        perror(file);
        return NULL;
    }
    if(fread(data, 1, st.st_size, fp)<(unsigned)st.st_size) {
        fprintf(stderr,"can not read data (file_load)\n");
        free(data);
        fclose(fp);
        return NULL;
    }
    fclose(fp);
    *psize = st.st_size;
    return data;
}





#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
    
    // prepare AquesTalk2
    m_pAqTk = AquesTalk2Da_Create(); // AquesTalk2インスタンス生成
	
	// Notificationの登録　発声終了を検知する必要がある場合に用いる
	// メソッド名やnameは任意で
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(daDone:)
	 name: @"AquesTalk2DaDoneNotify"
	 object:nil];
    
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
	if(m_pAqTk) AquesTalk2Da_Release(m_pAqTk);
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added 
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs

-(id)example:(id)args
{
	// example method
	return @"hello world";
}

-(id)exampleProp
{
	// example property getter
	return @"hello world";
}

-(void)setExampleProp:(id)value
{
	// example property setter
}

//-(void)say:(id)args
-(id)say:(id)args
{
    
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
//    NSNumber *x;
//    NSString *word;
//    NSString *voiceKindName;
    
//    ENSURE_ARG_OR_NIL_FOR_KEY(x, args, @"x", NSNumber);
//    ENSURE_ARG_OR_NIL_FOR_KEY(word, args, @"word", NSString)
//    ENSURE_ARG_OR_NIL_FOR_KEY(voiceKindName, args, @"voiceKindName", NSString)

//    NSString *word = @"ゆっくりしていってね";
//    NSString *voiceKindName = @"aq_yukkuri.phont";
    
    NSString *word = [TiUtils stringValue:@"word" properties:args def:YES];
    NSString *voiceKindName = [TiUtils stringValue:@"voiceKindName" properties:args def:YES];

    NSLog(@"[INFO] word: %@", word);
    NSLog(@"[INFO] voiceKindName: %@", voiceKindName);

    
//	// テキストボックスから文字列取得
//	NSString *word = [textfield text];
	
	// 文字コードをShiftJISに変換
	char *sjis = (char*)[word cStringUsingEncoding:NSShiftJISStringEncoding];
	
	// 音声合成　音声記号列->WAVデータ
	if(m_pAqTk==0) return;
	if(AquesTalk2Da_IsPlay(m_pAqTk)){
		AquesTalk2Da_Stop(m_pAqTk);
	}
	//終了通知イベントの作成　name部分はNSNotificationCenterに設定した値に合わせる
	NSNotification *notification = [NSNotification notificationWithName:@"AquesTalk2DaDoneNotify" object:self userInfo:nil];
	//非同期の音声合成出力
    //	int iret = AquesTalk2Da_Play(m_pAqTk, sjis, 100, nil, notification);
    //    int iret = AquesTalk2Da_Play(m_pAqTk, sjis, 100, [self readPhont], notification);
    
    NSString *path = [NSString stringWithFormat:@"modules/%@/phonts/%@", [self moduleId], voiceKindName];
    NSLog(@"[INFO] path: %@", path);
    
    NSURL *pathUrl = [TiUtils toURL:path relativeToURL:[[NSBundle mainBundle] bundleURL]];
    NSString *pathUrlStr = [pathUrl path];
    NSLog(@"[INFO] pathUrlStr: %@", pathUrlStr);
    
    const char *pathUrlUTF8Str = pathUrlStr.UTF8String;
    NSLog(@"[INFO] pathUrlUTF8Str: %s", pathUrlUTF8Str);
    
    int size;
    void *pPhont = file_load(pathUrlUTF8Str, &size);
    
    int iret = AquesTalk2Da_Play(m_pAqTk, sjis, 100, pPhont, notification);
//    int iret = AquesTalk2Da_Play(m_pAqTk, sjis, 100, nil, notification);
	if(iret!=0){
		// 合成失敗
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"音声記号列の指定が正しくありません"
													   delegate:self cancelButtonTitle:nil otherButtonTitles: @"OK", nil];
		[alert show];
		[alert release];
		return;
	}
////	onPlayLabel.text = @"Playing...";
}

- (void)daDone:(NSNotification*)notification
{
    // TODO
}

@end
