//
//  main.swift
//  Task2
//
//  Created by Alex Tischenko on 18.01.2024.
//

import Foundation

let parser = FileParser()
if CommandLine.arguments.count > 1 {
    parser.fileName = CommandLine.arguments[1]
}

if let table = parser.makeTable() {
    let fileGenerator: FileGenerator = HTMLGenerator(table: table)
    fileGenerator.generate()
} else {
    print("No such file")
}
