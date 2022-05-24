import Foundation
import Combine

protocol NewInternalSearchViewModelProtocol {
    
    var listModelPublisher: AnyPublisher<NewSearchView.ListModel, Never> { get }
    
    var selectionMode: NewSearchViewModel.SelectionMode { get }
    
    func search(text: String)
    
    func handleRowsSelection(ids: [String])
    
    func isCreateButtonAvailable(searchText: String) -> Bool
    
}

extension NewInternalSearchViewModelProtocol {
    
    func isCreateButtonAvailable(searchText: String) -> Bool {
        searchText.isNotEmpty
    }
    
}
