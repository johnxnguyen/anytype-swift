import Services
import SwiftUI

@MainActor
final class VersionHistoryCoordinatorViewModel:
    ObservableObject,
    VersionHistoryModuleOutput,
    ObjectVersionModuleOutput
{
    
    @Published var objectVersionData: ObjectVersionData?
    
    let data: VersionHistoryData
    
    private weak var output: (any ObjectVersionModuleOutput)?
    
    init(data: VersionHistoryData, output: (any ObjectVersionModuleOutput)?) {
        self.data = data
        self.output = output
    }
    
    // MARK: VersionHistoryModuleOutput
    
    func onVersionTap(title: String, icon: ObjectIcon?, versionId: String) {
        objectVersionData = ObjectVersionData(
            title: title,
            icon: icon,
            objectId: data.objectId, 
            spaceId: data.spaceId,
            versionId: versionId,
            isListType: data.isListType
        )
    }
    
    // MARK: ObjectVersionModuleOutput
    
    func versionRestored() {
        output?.versionRestored()
    }
}

