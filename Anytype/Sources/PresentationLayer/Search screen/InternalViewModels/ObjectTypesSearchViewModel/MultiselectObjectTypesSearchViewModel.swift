import Foundation
import BlocksModels
import Combine
import SwiftUI

final class MultiselectObjectTypesSearchViewModel {
    
    let selectionMode: NewSearchViewModel.SelectionMode = .multipleItems
    
    @Published private var rows: [ListRowConfiguration] = []
    
    private var objects: [ObjectDetails] = [] {
        didSet {
            rows = objects.asRowConfigurations(with: selectedObjectTypeIds)
        }
    }
    
    private var selectedObjectTypeIds: [String] = [] {
        didSet {
            rows = objects.asRowConfigurations(with: selectedObjectTypeIds)
        }
    }
    
    private let interactor: ObjectTypesSearchInteractor
    
    init(selectedObjectTypeIds: [String], interactor: ObjectTypesSearchInteractor) {
        self.selectedObjectTypeIds = selectedObjectTypeIds
        self.interactor = interactor
    }
    
}

extension MultiselectObjectTypesSearchViewModel: NewInternalSearchViewModelProtocol {
    
    var listModelPublisher: AnyPublisher<NewSearchView.ListModel, Never> {
        $rows.map { rows -> NewSearchView.ListModel in
            NewSearchView.ListModel.plain(rows: rows)
        }.eraseToAnyPublisher()
    }
    
    func search(text: String) {
        interactor.search(text: text) { [weak self] objects in
            self?.objects = objects
        }
    }
    
    func handleRowsSelection(ids: [String]) {
        self.selectedObjectTypeIds = ids
    }
    
}

private extension Array where Element == ObjectDetails {

    func asRowConfigurations(with selectedIds: [String]) -> [ListRowConfiguration] {
        map { details in
            ListRowConfiguration(
                id: details.id.value,
                contentHash: details.hashValue
            ) {
                SearchObjectRowView(
                    viewModel: SearchObjectRowView.Model(details: details),
                    selectionIndicatorViewModel: SelectionIndicatorViewModelBuilder.buildModel(id: details.id.value, selectedIds: selectedIds)
                ).eraseToAnyView()
            }
        }
    }
    
}

private extension SearchObjectRowView.Model {
    
    init(details: ObjectDetails) {
        let title = details.title
        self.icon = {
            if details.layout == .todo {
                return .todo(details.isDone)
            } else {
                return details.icon.flatMap { .icon($0) } ?? .placeholder(title.first)
            }
        }()
        self.title = title
        self.subtitle = details.description
    }
    
}
