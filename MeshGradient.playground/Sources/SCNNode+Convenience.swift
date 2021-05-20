import SceneKit

public extension SCNNode {
    /// Creates a `SCNNode` based on a `Grid` of 2D points and a `Grid` of
    /// colors.
    convenience init(points: Grid<simd_float2>, colors: Grid<simd_float3>) {
        precondition(points.width == colors.width && points.height == colors.height, "Grids must be of the same size.")

        var vertexList: [simd_float3] = []
        var colorList: [simd_float3] = []

        for x in 0 ..< points.width - 1 {
            for y in 0 ..< points.height - 1 {
                let p00 = points[x    , y    ]
                let p10 = points[x + 1, y    ]
                let p01 = points[x    , y + 1]
                let p11 = points[x + 1, y + 1]

                let v00 = simd_float3(p00.x, p00.y, 0)
                let v10 = simd_float3(p10.x, p10.y, 0)
                let v01 = simd_float3(p01.x, p01.y, 0)
                let v11 = simd_float3(p11.x, p11.y, 0)

                let c1 = colors[x    , y    ]
                let c2 = colors[x + 1, y    ]
                let c3 = colors[x    , y + 1]
                let c4 = colors[x + 1, y + 1]

                vertexList.append(contentsOf: [
                    v00, v10, v11,

                    v11, v01, v00
                ])

                colorList.append(contentsOf: [
                    c1, c2, c4,

                    c4, c3, c1
                ])
            }
        }

        let indices = vertexList.indices.map(Int32.init)

        let elements = SCNGeometryElement(indices: indices, primitiveType: .triangles)

        self.init(
            geometry: SCNGeometry(
                sources: [
                    SCNGeometrySource(vertices: vertexList.map { SCNVector3($0) }),
                    SCNGeometrySource(colors: colorList.map { SCNVector3($0) })
                ],
                elements: [elements]
            )
        )
    }
}
