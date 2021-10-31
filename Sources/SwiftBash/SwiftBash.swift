import Foundation
public struct SwiftBash {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}


func shell(launchPath: String, arguments: [String]) throws -> String
{
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    
    let pipe = Pipe()
    task.standardOutput = pipe
    let sterrPipe = Pipe()
    task.standardError = sterrPipe
    try task.run()
    
    
    
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: String.Encoding.utf8)!
    if output.count > 0 {
        //remove newline character.
        let lastIndex = output.index(before: output.endIndex)
        let a = output[output.startIndex ..< lastIndex]
        return String(a)
    }
    return output
}


struct WhichCommandCache {
    static var instance = WhichCommandCache()
    private var cache = [String:String]()
    mutating func get(_ key: String) -> String? {
        if let v = cache[key] {
            return v
        }
        let v = UserDefaults.standard.string(forKey: "cache:\(key)")
        cache[key] = v
        return v
    }
    
    mutating func set(_ value: String?, forKey: String) {
        cache[forKey] = value
        UserDefaults.standard.setValue(value, forKey: "cache:\(forKey)")
    }
    
}
var commandCache = [String: String]()

let lock = NSRecursiveLock()

func which(command: String) async throws -> String {
    return try shell(launchPath: "/bin/bash", arguments: [ "-l", "-c", "which \(command)" ])
}

func bash(command: String, arguments: [String]) async throws -> String {
    let which = try await which(command: command)
    if !which.isEmpty {
        return try shell(launchPath: which, arguments: arguments)
    } else {
        return try shell(launchPath: "/bin/bash", arguments: [command] + arguments)
    }
    
}
