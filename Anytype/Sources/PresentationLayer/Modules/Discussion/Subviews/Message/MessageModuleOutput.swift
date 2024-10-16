import Foundation
import Services

@MainActor
protocol MessageModuleOutput: AnyObject {
    func didSelectAddReaction(messageId: String)
    func didSelectObject(details: MessageAttachmentDetails)
    func didSelectReply(message: MessageViewData)
}
