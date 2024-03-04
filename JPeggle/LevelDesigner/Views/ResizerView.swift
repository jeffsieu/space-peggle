// swiftlint:disable closure_body_length

import SwiftUI

let resizerPadding: Double = 0
let rotationHandleYDistance: Double = 32
let controlsColor = Color.white

extension CGVector {
    var magnitude: CGFloat {
        sqrt(dx * dx + dy * dy)
    }
}

private let handleRelativeOffsets: [ResizerView.HandlePosition: Vector] = [
    .topLeft: Vector(x: -0.5, y: -0.5),
    .topRight: Vector(x: 0.5, y: -0.5),
    .bottomLeft: Vector(x: -0.5, y: 0.5),
    .bottomRight: Vector(x: 0.5, y: 0.5)
]

extension ResizerView.HandlePosition {
    func toRelativeOffset() -> Vector {
        assert(handleRelativeOffsets[self] != nil, "Handle position not found")
        return handleRelativeOffsets[self] ?? Vector.zero
    }
}

struct ResizerView: View {
    private let objectSize: CGSize
    private let minScale: Double
    private let lockAspectRatio: Bool
    private let transform: Transform
    private var onPreviewTransformChange: (Transform) -> Void
    private var onTransformChange: (Transform) -> Void
    @State private var transformRotation: Double?
    @State private var transformScale: Vector?

    enum HandlePosition {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }

    init(objectSize: CGSize, minScale: Double, lockAspectRatio: Bool, transform: Transform,
         onPreviewTransformChange: @escaping (Transform) -> Void,
         onTransformChange: @escaping (Transform) -> Void) {
        self.objectSize = objectSize
        self.minScale = minScale
        self.lockAspectRatio = lockAspectRatio
        self.transform = transform
        self.onPreviewTransformChange = onPreviewTransformChange
        self.onTransformChange = onTransformChange
    }

    private var scaledObjectSize: CGSize {
        let transformScale = transform.scale.toCGSize()

        return CGSize(
            width: objectSize.width * transformScale.width,
            height: objectSize.height * transformScale.height
        )
    }

    private var previewTransform: Transform {
        Transform(
            origin: transform.origin,
            rotation: transformRotation ?? transform.rotation,
            scale: transformScale ?? transform.scale
        )
    }

    private var previewObjectSize: CGSize {
        let transformScale = transformScale ?? transform.scale

        return CGSize(
            width: objectSize.width * transformScale.x,
            height: objectSize.height * transformScale.y
        )
    }

    private var resizerSize: CGSize {
        CGSize(
            width: ((objectSize.width + resizerPadding) * transform.scale.x).magnitude,
            height: ((objectSize.height + resizerPadding) * transform.scale.y).magnitude
        )
    }

    private var previewResizerSize: CGSize {
        let transformScale = transformScale ?? transform.scale

        return CGSize(
            width: ((objectSize.width + resizerPadding) * transformScale.x).magnitude,
            height: ((objectSize.height + resizerPadding) * transformScale.y).magnitude
        )
    }

    private func calculateNewScale(handlePosition: HandlePosition, scaleHandleTranslation translation: CGSize) -> Vector {
        let relativeOffset = handlePosition.toRelativeOffset()
        let preRotatedOriginalOffset = CGVector(
            dx: relativeOffset.x * resizerSize.width,
            dy: relativeOffset.y * resizerSize.height
        )
        let offsetMagnitude = preRotatedOriginalOffset.magnitude
        let preRotatedOffsetAngle = atan2(preRotatedOriginalOffset.dy, preRotatedOriginalOffset.dx)
        let offsetAngle = CGFloat(preRotatedOffsetAngle + transform.rotation)

        let originalOffset = CGVector(
            dx: offsetMagnitude * cos(offsetAngle),
            dy: offsetMagnitude * sin(offsetAngle)
        )

        let currentOffset = CGVector(
            dx: originalOffset.dx + translation.width,
            dy: originalOffset.dy + translation.height
        )

        let currentOffsetMagnitude = currentOffset.magnitude
        let currentOffsetAngle = atan2(currentOffset.dy, currentOffset.dx)

        let preRotatedCurrentOffset = CGVector(
            dx: currentOffsetMagnitude * cos(currentOffsetAngle - transform.rotation),
            dy: currentOffsetMagnitude * sin(currentOffsetAngle - transform.rotation)
        )

        var scaleMultiplier: CGVector {
            let rawMultiplier = CGVector(
                dx: preRotatedCurrentOffset.dx / preRotatedOriginalOffset.dx,
                dy: preRotatedCurrentOffset.dy / preRotatedOriginalOffset.dy
            )

            let clampedMultiplier = CGVector(
                dx: max(rawMultiplier.dx, minScale),
                dy: max(rawMultiplier.dy, minScale)
            )

            if !lockAspectRatio {
                return clampedMultiplier
            }

            let syncedMultiplier = min(clampedMultiplier.dx, clampedMultiplier.dy)
            return CGVector(dx: syncedMultiplier, dy: syncedMultiplier)
        }

        let newScale = Vector(
            x: transform.scale.x * scaleMultiplier.dx,
            y: transform.scale.y * scaleMultiplier.dy
        )

        return newScale
    }

    private func calculateNewRotation(rotationHandleTranslation translation: CGSize) -> Double {
        let preRotatedOriginalOffset = CGVector(
            dx: 0,
            dy: -resizerSize.height / 2 - rotationHandleYDistance
        )
        let offsetMagnitude = preRotatedOriginalOffset.magnitude
        let preRotatedOffsetAngle = atan2(preRotatedOriginalOffset.dy, preRotatedOriginalOffset.dx)
        let offsetAngle = CGFloat(preRotatedOffsetAngle + transform.rotation)

        let originalOffset = CGVector(
            dx: offsetMagnitude * cos(offsetAngle),
            dy: offsetMagnitude * sin(offsetAngle)
        )

        let currentOffset = CGVector(
            dx: originalOffset.dx + translation.width,
            dy: originalOffset.dy + translation.height
        )

        let angle = atan2(
            currentOffset.dy,
            currentOffset.dx
        ) + .pi / 2

        return angle
    }

    func createResizeHandle(handlePosition: HandlePosition) -> some View {
        let relativeOffset = handlePosition.toRelativeOffset()

        return RoundedRectangle(cornerRadius: 8)
            .fill(controlsColor)
            .offset((relativeOffset * 24).toCGSize())
            .frame(width: 24, height: 24)
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .onChanged {
                    transformScale = calculateNewScale(
                        handlePosition: handlePosition,
                        scaleHandleTranslation: $0.translation
                    )
                }
                .onEnded {
                    let newScale = calculateNewScale(
                        handlePosition: handlePosition,
                        scaleHandleTranslation: $0.translation
                    )

                    var newTransform = transform
                    newTransform.scale = newScale
                    onTransformChange(newTransform)

                    transformScale = nil
                }
            )
    }

    var body: some View {
        ZStack {
            Rectangle()
                .stroke(controlsColor, lineWidth: 4)
                .frame(width: previewResizerSize.width, height: previewResizerSize.height)
                .overlay(
                    Rectangle()
                        .fill(controlsColor)
                        .frame(width: 4, height: 32)
                        .offset(y: -32),
                    alignment: .top
                )
                .overlay(
                    Circle()
                        .fill(controlsColor)
                        .frame(width: 24, height: 24)
                        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
                            .onChanged {
                                transformRotation = calculateNewRotation(rotationHandleTranslation: $0.translation)
                            }
                            .onEnded {
                                let newRotation = calculateNewRotation(rotationHandleTranslation: $0.translation)

                                var newTransform = transform
                                newTransform.rotation = newRotation
                                onTransformChange(newTransform)

                                transformRotation = nil
                            }
                        )
                        .offset(y: -12 - rotationHandleYDistance),

                    alignment: .top
                )
                .overlay(
                    createResizeHandle(handlePosition: .topLeft),
                    alignment: .topLeading
                )
                .overlay(
                    createResizeHandle(handlePosition: .topRight),
                    alignment: .topTrailing
                )
                .overlay(
                    createResizeHandle(handlePosition: .bottomLeft),
                    alignment: .bottomLeading
                )
                .overlay(
                    createResizeHandle(handlePosition: .bottomRight),
                    alignment: .bottomTrailing
                )
        }
        .frame(
            width: (scaledObjectSize.width + 32).magnitude,
            height: (scaledObjectSize.height + 32).magnitude,
            alignment: .center
        )
        .rotationEffect(Angle(radians: transformRotation ?? transform.rotation))
        .position(transform.origin.toCGPoint())
        .onChange(of: previewTransform) {
            onPreviewTransformChange(previewTransform)
        }
    }
}

#Preview {
    ResizerView(
        objectSize: CGSize(width: 200, height: 200),
        minScale: 0.5,
        lockAspectRatio: true,
        transform: Transform(),
        onPreviewTransformChange: { _ in },
        onTransformChange: { _ in }
    )
    .frame(width: 200, height: 200)
}

// swiftlint:enable closure_body_length
