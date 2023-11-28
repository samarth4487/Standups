//
//  StandupFormView.swift
//  Standups
//
//  Created by Samarth Paboowal on 27/11/23.
//

import SwiftUI
import ComposableArchitecture

struct StandupFormFeature: Reducer {
    struct State: Equatable {
        @BindingState var standup: Standup
        @BindingState var focus: Field? = .title
        
        enum Field: Hashable {
            case title
            case attendee(Attendee.ID)
        }
    }
    
    enum Action: BindableAction {
        case addAttendeeButtonTapped
        case deleteAttendees(atOffsets: IndexSet)
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addAttendeeButtonTapped:
                let attendee = Attendee(id: UUID())
                state.standup.attendees.append(attendee)
                state.focus = .attendee(attendee.id)
                return .none
            case .deleteAttendees(atOffsets: let indices):
                state.standup.attendees.remove(atOffsets: indices)
                state.focus = nil
                return .none
            case .binding(_):
                return .none
            }
        }
    }
}

struct StandupFormView: View {
    let store: StoreOf<StandupFormFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    TextField("Title", text: viewStore.$standup.title)
                    HStack {
                        Slider(value: viewStore.$standup.duration.minutes, in: 5...30, step: 1) {
                            Text("Length")
                        }
                        Spacer()
                        Text(viewStore.standup.duration.formatted(.units()))
                    }
                    ThemePicker(selection: viewStore.$standup.theme)
                } header: {
                    Text("Standup Info")
                }
                
                Section {
                    ForEach(viewStore.$standup.attendees) { $attendee in
                        TextField("Name", text: $attendee)
                    }
                } header: {
                    Text("Attendees")
                }
            }
        }
    }
}

extension Duration {
    fileprivate var minutes: Double {
        get { Double(self.components.seconds / 60) }
        set { self = .seconds(newValue * 60) }
    }
}

struct ThemePicker: View {
    @Binding var selection: Theme
    
    var body: some View {
        Picker("Theme", selection: self.$selection) {
            ForEach(Theme.allCases) { theme in
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.mainColor)
                    Label(theme.name, systemImage: "paintpalette")
                        .padding(4)
                }
                .foregroundColor(theme.accentColor)
                .fixedSize(horizontal: false, vertical: true)
                .tag(theme)
            }
        }
    }
}

#Preview {
    StandupFormView(store: Store(initialState: StandupFormFeature.State(standup: .mock)) {
        StandupFormFeature()
    })
}
