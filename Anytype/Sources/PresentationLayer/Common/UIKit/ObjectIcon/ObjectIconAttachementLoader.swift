import Foundation
import UIKit
import Kingfisher

// KEEP IN SYNC WITH ObjectIconImageView

final class ObjectIconAttachementLoader {
    
    private let painter: ObjectIconImagePainterProtocol = ObjectIconImagePainter.shared
    weak var attachement: NSTextAttachment?
    
    init() { }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - ConfigurableView

extension ObjectIconAttachementLoader {
    func configure(model: ObjectIconImageModel, processor: ImageProcessor) {
        guard let attachement = attachement else {
            return
        }
        
        switch model.iconImage {
        case .icon(let objectIconType):
            handleObjectIconType(objectIconType, model: model, customProcessor: processor)
        case .todo(let isChecked):
            let image = model.imageGuideline.flatMap {
                painter.todoImage(
                    isChecked: isChecked,
                    imageGuideline: $0
                )
            }
            setImage(image: image, processor: processor)
            
        case .placeholder(let character):
            let image = stringIconImage(
                model: model,

                string: character.flatMap { String($0) } ?? "",
                textColor: UIColor.textTertiary,
                backgroundColor: UIColor.grayscale10
            )
            setImage(image: image, processor: processor)
        case .staticImage(let name):
            let image = model.imageGuideline.flatMap {
                painter.staticImage(name: name, imageGuideline: $0)
            }
            setImage(image: image, processor: processor)
        }
    }
    
    private func handleObjectIconType(
        _ type: ObjectIconType,
        model: ObjectIconImageModel,
        customProcessor: ImageProcessor
    ) {
        guard let attachement = attachement else {
            return
        }
        
        switch type {
        case .basic(let id):
            downloadImage(imageId: id, model: model, customProcessor: customProcessor)
        case .profile(let profile):
            switch profile {
            case .imageId(let id):
                downloadImage(imageId: id, model: model, customProcessor: customProcessor)
            case .character(let character):
                let image = stringIconImage(
                    model: model,
                    string: String(character),
                    textColor: UIColor.backgroundPrimary,
                    backgroundColor: UIColor.dividerSecondary
                )
                setImage(image: image, processor: customProcessor)
            }
        case .emoji(let iconEmoji):
            let image = stringIconImage(
                model: model,
                string: iconEmoji.value,
                textColor: UIColor.backgroundPrimary,
                backgroundColor: model.usecase.backgroundColor
            )
            setImage(image: image, processor: customProcessor)
        }
    }
    
    private func downloadImage(
        imageId: String,
        model: ObjectIconImageModel,
        customProcessor: ImageProcessor
    ) {
        guard let attachement = attachement else {
            return
        }
        
        guard let imageGuideline = model.imageGuideline else {
            attachement.image = nil
            return
        }
        
        setImage(image: ImageBuilder(imageGuideline).build(), processor: customProcessor)
        
        let processor = KFProcessorBuilder(
            scalingType: .resizing(.aspectFill),
            targetSize: imageGuideline.size,
            cornerRadius: .point(imageGuideline.cornersGuideline.radius)
        ).processor |> customProcessor
        
        guard let url = ImageID(id: imageId, width: imageGuideline.size.width.asImageWidth).resolvedUrl else {
            return
        }
        
        let view = UIView()
        attachement.kf.setImage(
            with: url,
            attributedView: view,
            placeholder: ImageBuilder(imageGuideline).build(),
            options: [.processor(processor), .transition(.fade(0.2))]
        )

    }
    
    private func stringIconImage(
        model: ObjectIconImageModel,
        string: String,
        textColor: UIColor,
        backgroundColor: UIColor
    ) -> UIImage? {
        guard let imageGuideline = model.imageGuideline, let font = model.font else { return nil}
        
        return painter.image(
            with: string,
            font: font,
            textColor: textColor,
            imageGuideline: imageGuideline,
            backgroundColor: backgroundColor
        )
    }
    
    private func setImage(image: UIImage?, processor: ImageProcessor) {
        guard let image = image else { return }
        attachement?.image = processor.process(item: .image(image), options: .init(nil))
    }
    
}
