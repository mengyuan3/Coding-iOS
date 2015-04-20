//
//  ProjectTopic.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectTopic.h"
#import "Login.h"

@implementation ProjectTopic

- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"ProjectTopicLabel", @"labels", nil];
        
        _page = [NSNumber numberWithInteger:1];
        _pageSize = [NSNumber numberWithInteger:20];
        _canLoadMore = YES;
        _isLoading = _willLoadMore = NO;
        _contentHeight = 1;
        
        _title = @"";
        _content = @"";
        _mdTitle = @"";
        _mdContent = @"";
        
        _labels = [[NSMutableArray alloc] initWithCapacity:3];
        _mdLabels = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return self;
}

- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeCode];
        _content = _htmlMedia.contentDisplay;
    }
}

+ (ProjectTopic *)feedbackTopic{
    ProjectTopic *topic = [[ProjectTopic alloc] init];
    topic.project = [Project project_FeedBack];
    topic.project_id = topic.project.id;
    return topic;
}

+ (ProjectTopic *)topicWithPro:(Project *)pro{
    ProjectTopic *topic = [[ProjectTopic alloc] init];
    topic.owner = [Login curLoginUser];
    topic.project = pro;
    topic.project_id = pro.id;
    return topic;
}
+ (ProjectTopic *)topicWithId:(NSNumber *)topicId{
    ProjectTopic *topic = [[ProjectTopic alloc] init];
    topic.id = topicId;
    return topic;
}

- (NSString *)toTopicPath{
    return [NSString stringWithFormat:@"api/topic/%d", self.id.intValue];
}

- (NSDictionary *)toEditParams
{
    NSMutableString *tempStr = [[NSMutableString alloc] initWithString:@""];
    for (NSString *lbl in _mdLabels) {
        [tempStr appendString:lbl];
    }
    return @{@"title" : [_mdTitle aliasedString],
             @"content" : [_mdContent aliasedString],
             @"label" : tempStr};
}

- (NSString *)toAddTopicPath{
    return [NSString stringWithFormat:@"api/project/%d/topic?parent=0", [self.project_id intValue]];
}
- (NSDictionary *)toAddTopicParams
{
    //NSMutableString *tempStr = [[NSMutableString alloc] initWithString:@""];
    NSMutableString *tempStr = [[NSMutableString alloc] initWithString:@"Bug, Feature"];
    for (NSString *lbl in _mdLabels) {
        [tempStr appendString:lbl];
    }
    return @{@"title" : [_mdTitle aliasedString],
             @"content" : [_mdContent aliasedString],
             @"labels" : [tempStr aliasedString]};
}

- (NSString *)toCommentsPath{
    return [NSString stringWithFormat:@"api/topic/%d/comments", _id.intValue];
}
- (NSDictionary *)toCommentsParams{
    return @{@"page" : (_willLoadMore? [NSNumber numberWithInteger:_page.integerValue +1] : [NSNumber numberWithInteger:1]),
             @"pageSize" : _pageSize};
}
- (void)configWithComments:(ProjectTopics *)comments{
    self.page = comments.page;
    self.totalRow = comments.totalRow;
    self.totalPage = comments.totalPage;
    
    if (_willLoadMore) {
        [_comments.list addObjectsFromArray:comments.list];
    }else{
        self.comments = comments;
    }
    _canLoadMore = (_page.integerValue < _totalPage.integerValue);
    
}

- (NSString *)toDoCommentPath{
    return [NSString stringWithFormat:@"api/project/%d/topic?parent=%d",_project_id.intValue, _id.intValue];
}
- (NSDictionary *)toDoCommentParams{
    return @{@"content" : [_nextCommentStr aliasedString]};
}
- (void)configWithComment:(ProjectTopic *)comment{
    if (self.comments && self.comments.list) {
        [self.comments.list addObject:comment];
    }else{
        self.comments = [[ProjectTopics alloc] init];
        self.comments.list = [NSMutableArray arrayWithObject:comment];
    }
    self.child_count = [NSNumber numberWithInteger:_child_count.intValue +1];
}
- (NSString *)toDeletePath{
    return [NSString stringWithFormat:@"api/topic/%d", self.id.intValue];
}

- (BOOL)canEdit
{
    return (self.owner_id.integerValue == [Login curLoginUser].id.integerValue // 讨论创建者
            || [Login isOwnerOfProjectWithOwnerId:self.project.owner_id]); // 项目创建者
}

@end
