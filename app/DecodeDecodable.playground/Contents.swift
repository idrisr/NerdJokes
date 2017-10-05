//: Playground - noun: a place where people can play

import UIKit
/*
var str = "Hello, playground"

func foo<T>(_ type: T, forKey key: String) -> T where T: MyProtocol {
    return T()
}

func foo<T: YourProtocol & MyProtocol>(_ type: T.Type, forKey key: String) -> T where T: Z  {
    return T()
}

func foo<T>(forKey key: String) -> T where T: MyProtocol {
    return T()
}

protocol YourProtocol {}

protocol MyProtocol {
    init()
}

class Z {}

class A: MyProtocol {
    required init() {
    }
}

class B: A {
}

class C: B {
}

func exampleA() {
    let x: [A.Type] = [A.self, B.self, C.self]

    let o = foo(A.self, forKey: "asdf")
    let oo = foo(A(), forKey: "asdf")

    let BIGO = foo(x[0], forKey: "\(x[0])")

    let m = foo(forKey: "asdf") as A
    // let BIGM = foo(forKey: "\(x[0])") as x[0]

    let n: A = foo(forKey: "asdf")
    // let BIGN: x[0] = foo(forKey: "\(x[0])")
}
*/

protocol P {
    init()
}

final class A: P {
    init() {}
}

final class B: P {
    init() {}
}

func foo<T: P>(_ type: T.Type) -> T {
    //return type()
    return T.init()
}

func foo2<T: P>() -> T {
    //return type()
    return T.init()
}

let xs: [P] = [A(), B()]
let a = foo(A.self)
let b: A = foo2()

let ys = xs.map ({ p: P in
    return foo2(p.Type)
})

