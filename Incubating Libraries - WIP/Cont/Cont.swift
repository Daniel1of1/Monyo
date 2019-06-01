public func id<A>(_ x: A) -> A {
    return x
}

public struct Cont<R, A> {
    public let run : (@escaping (A) -> R) -> R
    
    public init(_ run : @escaping ( @escaping (A) -> R) -> R) {
        self.run = run
    }
    
    public static func pure(_ a : A) -> Cont<R, A> {
        return Cont({ f in f(a) })
    }
    
    public func flatMap<B>(_ f: @escaping (A) -> Cont<R, B>) -> Cont<R,B> {
        return bind(self, f)
    }
    

    public func map<B>(_ f: @escaping (A) -> B) -> Cont<R,B> {
        return fmap(self, f)
    }
    
//    public func map<B,C,E>(_ f: @escaping (B) -> C) -> Cont<R,Result<C,E>> where A == Result<B,E> {
//        return fmap(self, f)
//    }
//    
//    public func map<B,C,E>(_ f: @escaping (B) -> Result<C,E>) -> Cont<R,Result<C,E>> where A == Result<B,E> {
//        return fmap(self, f)
//    }
    

}

public func bind<R, A, B>(_ c : Cont<R, A>, _ f : @escaping (A) -> Cont<R, B>) -> Cont<R, B> {
    return Cont({ k in  c.run({ a in  f(a).run(k) }) })
}

public func fmap<R, A, B>(_ c : Cont<R, A>, _ f : @escaping (A) -> B) -> Cont<R, B> {
    return Cont({ k in
        return c.run({ a in
            return k(f(a))
        })
    })
}


public func callcc<R, A, B>(_ f :@escaping (@escaping (A) -> Cont<R, B>) -> Cont<R, A> ) -> Cont<R, A> {
    return Cont({ (k: (@escaping (A) -> R)) in
        return f({ a in
            return Cont({ (x: (@escaping (B) -> R)) in
                return k(a)
            })
        }).run(k)
    })
}

public func fmap<R, A, B, E>(_ c : Cont<R, Result<A,E>>, _ f : @escaping (A) -> B) -> Cont<R, Result<B,E>> {
    return Cont({ k in
        return c.run({ a in
            return k(a.map(f))
        })
    })
}

public func fmap<R, A, B, E>(_ c : Cont<R, Result<A,E>>, _ f : @escaping (A) -> Result<B,E>) -> Cont<R, Result<B,E>> {
    return Cont({ k in
        return c.run({ a in
            return k(a.flatMap(f))
        })
    })
}
