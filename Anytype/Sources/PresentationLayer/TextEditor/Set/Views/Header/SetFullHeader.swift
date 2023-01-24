import SwiftUI
import Kingfisher

struct SetFullHeader: View {
    @State private var width: CGFloat = .zero

    @EnvironmentObject private var model: EditorSetViewModel
    
    private let minimizedHeaderHeight = ObjectHeaderConstants.minimizedHeaderHeight + UIApplication.shared.mainWindowInsets.top
    
    var body: some View {
        Group {
            if model.hasTargetObjectId {
                inlineHeader
            } else {
                header
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            cover
            VStack(alignment: .leading, spacing: 8) {
                titleView
                description
                flowRelations
            }
            .padding([.leading], 20)
        }
        .readSize { width = $0.width }
    }
    
    private var inlineHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            emptyCover
            VStack(alignment: .leading, spacing: 8) {
                iconWithTitle
                flowRelations
            }
            .padding([.leading], 20)
        }
        .readSize { width = $0.width }
    }
    
    private var cover: some View {
        Group {
            switch model.headerModel.header {
            case .empty(let data, _):
                Button(action: data.onTap) {
                    emptyCover
                }
            case .filled(let state, _):
                ObjectHeaderFilledContentSwitfUIView(
                    configuration: ObjectHeaderFilledConfiguration(
                        state: state,
                        isShimmering: false,
                        width: width
                    )
                )
                .frame(height: ObjectHeaderConstants.coverFullHeight)
            default:
                EmptyView()
            }
        }
    }
    
    private var emptyCover: some View {
        Color.Background.primary
            .frame(height: ObjectHeaderConstants.emptyViewHeight)
    }
}

extension SetFullHeader {
    private var description: some View {
        Group {
            if let description = model.details?.description, description.isNotEmpty {
                AnytypeText(
                    description,
                    style: .relation2Regular,
                    color: .Text.primary
                )
                .fixedSize(horizontal: false, vertical: true)
            } else {
                EmptyView()
            }
        }
    }
    
    private var iconWithTitle: some View {
        HStack(spacing: 8) {
            iconView
            titleView
        }
    }
    
    private var iconView: some View {
        Group {
            if model.hasTargetObjectId, let iconImage = model.details?.objectIconImage {
                SwiftUIObjectIconImageView(
                    iconImage: iconImage,
                    usecase: .inlineSetHeader)
                .frame(
                    width: 32,
                    height: 32
                )
                .padding(.top, 1)
                .onTapGesture {
                    model.showIconPicker()
                }
            }
        }
    }

    private var titleView: some View {
        AutofocusedTextField(
            placeholder: Loc.untitled,
            placeholderFont: .title,
            shouldSkipFocusOnFilled: true,
            text: $model.titleString
        )
        .padding([.trailing], 20)
        .font(AnytypeFontBuilder.font(anytypeFont: .title))
        .disableAutocorrection(true)
    }

    private var flowRelations: some View {
        FlowLayout(
            items: model.featuredRelations,
            alignment: .leading,
            spacing: .init(width: 6, height: 4),
            cell: { item, index in
                HStack(spacing: 0) {
                    let relation = RelationItemModel(relation: item)
                    RelationValueView(
                        relation: relation,
                        style: .featuredRelationBlock(
                            FeaturedRelationSettings(
                                allowMultiLine: false,
                                prefix: item.setOfPrefix,
                                showIcon: item.showIcon,
                                error: relation.isErrorState
                            )
                        )
                    ) { [weak model] in
                        UIApplication.shared.hideKeyboard()
                        model?.onRelationTap(relation: item)
                    }

                    if model.featuredRelations.count - 1 > index {
                        dotImage
                    }
                }
            }
        )
    }

    private var dotImage: some View {
        Image(systemName: "circle.fill")
            .resizable()
            .foregroundColor(.Text.secondary)
            .frame(width: 3, height: 3)
    }
}

struct SetFullHeader_Previews: PreviewProvider {
    static var previews: some View {
        SetFullHeader()
    }
}
