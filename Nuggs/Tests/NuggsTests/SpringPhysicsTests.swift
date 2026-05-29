import XCTest
@testable import Nuggs

final class SpringPhysicsTests: XCTestCase {

    func testBasicSpringMovement() {
        let currentPosition = CGPoint(x: 0, y: 0)
        let targetPosition = CGPoint(x: 100, y: 100)
        let initialVelocity = CGPoint(x: 0, y: 0)
        let isMoving = false
        let dt: TimeInterval = 0.05
        let stiffness: CGFloat = 180.0
        let damping: CGFloat = 18.0

        let nextState = SpringPhysics.calculateNextState(
            currentPosition: currentPosition,
            targetPosition: targetPosition,
            velocity: initialVelocity,
            isMoving: isMoving,
            dt: dt,
            stiffness: stiffness,
            damping: damping
        )

        // It should have started moving
        XCTAssertTrue(nextState.isMoving)

        // It should have moved towards the target
        XCTAssertGreaterThan(nextState.currentPosition.x, currentPosition.x)
        XCTAssertGreaterThan(nextState.currentPosition.y, currentPosition.y)

        // It should have gained velocity
        XCTAssertGreaterThan(nextState.velocity.x, initialVelocity.x)
        XCTAssertGreaterThan(nextState.velocity.y, initialVelocity.y)
    }

    func testSleepThreshold() {
        let currentPosition = CGPoint(x: 99.9, y: 99.9)
        let targetPosition = CGPoint(x: 100.0, y: 100.0)
        // Very small velocity
        let initialVelocity = CGPoint(x: 0.1, y: 0.1)
        let isMoving = true
        let dt: TimeInterval = 0.05
        let stiffness: CGFloat = 180.0
        let damping: CGFloat = 18.0

        let nextState = SpringPhysics.calculateNextState(
            currentPosition: currentPosition,
            targetPosition: targetPosition,
            velocity: initialVelocity,
            isMoving: isMoving,
            dt: dt,
            stiffness: stiffness,
            damping: damping
        )

        // Since it was very close to target with low velocity, it should snap and sleep
        XCTAssertFalse(nextState.isMoving)
        XCTAssertEqual(nextState.currentPosition, targetPosition)
        XCTAssertEqual(nextState.velocity, .zero)
    }

    func testDampingEffect() {
        let currentPosition = CGPoint(x: 100, y: 100)
        let targetPosition = CGPoint(x: 100, y: 100)
        // High initial velocity away from target
        let initialVelocity = CGPoint(x: 50, y: 50)
        let isMoving = true
        let dt: TimeInterval = 0.05
        let stiffness: CGFloat = 180.0
        let damping: CGFloat = 18.0

        let nextState = SpringPhysics.calculateNextState(
            currentPosition: currentPosition,
            targetPosition: targetPosition,
            velocity: initialVelocity,
            isMoving: isMoving,
            dt: dt,
            stiffness: stiffness,
            damping: damping
        )

        // Because it's at target but has velocity, the force will be purely damping (-velocity * damping)
        // It should move due to initial velocity
        XCTAssertGreaterThan(nextState.currentPosition.x, currentPosition.x)
        XCTAssertGreaterThan(nextState.currentPosition.y, currentPosition.y)

        // But velocity should have decreased due to damping
        XCTAssertLessThan(abs(nextState.velocity.x), abs(initialVelocity.x))
        XCTAssertLessThan(abs(nextState.velocity.y), abs(initialVelocity.y))
    }
}
