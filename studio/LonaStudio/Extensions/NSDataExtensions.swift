//
//  NSDataExtensions.swift
//
//  Created by david_chen on 6/7/18.
//
//  Compatible with Bohemian Coding's data format for pasteboard
import Foundation
import Compression

extension NSData {
    func dataByCompressingWithAlgorithm_bc(algorithm: compression_algorithm) -> NSData? {
        let sourceBuffer = bytes.assumingMemoryBound(to: UInt8.self)
        let header = UnsafeMutablePointer<UInt8>.allocate(capacity: 12)

        var algorithmCopy = algorithm
        withUnsafePointer(to: &algorithmCopy) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 4) {
                header.initialize(from: $0, count: 4)
            }
        }

        var lengthInt64 = Int64(length)
        withUnsafePointer(to: &lengthInt64) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 8) {
                header.advanced(by: 4).initialize(from: $0, count: 8)
            }
        }

        let headerSize = 12
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: headerSize + length)
        destinationBuffer.initialize(from: header, count: headerSize)
        header.deallocate()
        let outputSize = compression_encode_buffer(destinationBuffer.advanced(by: headerSize), length, sourceBuffer, length, nil, algorithm)
        let result = outputSize > 0 ? NSData(bytes: destinationBuffer, length: headerSize + outputSize) : nil
        destinationBuffer.deallocate()
        return result
    }

    func dataByDecompressing_bc() -> NSData? {
        let sourceBufferWithPrefix = bytes.assumingMemoryBound(to: UInt8.self)
        let algorithm = bytes.load(fromByteOffset: 0, as: compression_algorithm.self)
        let sizeBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: 8)
        sizeBytes.initialize(from: bytes.advanced(by: 4).assumingMemoryBound(to: UInt8.self), count: 8)
        var size: Int = 0
        sizeBytes.withMemoryRebound(to: Int64.self, capacity: 1) {
            size = Int($0.pointee)
        }
        sizeBytes.deallocate()

        let sourceBuffer = sourceBufferWithPrefix.advanced(by: 12)
        let sourceBufferSize = length - 12
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        let outputSize = compression_decode_buffer(destinationBuffer, size, sourceBuffer, sourceBufferSize, nil,
                                                   algorithm)
        let result = outputSize > 0 ? NSData(bytes: destinationBuffer, length: size) : nil
        destinationBuffer.deallocate()
        return result
    }
}
