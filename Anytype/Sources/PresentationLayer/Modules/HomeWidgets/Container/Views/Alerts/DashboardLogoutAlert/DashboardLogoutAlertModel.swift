import Foundation
import UIKit

@MainActor
final class DashboardLogoutAlertModel: ObservableObject {
    
    @Published var isLogoutInProgress = false
    
    // MARK: - DI
    
    private let authService: AuthServiceProtocol
    private let applicationStateService: ApplicationStateServiceProtocol
    private let onBackup: () -> Void
    private let onLogout: () -> Void
    
    init(
        authService: AuthServiceProtocol,
        applicationStateService: ApplicationStateServiceProtocol,
        onBackup: @escaping () -> Void,
        onLogout: @escaping () -> Void
    ) {
        self.authService = authService
        self.applicationStateService = applicationStateService
        self.onBackup = onBackup
        self.onLogout = onLogout
    }
    
    func onBackupTap() {
        onBackup()
    }
    
    func onLogoutTap() {
        isLogoutInProgress = true
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.logout)

        authService.logout(removeData: false) { [weak self] isSuccess in
            guard isSuccess else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            self?.onLogout()
            self?.applicationStateService.state = .initial
        }
    }
}
