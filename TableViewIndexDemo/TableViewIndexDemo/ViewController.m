//
//  ViewController.m
//  TableViewIndexDemo
//
//  Created by zhanggui on 16/7/19.
//  Copyright © 2016年 zhanggui. All rights reserved.
//

#import "ViewController.h"
#import "CityModel.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *cityTableView;

@property (nonatomic,strong)NSMutableArray *cityArray;

@property (nonatomic,strong)NSMutableDictionary *cityDict;

@property (nonatomic,strong)NSMutableArray *saveToLocalArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _cityDict = [[NSMutableDictionary alloc] initWithCapacity:26];
    _cityArray = [[NSMutableArray  alloc] initWithCapacity:526];
    self.cityTableView.tableFooterView = [UIView new];
    //加载本地数据，如果有本地数据就直接显示本地数据，如果没有则请求服务器
    [self p_loadLocalCityData];
    
    if ([_cityArray count]>0) {
        
        [self.cityTableView reloadData];
    }else {
         [self configDataFromRemote];
    }
   
}

#pragma mark - getRemoteData
- (void)configDataFromRemote {
    NSString *urlStr = [NSString stringWithFormat:@"http://apis.baidu.com/baidunuomi/openapi/cities"];
  
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
    [request setValue:@"2304cdaee07aa52690475edf3776cce6" forHTTPHeaderField:@"apikey"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        [self p_configCityArrWithDic:dict];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self p_saveToLocal];
        });
        [self performSelectorOnMainThread:@selector(p_refreshTableView) withObject:nil waitUntilDone:YES];
    }];
    [task resume];
}
#pragma mark - private Method
- (void)p_loadLocalCityData {
    [_cityArray removeAllObjects];   //清空城市数组
    [self.saveToLocalArray removeAllObjects];
    NSString *plistName = @"CiytList.plist";
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",docPath,plistName];
    
    //获取本地数据，放到数组里面
    NSMutableArray *arr = [NSMutableArray arrayWithContentsOfFile:filePath];
    
    [self p_initCityDicAndArr:arr];
}
- (void)p_saveToLocal {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:400];
    for (NSDictionary *dict in self.saveToLocalArray) {
        [array addObject:dict];
    }
    //保存到plist
    NSString *plistName = @"CiytList.plist";
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",docPath,plistName];
   BOOL isWriteToFile =  [array writeToFile:filePath atomically:YES];
    if (isWriteToFile) {
        NSLog(@"写入成功");
    }else {
        NSLog(@"写入失败");
    }
}
- (void)p_refreshTableView {
    [self.cityTableView reloadData];
}
- (void)p_configCityArrWithDic:(NSDictionary *)dic {
    NSArray *arr = dic[@"cities"];
    [self p_initCityDicAndArr:arr];
}
- (void)p_initCityDicAndArr:(NSArray *)arr {
    self.saveToLocalArray = [NSMutableArray arrayWithArray:arr];
    for(NSDictionary *cityDic in arr) {
        CityModel *model = [[CityModel alloc] initWithDic:cityDic];
        [_cityArray addObject:model];
    }
    for(CityModel *model in _cityArray) {
        NSMutableArray *letterArr = _cityDict[model.firstSepllStr];
        if (letterArr==nil) {
            letterArr = [NSMutableArray new];
            [_cityDict setObject:letterArr forKey:model.firstSepllStr];
        }
        [letterArr addObject:model];
    }

}
- (NSArray *)p_getCityDictAllKeys {
    NSArray *keys = [_cityDict allKeys];
    return [keys sortedArrayUsingSelector:@selector(compare:)];
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *arr = [self p_getCityDictAllKeys];
    if (arr.count!=0) {
        NSLog(@"%lu",(unsigned long)arr.count);
    }
    return arr.count;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *arr = [self p_getCityDictAllKeys];
    return arr[section];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *keys = [self p_getCityDictAllKeys];
    NSString *keyStr = keys[section];
    NSArray *arr = _cityDict[keyStr];
    return arr.count;
}
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self p_getCityDictAllKeys];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSArray *allCityLetterArr = [self p_getCityDictAllKeys];
    NSString *sectionCityLetter = allCityLetterArr[indexPath.section];
    NSArray *underLetterCityArr = _cityDict[sectionCityLetter];
    CityModel *model = underLetterCityArr[indexPath.row];
    cell.textLabel.text = model.cityName;
    return cell;
}
#pragma mark - setter
- (UITableView *)cityTableView {
    if (!_cityTableView) {
        _cityTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _cityTableView.delegate = self;
        _cityTableView.dataSource = self;
        [self.view addSubview:_cityTableView];
    }
    return _cityTableView;
}
- (NSMutableArray *)saveToLocalArray {
    if (!_saveToLocalArray) {
        _saveToLocalArray = [[NSMutableArray alloc] init];
    }
    return _saveToLocalArray;
}
@end
