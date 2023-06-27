import SwiftUI
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var phrase = ""
    @Published var autofocus = true
    @Published var walletRecoveryInProgress = false
    @Published var showQrCodeView: Bool = false
    @Published var showEnteringVoidView = false
    @Published var openSettingsURL = false
    @Published var entropy: String = "" {
        didSet {
            onEntropySet()
        }
    }
    @Published var error: String?
    
    let canRestoreFromKeychain: Bool
    
    private let authService: AuthServiceProtocol
    private let seedService: SeedServiceProtocol
    private let localAuthService: LocalAuthServiceProtocol
    private let cameraPermissionVerifier: CameraPermissionVerifierProtocol
    private weak var output: LoginFlowOutput?
    
    private var subscriptions = [AnyCancellable]()
    
    init(
        authService: AuthServiceProtocol,
        seedService: SeedServiceProtocol,
        localAuthService: LocalAuthServiceProtocol,
        cameraPermissionVerifier: CameraPermissionVerifierProtocol,
        output: LoginFlowOutput?
    ) {
        self.authService = authService
        self.seedService = seedService
        self.localAuthService = localAuthService
        self.cameraPermissionVerifier = cameraPermissionVerifier
        self.canRestoreFromKeychain = (try? seedService.obtainSeed()).isNotNil
        self.output = output
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logLoginScreenShow()
    }
    
    func onEnterButtonAction() {
        walletRecovery(with: phrase)
    }
    
    func onScanQRButtonAction() {
        cameraPermissionVerifier.cameraPermission
            .receiveOnMain()
            .sink { [unowned self] isGranted in
                if isGranted {
                    showQrCodeView = true
                } else {
                    openSettingsURL = true
                }
            }
            .store(in: &subscriptions)
    }
    
    func onKeychainButtonAction() {
        restoreFromkeychain()
    }
    
    func onNextAction() -> AnyView? {
        output?.onEntetingVoidAction()
    }
    
    private func onEntropySet() {
        Task {
            let phrase = try await authService.mnemonicByEntropy(entropy)
            walletRecovery(with: phrase)
        }
    }
    
    private func walletRecovery(with phrase: String) {
        Task {
            do {
                self.phrase = phrase
                walletRecoveryInProgress = true
                
                try await authService.walletRecovery(mnemonic: phrase.trimmingCharacters(in: .whitespacesAndNewlines))
                try seedService.saveSeed(phrase)
                
                recoverWalletSuccess()
            } catch {
                recoverWalletError()
            }
        }
    }
    
    private func restoreFromkeychain() {
        localAuthService.auth(reason: Loc.restoreSecretPhraseFromKeychain) { [unowned self] didComplete in
            guard didComplete,
                  let phrase = try? seedService.obtainSeed() else {
                return
            }
            walletRecovery(with: phrase)
        }
    }
    
    private func recoverWalletSuccess() {
        walletRecoveryInProgress = false
        showEnteringVoidView.toggle()
    }
    
    private func recoverWalletError() {
        walletRecoveryInProgress = false
    }
}
