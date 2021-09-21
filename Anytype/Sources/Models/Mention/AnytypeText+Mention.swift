import AnytypeCore

extension AnytypeFont {
    var mentionType: ObjectIconImageMentionType {
        switch self {
        case .title:
            return .title
        case .heading:
            return .heading
        case .subheading:
            return .subheading
        case .bodyRegular, .bodyBold:
            return .body
        case .callout:
            return .callout
        default:
            anytypeAssertionFailure("Not supported mention for forn \(self)")
            return .body
        }
    }
}
