//
//  BoardView.swift
//  Reversi
//
//  Created by Николай Ткачев on 11/11/2024.
//

import SwiftUI

struct ReversiBoardView: View {
    @ObservedObject var game: ReversiGame

    var body: some View {
        VStack {
            ForEach(0..<8) { row in
                HStack {
                    ForEach(0..<8) { col in
                        CellView(player: game.board[row][col])
                            .onTapGesture {
                                game.makeMove(row: row, col: col)
                            }
                    }
                }
            }
        }
    }
}

struct CellView: View {
    let player: Player

    var body: some View {
        Circle()
            .foregroundColor(playerColor)
            .frame(width: 40, height: 40)
            .background(Color.gray)
            .cornerRadius(5)
    }

    private var playerColor: Color {
        switch player {
        case .player1: return .black
        case .player2: return .white
        case .empty: return .clear
        }
    }
}
