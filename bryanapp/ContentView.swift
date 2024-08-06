//
//  ContentView.swift
//  bryanapp
//
//  Created by BryanMac on 2024/7/29.
//
import SwiftUI
import Combine

struct Cell {                   //定义结构体 Cell
    var isAlive: Bool           //细胞死活
}

class GameOfLife: ObservableObject { //定义了一个类 GameOfLife，当一个类遵循 ObservableObject 协议时，它可以让 SwiftUI 视图观察并响应其属性的变化。
    @Published var grid: [[Cell]] //@Published：属性包装器，当使用它来修饰类的属性时，这些属性的变化会自动发布给任何观察它们的视图
       //二维数组，包含所有细胞的状态。被发布的属性，当其值发生变化时，视图会自动更新。
    let rows: Int
    let columns: Int
    var timer: Timer?
    
    init(rows: Int, columns: Int) { //初始化，接受行数和列数作为参数。
        self.rows = rows
        self.columns = columns
        self.grid = Array(repeating: Array(repeating: Cell(isAlive: false), count: columns), count: rows) //创建二维数组，所有细胞初始状态都为死
        self.randomizeGrid()
        self.startTimer()
    }
    func randomizeGrid() {
            for row in 0..<rows {
                for column in 0..<columns {
                    grid[row][column].isAlive = Bool.random()
                }
            }
        }
    func toggleCellState(row: Int, column: Int) { //切换指定位置细胞的状态
        grid[row][column].isAlive.toggle() //从死变活或从活变死
    }
    
    func nextGeneration() { //计算并更新网格到下一代
        var newGrid = grid //创建一个新网格，初始值为当前网格
        for row in 0..<rows {
            for column in 0..<columns {
                let aliveNeighbors = countAliveNeighbors(row: row, column: column) //计算当前细胞周围活细胞的数量
                if grid[row][column].isAlive { /*检查当前细胞是否活着
                    如果活，看周围cell数量决定是否继续活（邻居为2或3时存活）
                    如果死，看周围cell数量决定细胞是否生（邻居为3时复活）*/
                    newGrid[row][column].isAlive = aliveNeighbors == 2 || aliveNeighbors == 3
                } else {
                    newGrid[row][column].isAlive = aliveNeighbors == 3
                }
            }
        }
        grid = newGrid //更新
    }
    
    func countAliveNeighbors(row: Int, column: Int) -> Int { //计算指定位置细胞周围活细胞的数量。
        var count = 0 //初始化活细胞计数为0
        for i in -1...1 {
            for j in -1...1 {
                if !(i == 0 && j == 0) { //排除自己
                    let newRow = row + i
                    let newColumn = column + j
                    if newRow >= 0 && newRow < rows && newColumn >= 0 && newColumn < columns {//确保邻居细胞在网格范围内
                        if grid[newRow][newColumn].isAlive { //如果邻居细胞是活的，计数加1
                            count += 1
                        }
                    }
                }
            }
        }
        return count
    }
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.nextGeneration()
            }
        }
        
    func stopTimer() {
            timer?.invalidate()
            timer = nil
        }
    func resetGrid() {
            self.randomizeGrid()
        }
}

struct ContentView: View {
    @ObservedObject var game = GameOfLife(rows: 20, columns: 20)
    
    var body: some View {
        VStack { //垂直堆叠视图
            ForEach(0..<game.rows, id: \.self) { row in
                HStack { //水平堆叠视图
                    ForEach(0..<game.columns, id: \.self) { column in
                        Rectangle() //创建一个矩形表示细胞
                            .fill(self.game.grid[row][column].isAlive ? Color.white : Color.black) //细胞的状态决定矩形颜色 活：黑色，死：白色
                            .frame(width: 20, height: 20)
                            .border(Color.gray) //灰色边框
                            .onTapGesture { //为矩形添加点击手势，点击时切换细胞状态
                                self.game.toggleCellState(row: row, column: column)
                            }
                    }
                }
            }
            HStack {
                Button("Start") {
                    self.game.startTimer()
                }
                .padding(.top, 20) // 按钮上方的间距
                Button("Stop") {
                    self.game.stopTimer()
                }
                .padding(.top, 20) // 按钮上方的间距
                Button("Reset") {
                    self.game.resetGrid()
                }
                .padding(.top, 20) // 按钮上方的间距
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
