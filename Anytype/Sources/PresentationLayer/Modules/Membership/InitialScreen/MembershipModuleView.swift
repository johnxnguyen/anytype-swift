import SwiftUI
import StoreKit
import Services
import Combine


struct MembershipModuleView: View {
    @Environment(\.openURL) private var openURL
    @State private var safariUrl: URL?
    
    private let membership: MembershipStatus
    private let tiers: [MembershipTier]
    private let onTierTap: (MembershipTier) -> ()
    
    init(
        membership: MembershipStatus,
        tiers: [MembershipTier],
        onTierTap: @escaping (MembershipTier) -> ()
    ) {
        self.membership = membership
        self.tiers = tiers
        self.onTierTap =  onTierTap
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            ScrollView {
                VStack {
                    Spacer.fixedHeight(40)
                    AnytypeText(Loc.Membership.Ad.title, style: .riccioneTitle)
                        .foregroundColor(.Text.primary)
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                    AnytypeText(Loc.Membership.Ad.subtitle, style: .relation2Regular)
                        .foregroundColor(.Text.primary)
                        .padding(.horizontal, 60)
                        .multilineTextAlignment(.center)
                    Spacer.fixedHeight(32)
                    
                    baners
                    MembershipTierListView(userMembership: membership, tiers: tiers) {
                        UISelectionFeedbackGenerator().selectionChanged()
                        onTierTap($0)
                    }
                    .padding(.vertical, 32)
                    
                    legal
                }
            }
        }
        .safariSheet(url: $safariUrl)
    }
    
    private var baners: some View {
        Group {
            switch membership.tier?.type {
            case .explorer, nil:
                bannersView
            case .builder, .coCreator, .custom:
                EmptyView()
            }
        }
    }
    
    private var bannersView: some View {
        TabView {
            MembershipBannerView(
                title: Loc.Membership.Banner.title1,
                subtitle: Loc.Membership.Banner.subtitle1,
                image: .Membership.banner1,
                gradient: .green
            )
            MembershipBannerView(
                title: Loc.Membership.Banner.title2,
                subtitle: Loc.Membership.Banner.subtitle2,
                image: .Membership.banner2,
                gradient: .yellow
            )
            MembershipBannerView(
                title: Loc.Membership.Banner.title3,
                subtitle: Loc.Membership.Banner.subtitle3,
                image: .Membership.banner3,
                gradient: .pink
            )
            MembershipBannerView(
                title: Loc.Membership.Banner.title4,
                subtitle: Loc.Membership.Banner.subtitle4,
                image: .Membership.banner4,
                gradient: .purple
            )
        }
        .tabViewStyle(.page)
        .frame(height: 300)
    }
    
    var legal: some View {
        VStack(alignment: .leading) {
            MembershipLegalButton(text: Loc.Membership.Legal.details) {
                safariUrl = URL(string: AboutApp.pricingLink)
            }
            MembershipLegalButton(text: Loc.Membership.Legal.privacy) { 
                safariUrl = URL(string: AboutApp.privacyPolicyLink)
            }
            MembershipLegalButton(text: Loc.Membership.Legal.terms) { 
                safariUrl = URL(string: AboutApp.termsLink)
            }
            
            Spacer.fixedHeight(32)
            contactUs
            Spacer.fixedHeight(24)
            restorePurchases
        }
    }
    
    private var contactUs: some View {
        Button {
            let mailLink = MailUrl(
                to: AboutApp.licenseMailTo,
                subject: Loc.Membership.Email.subject,
                body: Loc.Membership.Email.body
            )
            guard let mailUrl = mailLink.url else { return }
            openURL(mailUrl)
        } label: {
            Group {
                AnytypeText(
                    "\(Loc.Membership.Legal.wouldYouLike) ",
                    style: .caption1Regular
                ).foregroundColor(.Text.primary) +
                AnytypeText(
                    Loc.Membership.Legal.letUsKnow,
                    style: .caption1Regular
                ).foregroundColor(.Text.primary).underline()
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 20)
        }
    }
    
    private var restorePurchases: some View {
        AsyncButton {
            try await AppStore.sync()
        } label: {
            Group {
                AnytypeText(
                    "\(Loc.Membership.Legal.alreadyPurchasedTier) ",
                    style: .caption1Regular
                ).foregroundColor(.Text.primary) +
                AnytypeText(
                    Loc.Membership.Legal.restorePurchases,
                    style: .caption1Regular
                )
                .foregroundColor(.Text.primary).underline()
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    NavigationView {
        MembershipModuleView(
            membership: .empty,
            tiers: [],
            onTierTap: { _ in }
        )
    }
}
