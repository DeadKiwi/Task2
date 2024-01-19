//
//  HTMLGenerator.swift
//  Task2
//
//  Created by Alex Tischenko on 19.01.2024.
//

import Foundation
class HTMLGenerator: FileGenerator {
    enum Text {
        static let title = "Task 2"
        static let tableStyle = "style=\"width:100%; border-collapse: collapse; border-spacing: 0px;\""
        static let cellspacing = "cellspacing=\"0\""
        static let style = "style="
        static let bgColor = "bgColor="
        static let width = "width: "
        static let height = "height: "
        static let viewport = "vw"
        static let outputFilename = "output.html"
    }
    enum TagType: String {
        case docType = "!DOCTYPE html"
        case title = "title"
        case html = "html"
        case body = "body"
        case table = "table"
        case row = "tr"
        case cell = "td"
    }
    
    enum Dimension {
        case width
        case height
    }
    private let table: Table
    private var colorDictionary = [String: String]()
    private var filename = ""
    private var filePath: String?
    private var fileHandle: FileHandle?
    
    init(table: Table) {
        self.table = table
    }
    
    func generate() {
        createFile()
        generate(from: table)
        closeFile()
    }
    
    private func createFile() {
        let bundlePath = Bundle.main.bundlePath
        filePath = bundlePath + "/" + Text.outputFilename
        let fileManager = FileManager.default
        guard let path = filePath else { return }
        if fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)
            }
            catch {
                print(error)
                return
            }
        }
        fileManager.createFile(atPath: path, contents:Data("".utf8), attributes: nil)
    }
    
    private func writeFile(_ line: String) {
        guard let path = filePath else { return }
        if fileHandle == nil {
            fileHandle = FileHandle(forWritingAtPath: path)
        }
        guard let data = line.data(using: .utf8), let fileHandle = fileHandle else { return }
        do {
            try fileHandle.write(contentsOf: data)
        }
        catch {
            print(error)
            return
        }
    }
    
    private func closeFile() {
        do {
            try fileHandle?.close()
        }
        catch {
            print(error)
            return
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func generate(from table: Table) {
        addLine(type: .docType, isClosing: false)
        addLine(type: .html, isClosing: false)
        addLine(type: .title, isClosing: false, options: [Text.title])
        addLine(type: .title, isClosing: true)
        addLine(type: .body, isClosing: false)
        addLine(type: .table, isClosing: false, options: [Text.tableStyle])
        
        defer {
            addLine(type: .table, isClosing: true)
            addLine(type: .body, isClosing: true)
            addLine(type: .html, isClosing: true)
        }
        
        let totalWidth = table.xSizes.reduce(0, +)
        let totalHeight = table.ySizes.reduce(0, +)
        
        for (rowIndex, row) in table.grid.reversed().enumerated() {
            let rowHeight = table.ySizes.reversed()[rowIndex]
            let rowPercentHeight = rowHeight / totalHeight * 100
            let heightOptions = makeSizeOption(dimension: .height, percentValue: rowPercentHeight.rounded(toPlaces: 3))
            addLine(type: .row, isClosing: false, options: [heightOptions])
            for (columnIndex, cell) in row.enumerated() {
                var options = [String]()
                if cell.count > 0 {
                    options.append(makeColorOption(colorKey: cell))
                }
                if rowIndex == 0 {
                    let columnWidth = table.xSizes[columnIndex]
                    let columnPercentWidth = columnWidth / totalWidth * 100
                    options.append(makeSizeOption(dimension: .width, percentValue: columnPercentWidth.rounded(toPlaces: 3)))
                }
                addLine(type: .cell, isClosing: false, options: options)
                addLine(type: .cell, isClosing: true)
            }
            addLine(type: .row, isClosing: true)
        }
    }
    
    private func addLine(type: TagType, isClosing: Bool, options: [String]? = nil) {
        let slashIfNeeded = isClosing ? "/" : ""
        var optionsIfNeeded = ""
        if let options = options {
            for option in options {
                optionsIfNeeded.append(" ")
                optionsIfNeeded.append(option)
            }
        }
        
        let line = "<" + slashIfNeeded + type.rawValue + optionsIfNeeded + ">" + "\n"
        writeFile(line)
    }
    
    private func makeSizeOption(dimension: Dimension, percentValue: Double) -> String {
        var dimensionString = ""
        switch dimension {
        case .width:
            dimensionString = Text.width
        case .height:
            dimensionString = Text.height
        }
        return Text.style + "\"" + dimensionString + String(percentValue) + Text.viewport + "\""
    }
    
    private func makeColorOption(colorKey: String) -> String {
        if let color = colorDictionary[colorKey] {
            return color
        }
        let color = Text.bgColor + "\"" + randomHexColorString() + "\""
        colorDictionary[colorKey] = color
        return color
    }
    
    private func randomHexColorString() -> String {
        let randomInt = Int.random(in: 0..<65535)
        return String(format: "#%06X", randomInt)
    }
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
