//
//  StandupsListView.swift
//  Standups
//
//  Created by Samarth Paboowal on 27/11/23.
//

import SwiftUI
import ComposableArchitecture

struct StandupsListFeature: Reducer {
    struct State: Equatable {
        var standups: IdentifiedArrayOf<Standup> = []
    }
    
    enum Action {
        case addButtonTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.standups.append(
                    Standup(id: UUID(), theme: .allCases.randomElement()!)
                )
                return .none
            }
        }
    }
}

struct StandupsListView: View {
    let store: StoreOf<StandupsListFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            List {
                ForEach(viewStore.standups) { standup in
                    CardView(standup: standup)
                        .listRowBackground(standup.theme.mainColor)
                }
            }
            .navigationTitle("Daily Standups")
            .toolbar(content: {
                ToolbarItem {
                    Button("Add") {
                        viewStore.send(.addButtonTapped)
                    }
                }
            })
        }
    }
}

#Preview {
    NavigationStack {
        StandupsListView(store: Store(initialState: StandupsListFeature.State()) {
            StandupsListFeature()
                ._printChanges()
        })
    }
}
