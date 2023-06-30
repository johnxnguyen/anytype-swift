import Foundation
import UIKit
import Services
import AnytypeCore
import ShimmerSwift

final class ObjectHeaderView: UIView {

    // MARK: - Private variables

    private let iconView = ObjectHeaderIconView()
    private let coverView = ObjectHeaderCoverView()

    private var onIconTap: (() -> Void)?
    private var onCoverTap: (() -> Void)?
    
    private var leadingConstraint: NSLayoutConstraint!
    private var centerConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    private var fullHeightConstraint: NSLayoutConstraint?
    private var converViewHeightConstraint: NSLayoutConstraint?
    private var iconTopConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        coverViewCenter = coverView.layer.position
    }

    // MARK: - Internal functions
    private lazy var coverViewCenter: CGPoint = coverView.layer.position

    func applyCoverTransform(_ transform: CGAffineTransform) {
        if coverView.transform.isIdentity, !transform.isIdentity {
            let maxY = coverViewCenter.y + coverView.bounds.height / 2
            coverView.layer.position = CGPoint(x: coverViewCenter.x, y: maxY)
            coverView.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        } else if transform.isIdentity {
            coverView.layer.position = coverViewCenter
            coverView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }

//         Disable CALayer implicit animations
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        coverView.transform = transform

        CATransaction.commit()
    }
}

extension ObjectHeaderView: ConfigurableView {
    
    struct Model {
        let state: ObjectHeaderFilledState
        let width: CGFloat
        let isShimmering: Bool
    }
    
    func configure(model: Model) {
        switch model.state {
        case .iconOnly(let objectHeaderIconState):
            switchState(.icon)
            applyObjectHeaderIcon(objectHeaderIconState.icon)
            onCoverTap = objectHeaderIconState.onCoverTap
            
        case .coverOnly(let objectHeaderCover):
            switchState(.cover)
            
            applyObjectHeaderCover(objectHeaderCover, maxWidth: model.width)
            
        case .iconAndCover(let objectHeaderIcon, let objectHeaderCover):
            switchState(.iconAndCover)
            
            applyObjectHeaderIcon(objectHeaderIcon)
            applyObjectHeaderCover(objectHeaderCover, maxWidth: model.width)
        }
    }
    
    private func switchState(_ state: State) {
        let isIcon = state == .icon
        fullHeightConstraint?.isActive = !isIcon
        iconTopConstraint?.isActive = isIcon
        converViewHeightConstraint?.isActive = !isIcon
        
        switch state {
        case .icon:
            iconView.isHidden = false
            coverView.isHidden = true
        case .cover:
            iconView.isHidden = true
            coverView.isHidden = false
        case .iconAndCover:
            iconView.isHidden = false
            coverView.isHidden = false
        }
    }
    
    private func applyObjectHeaderIcon(_ objectHeaderIcon: ObjectHeaderIcon) {
        iconView.configure(model: objectHeaderIcon.icon)
        applyLayoutAlignment(objectHeaderIcon.layoutAlignment)
        onIconTap = objectHeaderIcon.onTap
    }
    
    private func applyLayoutAlignment(_ layoutAlignment: LayoutAlignment) {
        switch layoutAlignment {
        case .left:
            leadingConstraint.isActive = true
            centerConstraint.isActive = false
            trailingConstraint.isActive = false
        case .center:
            leadingConstraint.isActive = false
            centerConstraint.isActive = true
            trailingConstraint.isActive = false
        case .right:
            leadingConstraint.isActive = false
            centerConstraint.isActive = false
            trailingConstraint.isActive = true
        }
    }
    
    private func applyObjectHeaderCover(
        _ objectHeaderCover: ObjectHeaderCover,
        maxWidth: CGFloat
    ) {
        coverView.configure(
            model: ObjectHeaderCoverView.Model(
                objectCover: objectHeaderCover.coverType,
                size: CGSize(
                    width: maxWidth,
                    height: ObjectHeaderConstants.coverHeight
                ),
                fitImage: false
            )
        )

        onCoverTap = objectHeaderCover.onTap
    }
    
}

private extension ObjectHeaderView {
    
    func setupView() {
        backgroundColor = .Background.primary
        setupGestureRecognizers()
        
        setupLayout()
        
        iconView.isHidden = true
        coverView.isHidden = true
    }
    
    func setupGestureRecognizers() {
        iconView.addGestureRecognizer(
            TapGestureRecognizerWithClosure { [weak self] in
                self?.onIconTap?()
            }
        )
        
        addGestureRecognizer(
            TapGestureRecognizerWithClosure { [weak self] in
                self?.onCoverTap?()
            }
        )
    }
    
    func setupLayout() {
        layoutUsing.anchors {
            fullHeightConstraint = $0.height.equal(to: ObjectHeaderConstants.coverFullHeight, priority: .defaultLow)
        }

        addSubview(coverView) {
            $0.pinToSuperview(
                excluding: [.bottom],
                insets: .zero
            )
            $0.bottom.greaterThanOrEqual(to: bottomAnchor, constant: -ObjectHeaderConstants.coverBottomInset, priority: .init(rawValue: 999))
            converViewHeightConstraint = $0.height.equal(to: ObjectHeaderConstants.coverHeight)
        }
        
        addSubview(iconView) {
            $0.bottom.equal(
                to: bottomAnchor,
                constant: -ObjectHeaderConstants.iconBottomInset
            )

            leadingConstraint = $0.leading.equal(
                to: leadingAnchor,
                constant: ObjectHeaderConstants.iconHorizontalInset,
                activate: false
            )

            centerConstraint = $0.centerX.equal(
                to: centerXAnchor,
                activate: false
            )
            
            trailingConstraint =  $0.trailing.equal(
                to: trailingAnchor,
                constant: -ObjectHeaderConstants.iconHorizontalInset,
                activate: false
            )
            
            iconTopConstraint = $0.top.equal(
                to: topAnchor,
                constant: ObjectHeaderConstants.emptyViewHeight,
                activate: false
            )
        }
    }
}

extension ObjectHeaderView {
    
    enum State {
        case icon
        case cover
        case iconAndCover
    }
    
}
