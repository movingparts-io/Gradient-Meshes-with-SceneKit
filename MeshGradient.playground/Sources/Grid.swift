import Foundation

/// A two-dimensional grid of `Element`.
public struct Grid<Element> {
    public var elements: ContiguousArray<Element>

    public var width: Int

    public var height: Int

    public init(repeating element: Element, width: Int, height: Int) {
        self.width = width
        self.height = height
        self.elements = ContiguousArray(repeating: element, count: width * height)
    }

    public subscript(x: Int, y: Int) -> Element {
        get {
            elements[x + y * width]
        }
        set {
            elements[x + y * width] = newValue
        }
    }
}

extension Grid: Equatable where Element: Equatable {}

extension Grid: Hashable where Element: Hashable {}
