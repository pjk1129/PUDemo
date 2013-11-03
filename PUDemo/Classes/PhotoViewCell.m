//
//  PhotoViewCell.m
//  PUDemo
//
//  Created by JK.Peng on 13-11-3.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import "PhotoViewCell.h"
#import "UIImageView+WebCache.h"

@interface PhotoViewCell()
@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation PhotoViewCell

- (void)dealloc
{

}

- (id)initWithFrame:(CGRect)inRect reuseIdentifier:(NSString*)inReuseIdentifier
{
    self = [super initWithFrame:inRect reuseIdentifier:(NSString*)inReuseIdentifier];
    if (self){
        [self addSubview:self.imageView];
    }
    return self;
}


- (void)prepareForReuse
{
    [super prepareForReuse];

}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, self.bounds.size.width-10, self.bounds.size.height-10)];
        _imageView.userInteractionEnabled = YES;
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (void)setPhoto:(PUPhoto *)photo{
    if (_photo != photo) {
        _photo = photo;
        
        [self.imageView setImageWithURLString:_photo.thumbnailUrl placeholderImage:[UIImage imageNamed:@"PUPhotoBrowser.bundle/icon_placeholder.png"]];
    }
}


@end
