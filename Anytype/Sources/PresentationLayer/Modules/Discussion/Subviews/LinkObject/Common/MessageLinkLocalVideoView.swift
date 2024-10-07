import SwiftUI
import AVKit

import SwiftUI

struct MessageLinkLocalVideoView: View {
    
    let url: URL
    let onTapRemove: () -> Void
    
    // Prevent image creation for each view update
    @State private var image: UIImage?
    
    init(url: URL, onTapRemove: @escaping () -> Void) {
        self.url = url
        self.onTapRemove = onTapRemove
        self._image = State(initialValue: UIImage(videoPreview: url))
    }
    
    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            Color.black.opacity(0.2)
            Image(asset: .X32.video)
                .foregroundStyle(Color.white)
        }
        .onChange(of: url) { newValue in
            image = UIImage(videoPreview: url)
        }
        .frame(width: 72, height: 72)
        .messageLinkStyle()
        .messageLinkRemoveButton(onTapRemove: onTapRemove)
    }
}


fileprivate extension UIImage {
    
    convenience init?(videoPreview path: URL) {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            self.init(cgImage: cgImage)
        } catch {
            return nil
        }
    }
}
