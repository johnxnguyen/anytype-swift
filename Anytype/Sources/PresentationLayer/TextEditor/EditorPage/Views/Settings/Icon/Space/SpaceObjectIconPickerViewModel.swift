import Combine
import UIKit
import Services
import AnytypeCore

@MainActor
final class SpaceObjectIconPickerViewModel: ObservableObject {

    // MARK: - Private variables
    
    private let spaceViewId: String
    private let spaceId: String
    
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.fileActionsService)
    private var fileService: any FileActionsServiceProtocol
    @Injected(\.documentService)
    private var openDocumentProvider: any OpenedDocumentsProviderProtocol
    
    private lazy var document: any BaseDocumentProtocol = {
        openDocumentProvider.document(objectId: spaceViewId, spaceId: spaceId)
    }()
    
    @Published private(set) var isRemoveEnabled: Bool = false

    // MARK: - Initializer
    
    init(spaceViewId: String, spaceId: String) {
        self.spaceViewId = spaceViewId
        self.spaceId = spaceId
    }
    
    func startDocumentHandler() async {
        for await details in document.detailsPublisher.values {
            isRemoveEnabled = details.iconImage.isNotEmpty
        }
    }
    
    func uploadImage(from itemProvider: NSItemProvider) {
        guard let spaceId = document.details?.targetSpaceId else {
            anytypeAssertionFailure("target space id not found")
            return
        }
        AnytypeAnalytics.instance().logSetIcon()
        let safeSendableItemProvider = itemProvider.sendable()
        Task {
            let data = try await fileService.createFileData(source: .itemProvider(safeSendableItemProvider.value))
            let fileDetails = try await fileService.uploadFileObject(spaceId: spaceId, data: data, origin: .none)
            try await workspaceService.workspaceSetDetails(spaceId: spaceId, details: [.iconObjectId(fileDetails.id)])
        }
    }
    
    func removeIcon() {
        guard let spaceId = document.details?.targetSpaceId else {
            anytypeAssertionFailure("target space id not found")
            return
        }
        AnytypeAnalytics.instance().logRemoveIcon()
        Task {
            try await workspaceService.workspaceSetDetails(spaceId: spaceId, details: [.iconObjectId("")])
        }
    }
}
