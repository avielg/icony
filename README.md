icony
=====

<p align=center>icony is a command line tool written in Swift that makes resizing your 1024 png file into icons a breeze</p>

<p align=center><img src="http://aococ.co/aviel/icony_trailer.gif" alt="icony gif" width="600"/></p>

### Usage

Use the binary:

````
./icony original.png path/to/save
````

Or the `swift` directly:

````
swift icony.swift img.png path/to/save
````

Or compile the swift, then call your binary:

````
swiftc icony.swift -o icony
./icony img.png path/to/save
````
 - To call icony from anywhere, add it to your [PATH](http://unix.stackexchange.com/a/26059)

### Arguments

icony accepts either one or both of the following arguments:
1. The path to the original image. Preferably sized 1024X1024px. Any different size will be resized accordingly.
2. Optional: The path to save the created icons. If not passed, icony will save to `~/Desktop/icons/...`

### Output

icony creates the `iTunesArtwork` files (sizes 1024 and 512) and an `AppIcon.appiconset` folder that you can drag straight into your Xcode project!

### Future
 
  - Add to Homebrew
  - Recieve path to Xcode project to automatically copy the `.appiconset` folder into `.xcassets`
