//
//  CustomPrint.swift
//  Nasif
//
//  Created by Denish Gediya on 03/07/25.
//

import Foundation

let isPrintError = true
let isPrint = true
let isPrintWeb = true
let isPrintSuccess = true

public func printWeb(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if isPrintWeb == false {return}
    #if DEBUG
        let output = items.map { "\($0)" }.joined(separator: separator)
        Swift.print(output, terminator: terminator)
    #else
        Swift.print("RELEASE MODE")
    #endif
}

public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if isPrint == false {return}
    #if DEBUG
        let output = items.map { "\($0)" }.joined(separator: separator)
        Swift.print(output, terminator: terminator)
    #else
        Swift.print("RELEASE MODE")
    #endif
}

public func printSuccess(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if isPrintSuccess == false {return}
    #if DEBUG
        let output = items.map { "\($0)" }.joined(separator: separator)
    Swift.print("---------------✅Success✅--------------->")
        Swift.print(output, terminator: terminator)
    Swift.print("<-----------------------------------------")

    #else
        Swift.print("RELEASE MODE")
    #endif
}

public func printError(_ items: Any..., file: String = #file, function: String = #function, line: Int = #line, separator: String = " ") {
    if isPrintError == false {return}
    #if DEBUG
        let output = items.map { "\($0)" }.joined(separator: separator)
        Swift.print("--------------❗️Error❗️------------->")
        Swift.print("Error-\(output)")
        Swift.print("Function-\(function)")
        Swift.print("File-\(file)")
        Swift.print("Line-\(line)")
        Swift.print("<-----------------------------------")
    #else
        Swift.print("RELEASE MODE")
    #endif
}

func printInBox(_ value: String) {
    let length = value.count + 2
    Swift.print()
    Swift.print("+" + String(repeating: "-", count: length) + "+")
    Swift.print("| " + value + " |")
    Swift.print("+" + String(repeating: "-", count: length) + "+")
}

extension Data {
    func printToJson() {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: [])
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            guard let jsonString = String(data: data, encoding: .utf8) else {
                printWeb("Inavlid data")
                return
            }
            print(jsonString)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}

func printLine() {
    Swift.print("=================================================================")
}

