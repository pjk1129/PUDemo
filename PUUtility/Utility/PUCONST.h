//
//  PUCONST.h
//  PUDemo
//
//  Created by JK.PENG on 13-11-1.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#ifndef PUDemo_PUCONST_h
#define PUDemo_PUCONST_h

//图片资源获取
#define IMGFROMBUNDLE( X )	 [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:X ofType:@"" ]]
#define IMGNAMED( X )	     [UIImage imageNamed:X]

#ifdef DEBUG
#define DBLog(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DBLog(xx, ...)  ((void)0)
#endif

//定义字号
#define FONT_TITLE(X)     [UIFont systemFontOfSize:X]
#define FONT_CONTENT(X)   [UIFont systemFontOfSize:X]

#endif
