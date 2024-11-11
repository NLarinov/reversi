//
//  GameView.swift
//  Reversi
//
//  Created by Николай Ткачев on 11/11/2024.
//

import SwiftUI

struct GameView: View {
    @StateObject private var game = ReversiGame()
    @State private var playingAgainstAI = false
    @State private var aiDifficulty: ReversiGame.AIDifficulty = .novice

    var body: some View {
        VStack {
            Text("Реверси").font(.largeTitle)
            Text("Счет: Игрок 1 - \(game.score.player1) : Игрок 2 - \(game.score.player2)")

            ReversiBoardView(game: game)

            if game.gameOver {
                Text("Игра окончена! \(game.score.player1 > game.score.player2 ? "Игрок 1 победил" : "Игрок 2 победил")")
                    .font(.headline)
                    .padding()
            }

            VStack(spacing: 20) {
                Button("Новая игра с игроком") {
                    game.resetGame()
                }
                .padding(15)
                .foregroundColor(.white)
                .background(.black)
                .cornerRadius(10)

                Button("Игра с компьютером") {
                    playingAgainstAI.toggle()
                }
                .padding(15)
                .foregroundColor(.white)
                .background(.black)
                .cornerRadius(10)
                .actionSheet(isPresented: $playingAgainstAI) {
                    ActionSheet(
                        title: Text("Выберите уровень сложности"),
                        buttons: [
                            .default(Text("Новичок")) {
                                game.resetGame(againstAI: true, aiDifficulty: .novice)
                            },
                            .default(Text("Профессионал")) {
                                game.resetGame(againstAI: true, aiDifficulty: .professional)
                            },
                            .cancel()
                        ]
                    )
                }
            }
            .padding()
        }
    }
}

#Preview {
    GameView()
}
