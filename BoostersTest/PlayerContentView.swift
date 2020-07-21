//
//  PlayerContentView.swift
//  BoostersTest
//
//  Created by Dmytro Pasinchuk on 09.07.2020.
//  Copyright © 2020 Dmytro Pasinchuk. All rights reserved.
//

import SwiftUI

//MARK: - PlayerContentView
struct PlayerContentView: View {
    
    @ObservedObject var viewModel: PlayerViewModel
    
    @State private var selectedSoundDuration = 0
    @State private var selectedRecordingDuration = 0
    @State private var durationsWasChanged = false
    
    var body: some View {
        VStack {
            Text(viewModel.playerState.rawValue)
                .font(.headline)
                .multilineTextAlignment(.center)
            if (viewModel.playerState == .playing) {
                Text("Play Sound Remain \(Int(viewModel.soundPlayingRemainingTime)) sec...").padding(.top)
            } else if (viewModel.playerState == .recording) {
                Text("Record Remain \(Int(viewModel.recordingRemainingTime)) sec...").padding(.top)
            } else {
                Text("Remain NaN sec...").padding(.top).hidden()
            }
            Spacer()
            ButtonView(timerName: "Sound Timer", actionSheetDataSource: viewModel.playerModel.possibleSoundTimerDurations.map { $0.readableDuration }, selectedTimerDuration: $selectedSoundDuration, durationsWasChanged: $durationsWasChanged)
            ButtonView(timerName: "Recording Duration", actionSheetDataSource: viewModel.playerModel.possibleRecordingTimerDurations.map { $0.readableDuration }, selectedTimerDuration: $selectedRecordingDuration, durationsWasChanged: $durationsWasChanged)
            Divider()
                .padding([.leading, .bottom, .trailing])
            Button(action: {
                self.viewModel.toggleAudioFlow(withSoundTimerDuration: selectedSoundDuration, withRecordingTimerDuration: selectedRecordingDuration, durationsWasChanged: durationsWasChanged)
                self.durationsWasChanged = false
            }) {
                if (viewModel.playerState == .pausedFromPlaying && !isDurationsIsNotZero) || (viewModel.playerState == .pausedFromRecording && !isDurationsIsNotZero) {
                    getStartButton(with: "Stop")
                } else if viewModel.playerState == .idle || viewModel.playerState == .pausedFromPlaying || viewModel.playerState == .pausedFromRecording {
                    getStartButton(with: "Start")
                } else if !isDurationsIsNotZero {
                    getStartButton(with: "Stop")
                } else  {
                    getStartButton(with: "Pause")
                }
            }
        }
        .padding(.bottom)
    }
    
    private var isDurationsIsNotZero: Bool {
        return !(viewModel.playerModel.possibleSoundTimerDurations[selectedSoundDuration].durationInSeconds == 0 || viewModel.playerModel.possibleRecordingTimerDurations[selectedRecordingDuration].durationInSeconds == 0)
    }
    
    private func getStartButton(with text: String) -> some View {
        return Text(text)
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(12.0)
    }
}

//MARK: - ButtonView
struct ButtonView: View {
    let timerName: String
    let actionSheetDataSource: [String]
    @Binding var selectedTimerDuration: Int
    @Binding var durationsWasChanged: Bool
    
    @State private var showSelectedTimerDurationActionSheet = false
    
    var body: some View {
        VStack {
            Divider()
                .padding(.horizontal)
            HStack {
                Text(timerName).padding(.leading)
                Spacer()
                Button(action: {
                    self.showSelectedTimerDurationActionSheet.toggle()
                }) {
                    Text(actionSheetDataSource[selectedTimerDuration])
                }
                .padding(.trailing)
                .actionSheet(isPresented: $showSelectedTimerDurationActionSheet) {
                    ActionSheet(title: Text(timerName), message: Text("Select a new timer"), buttons: createActionsForTimer())
                }
            }
        }
    }
    
    private func createActionsForTimer() -> [ActionSheet.Button] {
        var actionSheets = actionSheetDataSource.map({ (timerName) -> ActionSheet.Button in
            return ActionSheet.Button.default(Text(timerName), action: {
                self.selectedTimerDuration = actionSheetDataSource.firstIndex(of: timerName) ?? 0
                self.durationsWasChanged = true
            } )
        })
        actionSheets.append(.cancel())
        return actionSheets
    }
}

//MARK: - Preview
struct PlayerContentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PlayerViewModel()
        PlayerContentView(viewModel: viewModel)
    }
}
