//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Adriano Valumin on 10/12/23.
//

import SwiftUI

struct FlagImage: View {
    var country: String

    var body: some View {
        Image(country)
            .clipShape(Capsule())
            .shadow(radius: 5)
    }
}

struct Title: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 10))
    }
}

extension View {
    func titleText(text: String) -> some View {
        ZStack {
            Text(" \(text) ")
                .modifier(Title())
        }
    }
}

struct ContentView: View {
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0 ... 2)
    @State private var messageUser = ""
    @State private var questionNumber = 0

    @State private var scoreTitle = ""
    @State private var playerScore = 0
    @State private var showingScore = false
    @State private var gameFinished = false

    @State private var animationAmount = 0.0
    @State private var animationScale = 1.0
    @State private var tappedFlag: Int?

    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color:
                    Color(red: Double.random(in: 0.0 ... 1.0),
                          green: Double.random(in: 0.0 ... 1.0),
                          blue: Double.random(in: 0.0 ... 1.0)),
                    location: 0.1),
                .init(color:
                    Color(.cyan),
                    location: 0.7),
                .init(color:
                    Color(
                        red: Double.random(in: 0.0 ... 0.6),
                        green: Double.random(in: 0.0 ... 0.3),
                        blue: Double.random(in: 0.0 ... 1.0)),
                    location: 1.3),
                .init(color:
                        Color(
                            red: Double.random(in: 0.0 ... 0.6),
                            green: Double.random(in: 0.0 ... 0.3),
                            blue: Double.random(in: 0.0 ... 1.0)),
                      location: 1.3),
            ], center: .top,
                           startRadius: 200,
                           endRadius: 700)
                .ignoresSafeArea()

            VStack {
                Spacer()

                titleText(text: "Guess the Flag")

                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))

                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }

                    ForEach(0 ..< 3) { number in
                        Button {
                            flagTapped(number)
                            withAnimation {
                                animationAmount += 360
                                animationScale -= 0.5
                            }
                        } label: {
                            FlagImage(country: countries[number])
                        }
                        .rotation3DEffect(
                            .degrees(number == tappedFlag ? animationAmount : 0),
                            axis: (x: 0.0, y: 1.0, z: 0.0)
                        )
                        .opacity(number == tappedFlag ? 1.0 : (tappedFlag == nil ? 1.0 : 0.25))
                        .scaleEffect(
                            number != tappedFlag && tappedFlag != nil ? withAnimation { animationScale } : 1.0
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))

                Spacer()
                Spacer()

                Text("Score: \(playerScore)")
                    .foregroundStyle(.white)
                    .font(.title.bold())

                Spacer()
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            Text(messageUser)
        }
        .alert("Game Over", isPresented: $gameFinished) {
            Button("Restart", action: restartGame)
        } message: {
            Text("Your score is \(playerScore)")
        }
    }

    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "Correct"
            messageUser = "You're right! \(countries[correctAnswer]) is the right answer!"
            playerScore += 1
        } else {
            scoreTitle = "Wrong"
            messageUser = "Ops! This flag is \(countries[correctAnswer]). You choose \(countries[number]) instead."
        }
        tappedFlag = number
        print(questionNumber)
        questionNumber += 1
        showingScore = true

        if questionNumber >= 8 {
            gameFinished = true
        }
    }

    func restartGame() {
        questionNumber = 0
        playerScore = 0
        askQuestion()
    }

    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0 ... 2)
        withAnimation {
            tappedFlag = nil
            animationScale = 1.0
        }
    }
}

#Preview {
    ContentView()
}
