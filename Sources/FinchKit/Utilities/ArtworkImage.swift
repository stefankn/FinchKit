//
//  ArtworkImage.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 17/10/2026.
//

import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Image data prepared for upload as playlist artwork. The server accepts JPEG,
/// PNG and WebP of at most 10 MB and 50 megapixels; anything else is converted
/// to a JPEG of at most `maxPixelSize` pixels on its longest side.
struct ArtworkImage {

    // MARK: - Private Properties

    private static let supportedTypes: [UTType: String] = [
        .jpeg: "image/jpeg",
        .png: "image/png",
        .webP: "image/webp"
    ]



    // MARK: - Properties

    static let maxBytes = 10 << 20
    static let maxPixels = 50_000_000
    static let maxPixelSize = 2000
    static let compressionQuality = 0.85

    let data: Data
    let mimeType: String



    // MARK: - Construction

    init(_ data: Data) throws {
        guard
            let source = CGImageSourceCreateWithData(data as CFData, nil),
            CGImageSourceGetCount(source) > 0,
            let identifier = CGImageSourceGetType(source) as String?,
            let type = UTType(identifier),
            let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
            let width = properties[kCGImagePropertyPixelWidth] as? Int,
            let height = properties[kCGImagePropertyPixelHeight] as? Int
        else {
            throw APIError.invalidImage
        }

        if let mimeType = Self.supportedTypes[type], data.count <= Self.maxBytes, width * height <= Self.maxPixels {
            self.data = data
            self.mimeType = mimeType
            return
        }

        let jpeg = try Self.jpeg(from: source, maxPixelSize: min(max(width, height), Self.maxPixelSize))
        guard jpeg.count <= Self.maxBytes else { throw APIError.imageTooLarge }

        self.data = jpeg
        self.mimeType = "image/jpeg"
    }



    // MARK: - Private Functions

    /// Decodes the first image of the source upright (applying its EXIF
    /// orientation), scaled down to `maxPixelSize`, and encodes it as JPEG.
    private static func jpeg(from source: CGImageSource, maxPixelSize: Int) throws -> Data {
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]

        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            throw APIError.invalidImage
        }

        let data = NSMutableData()
        guard
            let opaqueImage = flattened(image),
            let destination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil)
        else {
            throw APIError.invalidImage
        }

        let properties = [kCGImageDestinationLossyCompressionQuality: compressionQuality] as CFDictionary
        CGImageDestinationAddImage(destination, opaqueImage, properties)

        guard CGImageDestinationFinalize(destination) else { throw APIError.invalidImage }

        return data as Data
    }

    /// JPEG has no alpha channel, so transparent areas are drawn onto white,
    /// like the server does for album thumbnails.
    private static func flattened(_ image: CGImage) -> CGImage? {
        switch image.alphaInfo {
        case .none, .noneSkipFirst, .noneSkipLast:
            return image
        default:
            break
        }

        guard let context = CGContext(
            data: nil,
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ) else {
            return nil
        }

        let rect = CGRect(x: 0, y: 0, width: image.width, height: image.height)
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        context.fill(rect)
        context.draw(image, in: rect)

        return context.makeImage()
    }
}
