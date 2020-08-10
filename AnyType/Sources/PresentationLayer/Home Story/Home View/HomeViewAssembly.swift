//
//  HomeViewAssembly.swift
//  AnyType
//
//  Created by Denis Batvinkin on 24.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

class HomeViewAssembly {
    
    func createHomeView() -> HomeView {
        let viewModel: HomeViewModel = .init(homeCollectionViewAssembly: .init(), profileViewCoordinator: .init())
        let homeView: HomeView = .init(viewModel: viewModel, collectionViewModel: .init())
        
        return homeView
    }
}
