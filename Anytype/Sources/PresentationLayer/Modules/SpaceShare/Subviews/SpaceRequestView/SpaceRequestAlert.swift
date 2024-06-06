import Foundation
import SwiftUI

struct SpaceRequestAlertData: Identifiable {
    let id = UUID()
    let spaceId: String
    let spaceName: String
    let participantIdentity: String
    let participantName: String
    let route: ScreenInviteConfirmRoute
}

struct SpaceRequestAlert: View {
    
    @StateObject private var model: SpaceRequestAlertModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: SpaceRequestAlertData, onMembershipUpgradeTap: @escaping () -> ()) {
        _model = StateObject(wrappedValue: SpaceRequestAlertModel(
            data: data,
            onMembershipUpgradeTap: onMembershipUpgradeTap
        ))
    }
    
    var body: some View {
        BottomAlertView(title: model.title, message: "") {
            if model.showUpgradeButton {
                upgradeActions
            } else {
                defaultActions
            }
        }
        .throwTask {
            try await model.onAppear()
        }
    }
    
    private var defaultActions: [BottomAlertButton] {
        [
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.viewAccess, style: .secondary, disable: !model.canAddReaded) {
                try await model.onViewAccess()
                dismiss()
            },
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.editAccess, style: .secondary, disable: !model.canAddWriter) {
                try await model.onEditAccess()
                dismiss()
            },
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.reject, style: .warning) {
                try await model.onReject()
                dismiss()
            }
        ]
    }
    
    private var upgradeActions: [BottomAlertButton] {
        [
            BottomAlertButton(
                text: "\(MembershipConstants.membershipSymbol.rawValue) \(Loc.Membership.Upgrade.moreMembers)",
                style: .primary
            ) {
                model.onMembershipUpgrade()
                dismiss()
            },
            BottomAlertButton(text: Loc.SpaceShare.ViewRequest.reject, style: .warning) {
                try await model.onReject()
                dismiss()
            }
        ]
    }
}
