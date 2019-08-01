//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import RxSwift
import RxSwiftExt

extension ObservableConvertibleType {
    func cache() -> Observable<Element> {
        return self.asObservable().share(replay: 1, scope: .forever)
    }

    func firstOrError() -> Single<Element> {
        return self.asObservable().elementAt(0).take(1).asSingle()
    }
    
    func lastOrError() -> Single<Element> {
        // `count` is part of `RxSwiftExt`
        return asObservable().count().flatMap {
            return self.asObservable().elementAt($0 - 1)
        }.take(1).asSingle()
    }
    
    func flatMapIterable<Other>(_ selector: @escaping (Element) -> [Other]) -> Observable<Other> {
        return asObservable().flatMap { (element: Element) -> Observable<Other> in
            return Observable.from(selector(element))
        }
    }
}
