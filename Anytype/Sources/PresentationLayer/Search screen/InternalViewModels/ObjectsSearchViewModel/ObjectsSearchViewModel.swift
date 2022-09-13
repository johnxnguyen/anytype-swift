import Foundation
import BlocksModels
import Combine
import SwiftUI

final class ObjectsSearchViewModel {
    
    let selectionMode: NewSearchViewModel.SelectionMode
    let viewStateSubject = PassthroughSubject<NewSearchViewState, Never>()

    private let interactor: ObjectsSearchInteractorProtocol
    
    private var objects: [ObjectDetails] = []
    private var selectedObjectIds: [String] = []
    
    init(selectionMode: NewSearchViewModel.SelectionMode, interactor: ObjectsSearchInteractorProtocol) {
        self.selectionMode = selectionMode
        self.interactor = interactor
        self.setup()
    }
    
    private func setup() {
        if case let .multipleItems(preselectedIds) = selectionMode {
            self.selectedObjectIds = preselectedIds
        }
    }
}

extension ObjectsSearchViewModel: NewInternalSearchViewModelProtocol {
    
    func search(text: String) {
        let objects = interactor.search(text: text)
        
        if objects.isEmpty {
            handleError(for: text)
        } else {
            handleSearchResults(objects)
        }
        
        self.objects = objects
    }
    
    func handleRowsSelection(ids: [String]) {
        guard objects.isNotEmpty else { return }
        
        self.selectedObjectIds = ids
        handleSearchResults(objects)
    }
    
}

private extension ObjectsSearchViewModel {
    
    func handleError(for text: String) {
        viewStateSubject.send(.error(.noObjectError(searchText: text)))
    }
    
    func handleSearchResults(_ objects: [ObjectDetails]) {
        viewStateSubject.send(
            .resultsList(
                .plain(
                    rows: objects.asRowConfigurations(with: selectedObjectIds, selectionMode: selectionMode)
                )
            )
        )
    }
    
}

private extension Array where Element == ObjectDetails {

    func asRowConfigurations(with selectedIds: [String], selectionMode: NewSearchViewModel.SelectionMode) -> [ListRowConfiguration] {
        map { details in
            ListRowConfiguration(
                id: details.id,
                contentHash: details.hashValue
            ) {
                AnyView(
                    SearchObjectRowView(
                        viewModel: SearchObjectRowView.Model(details: details),
                        selectionIndicatorViewModel: selectionMode.asSelectionIndicatorViewModel(
                            details: details,
                            selectedIds: selectedIds
                        )
                    )
                )
            }
        }
    }
}

private extension NewSearchViewModel.SelectionMode {
    
    func asSelectionIndicatorViewModel(details: ObjectDetails, selectedIds: [String]) -> SelectionIndicatorView.Model? {
        switch self {
        case .multipleItems:
            return SelectionIndicatorViewModelBuilder.buildModel(id: details.id, selectedIds: selectedIds)
        case .singleItem:
            return nil
        }
    }
}

private extension SearchObjectRowView.Model {
    
    init(details: ObjectDetails) {
        let title = details.title
        self.icon = {
            if details.layoutValue == .todo {
                return .todo(details.isDone)
            } else {
                return details.icon.flatMap { .icon($0) } ?? .placeholder(title.first)
            }
        }()
        self.title = title
        self.subtitle = details.objectType.name
        self.style = .default
        self.isChecked = false
    }
    
}
