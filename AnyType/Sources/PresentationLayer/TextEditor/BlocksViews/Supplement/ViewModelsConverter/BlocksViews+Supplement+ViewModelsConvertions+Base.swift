//
//  BlocksViews+Supplement+ViewModelsConvertions+Base.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 01.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = BlocksViews.Supplement.ViewModelsConvertions
fileprivate typealias FileNamespace = BlocksViews.Supplement.ViewModelsConvertions.BaseConverter
fileprivate typealias ViewModels = BlocksViews.New

extension Namespace {
    class BaseConverter {
        fileprivate let document: BaseDocument
        func convert(_ blocks: [BaseDocument.ActiveModel]) -> [BlocksViews.New.Base.ViewModel] { [] }
        func convert(_ block: BaseDocument.ActiveModel) -> BlocksViews.New.Base.ViewModel? { nil }
        
        init(_ document: BaseDocument) {
            self.document = document
        }
    }
}

extension Namespace {
    /// TODO: Split later into
    class CompoundConverter: BaseConverter {
        override func convert(_ blocks: [BaseDocument.ActiveModel]) -> [BlocksViews.New.Base.ViewModel] {
            blocks.compactMap(self.convert)
        }
        override func convert(_ block: BaseDocument.ActiveModel) -> BlocksViews.New.Base.ViewModel? {
            switch block.blockModel.information.content {
            case .smartblock, .layout: return nil
            case let .text(value):
                switch value.contentType {
                case .title, .text, .quote, .checkbox, .bulleted, .numbered, .toggle, .header, .header2, .header3, .header4:
                    return ViewModels.Text.Base.ViewModel(block)
                case .callout: return ViewModels.Unknown.Label.ViewModel.init(block)
                }
            case let .file(value):
                switch value.contentType {
                case .file: return ViewModels.File.File.ViewModel.init(block)
                case .none: return ViewModels.Unknown.Label.ViewModel.init(block)
                case .image: return ViewModels.File.Image.ViewModel.init(block)
                case .video: return ViewModels.Unknown.Label.ViewModel.init(block)
                }
            case .divider: return ViewModels.Other.Divider.ViewModel.init(block)
            case .bookmark: return ViewModels.Bookmark.Bookmark.ViewModel.init(block)
            case let .link(value):
                let result = ViewModels.Tools.PageLink.ViewModel(block)
                if let details = self.document.getDetails(by: value.targetBlockID) {
                    _ = result.configured(details.wholeDetailsPublisher)
                }
                return result
            }
        }
    }
}
