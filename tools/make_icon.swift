// make_icon.swift — placeholder app icon: a ring gauge in the app's zone
// colours on the dark ground. Original artwork; no brand marks.
// Run: swift tools/make_icon.swift App/Assets.xcassets/AppIcon.appiconset/icon1024.png
// Output is a 1024×1024 PNG (Block K1; marked ASSUMED for replacement).

import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let size = 1024

guard let context = CGContext(
    data: nil,
    width: size,
    height: size,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: CGColorSpace(name: CGColorSpace.sRGB)!,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    fatalError("could not create context")
}

func rgb(_ hex: UInt32, _ alpha: CGFloat = 1) -> CGColor {
    return CGColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255.0,
        green: CGFloat((hex >> 8) & 0xFF) / 255.0,
        blue: CGFloat(hex & 0xFF) / 255.0,
        alpha: alpha
    )
}

// Ground.
context.setFillColor(rgb(0x0D1014))
context.fill(CGRect(x: 0, y: 0, width: size, height: size))

// Track.
let center = CGPoint(x: 512, y: 512)
let radius: CGFloat = 290
context.setLineWidth(150)
context.setLineCap(.round)
context.setStrokeColor(rgb(0x262C35))
context.addArc(center: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
context.strokePath()

// Zone arcs: green, amber (orange), red — from the top, clockwise.
func arc(fromDegrees start: CGFloat, toDegrees end: CGFloat, color: CGColor) {
    let startAngle = (start - 90) * .pi / 180
    let endAngle = (end - 90) * .pi / 180
    context.setStrokeColor(color)
    context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
    context.strokePath()
}

arc(fromDegrees: 0, toDegrees: 40, color: rgb(0x30D158))     // green
arc(fromDegrees: 44, toDegrees: 62, color: rgb(0xFF9F0A))    // amber
arc(fromDegrees: 66, toDegrees: 76, color: rgb(0xFF453A))    // red

// Marker dot at the target line.
context.setFillColor(rgb(0xF4F6F8))
let markerAngle = (CGFloat(44) - 90) * .pi / 180
let markerCenter = CGPoint(
    x: center.x + radius * cos(markerAngle),
    y: center.y + radius * sin(markerAngle)
)
context.fillEllipse(in: CGRect(x: markerCenter.x - 26, y: markerCenter.y - 26, width: 52, height: 52))

guard let image = context.makeImage() else {
    fatalError("could not make image")
}

let outputPath = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "icon1024.png"
let url = URL(fileURLWithPath: outputPath)
try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)

guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    fatalError("could not create destination")
}
CGImageDestinationAddImage(destination, image, nil)
guard CGImageDestinationFinalize(destination) else {
    fatalError("could not write png")
}
print("wrote \(outputPath)")
