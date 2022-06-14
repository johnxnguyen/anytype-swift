import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import AnytypeCore

final class DashboardService: DashboardServiceProtocol {
    
    private let searchService = ServiceLocator.shared.searchService()
    private let objectsService = ServiceLocator.shared.objectActionsService()
    
    func createNewPage() -> BlockId? {
        let availableTemplates = searchService.searchTemplates(
            for: .dynamic(ObjectTypeProvider.shared.defaultObjectType.url)
        )
        let hasSingleTemplate = availableTemplates?.count == 1
        let templateId = hasSingleTemplate ? (availableTemplates?.first?.id ?? "") : ""

        let defaultTypeUrl = ObjectTypeProvider.shared.defaultObjectType.url
        let id = objectsService.createPage(
            contextId: "",
            targetId: "",
            details: [
                .name(""),
                .isDraft(!hasSingleTemplate),
                .type(.dynamic(defaultTypeUrl))
            ],
            position: .bottom,
            templateId: templateId
        )

        if id.isNotNil {
            AnytypeAnalytics.instance().logCreateObject(objectType: defaultTypeUrl, route: .home)
        }
        
        return id
    }
    
}
