//
//  FileParser.swift
//  Task2
//
//  Created by Alex Tischenko on 19.01.2024.
//

import Foundation

final class FileParser {
    enum Text {
        static let enterFileName = "Please enter file name\n"
        static let orUseDefault = "Or do not enter anything to use default\n"
        static let failure = "Readline error"
        static let defaultFileName = "DefaultData"
        static let textSeparator = ","
    }

    struct Rectangle {
        let left: Double
        let top: Double
        let right: Double
        let bottom: Double
        
        init?(left: Double, top: Double, right: Double, bottom: Double) {
            guard left < right, top > bottom else { return nil }
            self.left = left
            self.top = top
            self.right = right
            self.bottom = bottom
        }
    }
    
    var fileName: String?
    private var rectangles = [Rectangle]()
    private var xAxisValues = [Double]()
    private var yAxisValues = [Double]()
    
    func makeTable() -> Table? {
        if let fileName = fileName {
            return readFile(fileName)
        } else {
            print(Text.enterFileName)
            print(Text.orUseDefault)
            if let inputString = readLine() {
                let fileName = inputString.count > 0 ? inputString : Text.defaultFileName
                return readFile(fileName)
            } else {
                print(Text.failure)
                return nil
            }
        }
    }
    
    private func readFile(_ name: String) -> Table? {
        print(Bundle.main.bundlePath)
        guard let path = Bundle.main.path(forResource: name, ofType: "txt") else { return nil }
        guard let file = freopen(path, "r", stdin) else {
            return nil
        }
        defer {
            fclose(file)
        }
        
        return buildTable()
    }
    
    private func buildTable() -> Table {
        while let line = readLine() {
            let rectangleParameters = line.components(separatedBy: Text.textSeparator).compactMap{ Double($0) }
            handleRectangleParameters(rectangleParameters)
        }
        
        var gridArray = [Array](repeating: [String](repeating: "", count: xAxisValues.count - 1), count: yAxisValues.count - 1)
        
        for (index, rectangle) in rectangles.enumerated() {
            guard let fromX = xAxisValues.firstIndex(where: { $0 == rectangle.left }),
                  let toX = xAxisValues.firstIndex(where: {$0 == rectangle.right }),
                  let fromY = yAxisValues.firstIndex(where: {$0 == rectangle.bottom }),
                  let toY = yAxisValues.firstIndex(where: {$0 == rectangle.top })
            else { break }
            
            for xIndex in fromX...toX - 1 {
                for yIndex in fromY...toY - 1 {
                    gridArray[yIndex][xIndex] = String(index + 1)
                }
            }
        }
        
        let rowSizes = calculateCellSizes(axisValues: xAxisValues)
        let columnSizes = calculateCellSizes(axisValues: yAxisValues)
        
        return Table(grid: gridArray, xSizes: rowSizes, ySizes: columnSizes)
    }
    
    private func handleRectangleParameters(_ params: [Double]) {
        guard params.count == 4 else { return }
        guard let rectangle = Rectangle(left: params[0], top: params[1], right: params[2], bottom: params[3]) else { return }
        rectangles.append(rectangle)
        
        xAxisValues.insertOrderedUnique(params[0])
        xAxisValues.insertOrderedUnique(params[2])
        yAxisValues.insertOrderedUnique(params[1])
        yAxisValues.insertOrderedUnique(params[3])
    }
    
    private func calculateCellSizes(axisValues: [Double]) -> [Double] {
        var previousValue: Double?
        var result = [Double]()
        for value in axisValues {
            if let prev = previousValue {
                result.append(value - prev)
            }
            previousValue = value
        }
        
        return result
    }
}

private extension Array where Element: Comparable {
    mutating func insertOrderedUnique(_ value: Element) {
        var slice : SubSequence = self[...]
        
        while !slice.isEmpty {
            let middle = slice.index(slice.startIndex, offsetBy: slice.count / 2)
            
            if value == slice[middle] {
                //Non-unique values should be ignored
                return
            }
            if value < slice[middle] {
                slice = slice[..<middle]
            } else {
                slice = slice[index(after: middle)...]
            }
        }
        insert(value, at: slice.startIndex)
    }
}
