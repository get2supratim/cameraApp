# Camera App

Professional iPhone camera foundation built with SwiftUI, AVFoundation, Core Image, Vision, Metal-ready rendering, SwiftData, MVVM, dependency injection, and repository boundaries.

## Current Modules

- Camera workspace with capture modes, RAW/ProRAW format selection, quick dock, thumb controls, grid, histogram, focus peaking, horizon guide, haptics, and lock gestures.
- AVFoundation camera service with capability detection, manual exposure/focus/white balance application, and simulator-safe fallbacks.
- Non-destructive editor recipe covering core adjustments, curves, detail, looks, AI tools, crop, and transform metadata.
- Core Image editor service backed by a Metal CIContext when a GPU is available.
- Vision AI service hooks for enhance, sky detection, structure, relight, dehaze, foliage, erase, and specialty looks.
- SwiftData photo library with RAW, ProRAW, AI edit badges, albums, favorites-ready metadata, and search.

## Production Next Steps

- Save captured photo data into Photos with `PHPhotoLibrary` and persist the returned local identifiers.
- Add device-only ProRAW settings with `AVCapturePhotoOutput` RAW pixel format negotiation per active camera.
- Replace the preview AI stubs with Core ML segmentation, depth, face relighting, and inpainting models.
- Add custom Metal kernels for curves, dehaze, grain, masking, and RAW tile processing.
- Add StoreKit entitlements, onboarding, subscription state, and full accessibility audit.
