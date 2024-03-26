import Foundation
import Services

@MainActor
final class ParticipantRemoveNotificationViewModel: ObservableObject {
    
    private let notification: NotificationParticipantRemove
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    
    private let onExport: (_ path: URL) async -> Void
    private let onDelete: (_ spaceId: String) async -> Void
    
    @Published var message: String = ""
    @Published var dismiss = false
    
    init(notification: NotificationParticipantRemove, onDelete: @escaping (_ spaceId: String) async -> Void, onExport: @escaping (_ path: URL) async -> Void) {
        self.notification = notification
        self.onDelete = onDelete
        self.onExport = onExport
        message = Loc.ParticipantRemoveNotification.text
    }
    
    func onTapExport() async {
        // Create detached task, because export can be very long. Notifications dismissed and current task context will be cancelled
        Task {
            let tempDir = FileManager.default.createTempDirectory()
            let path = try await workspaceService.workspaceExport(spaceId: notification.remove.spaceID, path: tempDir.path)
            guard let exportSpaceUrl = URL(string: path) else { return }
            await onExport(exportSpaceUrl)
        }
        dismiss.toggle()
    }
    
    func onTapDelete() async {
        await onDelete(notification.remove.spaceID)
        dismiss.toggle()
    }
}