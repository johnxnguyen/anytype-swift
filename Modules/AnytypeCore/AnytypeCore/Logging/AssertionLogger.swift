public enum ErrorDomain: String {
    case quickAction
    case userDefaults
    case debug
    
    case imageDownloader
    case imageCreation
    case colorCreation
    case fileLoader
    case diskStorage
    case camera
    case clearCache
    
    case treeBlockBuilder
    case localEventConverter
    case localEventConverterSetFocus
    case middlewareEventConverter
    case objectDetails
    case relationsBuilder
    
    case blockInformationCreator
    case blockContainer
    case blockDelegate
    case blocksConverter
    
    case blockImage
    case unknownLabel
    case unsupportedBlock
    case blockVideo
    
    case editorBrowser
    case editorPage
    case editorSet
    case loadingController
    
    case markStyleModifier
    case markupChanger
    case markStyleConverter
    case blockMarkupChanger
    case markupViewModel
    case mentionMarkup
    case markdownListener
    
    case anytypeText
    case iconEmoji
    case anytypeColor
    case mergedArray
    
    case textBlockActionHandler
    case blockActionsService
    case objectActionsService
    case keyboardListner
    case textLayout
    case textConverter
    case searchService
    case bookmarkService
    case pageService
    case textService
    case relationsService
    case blockListService
    case authService
    case subscriptionService
    case subscriptionStorage
    
    case homeView

    
    case iconPicker
    
    case appIcon
}

public protocol MessageLogger {
    func log(_ message: String, domain: ErrorDomain)
}

public final class AssertionLogger {
    public static var shared: MessageLogger?
}
