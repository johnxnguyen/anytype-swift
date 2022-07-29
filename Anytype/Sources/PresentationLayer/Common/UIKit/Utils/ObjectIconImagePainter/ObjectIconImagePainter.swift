import Foundation
import UIKit

final class ObjectIconImagePainter {
    
    static let shared = ObjectIconImagePainter()
    
    private let imageStorage: ImageStorageProtocol = ImageStorage.shared
       
}

extension ObjectIconImagePainter: ObjectIconImagePainterProtocol {
    
    func todoImage(isChecked: Bool, imageGuideline: ImageGuideline) -> UIImage {
        let hash = "todo.\(isChecked).\(imageGuideline.identifier)"
        let image = UIImage(asset: isChecked ? .todoCheckmark : .todoCheckbox) ?? UIImage()
        return draw(hash: hash, image: image, imageGuideline: imageGuideline)
    }
    
    func staticImage(imageAsset: ImageAsset, imageGuideline: ImageGuideline) -> UIImage {
        let hash = "staticImage.\(imageAsset.identifier).\(imageGuideline.identifier)"
        let image = UIImage(asset: imageAsset) ?? UIImage()
        return draw(hash: hash, image: image, imageGuideline: imageGuideline)
    }
    
    private func draw(hash: String, image: UIImage, imageGuideline: ImageGuideline) -> UIImage {
        if let image = imageStorage.image(forKey: hash) {
            return image
        }

        let modifiedImage = image
            .scaled(to: imageGuideline.size)
            .rounded(
                radius: imageGuideline.cornerRadius,
                backgroundColor: imageGuideline.cornersGuideline?.backgroundColor?.cgColor
            )
        
        imageStorage.saveImage(modifiedImage, forKey: hash)
        
        return modifiedImage
    }
    
    func image(
        with string: String,
        font: UIFont,
        textColor: UIColor,
        imageGuideline: ImageGuideline,
        backgroundColor: UIColor
    ) -> UIImage {
        ImageBuilder(imageGuideline)
            .setText(string)
            .setFont(font)
            .setTextColor(textColor)
            .setImageColor(backgroundColor)
            .build()
    }
    
}
