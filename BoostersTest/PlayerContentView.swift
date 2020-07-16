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
    
    @State private var selectedSoundTimer = 0
    @State private var selectedRecordingTimer = 0
    
    var body: some View {
        VStack {
            Text(viewModel.playerState.rawValue)
                .font(.headline)
                .multilineTextAlignment(.center)
            if (viewModel.playerState != .idle) {
                Text("Remain N sec...").padding(.top)
            } else {
                Text("Remain N sec...").padding(.top).hidden()
            }
            Spacer()
            ButtonView(timerName: "Sound Timer", actionSheetDataSource: viewModel.possibkeSoundTimers, selectedTimerDuration: $selectedSoundTimer)
            ButtonView(timerName: "Recording Duration", actionSheetDataSource: viewModel.possibkeRecordingTimers, selectedTimerDuration: $selectedRecordingTimer)
            Divider()
                .padding([.leading, .bottom, .trailing])
            Button(action: {
                self.viewModel.toggleAudioFlow(withSoundTimer: selectedSoundTimer, withRecordingTimer: selectedRecordingTimer)
            }) {
                if viewModel.playerState == .idle || viewModel.playerState == .pausedFromPlaying || viewModel.playerState == .pausedFromRecording {
                    Text("Start")
                        .padding(.vertical)
                } else if selectedSoundTimer == 0 || selectedRecordingTimer == 0 {
                    Text("Stop")
                        .padding(.vertical)
                } else  {
                    Text("Pause")
                        .padding(.vertical)
                }
            }
        }
        .padding(.bottom)
    }
}

//MARK: - ButtonView
struct ButtonView: View {
    let timerName: String
    let actionSheetDataSource: [String]
    @Binding var selectedTimerDuration: Int
    
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
            return ActionSheet.Button.default(Text(timerName), action: { self.selectedTimerDuration = actionSheetDataSource.firstIndex(of: timerName) ?? 0 } )
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
