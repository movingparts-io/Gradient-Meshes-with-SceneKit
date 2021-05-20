import SceneKit
import UIKit
import PlaygroundSupport

// Playground for https://movingparts.io/gradient-meshes .

// First example.
do {
    let vertexList: [SCNVector3] = [
        SCNVector3(-1, -1, 0), // p00
        SCNVector3( 1, -1, 0), // p10
        SCNVector3( 1,  1, 0), // p11

        SCNVector3( 1,  1, 0), // p11
        SCNVector3(-1,  1, 0), // p01
        SCNVector3(-1, -1, 0), // p00
    ]

    let colorList: [SCNVector3] = [
        SCNVector3(0.846, 0.035, 0.708), // magenta
        SCNVector3(0.001, 1.000, 0.603), // cyan
        SCNVector3(0.006, 0.023, 0.846), // blue

        SCNVector3(0.006, 0.023, 0.846), // blue
        SCNVector3(0.921, 0.051, 0.045), // red
        SCNVector3(0.846, 0.035, 0.708), // magenta
    ]

    let vertices = SCNGeometrySource(vertices: vertexList)

    let indices = vertexList.indices.map(Int32.init)

    let colors = SCNGeometrySource(colors: colorList)

    let elements = SCNGeometryElement(indices: indices, primitiveType: .triangles)

    SCNNode(geometry: SCNGeometry(sources: [vertices, colors], elements: [elements]))
}

struct ControlPoint {
    var color: simd_float3 = simd_float3(0, 0, 0)

    var location: simd_float2 = simd_float2(0, 0)

    var uTangent: simd_float2 = simd_float2(0, 0)

    var vTangent: simd_float2 = simd_float2(0, 0)
}

private let linearSRGCColorSpace = CGColorSpace(name: CGColorSpace.linearSRGB)!

// Example 2
example2: do {
    var grid = Grid(repeating: ControlPoint(), width: 3, height: 3)
    grid[0, 0].color = simd_float3(0.955, 0.015, 0.074)
    grid[0, 1].color = simd_float3(0.913, 0.005, 0.346)
    grid[0, 2].color = simd_float3(0.904, 0.001, 0.012)

    grid[1, 0].color = simd_float3(0.042, 0.135, 0.799)
    grid[1, 1].color = simd_float3(0.127, 0.104, 0.791)
    grid[1, 2].color = simd_float3(0.024, 0.007, 0.904)

    grid[2, 0].color = simd_float3(0.921, 0.955, 0.000)
    grid[2, 1].color = simd_float3(0.000, 0.921, 0.610)
    grid[2, 2].color = simd_float3(0.019, 0.007, 0.913)

    var vertexList: [SCNVector3] = []
    var colorList: [simd_float3] = []

    for y in 0 ..< grid.height - 1 {
        for x in 0 ..< grid.width - 1 {
            let xMin = lerp(CGFloat(x)     / CGFloat(grid.width - 1), -1, 1)
            let xMax = lerp(CGFloat(x + 1) / CGFloat(grid.width - 1), -1, 1)

            let yMin = lerp(CGFloat(y)     / CGFloat(grid.height - 1), -1, 1)
            let yMax = lerp(CGFloat(y + 1) / CGFloat(grid.height - 1), -1, 1)

            vertexList.append(contentsOf: [
                SCNVector3(xMin, yMin, 0),
                SCNVector3(xMax, yMin, 0),
                SCNVector3(xMax, yMax, 0),

                SCNVector3(xMax, yMax, 0),
                SCNVector3(xMin, yMax, 0),
                SCNVector3(xMin, yMin, 0)
            ])

            colorList.append(contentsOf: [
                grid[    x,     y].color,
                grid[x + 1,     y].color,
                grid[x + 1, y + 1].color,

                grid[x + 1, y + 1].color,
                grid[    x, y + 1].color,
                grid[    x,     y].color
            ])
        }
    }

    let vertices = SCNGeometrySource(vertices: vertexList)

    let indices = vertexList.indices.map(Int32.init)

    let colors = SCNGeometrySource(colors: colorList.map(SCNVector3.init))

    let elements = SCNGeometryElement(indices: indices, primitiveType: .triangles)

    SCNNode(geometry: SCNGeometry(sources: [vertices, colors], elements: [elements]))
}

// Example 3
example3: do {
//    break example3

    let H = simd_float4x4(rows: [
        simd_float4( 2, -2,  1,  1),
        simd_float4(-3,  3, -2, -1),
        simd_float4( 0,  0,  1,  0),
        simd_float4( 1,  0,  0,  0)
    ])

    let H_T = H.transpose

    func surfacePoint(u: Float, v: Float, X: simd_float4x4, Y: simd_float4x4) -> simd_float2 {
        let U = simd_float4(u * u * u, u * u, u, 1)
        let V = simd_float4(v * v * v, v * v, v, 1)

        return simd_float2(
            dot(V, U * H * X * H_T),
            dot(V, U * H * Y * H_T)
        )
    }

    func meshCoefficients(_ p00: ControlPoint, _ p01: ControlPoint, _ p10: ControlPoint, _ p11: ControlPoint, axis: KeyPath<simd_float2, Float>) -> simd_float4x4 {
        func l(_ controlPoint: ControlPoint) -> Float {
            controlPoint.location[keyPath: axis]
        }

        func u(_ controlPoint: ControlPoint) -> Float {
            controlPoint.uTangent[keyPath: axis]
        }

        func v(_ controlPoint: ControlPoint) -> Float {
            controlPoint.vTangent[keyPath: axis]
        }

        return simd_float4x4(rows: [
            simd_float4(l(p00), l(p01), v(p00), v(p01)),
            simd_float4(l(p10), l(p11), v(p10), v(p11)),
            simd_float4(u(p00), u(p01),      0,      0),
            simd_float4(u(p10), u(p11),      0,      0)
        ])
    }

    func colorCoefficients(_ p00: ControlPoint, _ p01: ControlPoint, _ p10: ControlPoint, _ p11: ControlPoint, axis: KeyPath<simd_float3, Float>) -> simd_float4x4 {
        func l(_ point: ControlPoint) -> Float {
            point.color[keyPath: axis]
        }

        return simd_float4x4(rows: [
            simd_float4(l(p00), l(p01), 0, 0),
            simd_float4(l(p10), l(p11), 0, 0),
            simd_float4(     0,      0, 0, 0),
            simd_float4(     0,      0, 0, 0)
        ])
    }

    func colorPoint(u: Float, v: Float, R: simd_float4x4, G: simd_float4x4, B: simd_float4x4) -> simd_float3 {
        let U = simd_float4(u * u * u, u * u, u, 1)
        let V = simd_float4(v * v * v, v * v, v, 1)

        return simd_float3(
            dot(V, U * H * R * H_T),
            dot(V, U * H * G * H_T),
            dot(V, U * H * B * H_T)
        )
    }

    func bilinearInterpolation(u: Float, v: Float, _ c00: ControlPoint, _ c01: ControlPoint, _ c10: ControlPoint, _ c11: ControlPoint) -> simd_float3 {
        let r = simd_float2x2(rows: [
            simd_float2(c00.color.x, c01.color.x),
            simd_float2(c10.color.x, c11.color.x),
        ])

        let g = simd_float2x2(rows: [
            simd_float2(c00.color.y, c01.color.y),
            simd_float2(c10.color.y, c11.color.y),
        ])

        let b = simd_float2x2(rows: [
            simd_float2(c00.color.z, c01.color.z),
            simd_float2(c10.color.z, c11.color.z),
        ])

        let r_ = dot(simd_float2(1 - u, u), r * simd_float2(1 - v, v))
        let g_ = dot(simd_float2(1 - u, u), g * simd_float2(1 - v, v))
        let b_ = dot(simd_float2(1 - u, u), b * simd_float2(1 - v, v))

        return simd_float3(r_, g_, b_)
    }

    var grid = Grid(repeating: ControlPoint(), width: 3, height: 3)
    grid[0, 0].color = simd_float3(0.955, 0.015, 0.074)
    grid[0, 1].color = simd_float3(0.913, 0.005, 0.346)
    grid[0, 2].color = simd_float3(0.904, 0.001, 0.012)

    grid[1, 0].color = simd_float3(0.042, 0.135, 0.799)
    grid[1, 1].color = simd_float3(0.127, 0.104, 0.791)
    grid[1, 2].color = simd_float3(0.024, 0.007, 0.904)

    grid[2, 0].color = simd_float3(0.921, 0.955, 0.000)
    grid[2, 1].color = simd_float3(0.000, 0.921, 0.610)
    grid[2, 2].color = simd_float3(0.019, 0.007, 0.913)

    for y in 0 ..< grid.height {
        for x in 0 ..< grid.width {
            grid[x, y].location = simd_float2(
                lerp(Float(x) / Float(grid.width  - 1), -1, 1),
                lerp(Float(y) / Float(grid.height - 1), -1, 1)
            )

            grid[x, y].uTangent.x = 2 / Float(grid.width  - 1)
            grid[x, y].vTangent.y = 2 / Float(grid.height - 1)

            // Try randomizing the grid:
            //
            //     grid[x, y].uTangent.x += .random(in: -1.5 ... 1.5)
            //     grid[x, y].uTangent.y += .random(in: -1.5 ... 1.5)
            //     grid[x, y].vTangent.x += .random(in: -1.5 ... 1.5)
            //     grid[x, y].vTangent.y += .random(in: -1.5 ... 1.5)
            //
        }
    }

    // How many points to sample along each edge of a patch.
    let subdivisions = 15

    var points = Grid(
        repeating: simd_float2(0, 0),
        width: (grid.width - 1) * subdivisions,
        height: (grid.height - 1) * subdivisions
    )

    var colors = Grid(
        repeating: simd_float3(0, 0 , 0),
        width: (grid.width - 1) * subdivisions,
        height: (grid.height - 1) * subdivisions
    )

    for x in 0 ..< grid.width - 1 {
        for y in 0 ..< grid.height - 1 {
            // The four control points in the corners of the current patch.
            let p00 = grid[    x,     y]
            let p01 = grid[    x, y + 1]
            let p10 = grid[x + 1,     y]
            let p11 = grid[x + 1, y + 1]

            // The X and Y coefficient matrices for the current Hermite patch.
            let X = meshCoefficients(p00, p01, p10, p11, axis: \.x)
            let Y = meshCoefficients(p00, p01, p10, p11, axis: \.y)

            // The coefficients matrices for the current hermite patch in RGB
            // space
            let R = colorCoefficients(p00, p01, p10, p11, axis: \.x)
            let G = colorCoefficients(p00, p01, p10, p11, axis: \.y)
            let B = colorCoefficients(p00, p01, p10, p11, axis: \.z)

            for u in 0 ..< subdivisions {
                for v in 0 ..< subdivisions {
                    points[x * subdivisions + u, y * subdivisions + v] =
                        surfacePoint(
                            u: Float(u) / Float(subdivisions - 1),
                            v: Float(v) / Float(subdivisions - 1),
                            X: X,
                            Y: Y
                        )

                    // Compare against bilinear interpolation here by using
                    //
                    //     bilinearInterpolation(
                    //         u: Float(u) / Float(subdivisions - 1),
                    //         v: Float(v) / Float(subdivisions - 1),
                    //         c00, c01, c10, c11)
                    //
                    colors[x * subdivisions + u, y * subdivisions + v] =
                        colorPoint(
                            u: Float(u) / Float(subdivisions - 1),
                            v: Float(v) / Float(subdivisions - 1),
                            R: R, G: G, B: B
                        )
                }
            }
        }
    }

    SCNNode(points: points, colors: colors)
}
