//
//  GridLayout.swift
//  vnvce
//
//  Created by Kerem Cesme on 23.08.2022.
//

import SwiftUI

// MARK: Building Custom View like ForEach -
struct GridLayout<Content, Item, ID>: View
where Content: View,
      ID: Hashable,
      Item: RandomAccessCollection,
      Item.Element: Hashable {
    
    var content: (Item.Element) -> Content
    var items: Item
    var id: KeyPath<Item.Element, ID>
    let spacing: CGFloat
    let columnCount: Int
    let cellRatio: CGFloat
    
    var cellHeight: CGFloat!
    
    init(items: Item,
         id: KeyPath<Item.Element, ID>,
         spacing: CGFloat = 0,
         columnCount: Int = 2,
         cellRatio: CGFloat = 1,
         @ViewBuilder content: @escaping (Item.Element) -> Content) {
        self.content = content
        self.id = id
        self.spacing = spacing
        self.items = items
        self.columnCount = columnCount
        self.cellRatio = cellRatio
        self.cellHeight = generateCellHeight(column: columnCount, ratio: cellRatio)
    }
    
    var body: some View {
        LazyVStack(spacing: spacing) {
            ForEach(generateColumns(), id: \.self){row in
                RowView(row: row)
            }
        }
    }
}

extension GridLayout {
    
    //MARK: Row View -
    @ViewBuilder
    func RowView(row: [Item.Element]) -> some View {
        GeometryReader{ proxy in
            let width = proxy.size.width
//            let height = (proxy.size.height - spacing)
            let column = CGFloat(columnCount)
            let columnWidth = (width > 0 ? ((width - spacing) / column) : 0)
            
            HStack(spacing: spacing) {
                ForEach(0...columnCount, id: \.self){ inx in
                    SaveView(row: row, index: inx)
                        .frame(width: columnWidth)
                }
                
//                SaveView(row: row, index: 1)
//                    .frame(width: columnWidth)
            }
        }
        .frame(height: cellHeight)
    }
    
    // MARK: Safely Unwrapping Content Index -
    @ViewBuilder
    func SaveView(row: [Item.Element], index: Int) -> some View {
        if (row.count - 1) >= index {
            content(row[index])
        }
    }
    
    // MARK: Return Cell Height -
    func generateCellHeight(column: Int, ratio: CGFloat) -> CGFloat {
        let width = UIScreen.main.bounds.width / CGFloat(column)
        return width * ratio
    }
    
    // MARK: Constructing Custom Rows and Columns -
    func generateColumns() -> [[Item.Element]] {
        var columns: [[Item.Element]] = []
        var row: [Item.Element] = []
        
        for item in items {
            // MARK: Each Row Consistes of 2 Views
            // Optional you can modify
            if row.count == columnCount {
                columns.append(row)
                row.removeAll()
                row.append(item)
            } else {
                row.append(item)
            }
        }
        
        // MARK: Adding Exhaust Ones
        columns.append(row)
        row.removeAll()
        return columns
    }
}
