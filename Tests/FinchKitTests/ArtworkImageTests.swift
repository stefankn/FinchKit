//
//  ArtworkImageTests.swift
//  FinchKit
//
//  Created by Stefan Klein Nulent on 17/10/2026.
//

import CoreGraphics
import Foundation
import ImageIO
import Testing
import UniformTypeIdentifiers
@testable import FinchKit

struct ArtworkImageTests {

    // MARK: - Functions

    @Test(arguments: [(UTType.jpeg, "image/jpeg"), (UTType.png, "image/png")])
    func supportedImageIsUnchanged(type: UTType, mimeType: String) throws {
        let data = try makeImage(width: 400, height: 300, type: type)

        let artwork = try ArtworkImage(data)

        #expect(artwork.data == data)
        #expect(artwork.mimeType == mimeType)
    }

    @Test func unsupportedImageIsConvertedToJPEG() throws {
        let data = try makeImage(width: 400, height: 300, type: .tiff)

        let artwork = try ArtworkImage(data)

        #expect(artwork.mimeType == "image/jpeg")
        #expect(try type(of: artwork.data) == .jpeg)
        #expect(try size(of: artwork.data) == CGSize(width: 400, height: 300))
    }

    @Test func transparencyIsFlattenedOntoWhite() throws {
        let data = try makeImage(width: 10, height: 10, type: .tiff, isTransparent: true)

        let artwork = try ArtworkImage(data)

        let pixel = try firstPixel(of: artwork.data)
        #expect(pixel.allSatisfy { $0 > 250 })
    }

    @Test func imageWithTooManyPixelsIsScaledDown() throws {
        let data = try makeImage(width: 8000, height: 6400, type: .png)

        let artwork = try ArtworkImage(data)

        #expect(artwork.mimeType == "image/jpeg")
        #expect(try size(of: artwork.data) == CGSize(width: 2000, height: 1600))
    }

    @Test func invalidDataThrows() {
        #expect(throws: APIError.self) {
            try ArtworkImage(Data("not an image".utf8))
        }
    }



    // MARK: - Private Functions

    private func makeImage(width: Int, height: Int, type: UTType, isTransparent: Bool = false) throws -> Data {
        let context = try #require(CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: (isTransparent ? CGImageAlphaInfo.premultipliedLast : .noneSkipLast).rawValue
        ))

        if !isTransparent {
            context.setFillColor(CGColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1))
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }

        let image = try #require(context.makeImage())
        let data = NSMutableData()
        let destination = try #require(CGImageDestinationCreateWithData(data, type.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, image, nil)
        try #require(CGImageDestinationFinalize(destination))

        return data as Data
    }

    private func source(for data: Data) throws -> CGImageSource {
        try #require(CGImageSourceCreateWithData(data as CFData, nil))
    }

    private func type(of data: Data) throws -> UTType? {
        try (CGImageSourceGetType(source(for: data)) as String?).flatMap(UTType.init)
    }

    private func size(of data: Data) throws -> CGSize {
        let image = try #require(CGImageSourceCreateImageAtIndex(source(for: data), 0, nil))
        return CGSize(width: image.width, height: image.height)
    }

    private func firstPixel(of data: Data) throws -> [UInt8] {
        let image = try #require(CGImageSourceCreateImageAtIndex(source(for: data), 0, nil))
        var pixel = [UInt8](repeating: 0, count: 4)
        let context = try #require(CGContext(
            data: &pixel,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
        ))
        context.draw(image, in: CGRect(x: 0, y: 0, width: 1, height: 1))

        return Array(pixel.prefix(3))
    }
}
