//
//  BlocksModelsModule+Parser+Common.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import BlocksModels
import ProtobufMessages

fileprivate typealias Namespace = BlocksModelsModule

// MARK: - Common
extension Namespace.Parser {
    /// It is a namespace of common models.
    /// It contains parsers and converters which related to conversion between middleware and our model.
    enum Common {
        enum Alignment {}
        enum Position {}
    }
}

// MARK: - Common / Alignment
extension Namespace.Parser.Common.Alignment {
    /// Alignment: Conversion between model between middleware and our model.
    enum Converter {
        typealias Model = TopLevel.Alignment
        typealias MiddlewareModel = Anytype_Model_Block.Align
        static func asModel(_ value: MiddlewareModel) -> Model? {
            switch value {
            case .left: return .left
            case .center: return .center
            case .right: return .right
            default: return nil
            }
        }
        
        static func asMiddleware(_ value: Model) -> MiddlewareModel? {
            switch value {
            case .left: return .left
            case .center: return .center
            case .right: return .right
            }
        }
    }
    
    /// Alignment: Conversion between our model and UIKit textAlignment.
    /// Later it will be separated into textAlignment and contentMode.
    enum UIKitConverter {
        typealias Model = TopLevel.Alignment
        typealias UIKitModel = NSTextAlignment
        static func asModel(_ value: UIKitModel) -> Model? {
            switch value {
            case .left: return .left
            case .center: return .center
            case .right: return .right
            default: return nil
            }
        }
        
        static func asUIKitModel(_ value: Model) -> UIKitModel? {
            switch value {
            case .left: return .left
            case .center: return .center
            case .right: return .right
            }
        }
    }
}

// MARK: - Common / Position
extension Namespace.Parser.Common.Position {
    /// Position: Conversion between our model and middleware model.
    enum Converter {
        /// TODO: Rethink.
        /// Maybe we will move Position and Common structures to `BlocksModels`.
        ///
        typealias Model = TopLevel.Position
        typealias MiddlewareModel = Anytype_Model_Block.Position
        
        static func asModel(_ value: MiddlewareModel) -> Model? {
            switch value {
            case .none: return Model.none
            case .top: return .top
            case .bottom: return .bottom
            case .left: return .left
            case .right: return .right
            case .inner: return .inner
            case .replace: return .replace
            default: return nil
            }
        }
        static func asMiddleware(_ value: Model) -> MiddlewareModel? {
            switch value {
            case .none: return MiddlewareModel.none
            case .top: return .top
            case .bottom: return .bottom
            case .left: return .left
            case .right: return .right
            case .inner: return .inner
            case .replace: return .replace
            }
        }
    }
}
