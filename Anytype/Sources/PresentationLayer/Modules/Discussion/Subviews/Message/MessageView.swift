import Foundation
import SwiftUI

struct MessageView: View {
    let data: MessageViewData
    weak var output: MessageModuleOutput?
    
    var body: some View {
        MessageInternalView(data: data, output: output)
            .id(data.id)
    }
}

private struct MessageInternalView: View {
        
    @StateObject private var model: MessageViewModel
    
    init(
        data: MessageViewData,
        output: MessageModuleOutput? = nil
    ) {
        self._model = StateObject(wrappedValue: MessageViewModel(data: data, output: output))
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            leadingView
            content
            trailingView
        }
        .padding(.horizontal, 8)
        .task {
            await model.subscribeOnBlock()
        }
    }
    
    private var messageBackgorundColor: Color {
        return model.isYourMessage ? Color.VeryLight.green : Color.VeryLight.grey
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(model.author)
                    .anytypeStyle(.previewTitle2Medium)
                    .foregroundColor(.Text.primary)
                Spacer()
                Text(model.date)
                    .anytypeStyle(.caption1Regular)
                    .foregroundColor(.Text.secondary)
            }
            Text(model.message)
                .anytypeStyle(.bodyRegular)
                .foregroundColor(.Text.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(messageBackgorundColor)
        .cornerRadius(24, style: .circular)
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 24, style: .circular))
        .contextMenu {
            contextMenu
        }
    }
    
    @ViewBuilder
    private var leadingView: some View {
        if model.isYourMessage {
            Spacer.fixedWidth(32)
        } else {
            IconView(icon: model.authorIcon)
                .frame(width: 32, height: 32)
        }
    }
    
    @ViewBuilder
    private var trailingView: some View {
        if model.isYourMessage {
            IconView(icon: model.authorIcon)
                .frame(width: 32, height: 32)
        } else {
            Spacer.fixedWidth(32)
        }
    }
    
    @ViewBuilder
    private var contextMenu: some View {
        Button {
            model.onTapAddReaction()
        } label: {
            Text(Loc.Message.Action.addReaction)
        }
    }
}
