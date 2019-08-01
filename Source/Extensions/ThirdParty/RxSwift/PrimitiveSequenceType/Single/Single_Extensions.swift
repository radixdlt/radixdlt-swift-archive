/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation
import RxSwift

extension PrimitiveSequenceType where Self: ObservableConvertibleType, Self.Trait == SingleTrait {
    
    func flatMapObservable<Other>(_ selector: @escaping (Element) throws -> Observable<Other>) -> Observable<Other> {
        return self.asObservable().flatMap(selector)
    }
    
    func cache() -> Single<Element> {
        return self.asObservable().cache().asSingle()
    }
        
    func flatMapCompletable(_ selector: @escaping (Element) -> Completable) -> Completable {
        return self
            .asObservable()
            .flatMap { element -> Observable<Never> in
                selector(element).asObservable()
            }
            .asCompletable()
    }
    
    func flatMapCompletableVoid(_ selector: @escaping () -> Completable) -> Completable {
        return self
            .asObservable().mapToVoid()
            .flatMap { _ -> Observable<Never> in
                selector().asObservable()
            }
            .asCompletable()
    }
    
}
