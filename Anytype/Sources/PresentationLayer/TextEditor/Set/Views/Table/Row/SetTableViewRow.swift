
import SwiftUI

struct SetTableViewRow: View {
    let data: SetTableViewRowData
    let xOffset: CGFloat
    
    @EnvironmentObject private var model: EditorSetViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(18)
            details
            Spacer.fixedHeight(18)
            cells
            Spacer.fixedHeight(12)
            AnytypeDivider()
        }
    }
    
    private var details: some View {
        HStack(spacing: 0) {
            icon
            title
        }
        .padding(.horizontal, 16)
        .offset(x: xOffset, y: 0)
    }
    
    private var icon: some View {
        Group {
            if let icon = data.icon, data.showIcon {
                Button {
                    data.onIconTap()
                } label: {
                    SwiftUIObjectIconImageView(iconImage: icon, usecase: .setRow).frame(width: 18, height: 18)
                    Spacer.fixedWidth(8)
                }
            }
        }
    }
    
    private var title: some View {
        Button {
            model.showPage(data.screenData)
        } label: {
            AnytypeText(data.title, style: .previewTitle2Medium, color: .textPrimary)
                .lineLimit(1)
        }
    }
    
    private var cells: some View {
        LazyHStack(spacing: 0) {
            ForEach(data.relations) { colum in
                Spacer.fixedWidth(16)
                cell(colum)
                Rectangle()
                    .frame(width: 0.5, height: 18)
                    .foregroundColor(.strokePrimary)
            }
        }
        .frame(height: 18)
    }
    
    private func cell(_ relationData: Relation) -> some View {
        RelationValueView(relation: RelationItemModel(relation: relationData), style: .set) {
            AnytypeAnalytics.instance().logChangeRelationValue(type: .set)

            model.showRelationValueEditingView(
                objectId: data.id,
                source: .dataview(contextId: model.document.objectId),
                relation: relationData
            )
        }
        .frame(width: 128)
    }
}
