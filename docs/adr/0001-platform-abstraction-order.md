# Platform abstraction resolution order

For anything that varies between Linux and Windows (file paths, accent colors, process spawning, OS metadata), code resolves the implementation in this order: **(1) Flutter/Dart cross-platform API → (2) pub package → (3) native command/subprocess**. Native commands are the last resort because Linux distros (Ubuntu / Mint / Fedora / Bazzite) ship different versions and binaries; an abstraction shields the app from that variance.

When resolving via a native command, guard with `Platform.isLinux` / `Platform.isWindows` and return a sentinel (`null` / fallback) on the unsupported platform instead of erroring.
