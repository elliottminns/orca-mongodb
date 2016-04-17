/*The MIT License (MIT)

Copyright (c) 2015 Dan Appel

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
// TODO: Make this more generic
struct UnsafeMutablePointerSequence {

    typealias Pointer = UnsafeMutablePointer<Element>
    typealias Element = UnsafeMutablePointer<Int8>

    var pointer: Pointer
}

extension UnsafeMutablePointerSequence: Sequence {
    func generate() -> UnsafeMutablePointerSequence {
        return UnsafeMutablePointerSequence(pointer: pointer)
    }
}
extension UnsafeMutablePointerSequence: IteratorProtocol {
    mutating func next() -> Element? {
        defer { pointer = pointer.advanced(by: 1) }

        return pointer.pointee
    }
}


protocol UnsafeMutablePointerType {}
extension UnsafeMutablePointer: UnsafeMutablePointerType {}


// constrains memory memory to UnsafeMutablePointer
// ie: UnsafeMutablePointer<UnsafeMutablePointer<T>>
extension UnsafeMutablePointer where Pointee: UnsafeMutablePointerType {
    func sequence() -> UnsafeMutablePointerSequence? {

        switch pointee {
        case is UnsafeMutablePointer<Int8>:
            let ptr = UnsafeMutablePointer<UnsafeMutablePointer<Int8>>(self)
            return UnsafeMutablePointerSequence(pointer: ptr)

        default:
            return nil
        }
    }
}
