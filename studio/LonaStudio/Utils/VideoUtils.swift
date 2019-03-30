//
//  VideoUtils.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/23/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit
import AVFoundation
import Lottie

class VideoUtils {
    static func writeVideo(capturing view: NSView, scaledBy scale: CGFloat, atFPS fps: Int32, to url: URL) {
        let size = CGSize(width: scale * view.bounds.size.width, height: scale * view.bounds.size.height)

        // Remove the file if it exists
        try? FileManager.default.removeItem(at: url)

        guard let frames = renderFrames(capturing: view, scaledBy: scale, atFPS: fps) else {
            Swift.print("Failed to capture video frames", url)
            return
        }

        guard let (writer, input) = assetWriter(for: url, atFPS: fps, size: size) else {
            Swift.print("Failed to create AVAssetWriter", url)
            return
        }

        let adaptor = self.pixelBufferAdaptor(for: input, size: size)

        writer.startWriting()
        writer.startSession(atSourceTime: CMTime.zero)

        if adaptor.pixelBufferPool == nil {
            Swift.print("Failed to start asset writing session", url)
            return
        }

        func write(currentFrame: Int, currentTime: CMTime) {
            if !adaptor.append(frames[currentFrame], withPresentationTime: currentTime) {
                Swift.print("Couldn't append to pixel buffer", url)
            }
        }

        func done() {
            input.markAsFinished()

            writer.finishWriting {
                if let error = writer.error {
                    Swift.print("Error writing video", error, url)
                } else {
                    Swift.print("Finished writing video", url)
                }
            }
        }

        writeFrames(
            to: input,
            frameCount: frames.count,
            fps: fps,
            write: write(currentFrame:currentTime:),
            done: done
        )
    }

    private static func writeFrames(
        to input: AVAssetWriterInput,
        frameCount: Int,
        fps: Int32,
        write: @escaping (Int, CMTime) -> Void,
        done: @escaping () -> Void) {
        let queue = DispatchQueue(label: "mediaQueue", attributes: [])
        let frameDuration = CMTime(value: 1, timescale: fps)
        var currentTime = CMTime(value: 0, timescale: fps)
        var currentFrame = 0

        input.requestMediaDataWhenReady(on: queue, using: {
            while input.isReadyForMoreMediaData && currentFrame < frameCount {
                write(currentFrame, currentTime)

                currentTime = currentTime + frameDuration
                currentFrame += 1
            }

            if currentFrame >= frameCount {
                done()
            }
        })
    }

    private static func assetWriter(for url: URL, atFPS fps: Int32, size: CGSize) -> (writer: AVAssetWriter, input: AVAssetWriterInput)? {
        do {
            let writer = try AVAssetWriter(outputURL: url, fileType: AVFileType.mp4)

            let compressionProperties: NSDictionary = [
//                AVVideoAverageBitRateKey : 10.1,
                AVVideoExpectedSourceFrameRateKey: fps
//                AVVideoMaxKeyFrameIntervalKey : fps,
            ]

            let settings: [String: AnyObject] = [
                AVVideoCodecKey: AVVideoCodecH264 as AnyObject,
                AVVideoWidthKey: size.width as AnyObject,
                AVVideoHeightKey: size.height as AnyObject,
                AVVideoCompressionPropertiesKey: compressionProperties
            ]

            let input = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: settings)

            writer.add(input)

            return (writer, input)
        } catch {
            return nil
        }
    }

    private static func pixelBufferAdaptor(
        for input: AVAssetWriterInput,
        size: CGSize
        ) -> AVAssetWriterInputPixelBufferAdaptor {
        let sourcePixelBufferAttributes: [String: AnyObject] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB) as AnyObject,
            kCVPixelBufferWidthKey as String: size.width as AnyObject,
            kCVPixelBufferHeightKey as String: size.height as AnyObject
            ]

        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: input,
            sourcePixelBufferAttributes: sourcePixelBufferAttributes
        )

        return pixelBufferAdaptor
    }

    private static func renderFrames(capturing view: NSView, scaledBy scale: CGFloat, atFPS fps: Int32) -> [CVPixelBuffer]? {
        guard let animationView = AnimationUtils.findAnimationView(in: view) else { return nil }

        if animationView.animationDuration.isEqual(to: 0) {
            Swift.print("Animation duration is 0")
            return nil
        }

        var frames: [CVPixelBuffer] = []
        var progress: CGFloat = 0
        let step: CGFloat = (1 / CGFloat(fps)) / animationView.animationDuration * animationView.animationSpeed

        while progress < 1 {
            Swift.print("Rendering", progress)

            progress += step

            // TODO: We can probably clean up the loop logic to remove this, although rendering
            // at progress = 0 may have issues
            if progress > 1 { break }

            animationView.animationProgress = progress
            animationView.layout()
            guard let buffer = view.pixelBuffer(scaledBy: scale) else { continue }

            frames.append(buffer)
        }

        animationView.animationProgress = 0

        return frames
    }
}
