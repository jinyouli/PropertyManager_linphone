//
//  MyFMDataBase.m
//  FMDataBaseDemo
//
//  Created by 黄嘉宏 on 15/9/6.
//  Copyright (c) 2015年 黄嘉宏. All rights reserved.
//

#import "MyFMDataBase.h"
#import "ComplainHeaderDataModel.h" //header模型
#import "ComplainReplyDataModel.h" //回复模型
#import "ContactModel.h"    //联系人模型

@interface MyFMDataBase ()

//全局声明数据库dataBase
@property(nonatomic,strong)FMDatabase *dataBase;

@end

@implementation MyFMDataBase

+(MyFMDataBase *)shareMyFMDataBase{
    static MyFMDataBase * _manager;
    if (_manager == nil) {
        _manager = [[MyFMDataBase alloc]init];
    }
    
    UserManager * user = [UserManagerTool userManager];
    

    if ([_manager createDataBaseWithDataBaseName:user.worker_id]){
        //创建表单
        // 订单列表
        [_manager createTableWithTableName:OrderInfo tableArray:OrderInfoInfoDic];
        // 回复列表
        [_manager createTableWithTableName:DetailInfo tableArray:DetailInfoDic];
        
        // 分组表单
        [_manager createTableWithTableName:SortInfo tableArray:SortInfoDic];
        // 存储联系人表单
        [_manager createTableWithTableName:StorageInfo tableArray:StorageInfoDic];
        //勿扰模式列表
        [_manager createTableWithTableName:DontDisturbInfo tableArray:DontDisturbInfoDic];
        //创建小区公告已读模式
        [_manager createTableWithTableName:PlotNewsInfo tableArray:PlotNewsInfoDic];
        //通话记录
        [_manager createTableWithTableName:ListenHistoryInfo tableArray:ListenHistoryInfoDic];
    }

    // A_Z表单
    [_manager createDataBaseWithDataBaseName:A_ZInfo];
    [_manager createTableWithTableName:A_ZInfo tableArray:A_ZInfoDic];
    
    NSArray *userArray = [NSArray arrayWithObjects:@"fusername",@"first_py",@"fdepartmentname",@"fworkername",@"worker_id",@"user_sip",@"fgroup_name", nil];
    [_manager createDataBaseWithDataBaseName:@"PeopleCalled"];
    [_manager createTableWithTableName:@"PeopleCalled" tableArray:userArray];
    
    return _manager;
}

#pragma mark - 创建一个数据库
-(BOOL)createDataBaseWithDataBaseName:(NSString *)dbName{
    @synchronized(self) {
    
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *filePath = [NSString stringWithFormat:@"%@/Documents/%@.sqlite",NSHomeDirectory(),dbName];
        
        if ([fileManager fileExistsAtPath:filePath]) {
            self.dataBase = [FMDatabase databaseWithPath:filePath];
        }else{
            self.dataBase = [[FMDatabase alloc]initWithPath:filePath];
        }

        //把数据库打开
        if (self.dataBase.open) {
            //SYLog(@"自己建立的数据库打开成功  路径：%@",filePath);
            return YES;
        }
        else{
            //SYLog(@"自己建立的数据库打开失败  路径：%@",filePath);
            return NO;
        }

    }
}

#pragma mark - 创建一个表单
-(void)createTableWithTableName:(NSString *)tableName tableArray:(NSArray *)tableArray{

    NSString *scutureString = @"";
    
    for (NSString *stringKey in tableArray) {
        scutureString = [NSString stringWithFormat:@"%@%@ varchar(32),",scutureString,stringKey];
    }
    
    NSString *scutureString2 = [scutureString substringToIndex:scutureString.length - 1];
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(id integer PRIMARY KEY AUTOINCREMENT,%@)",tableName,scutureString2];
    
    
    //SYLog(@"创建表单语句 === %@",sql);
    
    //通过dataBase使用sql语句
    @synchronized(self) {
       BOOL isCreate = [self.dataBase executeUpdate:sql];
        if (isCreate) {
            //SYLog(@"创建表单成功  表单名称 %@",tableName);
        }
        else{
            //SYLog(@"创建表单失败  表单名称 %@",tableName);
        }
    }
  
}

#pragma mark - insert插入数据
-(void)insertDataWithTableName:(NSString *)tableName insertDictionary:(NSDictionary *)insertDictionary{

    NSString *scutureString = @"";
    
    for (NSString *keyString in insertDictionary.allKeys) {
        scutureString = [NSString stringWithFormat:@"%@,%@",scutureString,keyString];
    }
    NSString *scutureString2 = [scutureString substringFromIndex:1];
    
    //值字符串
    //字段名字符串
    NSString *valueString = @"";
    
    for (NSString *keyString in insertDictionary.allKeys) {
        valueString = [NSString stringWithFormat:@"%@,'%@'",valueString,insertDictionary[keyString]];
    }
    NSString *valueString2 = [valueString substringFromIndex:1];
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES(%@)",tableName,scutureString2,valueString2];
    
    //SYLog(@"插入语句 ===   %@",sql);
    
    BOOL isInsert = [self.dataBase executeUpdate:sql];
    
    if (isInsert) {
        //SYLog(@"插入sql数据成功");
    }
    else{
        //SYLog(@"插入sql数据失败");
    }
}

#pragma mark - 修改表单中的数据
-(void)updateDataWithTableName:(NSString *)tableName updateDictionary:(NSDictionary *)updateArray whereArray:(NSDictionary *)whereArray{
    
    //拼接需要改变的字段名
    NSString *setString = @"";
    int i = 0;
    for (NSString *keyString in updateArray.allKeys) {
        setString = [NSString stringWithFormat:@"%@ = '%@',",keyString,updateArray[updateArray.allKeys[i]]];
        i++;
    }
    NSString *setString2 = [setString substringToIndex:setString.length - 1];
    
    //拼接条件字段名
    NSString *whereString = @"";
    int j = 0;
    for (NSString *keyString in whereArray.allKeys) {
        whereString = [NSString stringWithFormat:@"%@ = '%@',",keyString,whereArray[whereArray.allKeys[j]]];
        j++;
    }
    NSString *whereString2 = [whereString substringToIndex:whereString.length - 1];
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@",tableName,setString2,whereString2];
    
//    SYLog(@"修改表达内容语句 === %@",sql);
    
    //修改某个数据
    @synchronized(self) {

    BOOL isUpdate = [self.dataBase executeUpdate:sql];
    
        if (isUpdate) {
            SYLog(@"修改数据成功");
        }
        else{
            SYLog(@"修改数据失败");
        }

    }
}

#pragma mark - deleteData删除操作
-(void)deleteDataWithTableName:(NSString *)tableName delegeteDic:(NSDictionary *)delegeteDic{

    NSString *sql = @"";
    
    if (!delegeteDic) {
        sql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
    }
    else{
        NSString *whereString = @"";
        int j = 0;
        for (NSString *keyString in delegeteDic.allKeys) {
            whereString = [whereString stringByAppendingFormat:@"%@ = '%@' and ",keyString,delegeteDic[delegeteDic.allKeys[j]]];
            j++;
            NSLog(@"wherestr  ==  %@",whereString);
        }
        NSString *whereString2 = [whereString substringToIndex:whereString.length - 4];
        
        sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",tableName,whereString2];
    }
    
    
//    SYLog(@"删除表单内容语句 === %@",sql);
    
    @synchronized(self) {
        BOOL isDelete = [self.dataBase executeUpdate:sql];
        
        if (isDelete) {
            NSLog(@"删除该数据成功");
        }
        else{
            NSLog(@"删除该数据失败");
        }
        
    }
}

#pragma mark - 查询数据表中的数据 筛选条件
-(NSArray *)selectDataWithTableName:(NSString *)tableName withDic:(NSDictionary *)selecDic{
    //sql的查询语句
    //拼接条件字段名
    NSString *whereString = @"";
    NSString *whereString2 = @"";
    if (selecDic) {
        
        for (NSString * keyString in selecDic.allKeys) {
            whereString = [NSString stringWithFormat:@"%@%@ = '%@' and ",whereString,keyString,selecDic[keyString]];
            
        }
        whereString2 = [whereString substringToIndex:whereString.length - 4];
    }
    
//    SYLog(@"whereString2 ==== %@",whereString2);
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ ",tableName,whereString2];
    
    if (!selecDic || selecDic.count == 0) {
        sql = [NSString stringWithFormat:@"SELECT * FROM %@ ",tableName];
    }
    
    
   // SYLog(@"选择内容语句 === %@",sql);
    @synchronized(self) {
    NSMutableArray * mArr = [NSMutableArray array];
    FMResultSet *result = [self.dataBase executeQuery:sql];
        
        
        
    while ([result next]) {
        if ([tableName isEqualToString:@"PersonCall"]) {
            
            NSMutableDictionary * mdic = [[NSMutableDictionary alloc]init];
            [mdic setObject:[result stringForColumn:@"user"] forKey:@"user"];
            [mdic setObject:[result stringForColumn:@"time"] forKey:@"time"];
            [mdic setObject:[result stringForColumn:@"message"] forKey:@"message"];
            [mdic setObject:[NSNumber numberWithInt:[result intForColumn:@"state"]] forKey:@"state"];
            [mdic setObject:[result stringForColumn:@"id"] forKey:@"id"];
            [mArr addObject:mdic];
        }
        if ([tableName isEqualToString:@"PeopleCalled"]) {

            NSMutableDictionary * mdic = [[NSMutableDictionary alloc]init];
            [mdic setObject:[result stringForColumn:@"fusername"] forKey:@"fusername"];
            [mdic setObject:[result stringForColumn:@"first_py"] forKey:@"first_py"];
            [mdic setObject:[result stringForColumn:@"fdepartmentname"] forKey:@"fdepartmentname"];
            [mdic setObject:[result stringForColumn:@"fworkername"] forKey:@"fworkername"];
            [mdic setObject:[result stringForColumn:@"worker_id"] forKey:@"worker_id"];
            [mdic setObject:[result stringForColumn:@"user_sip"] forKey:@"user_sip"];
            [mdic setObject:[result stringForColumn:@"fgroup_name"] forKey:@"fgroup_name"];
            [mArr addObject:mdic];
        }
        
        if ([tableName isEqualToString:OrderInfo]) {
            // 报修单模型
            ComplainHeaderDataModel * headModel = [[ComplainHeaderDataModel alloc]init];
            //获取数字类型的元素属性
            NSInteger power_do = [result intForColumn:@"power_do"];
            headModel.power_do = @(power_do);
            
            NSInteger normal_do = [result intForColumn:@"normal_do"];
            headModel.power_do = @(normal_do);
            
            NSInteger record_num = [result intForColumn:@"record_num"];
            headModel.power_do = @(record_num);
            //获取字符类型的元素属性
            headModel.fstatus = [result stringForColumn:@"fstatus"];
            headModel.deal_worker_id = [result stringForColumn:@"deal_worker_id"];
            headModel.fscore = [result stringForColumn:@"fscore"];
            headModel.repair_id = [result stringForColumn:@"repair_id"];
            headModel.faddress = [result stringForColumn:@"faddress"];
            headModel.fservicecontent = [result stringForColumn:@"fservicecontent"];
            headModel.frealname = [result stringForColumn:@"frealname"];
            headModel.fcreatetime = [result stringForColumn:@"fcreatetime"];
            headModel.fordernum = [result stringForColumn:@"fordernum"];
            headModel.fworkername = [result stringForColumn:@"fworkername"];
            headModel.fusername = [result stringForColumn:@"fusername"];
            headModel.fheadurl = [result stringForColumn:@"fheadurl"];
            headModel.fremindercount = [result stringForColumn:@"fremindercount"];
            headModel.flinkman_phone = [result stringForColumn:@"flinkman_phone"];
            headModel.flinkman = [result stringForColumn:@"flinkman"];
            
            //bool类型
            headModel.isOpenDetail = [result boolForColumn:@"isOpenDetail"];
            
            // 处理图片数组
            if ([PMTools isNullOrEmpty:[result stringForColumn:@"fimagpath1"]]) {
                headModel.repairs_imag_list = @[];
            }
            else{
                if ([PMTools isNullOrEmpty:[result stringForColumn:@"fimagpath2"]]) {
                    headModel.repairs_imag_list = @[@{@"fimagpath":[result stringForColumn:@"fimagpath1"]}];
                }
                else{
                    if ([PMTools isNullOrEmpty:[result stringForColumn:@"fimagpath3"]]) {
                        headModel.repairs_imag_list = @[@{@"fimagpath":[result stringForColumn:@"fimagpath1"]},
                                                        @{@"fimagpath":[result stringForColumn:@"fimagpath2"]}];
                    }
                    else{
                        headModel.repairs_imag_list = @[@{@"fimagpath":[result stringForColumn:@"fimagpath1"]},
                                                        @{@"fimagpath":[result stringForColumn:@"fimagpath2"]},
                                                        @{@"fimagpath":[result stringForColumn:@"fimagpath3"]}];
                    }
                }
            }
            
            [mArr addObject:headModel];
        }
        if ([tableName isEqualToString:DetailInfo]) {
            // 回复模型
            ComplainReplyDataModel * replyModel = [[ComplainReplyDataModel alloc]init];
            replyModel.reply_id = [result stringForColumn:@"reply_id"];
            replyModel.ftype = [result stringForColumn:@"ftype"];
            replyModel.fcreatetime = [result stringForColumn:@"fcreatetime"];
            replyModel.name = [result stringForColumn:@"name"];
            replyModel.old_name = [result stringForColumn:@"old_name"];
            replyModel.nMyName1 = [result stringForColumn:@"nMyName1"];
            replyModel.fcontent = [result stringForColumn:@"fcontent"];
            
            // 处理图片数组
            if ([PMTools isNullOrEmpty:[result stringForColumn:@"fimagpath1"]]) {
                replyModel.reply_imag_list = @[];
            }
            else{
                if ([PMTools isNullOrEmpty:[result stringForColumn:@"fimagpath2"]]) {
                    replyModel.reply_imag_list = @[@{@"fimagpath":[result stringForColumn:@"fimagpath1"]}];
                }
                else{
                    if ([PMTools isNullOrEmpty:[result stringForColumn:@"fimagpath3"]]) {
                        replyModel.reply_imag_list = @[@{@"fimagpath":[result stringForColumn:@"fimagpath1"]},
                                                        @{@"fimagpath":[result stringForColumn:@"fimagpath2"]}];
                    }
                    else{
                        replyModel.reply_imag_list = @[@{@"fimagpath":[result stringForColumn:@"fimagpath1"]},
                                                        @{@"fimagpath":[result stringForColumn:@"fimagpath2"]},
                                                        @{@"fimagpath":[result stringForColumn:@"fimagpath3"]}];
                    }
                }
            }
            [mArr addObject:replyModel];
            
//            SYLog(@"回复型 %@",replyModel);
//            SYLog(@"回复模型的数组 %@",replyModel.reply_imag_list);
        }
        
        if ([tableName isEqualToString:A_ZInfo]||[tableName isEqualToString:StorageInfo]) {
        
            ContactModel * model = [[ContactModel alloc]init];
            model.fusername = [result stringForColumn:@"fusername"];
            model.first_py = [result stringForColumn:@"first_py"];
            model.fdepartmentname = [result stringForColumn:@"fdepartmentname"];
            model.fworkername = [result stringForColumn:@"fworkername"];
            model.worker_id = [result stringForColumn:@"worker_id"];
            model.user_sip = [result stringForColumn:@"user_sip"];
            [mArr addObject:model];
            
            //SYLog(@"A_Z联系人模型 %@",model);
        }
        
        if ([tableName isEqualToString:SortInfo]) {
            
            ContactModel * model = [[ContactModel alloc]init];
            model.fusername = [result stringForColumn:@"fusername"];
            model.fdepartmentname = [result stringForColumn:@"fdepartmentname"];
            model.fworkername = [result stringForColumn:@"fworkername"];
            model.worker_id = [result stringForColumn:@"worker_id"];
            model.first_py = [result stringForColumn:@"first_py"];
            model.fgroup_name = [result stringForColumn:@"fgroup_name"];
            model.user_sip = [result stringForColumn:@"user_sip"];
            [mArr addObject:model];
            
           // SYLog(@"分组联系人模型 %@",model);
        }
        
        //勿扰模式
        if ([tableName isEqualToString:DontDisturbInfo]) {
            NSMutableDictionary * mdic = [[NSMutableDictionary alloc]init];
            [mdic setObject:[result stringForColumn:@"isDontDisturb"] forKey:@"isDontDisturb"];
            [mdic setObject:[result stringForColumn:@"statTime"] forKey:@"statTime"];
            [mdic setObject:[result stringForColumn:@"endTime"] forKey:@"endTime"];
            [mArr addObject:mdic];
        }
        //小区公告
        if ([tableName isEqualToString:PlotNewsInfo]) {
            NSMutableDictionary * mdic = [[NSMutableDictionary alloc]init];
            [mdic setObject:[result stringForColumn:@"fusername"] forKey:@"fusername"];
            [mdic setObject:[result stringForColumn:@"noticeID"] forKey:@"noticeID"];
            [mArr addObject:mdic];
        }
    }
    
    return mArr;
    }
}

#pragma mark - 关闭数据库
-(void)closeDataBase{
    //关闭数据库
    @synchronized(self) {
        
        BOOL isClose = [self.dataBase close];
        
        if (isClose) {
            SYLog(@"关闭数据库成功");
        }
        else{
            SYLog(@"关闭数据库失败");
        }
    }
}


@end
