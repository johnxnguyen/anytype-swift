import Foundation
import SwiftUI

struct ListWidgetView: View {
    
    let data: WidgetSubmoduleData
    let style: ListWidgetStyle
    let internalModel: WidgetInternalViewModelProtocol
    let internalHeaderModel: WidgetDataviewInternalViewModelProtocol?
    
    var body: some View {
        ListWidgetInternalView(
            data: data,
            style: style,
            internalModel: internalModel,
            internalHeaderModel: internalHeaderModel
        )
        .id(data.widgetBlockId + style.rawValue)
    }
}

private struct ListWidgetInternalView: View {
    
    let data: WidgetSubmoduleData
    
    @StateObject private var model: ListWidgetViewModel
    
    init(
        data: WidgetSubmoduleData,
        style: ListWidgetStyle,
        internalModel: WidgetInternalViewModelProtocol,
        internalHeaderModel: WidgetDataviewInternalViewModelProtocol?
    ) {
        self.data = data
        self._model = StateObject(
            wrappedValue: ListWidgetViewModel(
                widgetBlockId: data.widgetBlockId,
                widgetObject: data.widgetObject,
                style: style,
                internalModel: internalModel,
                internalHeaderModel: internalHeaderModel,
                output: data.output
            )
        )
    }
    
    var body: some View {
        WidgetContainerView(
            widgetBlockId: data.widgetBlockId,
            widgetObject: data.widgetObject,
            homeState: data.homeState,
            name: model.name,
            dragId: model.dragId,
            onCreateObjectTap: model.allowCreateObject ? {
                model.onCreateObjectTap()
            } : nil,
            onHeaderTap: {
                model.onHeaderTap()
            },
            output: data.output,
            content: {
                bodyContent
            }
        )
    }
    
    private var bodyContent: some View {
        VStack(spacing: 0) {
            ViewWidgetTabsView(items: model.headerItems)
            content
        }
    }
        
    private var content: some View {
        ZStack {
            if let rows = model.rows {
                if rows.isEmpty {
                    VStack(spacing: 0) {
                        WidgetEmptyView(title: model.emptyTitle)
                            .frame(height: 72)
                        Spacer.fixedHeight(8)
                    }
                    .transition(.opacity)
                }
                else {
                    VStack(spacing: 0) {
                        ForEach(rows) {
                            rowView(row: $0, showDivider: $0.id != rows.last?.id)
                        }
                        Spacer.fixedHeight(8)
                    }
                    .transition(.opacity)
                }
            }
        }
        // This fixes the tap area for header in bottom side
        .fixTappableArea()
    }
    
    @ViewBuilder
    private func rowView(row: ListWidgetRowModel, showDivider: Bool) -> some View {
        switch model.style {
        case .compactList:
            ListWidgetCompactRow(model: row, showDivider: showDivider)
        case .list:
            ListWidgetRow(model: row, showDivider: showDivider)
        }
    }
}
