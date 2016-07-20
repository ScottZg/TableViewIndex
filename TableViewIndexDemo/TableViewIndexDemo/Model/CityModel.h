//
//  CityModel.h
//  TableViewIndexDemo
//
//  Created by zhanggui on 16/7/20.
//  Copyright © 2016年 zhanggui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityModel : NSObject

@property (nonatomic,strong)NSString *cityId;
@property (nonatomic,strong)NSString *cityName;
@property (nonatomic,strong)NSString *shortName;
@property (nonatomic,strong)NSString *citySpelling;
@property (nonatomic,strong)NSString *shorSpelling;

@property (nonatomic,strong)NSString *firstSepllStr;

- (instancetype)initWithDic:(NSDictionary *)dic;
@end
