extension ObjectIconImageUsecase {
    var objectIconImageGuidelineSet: ObjectIconImageGuidelineSet {
        switch self {
        case .openedObject:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x96,
                profileImageGuideline: ProfileIconImageGuideline.x112,
                emojiImageGuideline: EmojiIconImageGuideline.x80,
                todoImageGuideline: TodoIconImageGuideline.x28,
                placeholderImageGuideline: PlaceholderIconImageGuideline.x48,
                staticImageGuideline: StaticImageGuideline.x80,
                bookmarkImageGuideline: nil
            )
        case .openedObjectNavigationBar:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x18,
                profileImageGuideline: ProfileIconImageGuideline.x18,
                emojiImageGuideline: EmojiIconImageGuideline.x18,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: nil,
                staticImageGuideline: nil,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x18
            )
        case .editorSearch:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x40,
                profileImageGuideline: ProfileIconImageGuideline.x40,
                emojiImageGuideline: EmojiIconImageGuideline.x40,
                todoImageGuideline: TodoIconImageGuideline.x24,
                placeholderImageGuideline: PlaceholderIconImageGuideline.x40,
                staticImageGuideline: StaticImageGuideline.x24,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x24
            )
        case .editorSearchExpandedIcons:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x40,
                profileImageGuideline: ProfileIconImageGuideline.x40,
                emojiImageGuideline: EmojiIconImageGuideline.x40,
                todoImageGuideline: TodoIconImageGuideline.x24,
                placeholderImageGuideline: PlaceholderIconImageGuideline.x40,
                staticImageGuideline: StaticImageGuideline.x40,
                bookmarkImageGuideline: nil
            )
        case .editorCalloutBlock:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x20,
                profileImageGuideline: ProfileIconImageGuideline.x20,
                emojiImageGuideline: EmojiIconImageGuideline.x24,
                todoImageGuideline: TodoIconImageGuideline.x20,
                placeholderImageGuideline: PlaceholderIconImageGuideline.x40,
                staticImageGuideline: StaticImageGuideline.x20,
                bookmarkImageGuideline: nil
            )
        case .dashboardList:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x48,
                profileImageGuideline: ProfileIconImageGuideline.x48,
                emojiImageGuideline: EmojiIconImageGuideline.x48,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: nil,
                staticImageGuideline: nil,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x18
            )
        case .dashboardProfile:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: nil,
                profileImageGuideline: ProfileIconImageGuideline.x80,
                emojiImageGuideline: nil,
                todoImageGuideline: nil,
                placeholderImageGuideline: nil,
                staticImageGuideline: nil,
                bookmarkImageGuideline: nil
            )
        case .dashboardSearch:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x48,
                profileImageGuideline: ProfileIconImageGuideline.x48,
                emojiImageGuideline: EmojiIconImageGuideline.x48,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: PlaceholderIconImageGuideline.x48,
                staticImageGuideline: StaticImageGuideline.x24,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x24
            )
        case let .mention(type):
            return mentionImageGuidelineSet(for: type)
        case .editorAccessorySearch:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: nil,
                profileImageGuideline: nil,
                emojiImageGuideline: EmojiIconImageGuideline.x48,
                todoImageGuideline: nil,
                placeholderImageGuideline: nil,
                staticImageGuideline: nil,
                bookmarkImageGuideline: nil
            )
        case .setRow:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x18,
                profileImageGuideline: ProfileIconImageGuideline.x18,
                emojiImageGuideline: EmojiIconImageGuideline.x18,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: nil,
                staticImageGuideline: nil,
                bookmarkImageGuideline: nil
            )
        case .setGallery:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x16,
                profileImageGuideline: ProfileIconImageGuideline.x16,
                emojiImageGuideline: EmojiIconImageGuideline.x16,
                todoImageGuideline: TodoIconImageGuideline.x16,
                placeholderImageGuideline: nil,
                staticImageGuideline: nil,
                bookmarkImageGuideline: nil
            )
        case .featuredRelationsBlock:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x18,
                profileImageGuideline: ProfileIconImageGuideline.x18,
                emojiImageGuideline: EmojiIconImageGuideline.x18,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: nil,
                staticImageGuideline: StaticImageGuideline.x18,
                bookmarkImageGuideline: nil
            )
        }
    }
    
    private func mentionImageGuidelineSet(for type: ObjectIconImageMentionType) -> ObjectIconImageGuidelineSet {
        switch type {
        case .title:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x28,
                profileImageGuideline: ProfileIconImageGuideline.x28,
                emojiImageGuideline: EmojiIconImageGuideline.x28,
                todoImageGuideline: TodoIconImageGuideline.x28,
                placeholderImageGuideline: nil,
                staticImageGuideline: StaticImageGuideline.x28,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x28
            )
        case .heading:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x24,
                profileImageGuideline: ProfileIconImageGuideline.x24,
                emojiImageGuideline: EmojiIconImageGuideline.x24,
                todoImageGuideline: TodoIconImageGuideline.x24,
                placeholderImageGuideline: nil,
                staticImageGuideline: StaticImageGuideline.x24,
                bookmarkImageGuideline: nil
            )
        case .subheading, .body:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x20,
                profileImageGuideline: ProfileIconImageGuideline.x20,
                emojiImageGuideline: EmojiIconImageGuideline.x20,
                todoImageGuideline: TodoIconImageGuideline.x20,
                placeholderImageGuideline: nil,
                staticImageGuideline: StaticImageGuideline.x20,
                bookmarkImageGuideline: nil
            )
        case .callout:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x18,
                profileImageGuideline: ProfileIconImageGuideline.x18,
                emojiImageGuideline: EmojiIconImageGuideline.x18,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: nil,
                staticImageGuideline: StaticImageGuideline.x18,
                bookmarkImageGuideline: nil
            )
        }
    }
}
