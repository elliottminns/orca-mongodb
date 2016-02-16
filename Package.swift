import PackageDescription

let package = Package(name: "OrcaMongoDB",
    dependencies: [
        .Package(url: "https://github.com/elliottminns/orca.git",
            majorVersion: 0),
        .Package(url: "https://github.com/elliottminns/mongodb-module.git",
            majorVersion: 0),
        .Package(url: "https://github.com/elliottminns/echo.git",
            majorVersion: 0),
        .Package(url: "https://github.com/bignerdranch/Freddy.git", 
majorVersion: 2)
            // .Package(url: "https://github.com/tannernelson/csqlite.git", majorVersion: 0)
    ])
