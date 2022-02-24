# Using DBR without DCE

In this sample, we demonstrate how to bets configure DBR for use in an interactive video scenario, but without the use of the Camera Enhancer SDK which is mainly responsible for the UI and camera control.

In order to build and deploy the sample, the `DynamsoftBarcodeReader` framework or xcframework must be added to the project. 
- Once you download the library from our website, please drag and drop the `.framework` or `.xcframework` into the project.
- Please check *Copy Items if Needed* and *Create Groups* to make sure that the framework is integrated in
- In the project's settings, under *General -> Frameworks, Libraries, and Embedded Content*, please set the `DynamsoftBarcodeReader`framework or xcframework to *Embed & Sign*.
- Under *Build Phases* -> *Link Binary with Libraries*, please add `libc++.1.tbd` so that the build is successful.

In this [article] we explore this sample in further detail on the methods and structure of the sample.