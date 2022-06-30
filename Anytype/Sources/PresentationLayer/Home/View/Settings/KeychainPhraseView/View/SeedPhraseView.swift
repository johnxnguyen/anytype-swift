import SwiftUI

struct SeedPhraseView: View {
    @StateObject private var model = KeychainPhraseViewModel()
    
    let onTap: () -> ()
    
    var body: some View {
        Button(action: { model.onSeedViewTap(onTap: onTap) }) {
            VStack(alignment: .center) {
                Spacer.fixedHeight(10)
                AnytypeText(
                    model.recoveryPhrase ?? Loc.RedactedText.seedPhrase,
                    style: .codeBlock,
                    color: .Text.sky
                )
                    .redacted(reason: model.recoveryPhrase.isNil ? .placeholder : [])
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                Spacer.fixedHeight(10)
            }
            .frame(maxWidth: .infinity)
            .background(Color.strokeTransperent)
            .cornerRadius(4)
        }
    }
}

struct SeedPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        SeedPhraseView(onTap: {}).padding()
    }
}

