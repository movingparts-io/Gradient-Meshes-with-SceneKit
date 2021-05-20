import Foundation

/// Linear interpolation between `min` and `max`.
public func lerp<S: SignedNumeric>(_ f: S, _ min: S, _ max: S) -> S {
    min + f * (max - min)
}
