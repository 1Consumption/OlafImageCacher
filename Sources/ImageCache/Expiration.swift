//
//  Expiration.swift
//  OlafImageCacher
//
//  Created by 신한섭 on 2020/09/20.
//

import Foundation

public enum Expiration {
    case never
    case seconds(TimeInterval)
    case minutes(TimeInterval)
    case hours(TimeInterval)
    case days(TimeInterval)
    case expired
    
    public var expirationDateFromNow: Date {
        switch self {
        case .never:
            return .distantFuture
        case .seconds(let seconds):
            return Date().addingTimeInterval(seconds)
        case .minutes(let minutes):
            return Date().addingTimeInterval(minutes * 60.0)
        case .hours(let hours):
            return Date().addingTimeInterval(hours * 60.0 * 60.0)
        case .days(let days):
            return Date().addingTimeInterval(days * 60.0 * 60.0 * 24.0)
        case .expired:
            return .distantPast
        }
    }
}
