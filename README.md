PUDemo
======
该工程可作为项目基础框架，项目中已经引进的第三方框架为ASI，SDWebImageV3,Reachability,MBProgressHUD,GridView等。
其中对MBProgressHUD进行扩充，在类别MBProgressHUD＋Addition中实现一些tips功能，可在程序中，直接使用；
在PUHttpRequest类中对ASIHttpy请求，以block代替觉用的delegate模式，更方便高效管理htpp请求。

该项目主要实现两大主要功能：
一、图片浏览功能，仿QQ空间图片浏览模式，支持git图片播放，支持循环滑动
二、Http网络请求示例，以糗事百科API为测试源，

几点说明：
该工程运行在6.0及其以上OS系统
该工程是使用ARC管理内存，其中ASI等第三方库为非ARC文件，在使用时请在Compile Flags使用-fno-objc-arc标记。

致谢：
该工程参考了一些前辈们的劳动成果，对此表示感谢

PUDemo
