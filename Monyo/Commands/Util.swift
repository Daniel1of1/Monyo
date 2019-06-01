
// TODO: verify this is correct functional vocabulary

func bind<A,B,E>(_ f: @escaping (A) -> Result<B,E>) -> ((Result<A,E>) -> Result<B,E>) {
    return { result in
        return result.flatMap(f)
    }
}

func lift<A,B,E>(_ f: @escaping (A) -> B) -> ((Result<A,E>) -> Result<B,E>) {
    return { result in
        return result.map(f)
    }
}

// TODO: Is this actually Unit?
func unit2<A,B,C,E>(_ f: @escaping (A,B) -> C) -> (_ a: Result<A,E>, _ b:Result<B,E>) -> Result<C,E> {
    return {a,b in
        switch (a,b) {
        case (.success(let aS), .success(let bS)):
            return .success(f(aS,bS))
        case (.failure(let aE), _ ):
            return .failure(aE)
        case (_, .failure(let bE)):
            return .failure(bE)
        }
    }
    
}
