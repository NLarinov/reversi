//
//  ReversiGameModel.swift
//  Reversi
//
//  Created by Николай Ткачев on 11/11/2024.
//

import Foundation

enum Player {
    case player1
    case player2
    case empty
}

class ReversiGame: ObservableObject {
    @Published var board: [[Player]]
    @Published var currentPlayer: Player
    @Published var score: (player1: Int, player2: Int)
    @Published var gameOver: Bool = false
    var againstAI: Bool = false
    var aiDifficulty: AIDifficulty = .novice

    enum AIDifficulty {
        case novice
        case professional
    }

    let directions = [
        (0, 1), (1, 0), (0, -1), (-1, 0),
        (1, 1), (-1, -1), (1, -1), (-1, 1)
    ]

    init() {
        board = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        currentPlayer = .player1
        score = (2, 2)
        setupInitialBoard()
    }

    func setupInitialBoard() {
        board[3][3] = .player1
        board[3][4] = .player2
        board[4][3] = .player2
        board[4][4] = .player1
    }

    func resetGame(againstAI: Bool = false, aiDifficulty: AIDifficulty = .novice) {
        self.againstAI = againstAI
        self.aiDifficulty = aiDifficulty
        currentPlayer = .player1
        board = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        setupInitialBoard()
        updateScore()
        gameOver = false
    }

    func makeMove(row: Int, col: Int) {
        guard board[row][col] == .empty, isMoveValid(row: row, col: col) else { return }

        flipDiscs(row: row, col: col)
        board[row][col] = currentPlayer
        updateScore()
        
        if !hasAvailableMoves(for: .player1) && !hasAvailableMoves(for: .player2) {
            gameOver = true
        } else {
            currentPlayer = currentPlayer == .player1 ? .player2 : .player1
            if againstAI && currentPlayer == .player2 {
                // Задержка перед ходом компьютера
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.performAIMove()
                }
            }
        }
    }

    func updateScore() {
        let player1Count = board.flatMap { $0 }.filter { $0 == .player1 }.count
        let player2Count = board.flatMap { $0 }.filter { $0 == .player2 }.count
        score = (player1Count, player2Count)
    }

    func isMoveValid(row: Int, col: Int) -> Bool {
        for direction in directions {
            if canFlipInDirection(row: row, col: col, direction: direction) {
                return true
            }
        }
        return false
    }

    func canFlipInDirection(row: Int, col: Int, direction: (Int, Int)) -> Bool {
        let opponent: Player = currentPlayer == Player.player1 ? Player.player2 : Player.player1
        var r = row + direction.0
        var c = col + direction.1
        var foundOpponent = false

        while r >= 0 && r < 8 && c >= 0 && c < 8 {
            if board[r][c] == opponent {
                foundOpponent = true
            } else if board[r][c] == currentPlayer {
                return foundOpponent
            } else {
                break
            }
            r += direction.0
            c += direction.1
        }
        return false
    }

    func flipDiscs(row: Int, col: Int) {
        for direction in directions {
            if canFlipInDirection(row: row, col: col, direction: direction) {
                flipInDirection(row: row, col: col, direction: direction)
            }
        }
    }

    func flipInDirection(row: Int, col: Int, direction: (Int, Int)) {
        let opponent: Player = currentPlayer == Player.player1 ? Player.player2 : Player.player1
        var r = row + direction.0
        var c = col + direction.1

        while r >= 0 && r < 8 && c >= 0 && c < 8 && board[r][c] == opponent {
            board[r][c] = currentPlayer
            r += direction.0
            c += direction.1
        }
    }

    func hasAvailableMoves(for player: Player) -> Bool {
        for row in 0..<8 {
            for col in 0..<8 {
                if board[row][col] == .empty && isMoveValid(row: row, col: col) {
                    return true
                }
            }
        }
        return false
    }

    func performAIMove() {
        let possibleMoves = getPossibleMoves(for: .player2)
        if aiDifficulty == .novice {
            if let bestMove = possibleMoves.max(by: { $0.1 < $1.1 })?.0 {
                makeMove(row: bestMove.0, col: bestMove.1)
            }
        } else {
            if let bestMove = possibleMoves.max(by: { evaluateMove($0.0) < evaluateMove($1.0) })?.0 {
                makeMove(row: bestMove.0, col: bestMove.1)
            }
        }
    }

    func getPossibleMoves(for player: Player) -> [((Int, Int), Int)] {
        var moves: [((Int, Int), Int)] = []
        for row in 0..<8 {
            for col in 0..<8 {
                if board[row][col] == .empty && isMoveValid(row: row, col: col) {
                    let flippedDiscs = getFlipCount(row: row, col: col)
                    moves.append(((row, col), flippedDiscs))
                }
            }
        }
        return moves
    }

    func getFlipCount(row: Int, col: Int) -> Int {
        var count = 0
        for direction in directions {
            if canFlipInDirection(row: row, col: col, direction: direction) {
                count += countFlipsInDirection(row: row, col: col, direction: direction)
            }
        }
        return count
    }

    func countFlipsInDirection(row: Int, col: Int, direction: (Int, Int)) -> Int {
        let opponent: Player = currentPlayer == Player.player1 ? Player.player2 : Player.player1
        var r = row + direction.0
        var c = col + direction.1
        var count = 0

        while r >= 0 && r < 8 && c >= 0 && c < 8 && board[r][c] == opponent {
            count += 1
            r += direction.0
            c += direction.1
        }
        return count
    }

    func evaluateMove(_ move: (Int, Int)) -> Int {
        let flippedDiscsForCurrent = getFlipCount(row: move.0, col: move.1)
        let opponentMoves = getPossibleMoves(for: currentPlayer == .player1 ? .player2 : .player1)
        let opponentBestMoveValue = opponentMoves.max(by: { $0.1 < $1.1 })?.1 ?? 0
        return flippedDiscsForCurrent - opponentBestMoveValue
    }
}
