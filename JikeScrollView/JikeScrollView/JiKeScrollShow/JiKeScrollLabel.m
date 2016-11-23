//
//  JiKeScrollLabel.m
//  JikePictureShow
//
//  Created by 李龙 on 16/11/21.
//  Copyright © 2016年 李龙. All rights reserved.
//

#import "JiKeScrollLabel.h"
#import "UIView+Frame.h"
#import "Cionfig.h"

@interface JiKeScrollLabel ()


@property (nonatomic,strong) UILabel *myLabel0;
@property (nonatomic,strong) UILabel *myLabel1;
@property (nonatomic,strong) NSArray *myLabelArray;

@end


@implementation JiKeScrollLabel
{
    int _scrollIndex;
    BOOL isRunning;
    
    CGFloat _originalTopY;
    CGFloat _originalCenterY;
    CGFloat _originalDownY;
    
    NSString *currentShowDes;
    
}


- (instancetype)init {
    if (self = [super init]) {
        //初始化控件
        [self initSubViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        //初始化控件
        [self initSubViews];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //初始化控件
        [self initSubViews];
    }
    return self;
}


- (NSArray *)myLabelArray
{
    if (!_myLabelArray) {
        

        UILabel *label0 = [[UILabel alloc] init];
//        label0.text = [self getRealShowStr:@"这些微博的评论更好看"];
        
        UILabel *label1 = [[UILabel alloc] init];
//        label1.text = [self getRealShowStr:@"「看理想」系列视频更新提醒"];
        
        _myLabelArray = [NSArray arrayWithObjects:label0,label1, nil];
    }
    
    return _myLabelArray;
}


static CGFloat const labelH = 30;
static CGFloat const labelW = 113;

- (void)initSubViews{

    CGFloat topMargin = 0;
    _originalTopY = topMargin-labelH;
    _originalCenterY = topMargin;
    _originalDownY = topMargin+labelH;
    
    CGFloat showLabelViewHeight = labelH;
    UIFont *labelFont = [UIFont systemFontOfSize:12];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelW, showLabelViewHeight)];
    backView.clipsToBounds = YES;
    [self addSubview:backView];
    

    
    _myLabel0 = ({
        UILabel *label = self.myLabelArray[0];
        label.frame = (CGRect){0,_originalCenterY,labelW,labelH};
        label.numberOfLines = 0;
        label.font = labelFont;
//        label.backgroundColor = [UIColor greenColor];
        [backView addSubview:label];
        label;
    });
    
    _myLabel1 = ({
        UILabel *label = self.myLabelArray[1];
        label.frame = (CGRect){0,_originalTopY,labelW,labelH};
        label.numberOfLines = 0;
        label.font = labelFont;
//        label.backgroundColor = [UIColor yellowColor];
        [backView addSubview:label];
        label;
    });
    
    _scrollIndex = 0;
    
}


- (void)beiginScrollDown{
    
    _scrollIndex++;
    [self runAnimation];
}

- (void)runAnimation{
    
    _myLabel0.alpha = 1;
    _myLabel1.alpha = 1;
    
    
    


    void (^changeBlock)() = ^(){
        
        NSLog(@"%@",currentShowDes);
        
        isRunning = YES;
        if (![self isInOneWholeLine:currentShowDes]) {
            NSLog(@"--------- 开始0");
            //第一个动画
            if (_scrollIndex == 1) {
                _myLabel1.y = _originalCenterY;
                
                _myLabel0.y = _originalDownY;
                _myLabel0.alpha = 0.3;
                
            }else if(_scrollIndex == 2){
                
                _myLabel0.y = _originalCenterY;
                
                _myLabel1.y = _originalDownY;
                _myLabel1.alpha = 0.3;
                
                _scrollIndex = 0; //标记归0
            }
            
        }else{
            //叠影动画逻辑
            //当前正在显示的label的动画执行时间比即将显示的label的动画执行时间延迟一些执行,产生叠影效果
            NSLog(@"动画2");

            if (_scrollIndex == 1) {
                
                _myLabel1.y = _originalCenterY;
                
                void (^overlapChangeBlock)() = ^(){
                    _myLabel0.alpha = 0.2;
                    _myLabel0.y = _originalDownY;
                };
                
                
                [self doAnimationWithDuration:0.4f delay:0.2f change:overlapChangeBlock completion:nil];
                
            }else if(_scrollIndex == 2){

                _myLabel0.y = _originalCenterY;
                
                void (^overlapChangeBlock)() = ^(){
                    _myLabel1.alpha = 0.2;
                    _myLabel1.y = _originalDownY;
                };
                
                [self doAnimationWithDuration:0.4f delay:0.2f change:overlapChangeBlock completion:nil];
                
                _scrollIndex = 0; //标记归0
            }            
        }

    };
    
    
    
    void (^completionBlock)(BOOL) =  ^(BOOL finished){
        if(finished){
            
                //第一个动画
            if (_scrollIndex == 1) {
                
                _myLabel0.alpha = 0;
                _myLabel0.y = _originalTopY;
                _myLabel0.alpha = 1;
                
                currentShowDes = _myLabel1.text;
            }else if(_scrollIndex == 0){
                
                _myLabel1.alpha = 0;
                _myLabel1.y = _originalTopY;
                _myLabel1.alpha = 1;
                
                currentShowDes = _myLabel0.text;
            }
            NSLog(@"--------- 结束0");

            
            isRunning = NO;
        }
        
        
    };

    
    [self doAnimationWithDuration:0.6f delay:0.1f change:changeBlock completion:completionBlock];
    
}


- (void)doAnimationWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay change:(void(^)())changeBK completion:(void(^)(BOOL finished))competionBK{
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseInOut animations:changeBK completion:competionBK];
}


#pragma mark ================ 处理数据 ================

-(void)setMyFirstShowLabelDes:(NSString *)myFirstShowLabelDes{
    _myFirstShowLabelDes = myFirstShowLabelDes;
    currentShowDes = myFirstShowLabelDes;
    _myLabel0.text = [self getRealShowStr:myFirstShowLabelDes];
    
}


-(void)setMyNextShowLabelDes:(NSString *)myNextShowLabelDes{
    
    //保证动画当前顺序执行
    if (isRunning){
        NSLog(@"---------------------------  Label动画ing ------------------------");
        return;
}

    //数据处理
    if(_myFirstShowLabelDes == nil)
        ULog(@"还是设置第一个图片描述");
    
    _myNextShowLabelDes = myNextShowLabelDes;
    
    if (_scrollIndex == 0)
        _myLabel1.text = [self getRealShowStr:myNextShowLabelDes];
    else if (_scrollIndex == 1)
        _myLabel0.text = [self getRealShowStr:myNextShowLabelDes];
    
    [self beiginScrollDown];
    
}


- (BOOL)isInOneWholeLine:(NSString *)str{
    return (str.length <= 10);
}

- (NSString *)getRealShowStr:(NSString *)str{
    if (str.length <= 9) {
        str = [str stringByAppendingString:@"\n"];
    }
    
    return str;
}





@end