import Foundation
import CoreGraphics

public struct SpringPhysicsState {
    public var currentPosition: CGPoint
    public var velocity: CGPoint
    public var isMoving: Bool
}

public struct SpringPhysics {
    public static func calculateNextState(
        currentPosition: CGPoint,
        targetPosition: CGPoint,
        velocity: CGPoint,
        isMoving: Bool,
        dt: TimeInterval,
        stiffness: CGFloat,
        damping: CGFloat
    ) -> SpringPhysicsState {
        var newPosition = currentPosition
        var newVelocity = velocity
        var newIsMoving = isMoving

        let dx = targetPosition.x - currentPosition.x
        let dy = targetPosition.y - currentPosition.y
        let distanceSq = dx * dx + dy * dy

        // Sleep threshold
        if distanceSq < 0.5 && velocity.x * velocity.x + velocity.y * velocity.y < 0.5 {
            newPosition = targetPosition
            newVelocity = .zero
            newIsMoving = false
            return SpringPhysicsState(currentPosition: newPosition, velocity: newVelocity, isMoving: newIsMoving)
        }

        if !newIsMoving {
            newIsMoving = true
        }

        // Apply damped spring motion
        let forceX = (targetPosition.x - currentPosition.x) * stiffness - velocity.x * damping
        let forceY = (targetPosition.y - currentPosition.y) * stiffness - velocity.y * damping

        newVelocity.x += forceX * CGFloat(dt)
        newVelocity.y += forceY * CGFloat(dt)

        newPosition.x += newVelocity.x * CGFloat(dt)
        newPosition.y += newVelocity.y * CGFloat(dt)

        return SpringPhysicsState(currentPosition: newPosition, velocity: newVelocity, isMoving: newIsMoving)
    }
}
