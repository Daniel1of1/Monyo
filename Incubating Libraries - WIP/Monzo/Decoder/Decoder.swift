//
//  Decoder.swift
//  Monyo
//
//  Created by Daniel Haight on 21/05/2019.
//  Copyright © 2019 Daniel Haight. All rights reserved.
//

import Foundation

private let jsonDecoder = JSONDecoder()

func decoder<T>(for type: T.Type) -> ((Data,URLResponse)) -> Result<T,Swift.Error> where T: Decodable {
    return { response in
        guard let httpResponse = response.1 as? HTTPURLResponse else {
            return .failure(MonzoError.unknown(response))
        }
        switch httpResponse.statusCode {
        case 200:
            return Result{ try jsonDecoder.decode(T.self, from: response.0) }
        default:
            let res = Result{ try jsonDecoder.decode(ErrorResponse.self, from: response.0) }
            switch res {
            case .success(let errorResponse):
                return Result<T,Swift.Error>.failure(MonzoError.init(errorResponse))
            case .failure:
                return Result<T,Swift.Error>.failure(MonzoError.unknown(response))
            }
        }
    }
}
