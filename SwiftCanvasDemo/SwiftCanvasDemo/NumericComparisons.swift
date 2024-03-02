//
//  NumericComparisons.swift
//  SwiftCanvasDemo
//
//  Created by Andre Pham on 1/3/2024.
//

import Foundation

internal let doublePrecision: Double = 1e-5
internal let floatPrecision: Float = 1e-5
internal let cgFloatPrecision: CGFloat = 1e-5

// MARK: - Double

/// `a < b`
internal func isLess(_ a: Double, _ b: Double, precision: Double = doublePrecision) -> Bool {
    return (b - a > precision)
}

/// `a <= b`
internal func isLessOrEqual(_ a: Double, _ b: Double, precision: Double = doublePrecision) -> Bool {
    return (isEqual(a, b, precision: precision) || isLess(a, b, precision: precision))
}

/// `a > b`
internal func isGreater(_ a: Double, _ b: Double, precision: Double = doublePrecision) -> Bool {
    return (a - b > precision)
}

/// `a >= b`
internal func isGreaterOrEqual(_ a: Double, _ b: Double, precision: Double = doublePrecision) -> Bool {
    return (isEqual(a, b, precision: precision) || isGreater(a, b, precision: precision))
}

/// `a == b`
internal func isEqual(_ a: Double, _ b: Double, precision: Double = doublePrecision) -> Bool {
    return (abs(a - b) <= precision)
}

/// `x == 0`
internal func isZero(_ x: Double, precision: Double = doublePrecision) -> Bool {
    return isEqual(x, 0.0, precision: precision)
}

/// `x < 0`
internal func isLessZero(_ x: Double, precision: Double = doublePrecision) -> Bool {
    return isLess(x, 0.0, precision: precision)
}

/// `x <= 0`
internal func isLessOrEqualZero(_ x: Double, precision: Double = doublePrecision) -> Bool {
    return isLessOrEqual(x, 0.0, precision: precision)
}

/// `x > 0`
internal func isGreaterZero(_ x: Double, precision: Double = doublePrecision) -> Bool {
    return isGreater(x, 0.0, precision: precision)
}

/// `x >= 0`
internal func isGreaterOrEqualZero(_ x: Double, precision: Double = doublePrecision) -> Bool {
    return isGreaterOrEqual(x, 0.0, precision: precision)
}

// MARK: - Float

/// `a < b`
internal func isLess(_ a: Float, _ b: Float, precision: Float = floatPrecision) -> Bool {
    return (b - a > precision)
}

/// `a <= b`
internal func isLessOrEqual(_ a: Float, _ b: Float, precision: Float = floatPrecision) -> Bool {
    return (isEqual(a, b, precision: precision) || isLess(a, b, precision: precision))
}

/// `a > b`
internal func isGreater(_ a: Float, _ b: Float, precision: Float = floatPrecision) -> Bool {
    return (a - b > precision)
}

/// `a >= b`
internal func isGreaterOrEqual(_ a: Float, _ b: Float, precision: Float = floatPrecision) -> Bool {
    return (isEqual(a, b, precision: precision) || isGreater(a, b, precision: precision))
}

/// `a == b`
internal func isEqual(_ a: Float, _ b: Float, precision: Float = floatPrecision) -> Bool {
    return (abs(a - b) <= precision)
}

/// `x == 0`
internal func isZero(_ x: Float, precision: Float = floatPrecision) -> Bool {
    return isEqual(x, 0.0, precision: precision)
}

/// `x < 0`
internal func isLessZero(_ x: Float, precision: Float = floatPrecision) -> Bool {
    return isLess(x, 0.0, precision: precision)
}

/// `x <= 0`
internal func isLessOrEqualZero(_ x: Float, precision: Float = floatPrecision) -> Bool {
    return isLessOrEqual(x, 0.0, precision: precision)
}

/// `x > 0`
internal func isGreaterZero(_ x: Float, precision: Float = floatPrecision) -> Bool {
    return isGreater(x, 0.0, precision: precision)
}

/// `x >= 0`
internal func isGreaterOrEqualZero(_ x: Float, precision: Float = floatPrecision) -> Bool {
    return isGreaterOrEqual(x, 0.0, precision: precision)
}

// MARK: - CGFloat

/// `a < b`
internal func isLess(_ a: CGFloat, _ b: CGFloat, precision: CGFloat = cgFloatPrecision) -> Bool {
    return (b - a > precision)
}

/// `a <= b`
internal func isLessOrEqual(_ a: CGFloat, _ b: CGFloat, precision: CGFloat = cgFloatPrecision) -> Bool {
    return (isEqual(a, b, precision: precision) || isLess(a, b, precision: precision))
}

/// `a > b`
internal func isGreater(_ a: CGFloat, _ b: CGFloat, precision: CGFloat = cgFloatPrecision) -> Bool {
    return (a - b > precision)
}

/// `a >= b`
internal func isGreaterOrEqual(_ a: CGFloat, _ b: CGFloat, precision: CGFloat = cgFloatPrecision) -> Bool {
    return (isEqual(a, b, precision: precision) || isGreater(a, b, precision: precision))
}

/// `a == b`
internal func isEqual(_ a: CGFloat, _ b: CGFloat, precision: CGFloat = cgFloatPrecision) -> Bool {
    return (abs(a - b) <= precision)
}

/// `x == 0`
internal func isZero(_ x: CGFloat, precision: CGFloat = cgFloatPrecision) -> Bool {
    return isEqual(x, 0.0, precision: precision)
}

/// `x < 0`
internal func isLessZero(_ x: CGFloat, precision: CGFloat = cgFloatPrecision) -> Bool {
    return isLess(x, 0.0, precision: precision)
}

/// `x <= 0`
internal func isLessOrEqualZero(_ x: CGFloat, precision: CGFloat = cgFloatPrecision) -> Bool {
    return isLessOrEqual(x, 0.0, precision: precision)
}

/// `x > 0`
internal func isGreaterZero(_ x: CGFloat, precision: CGFloat = cgFloatPrecision) -> Bool {
    return isGreater(x, 0.0, precision: precision)
}

/// `x >= 0`
internal func isGreaterOrEqualZero(_ x: CGFloat, precision: CGFloat = cgFloatPrecision) -> Bool {
    return isGreaterOrEqual(x, 0.0, precision: precision)
}
