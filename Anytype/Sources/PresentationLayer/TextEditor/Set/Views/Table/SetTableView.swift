import SwiftUI

struct SetTableView: View {
    @Binding var tableHeaderSize: CGSize
    @Binding var offset: CGPoint
    var headerMinimizedSize: CGSize

    @State private var initialOffset = CGPoint.zero

    @EnvironmentObject private var model: EditorSetViewModel

    var body: some View {
        SingleAxisGeometryReader { fullWidth in
            OffsetAwareScrollView(
                axes: [.horizontal],
                showsIndicators: false,
                offsetChanged: { offset.x = $0.x }
            ) {
                OffsetAwareScrollView(
                    axes: [.vertical],
                    showsIndicators: false,
                    offsetChanged: { offset.y = $0.y }
                ) {
                    Spacer.fixedHeight(tableHeaderSize.height)
                    LazyVStack(
                        alignment: .leading,
                        spacing: 0,
                        pinnedViews: [.sectionHeaders]
                    ) {
                        Section(header: compoundHeader) {
                            ForEach(model.rows) { row in
                                SetTableViewRow(data: row, initialOffset: initialOffset.x, xOffset: offset.x)
                            }
                        }
                    }
                    .frame(minWidth: fullWidth)
                    .onAppear {
                        DispatchQueue.main.async {
                            // initial y offset is 0 for some reason
                            offset = CGPoint(x: offset.x, y: 0)
                            initialOffset = offset
                        }
                    }
                    .padding(.top, -headerMinimizedSize.height)
                }
                // Initial scroll offset
                .offset(x: 0, y: -8)
            }
            .overlay(
                SetFullHeader()
                    .offset(x: 0, y: offset.y)
                    .readSize { tableHeaderSize = $0 }
                    .frame(width: fullWidth)
                , alignment: .topLeading
            )
        }
    }

    private var xOffset: CGFloat {
        initialOffset.x >= offset.x ? initialOffset.x - offset.x : 0
    }

    private var compoundHeader: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(headerMinimizedSize.height)
            VStack {
                SetHeaderSettings()
                    .offset(x: xOffset, y: 0)
                    .environmentObject(model)
                SetTableViewHeader()
            }
            .background(Color.backgroundPrimary)
        }
    }
}


struct SetTableView_Previews: PreviewProvider {
    static var previews: some View {
        SetTableView(
            tableHeaderSize: .constant(.zero),
            offset: .constant(.zero),
            headerMinimizedSize: .zero
        )
    }
}

