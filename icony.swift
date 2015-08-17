#!/usr/bin/env xcrun swift

import Foundation
import AppKit

// MARK: - ARGUMENTS CHECK
//TODO: remove this part
let argsCount = Process.arguments.count
for i in 1..<argsCount {
    let s = Process.arguments[i]
    println(" arg:\(s)")
}

// MARK: - TOOLS
extension NSImage {
    // / Returns an image with the long edge being maxLongEdge
    func resize(#maxLongEdge: CGFloat) -> NSImage? {
        let longEdge = max(size.width, size.height)
        let shortEdge = min(size.width, size.height)
        
        if longEdge <= maxLongEdge {
            return self
        }
        
        let scale = maxLongEdge/longEdge
        if longEdge == size.width {
            return resized(CGSize(width: maxLongEdge, height: shortEdge * scale))
        } else {
            return resized(CGSize(width: shortEdge * scale, height: maxLongEdge))
        }
    }
    
    /// Returns an image in the given size (in pixels)
    func resized(size: CGSize) -> NSImage? {
        let image = self.CGImageForProposedRect(nil, context: nil, hints: nil)?.takeRetainedValue()
        
        let bitsPerComponent = CGImageGetBitsPerComponent(image)
        let bytesPerRow = CGImageGetBytesPerRow(image)
        let colorSpace = CGImageGetColorSpace(image)
        let bitmapInfo = CGImageGetBitmapInfo(image)
        
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)
        CGContextSetInterpolationQuality(context, kCGInterpolationMedium)
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: size), image)
        
        return NSImage(CGImage: CGBitmapContextCreateImage(context), size: size)
    }
    
    /// Saves the image to file
    func save(path: String) -> Bool {
        if let cgRef = self.CGImageForProposedRect(nil, context: nil, hints: nil)?.takeRetainedValue() {
            let newRep = NSBitmapImageRep(CGImage: cgRef)
            newRep.size = self.size
            let pngData = newRep.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])
            if let writeResult = pngData?.writeToFile(path, atomically: true) {
                return writeResult
            }
        }
        return false
    }

}

extension CGSize {
    var present: String {
        return "\(Int(self.width))X\(Int(self.height))"
    }
}

//===-------------------------------------------------------------------===##\\

// MARK: - Set path to save files

let defStPath = NSHomeDirectory() + "/Desktop"
var startPath = defStPath

let fileMan = NSFileManager.defaultManager()

if argsCount > 2 {
    var givenPath = Process.arguments[2]
//    givenPath = givenPath.stringByReplacingOccurrencesOfString("~", withString: NSHomeDirectory())
    
    if fileMan.fileExistsAtPath(givenPath) {
        startPath = givenPath
    } else {
        
        let prefixValid = givenPath.hasPrefix("~") || givenPath.hasPrefix("/")
        
        if prefixValid && fileMan.createDirectoryAtPath(givenPath, withIntermediateDirectories: true, attributes: nil, error: nil) {
            println("X given path does not exists, creating necessarily folders for path: \(givenPath)")
            startPath = givenPath
        } else {
            println("X given path does not exists or invalid: \(givenPath)\n  -> Using '~/Desktop/icons' instead")
        }
    }
}

var resultFolder = "icons"
var mainPath = startPath.stringByAppendingPathComponent(resultFolder)

// Create missing paths
let path = mainPath.stringByAppendingPathComponent("AppIcon.appiconset/")
fileMan.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil)


// MARK: - EXECUTION
var fail = false

if argsCount > 1 {
    if let img = NSImage(contentsOfFile: Process.arguments[1]) {
        
        
        // Check image size
        if img.size != CGSize(width: 1024, height: 1024) {
            let sizeDesc = img.size.present
            println("X Warning: Image size (\(sizeDesc)) is not the recommended size (1024X1024)")
        }
        
        
        // Resize and save files
        
        let sizesAndPaths = [
            ("iTunesArtwork@2x.png",                 1024),//also making sure its PNG
            ("iTunesArtwork.png",                    512),
            ("AppIcon.appiconset/Icon-40.png",       40),
            ("AppIcon.appiconset/Icon-40@2x.png",    80),
            ("AppIcon.appiconset/Icon-40@3x.png",    120),
            ("AppIcon.appiconset/Icon-60@2x.png",    120),
            ("AppIcon.appiconset/Icon-60@3x.png",    180),
            ("AppIcon.appiconset/Icon-76.png",       76),
            ("AppIcon.appiconset/Icon-76@2x.png",    152),
            ("AppIcon.appiconset/Icon-Small.png",    29),
            ("AppIcon.appiconset/Icon-Small@2x.png", 58),
            ("AppIcon.appiconset/Icon-Small@3x.png", 87)
        ]
        
        for (relativePath, diameter) in sizesAndPaths {
            let path = mainPath.stringByAppendingPathComponent(relativePath)
            let size = CGSizeMake(CGFloat(diameter), CGFloat(diameter))
            if let sized = img.resized(size) {
                let saved = sized.save(path)
                if saved == false {
                    println("X error: can't save image for size \(size.present)")
                    fail = true
                }
            } else {
                println("X error: can't resize to \(size.present)")
                fail = true
            }
        }
        
    } else {
        println("X can't get image from path - check your path")
        fail = true
    }
} else {
    println("X no image path given")
    fail = true
}


if !fail {
    println("\n\n 🍕  All Done! 🍻\n\n")
    exit(0)
} else {
    exit(1)
}


