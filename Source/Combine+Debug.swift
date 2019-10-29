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
import Combine

// swiftlint:disable all

internal extension Publisher {
    
    func debug(
        _ message: String? = nil,
        _ line: Int = #line,
        _ function: String = #function,
        _ file: String = #file
    ) -> AnyPublisher<Output, Failure> {
        
        let symbol: String = SFSymbolWithUnicode.deterministicRandom(seed: "\(file)\(function)\(line)")
        
        let customMessage: String? = message != nil ? "__\(message!)__" : nil
        
        func log<Printable>(event: Publishers.Event, _ printable: Printable? = nil) {
            let fromPrintable: String? = printable != nil ? String(describing: printable!) : nil
            let strings: [String] = [symbol, String(describing: event), fromPrintable, customMessage].compactMap { $0 }
                
            Swift.print(strings.joined(separator: " "))
        }
        
        return self.handleEvents(
            receiveSubscription: { log(event: .subscription, $0) },
            receiveOutput: { log(event: .output, $0) },
            receiveCompletion: { log(event: .completion, $0) },
            receiveCancel: { log(event: .cancel, Void?.none) },
            receiveRequest: { log(event: .request, $0) }
        ).eraseToAnyPublisher()
    }
}

extension Publishers {
    enum Event {
        case cancel
        case completion
        case output
        case request
        case subscription
    }
}

private enum SFSymbolWithUnicode {
    
    static func deterministicRandom<Seed>(seed: Seed) -> String where Seed: Hashable {
        let hash = abs(seed.hashValue)
        let indexFromHash = hash % Self.symbols.count
        return symbols[indexFromHash]
    }
    
    static let symbols: [String] = [
        "􀀺",
        "􀀼",
        "􀀾",
        "􀁀",
        "􀁂",
        "􀁄",
        "􀁆",
        "􀁈",
        "􀁊",
        "􀓾",
        "􀀄",
        "􀀆",
        "􀀈",
        "􀀊",
        "􀀌",
        "􀀎",
        "􀀐",
        "􀀒",
        "􀀔",
        "􀀖",
        "􀀘",
        "􀀚",
        "􀀜",
        "􀀞",
        "􀀠",
        "􀀢",
        "􀀤",
        "􀀦",
        "􀀨",
        "􀀪",
        "􀀬",
        "􀀮",
        "􀀰",
        "􀀲",
        "􀀴",
        "􀀶",
        "􀀸",
        "􀔝",
        "􀀹",
        "􀂓",
        "􀄤",
        "􀄧",
        "􀄥",
        "􀄦",
        "􀀁",
        "􀋃",
        "􀋂",
        "􀆺",
        "􀊾",
        "􀒂",
        "􀒄",
        "􀊽",
        "􀒅",
        "􀊼",
        "􀊿",
        "􀒃",
        "􀇾",
        "􀑓",
        "􀆅",
        "􀆄",
        "􀀻",
        "􀀽",
        "􀀿",
        "􀁁",
        "􀁃",
        "􀁅",
        "􀁇",
        "􀁉",
        "􀁋",
        "􀅃",
        "􀅄",
        "􀄲",
        "􀄳",
        "􀄴",
        "􀄵",
        "􀄶",
        "􀄷",
        "􀄸",
        "􀄹",
        "􀂔",
        "􀂖",
        "􀂘",
        "􀂚",
        "􀂜",
        "􀂞",
        "􀂠",
        "􀂢",
        "􀂤",
        "􀂦",
        "􀂨",
        "􀂪",
        "􀂬",
        "􀂮",
        "􀂰",
        "􀂲",
        "􀂴",
        "􀂶",
        "􀂸",
        "􀂺",
        "􀂼",
        "􀂾",
        "􀃀",
        "􀃂",
        "􀃄",
        "􀃆",
        "􀀅",
        "􀀇",
        "􀀉",
        "􀀋",
        "􀀍",
        "􀀏",
        "􀀑",
        "􀀓",
        "􀀕",
        "􀀗",
        "􀀙",
        "􀀛",
        "􀀝",
        "􀀟",
        "􀀡",
        "􀀣",
        "􀀥",
        "􀀧",
        "􀀩",
        "􀀫",
        "􀀭",
        "􀀯",
        "􀀱",
        "􀀳",
        "􀀵",
        "􀀷",
        "􀂕",
        "􀂗",
        "􀂙",
        "􀂛",
        "􀂝",
        "􀂟",
        "􀂡",
        "􀂣",
        "􀂥",
        "􀂧",
        "􀂩",
        "􀂫",
        "􀂭",
        "􀂯",
        "􀂱",
        "􀂳",
        "􀂵",
        "􀂷",
        "􀂹",
        "􀂻",
        "􀂽",
        "􀂿",
        "􀃁",
        "􀃃",
        "􀃅",
        "􀃇"
    ]
}

