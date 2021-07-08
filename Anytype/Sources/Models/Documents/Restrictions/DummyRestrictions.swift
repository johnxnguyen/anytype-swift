import BlocksModels

struct DummyRestrictions: BlockRestrictions {
    let canApplyBold = false
    let canApplyItalic = false
    let canApplyOtherMarkup = false
    let canApplyBlockColor = false
    let canApplyBackgroundColor = false
    let canApplyMention = false
    let turnIntoStyles: [BlockViewType] = []
    let availableAlignments: [LayoutAlignment] = []
}
