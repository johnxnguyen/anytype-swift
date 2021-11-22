import SwiftUI

struct RelationsListRowView: View {
    
    @Binding var editingMode: Bool
    let relation: Relation
    
    let onRemoveTap: (String) -> ()
    let onStarTap: (String) -> ()
    let onEditTap: (String) -> ()
    
    var body: some View {
        GeometryReader { gr in
            HStack(spacing: 8) {
                if editingMode {
                    if relation.isEditable {
                        removeButton
                    } else {
                        Spacer.fixedWidth(Constants.buttonWidth)
                    }
                }
                
                // If we will use spacing more than 0 it will be added to
                // `Spacer()` from both sides as a result
                // `Spacer` will take up more space
                HStack(spacing: 0) {
                    name
                        .frame(width: gr.size.width * 0.4, alignment: .leading)
                    Spacer.fixedWidth(8)
                    valueView
                    Spacer(minLength: 8)
                    starImageView
                }
                .frame(height: gr.size.height)
                .modifier(DividerModifier(spacing:0))
            }
        }
        .frame(height: 48)
    }
    
    private var name: some View {
        HStack(spacing: 6) {
            if !relation.isEditable {
                Image.Relations.locked
                    .frame(width: 15, height: 12)
            }
            AnytypeText(relation.name, style: .relation1Regular, color: .textSecondary).lineLimit(1)
        }
    }
    
    private var valueView: some View {
        Button {
            onEditTap(relation.id)
        } label: {
            Group {
                let value = relation.value
                let hint = relation.hint
                switch value {
                case .text(let string):
                    TextRelationView(value: string, hint: hint)
                    
                case .status(let statusRelation):
                    StatusRelationView(value: statusRelation, hint: hint)
                    
                case .checkbox(let bool):
                    CheckboxRelationView(isChecked: bool)
                    
                case .tag(let tags):
                    TagRelationView(value: tags, hint: hint)
                    
                case .object(let objectRelation):
                    ObjectRelationView(value: objectRelation, hint: hint)
                    
                case .unknown(let string):
                    RelationsListRowHintView(hint: string)
                }
            }
        }
    }
    
    private var removeButton: some View {
        withAnimation(.spring()) {
            Button {
                onRemoveTap(relation.id)
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
            }.frame(width: Constants.buttonWidth, height: Constants.buttonWidth)
        }
    }
    
    private var starImageView: some View {
        Button {
            onStarTap(relation.id)
        } label: {
            relation.isFeatured ?
            Image.Relations.removeFromFeatured :
            Image.Relations.addToFeatured
        }.frame(width: Constants.buttonWidth, height: Constants.buttonWidth)
    }
}

private extension RelationsListRowView {
    
    enum Constants {
        static let buttonWidth: CGFloat = 24
    }
    
}

struct ObjectRelationRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            RelationsListRowView(
                editingMode: .constant(false),
                relation: Relation(
                    id: "1", name: "Relation name",
                    value: .tag([
                        TagRelation(text: "text", textColor: .darkTeal, backgroundColor: .grayscaleWhite),
                        TagRelation(text: "text2", textColor: .darkRed, backgroundColor: .lightRed),
                        TagRelation(text: "text", textColor: .darkTeal, backgroundColor: .lightTeal),
                        TagRelation(text: "text2", textColor: .darkRed, backgroundColor: .lightRed)
                    ]),
                    hint: "hint",
                    isFeatured: false,
                    isEditable: true
                ),
                onRemoveTap: { _ in },
                onStarTap: { _ in },
                onEditTap: { _ in }
            )
            RelationsListRowView(
                editingMode: .constant(false),
                relation: Relation(
                    id: "1", name: "Relation name",
                    value: .text("hello"),
                    hint: "hint",
                    isFeatured: false,
                    isEditable: false
                ),
                onRemoveTap: { _ in },
                onStarTap: { _ in },
                onEditTap: { _ in }
            )
        }
    }
}
