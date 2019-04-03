//
//  Loggable.swift
//  com.statemachine.repositioning
//
//  Created by Julien Goudet on 02/04/2019.
//  Copyright © 2019 Hootcode. All rights reserved.
//

import Foundation

fileprivate extension DateFormatter {
    static func format(_ format: String) -> DateFormatter {
        let _df = DateFormatter()
        _df.dateFormat = format
        return _df
    }
}

private let loggerDateFromater: DateFormatter = DateFormatter.format("HH:mm:ss")

protocol LoggableType {
    var emoji: Character { get }
    var loggerLevel: Logger.Level { get }
}


protocol Loggable {
    var mode: LogMode { get }
    var domain: Logger.Domain { get }
    func log(_ functionName: String, type: LogType)
    func log(_ functionName: String, message: String)
    func log(_ functionName: String, message: String, args: String)
}

enum LogMode {
    case silence
    case nslogger
    case print
}

enum LogType {
    case timestamp(milliseconds: TimeInterval)
    case begin
    case end
    case warning
    case failure
    case success
}


extension LogType: LoggableType {
    var emoji: Character {
        switch  self {
        case .begin:
            return "↘️"
        case .end:
            return "↗️"
        case .warning:
            return "⚠️"
        case .failure:
            return "❌"
        case .success:
            return "✅"
        case .timestamp:
            return "⏱"
        }
    }
    
    var loggerLevel: Logger.Level {
        switch  self {
        case .begin:
            return Logger.Level.info
        case .end:
            return Logger.Level.info
        case .warning:
            return Logger.Level.warning
        case .failure:
            return Logger.Level.error
        case .success:
            return Logger.Level.info
        case .timestamp:
            return Logger.Level.noise
        }
    }
    
    var details: String {
        switch  self {
        case .begin:
            return ""
        case .end:
            return ""
        case .warning:
            return ""
        case .failure:
            return ""
        case .success:
            return ""
        case .timestamp(let milliseconds):
            return "\(milliseconds) ms"
        }
    }
}


extension Loggable {
    
    var mode: LogMode {
        return .nslogger
    }
    
    func log(_ functionName: String, type: LogType) {
        switch mode {
        case .nslogger:
            print("[\(domain.rawValue)] -- \(functionName) -- \(type.emoji)")
        case .print:
            print("[\(domain.rawValue)] -- \(functionName) -- \(type.emoji)")
        case .silence:
            // 🤫
            break
        }
    }
    
    func log(_ functionName: String, message: String) {
        switch mode {
        case .nslogger:
            print("[\(domain.rawValue)] -- \(functionName) -- \(message)")
        case .print:
            print("[\(domain.rawValue)] -- \(functionName) -- \(message)")
        case .silence:
            // 🤫
            break
        }
    }
    
    func log(_ functionName: String, message: String, args: String) {
        
        switch mode {
        case .nslogger:
            print("[\(domain.rawValue)] -- \(functionName) -- \(message):\t\(args)")
        case .print:
            print("[\(domain.rawValue)] -- \(functionName) -- \(message):\t\(args)")
        case .silence:
            // 🤫
            break
        }
    }
    
    
    
}


struct Logger {
    
    
    public struct Domain: RawRepresentable {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        
        public static let app = Domain(rawValue: "App")
        public static let view = Domain(rawValue: "View")
        public static let layout = Domain(rawValue: "Layout")
        public static let controller = Domain(rawValue: "Controller")
        public static let routing = Domain(rawValue: "Routing")
        public static let service = Domain(rawValue: "Service")
        public static let network = Domain(rawValue: "Network")
        public static let model = Domain(rawValue: "Model")
        public static let cache = Domain(rawValue: "Cache")
        public static let db = Domain(rawValue: "DB")
        public static let io = Domain(rawValue: "IO")
        
        public static func custom(_ value: String) -> Domain {
            return Domain(rawValue: value)
        }
    }
    
    public struct Level: RawRepresentable {
        
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        
        public static let error = Level(rawValue: 0)
        public static let warning = Level(rawValue: 1)
        public static let important = Level(rawValue: 2)
        public static let info = Level(rawValue: 3)
        public static let debug = Level(rawValue: 4)
        public static let verbose = Level(rawValue: 5)
        public static let noise = Level(rawValue: 6)
        
        public static func custom(_ value: Int) -> Level {
            return Level(rawValue: value)
        }
    }
    
}
