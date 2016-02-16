# Orca-MongoDB

A MongoDB driver for the [Orca](https://github.com/elliottminns/orca) ODM

## Requirements

Due to the nature of the Swift Package manager and building, there are some caveats to using MongoDB.

### Installing MongoDB

A prebuilt binary for Ubuntu & OS X is in the roadmap, but until then you need to do some initial setup.

First of all, you need to install the MongoDB C-Driver.

#### OS X

On OS X, you can achieve this using homebrew.

```
brew install mongo-c
```

and then linking the outputs

```
brew link --overwrite mongo-c 
brew link --overwrite bson 
```

#### Linux

On Linux, this is a different story. Adding a prebuilt binary is in the roadmap. Currently, follow the instructions found [here](https://github.com/mongodb/mongo-c-driver).

#### Building

In order to build your project, the swift compiler needs to know where the include files live. This only needs to be done the first time so that it compiles the MongoDB module.

#### OS X

```
swift build -Xcc -I/usr/local/opt/libbson/include/libbson-1.0/
```

### Linux

```
swift build -Xcc -I/usr/include/libbson/
```

## Getting Started

Add Orca-MongoDB to your Package.swift

```swift
Package.swift
```

```swift

    depencies: [
        .Package(url: "https://github.com/elliottminns/orca.git", majorVersion: 0),
        .Package(url: "https://github.com/elliottminns/orca-mongodb.git", majorVersion: 0)
    ]

```

Then create a MongoDB driver, connect to your database  and add it to Orca.

```
main.swift
```

```swift
import Orca
import OrcaMongoDB

let mongo = OrcaMongoDB()

mongo.connect(host: "localhost", port: 27017, database: "test") { error in 
    if error == nil {
        print("connected")
    }
}

let database = Orca(driver: mongo)

```

and you're good to go.
