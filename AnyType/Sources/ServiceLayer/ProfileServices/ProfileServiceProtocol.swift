//
//  ProfileServiceProtocol.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Combine

/// Protocol working with user profile
protocol ProfileServiceProtocol {
    /// User name
    var name: String? { get set }
    /// User avatar
    var avatar: String? {get set }
    
    func obtainUserInformation() -> AnyPublisher<ServiceLayerModule.Success, Error>
}
