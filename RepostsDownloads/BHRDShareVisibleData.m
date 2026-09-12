#import "BHRDShareVisibleData.h"
#import "BHRDMediaResolver.h"
#import "BHRDShareLoadedMedia.h"
#import "BHRDRepostAuthor.h"
#import "BHRDManager.h"
#import <float.h>
#import <math.h>
static NSUInteger HanCount(NSString *text) {
    NSUInteger count = 0; for (NSUInteger i = 0; i < text.length; i++) { unichar c = [text characterAtIndex:i]; if (c >= 0x3400 && c <= 0x9FFF) count++; } return count;
}
static NSUInteger LatinCount(NSString *text) {
    NSUInteger count = 0; for (NSUInteger i = 0; i < text.length; i++) { unichar c = [text characterAtIndex:i]; if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')) count++; } return count;
}
static BOOL QuoteView(UIView *view) {
    NSString *name = NSStringFromClass(view.class).lowercaseString;
    return ([name containsString:@"quoted"] || [name containsString:@"quote"]) && ![view isKindOfClass:UIControl.class];
}
static BOOL BodyView(UIView *view, UIView *root) {
    BOOL body = NO;
    for (UIView *p = view; p && p != root; p = p.superview) {
        NSString *name = NSStringFromClass(p.class).lowercaseString;
        if ([name containsString:@"username"] || [name containsString:@"author"]) return NO;
        if ([name containsString:@"tweettext"] || [name containsString:@"statustext"] || [name containsString:@"attributedtext"] || [name containsString:@"richtext"]) body = YES;
    }
    return body;
}
static void Enrich(BHRDSharePost *post, UIView *card, NSUInteger depth) {
    if (!post || !card || depth > 2) return;
    // Native author headers can be UIControls. The body/media traversal below
    // deliberately skips controls, so read the isolated header separately.
    if (!post.author.length || !post.handle.length || (!post.avatar && !post.avatarData)) {
        BHRDRepostInfo *header = [BHRDRepostInfo new];
        header.authorName = post.author;
        header.authorHandle = post.handle;
        header.avatar = post.avatar;
        UIImage *avatar = BHRDCaptureRepostAuthor(card, nil, nil, header);
        BHRDApplyShareTextRows(post, @[@{@"role": @"author", @"text": header.authorName ?: @""},
                                     @{@"role": @"handle", @"text": header.authorHandle ?: @""}]);
        if (!post.avatar) post.avatar = header.avatar;
        if (!post.avatarData && avatar) post.avatarData = UIImagePNGRepresentation(avatar);
    }
    NSString *originalBeforeView = [post.body copy];
    BOOL originalFlag = post.bodyIsOriginal;
    NSMutableArray<UIView *> *pending = [NSMutableArray arrayWithArray:card.subviews];
    NSMutableArray<UIView *> *quotes = [NSMutableArray array];
    NSMutableArray<NSDictionary *> *labels = [NSMutableArray array], *avatars = [NSMutableArray array], *rows = [NSMutableArray array];
    NSUInteger budget = 350;
    while (pending.count && budget--) {
        UIView *view = pending.firstObject; [pending removeObjectAtIndex:0];
        NSString *name = NSStringFromClass(view.class);
        if (view.hidden || view.alpha <= 0.01 || [view isKindOfClass:UIControl.class] || [name containsString:@"InlineActionsView"]) continue;
        if (QuoteView(view)) { [quotes addObject:view]; continue; }
        id model = BHRDMediaObject(view, @"viewModel") ?: BHRDMediaObject(view, @"status");
        if (model) {
            BHRDSharePost *candidate = BHRDSharePostFromSource(model);
            if (post.identifier.length && [candidate.identifier isEqual:post.identifier]) BHRDMergeSharePost(post, candidate);
            else if (post.identifier.length && candidate.identifier.length && candidate.body.length && ([name containsString:@"Status"] || [name containsString:@"Embedded"] || [name containsString:@"Tweet"])) {
                // 未带 Quote 类名的嵌入推文，也按独立身份划为引用原文。
                [quotes addObject:view]; continue;
            }
        }
        CGRect rect = [view convertRect:view.bounds toView:card];
        NSString *text = BHRDShareText(BHRDMediaObject(view, @"attributedText") ?: BHRDMediaObject(view, @"text") ?: BHRDMediaObject(view, @"textModel"));
        if (text.length) [labels addObject:@{@"text": text, @"view": view, @"x": @(rect.origin.x), @"y": @(rect.origin.y), @"body": @(BodyView(view, card))}];
        NSString *translated = BHRDShareText(BHRDMediaObject(view, @"translatedText") ?: BHRDMediaObject(view, @"translatedTextModel") ?: BHRDMediaObject(BHRDMediaObject(view, @"translationViewModel"), @"text"));
        if (translated.length && ![translated isEqual:post.body]) [labels addObject:@{@"text": translated, @"view": view, @"x": @(rect.origin.x), @"y": @(rect.origin.y), @"body": @YES, @"translated": @YES}];
        NSString *accessible = view.accessibilityLabel;
        if (BodyView(view, card) && accessible.length >= 30 && ![accessible isEqual:text] && HanCount(accessible) >= 6 && HanCount(post.body) == 0) [labels addObject:@{@"text": accessible, @"view": view, @"x": @(rect.origin.x), @"y": @(rect.origin.y), @"body": @YES, @"translated": @YES}];
        id image = BHRDMediaObject(view, @"image");
        if ([image isKindOfClass:UIImage.class] && rect.origin.y < 110 && rect.origin.x < 90 && rect.size.width >= 20 && rect.size.width <= 90 && fabs(rect.size.width - rect.size.height) < 10) {
            [avatars addObject:@{@"image": image, @"area": @(rect.size.width * rect.size.height), @"y": @(rect.origin.y)}];
        }
        [pending addObjectsFromArray:view.subviews];
    }
    [labels sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
        NSComparisonResult y = [a[@"y"] compare:b[@"y"]]; return y == NSOrderedSame ? [a[@"x"] compare:b[@"x"]] : y;
    }];
    BOOL translatedContext = NO;
    for (NSDictionary *label in labels) {
        NSString *value = label[@"text"];
        if ([label[@"translated"] boolValue] || [value hasPrefix:@"翻译自"] || [value hasPrefix:@"译自"] || [value containsString:@"Translated from"] || [value hasPrefix:@"评价此翻译"] || [value isEqual:@"显示原文"]) { translatedContext = YES; break; }
    }
    if (!translatedContext && HanCount(originalBeforeView) == 0 && LatinCount(originalBeforeView) >= 12) {
        for (NSDictionary *label in labels) if (([label[@"body"] boolValue] || [label[@"y"] doubleValue] > 45) && HanCount(label[@"text"]) >= 6 && [label[@"text"] length] >= 30) { translatedContext = YES; break; }
    }
    BOOL preferChineseTranslation = NO;
    if (translatedContext && HanCount(originalBeforeView) == 0 && LatinCount(originalBeforeView) >= 12) {
        for (NSDictionary *label in labels) if (HanCount(label[@"text"]) >= 6 && [label[@"text"] length] >= 30) { preferChineseTranslation = YES; break; }
    }
    if (translatedContext && originalBeforeView.length) { post.body = originalBeforeView; post.bodyIsOriginal = originalFlag; }
    NSRegularExpression *handleRE = [NSRegularExpression regularExpressionWithPattern:@"@([A-Za-z0-9_]{1,15})(?![A-Za-z0-9_])" options:0 error:nil];
    NSDictionary *handleRow = nil;
    CGFloat headerY = -1;
    for (NSDictionary *label in labels) {
        NSString *text = label[@"text"];
        if ([label[@"y"] doubleValue] > 110 || [text containsString:@"\n"] || [text hasPrefix:@"回复"] || [text hasPrefix:@"Replying"]) continue;
        NSTextCheckingResult *match = [handleRE firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
        if (!match) continue;
        NSUInteger end = NSMaxRange(match.range);
        if (end < text.length && [@".…" rangeOfString:[text substringWithRange:NSMakeRange(end, 1)]].location != NSNotFound) continue;
        NSString *suffix = [[text substringFromIndex:end] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        if (suffix.length && ![suffix hasPrefix:@"·"] && ![suffix hasPrefix:@"•"]) continue;
        NSString *handle = [text substringWithRange:[match rangeAtIndex:1]];
        if (post.handle.length && ![post.handle.lowercaseString isEqual:handle.lowercaseString]) continue;
        NSString *prefix = [[text substringToIndex:match.range.location] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ·\t"]];
        if (prefix.length > 90) continue;
        [rows addObject:@{@"role": @"handle", @"text": handle}];
        if (prefix.length) [rows addObject:@{@"role": @"author", @"text": prefix}];
        handleRow = label; headerY = [label[@"y"] doubleValue]; break;
    }
    if (handleRow && !post.author.length) {
        NSDictionary *best = nil; double distance = DBL_MAX;
        for (NSDictionary *label in labels) {
            NSString *text = label[@"text"]; double y = [label[@"y"] doubleValue], x = [label[@"x"] doubleValue];
            if (label == handleRow || text.length < 2 || [text containsString:@"@"] || [text containsString:@"\n"] || [text hasPrefix:@"http"] || y > headerY + 8 || y < headerY - 45) continue;
            if (fabs(y - headerY) < 8 && x >= [handleRow[@"x"] doubleValue]) continue;
            double score = fabs(headerY - y) + (fabs(y - headerY) < 8 ? 0 : 5);
            if (score < distance) { distance = score; best = label; }
        }
        if (best) [rows addObject:@{@"role": @"author", @"text": best[@"text"]}];
    }
    for (NSDictionary *label in labels) {
        NSString *text = label[@"text"];
        if ([text hasPrefix:@"翻译自"] || [text hasPrefix:@"译自"] || [text hasPrefix:@"评价此翻译"] || [text containsString:@"Translated from"] || [text isEqual:@"显示原文"] || [text isEqual:@"查看翻译"]) continue;
        if (preferChineseTranslation && HanCount(text) < 4) continue;
        BOOL semantic = [label[@"body"] boolValue];
        BOOL paragraph = text.length >= 40 && [label[@"y"] doubleValue] > MAX(45, headerY + 18) && ![text hasPrefix:@"http"];
        if ((headerY < 0 || [label[@"y"] doubleValue] > headerY + 18) && (semantic || paragraph) && (!translatedContext || !originalBeforeView.length || ![originalBeforeView containsString:text])) [rows addObject:@{@"role": translatedContext ? @"translation" : @"body", @"text": text}];
    }
    BHRDApplyShareTextRows(post, rows);
    if (!post.avatarData && avatars.count) {
        [avatars sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) { return [b[@"area"] compare:a[@"area"]]; }];
        post.avatarData = UIImagePNGRepresentation(avatars.firstObject[@"image"]);
    }
    BHRDCaptureLoadedShareMedia(post, card, quotes);
    for (UIView *quoteView in quotes) {
        BHRDSharePost *quote = BHRDSharePostFromSource(BHRDMediaObject(quoteView, @"viewModel") ?: BHRDMediaObject(quoteView, @"status"));
        Enrich(quote, quoteView, depth + 1);
        if (!quote.body.length && !quote.author.length) continue;
        if (!post.quotedPost) post.quotedPost = quote; else BHRDMergeSharePost(post.quotedPost, quote);
        break;
    }
}
void BHRDEnrichSharePostFromView(BHRDSharePost *post, UIView *card) {
    Enrich(post, card, 0);
    // 部分详情布局把作者栏放在 tableHeaderView，正文/操作栏在焦点单元格内。
    // 仅在明确的焦点单元格中补读同一详情表头，不扫描普通列表的其他作者。
    if (post.author.length && post.handle.length && (post.avatar || post.avatarData)) return;
    if (![NSStringFromClass(card.class) containsString:@"Focal"]) return;
    for (UIView *parent = card.superview; parent; parent = parent.superview) {
        if (![parent isKindOfClass:UITableView.class]) continue;
        UIView *header = ((UITableView *)parent).tableHeaderView;
        if (!header) break;
        BHRDSharePost *author = [BHRDSharePost new]; author.identifier = post.identifier;
        Enrich(author, header, 0);
        if (!post.author.length) post.author = author.author;
        if (!post.handle.length) post.handle = author.handle;
        if (!post.avatar) post.avatar = author.avatar;
        if (!post.avatarData) post.avatarData = author.avatarData;
        if ([post.title isEqual:@"X 推文"] && post.handle.length) post.title = [NSString stringWithFormat:@"@%@ 的推文", post.handle];
        break;
    }
}

void BHRDEnrichShareReplyContextFromView(BHRDSharePost *post, UIView *card) {
    if (!post.replyToIdentifier.length) return;
    UITableView *table = nil;
    for (UIView *parent = card.superview; parent; parent = parent.superview)
        if ([parent isKindOfClass:UITableView.class]) { table = (UITableView *)parent; break; }
    for (UITableViewCell *cell in table.visibleCells) {
        if (cell == card) continue;
        NSIndexPath *path = [table indexPathForCell:cell];
        id delegate = table.delegate;
        id model = nil;
        if ([delegate respondsToSelector:@selector(itemAtIndexPath:)])
            model = [(id)delegate itemAtIndexPath:path];
        BHRDSharePost *candidate = BHRDSharePostFromSource(model);
        if (!candidate.identifier.length ||
            (![candidate.identifier isEqual:post.replyToIdentifier] && ![candidate.identifier isEqual:post.conversationIdentifier])) continue;
        BHRDEnrichSharePostFromView(candidate, cell);
        BHRDAttachShareReplyContext(post, candidate);
    }
}
