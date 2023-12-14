//
//  StandupFormTests.swift
//  StandupsTests
//
//  Created by Samarth Paboowal on 14/12/23.
//

import XCTest
import ComposableArchitecture
@testable import Standups

@MainActor
final class StandupFormTests: XCTestCase {

    func testAddDeleteAttendee() async {
        let standup = Standup(
            id: UUID(),
            attendees: [
                Attendee(
                    id: UUID()
                )
            ])
        
        let store = TestStore(
            initialState: StandupFormFeature.State(
                standup: standup
            )
        ) {
            StandupFormFeature()
        } withDependencies: {
            $0.uuid = .incrementing
        }
        
        await store.send(.addAttendeeButtonTapped) {
            $0.focus = .attendee(UUID(0))
            $0.standup.attendees.append(Attendee(id: UUID(0)))
        }
        
        await store.send(.deleteAttendees(atOffsets: [1])) {
            $0.focus = nil
            $0.standup.attendees.remove(at: 1)
        }
    }
}
