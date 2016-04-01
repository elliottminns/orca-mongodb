import PackageDescription

let package = Package(name: "OrcaMongoDB",
    dependencies: [
        .Package(url: "https://github.com/elliottminns/orca.git",
            majorVersion: 0),
        .Package(url: "../mongodb-osx",
            majorVersion: 0),
        .Package(url: "https://github.com/elliottminns/echo.git",
            majorVersion: 0),
        .Package(url: "https://github.com/elliottminns/Swift-PureJsonSerializer.git",
            majorVersion: 1)
    ])
