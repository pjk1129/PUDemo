//
//  APIDefine.h
//  PUDemo
//
//  Created by JK.Peng on 13-11-3.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#ifndef PUDemo_APIDefine_h
#define PUDemo_APIDefine_h

/**
 *@brief QSBK api接口
 */
//随便逛逛:干货、嫩草
#define api_stroll_suggest(count, page)          [NSString stringWithFormat:@"http://m2.qiushibaike.com/article/list/suggest?count=%d&page=%d", count, page]
#define api_stroll_latest(count, page)           [NSString stringWithFormat:@"http://m2.qiushibaike.com/article/list/latest?count=%d&page=%d", count, page]
//精华:日、周、月
#define api_elite_day(count, page)               [NSString stringWithFormat:@"http://m2.qiushibaike.com/article/list/day?count=%d&page=%d", count, page]
#define api_elite_week(count, page)              [NSString stringWithFormat:@"http://m2.qiushibaike.com/article/list/week?count=%d&page=%d", count, page]
#define api_elite_month(count, page)             [NSString stringWithFormat:@"http://m2.qiushibaike.com/article/list/month?count=%d&page=%d", count, page]
//有图有真相:硬菜、时令
#define api_imagetruth_imgrank(count, page)      [NSString stringWithFormat:@"http://m2.qiushibaike.com/article/list/imgrank?count=%d&page=%d", count, page]
#define api_imagetruth_images(count, page)       [NSString stringWithFormat:@"http://m2.qiushibaike.com/article/list/images?count=%d&page=%d", count, page]
//穿越
#define api_traversing_history(day, count, page) [NSString stringWithFormat:@"http://m2.qiushibaike.com/article/history/%@?count=%d&page=%d", day, count, page]
//评论: 糗事ID，每页显示数量，当前页数
#define api_article_comment(id, count, page)     [NSString stringWithFormat:@"http://m2.qiushibaike.com/article/%@/comments?count=%d&page=%d", id, count, page]

//发表评论: POST Header:Qbtoken 参数：{"content" : "啊啊啊","anonymous" : false}
#define api_create_comment(id)                   [NSString stringWithFormat:@"http://m2.qiushibaike.com/article/%@/comment/create", id]
//登录:POST
#define api_qiushi_login                         @"http://m2.qiushibaike.com/user/signin"
//反馈:POST
#define api_qiushi_feedback                      @"http://m2.qiushibaike.com/feedback"
//我收藏的: GET Header:Qbtoken
#define api_mine_collect(page, count)            [NSString stringWithFormat:@"http://m2.qiushibaike.com/collect/list?page=%d&count=%d", page, count]
//我评论的: GET Header:Qbtoken
#define api_mine_participate(page, count)        [NSString stringWithFormat:@"http://m2.qiushibaike.com/user/my/participate?page=%d&count=%d", page, count]
//我发表的: GET Header:Qbtoken
#define api_mine_articles(page, count)           [NSString stringWithFormat:@"http://m2.qiushibaike.com/user/my/articles?page=%d&count=%d", page, count]
//收藏功能 POST Header:Qbtoken
#define api_qiushi_collect(id)                   [NSString stringWithFormat:@"http://m2.qiushibaike.com/collect/%@", id]
//取消收藏功能 DELETE Header:Qbtoken
#define api_qiushi_delete(id)                    [NSString stringWithFormat:@"http://m2.qiushibaike.com/collect/%@", id]
//顶、踩糗事:POST
#define api_qiushi_vote                          @"http://vote.qiushibaike.com/vote_queue"
//发布糗事:POST Header:Qbtoken:94b0843c2b1b940a5b50594e5422ef6d976dedcb Content-Type:multipart/form-data; boundary=ixhan-dot-com
#define api_qiushi_create                        @"http://m2.qiushibaike.com/article/create"
/*
 post:
 --ixhan-dot-com
 Content-Disposition: form-data; name="json"
 
 {"content":"谢谢","anonymous":true,"allow_comment":true}
 --ixhan-dot-com
 
 --ixhan-dot-com--
 */

/**
 *@brief 内涵 api
 */
//段子: GET
#define api_neihan_joke2(page)                  [NSString stringWithFormat:@"http://42.121.111.22/weibofun/weibo_list.php?apiver=10200&category=weibo_jokes&page=%d&page_size=30&max_timestamp=-1&vip=1&platform=iphone", page]
//趣图: GET
#define api_neihan_picture2(page)               [NSString stringWithFormat:@"http://42.121.111.22/weibofun/weibo_list.php?apiver=10200&category=weibo_pics&page=%d&page_size=30&max_timestamp=-1&vip=1&platform=iphone", page]
//美女: GET
#define api_neihan_girl2(page)                  [NSString stringWithFormat:@"http://42.121.111.22/weibofun/weibo_list.php?apiver=10200&category=weibo_girls&page=%d&page_size=30&max_timestamp=-1&vip=1&platform=iphone", page]
//视频: GET
#define api_neihan_video2(page)                 [NSString stringWithFormat:@"http://42.121.111.22/weibofun/weibo_list.php?apiver=10200&category=weibo_videos&page=%d&page_size=30&max_timestamp=-1&vip=1&platform=iphone", page]

/**
 *@brief 更新：原内涵接口已失效
 */
//囧图: GET
#define api_neihan_picture(page)                [NSString stringWithFormat:@"http://api.budejie.com/api/api_open.php?c=data&a=list&per=30&page=%d", page]
//美女: GET
#define api_neihan_girl(offset)                 [NSString stringWithFormat:@"http://i.snssdk.com/gallery/1/top/?tag=ppmm&offset=%d&count=30", offset]
//视频: GET
#define api_neihan_video(offset)                [NSString stringWithFormat:@"http://api.jimu.me/video/?device=iPod4,1&app=iPhone&mix_list=1&sign=1831c697bbfd19e33618cfb896e9e553&category_id=33&v=2&am_user_id=142471&method=video.list&unique_id=88:C6:63:67:C4:ED&count=10&start=%d", offset]


#endif
