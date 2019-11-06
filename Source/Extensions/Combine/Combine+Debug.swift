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
        events: Publishers.EventsToDebug = .output,
        _ prefix: String? = nil,
        
        _ line: Int = #line,
        _ function: String = #function,
        _ file: String = #file
    ) -> AnyPublisher<Output, Failure> {
        
        let symbol: String = SFSymbolWithUnicode.deterministicRandom(seed: "\(file)\(function)\(line)")
        
        let customMessage: String? = prefix != nil ? "__\(prefix!)__" : nil
        
        func log<Printable>(event: Publishers.Event, _ printable: Printable? = nil) {
            let fromPrintable: String? = printable != nil ? String(describing: printable!) : nil
            let strings: [String] = [symbol, String(describing: event), fromPrintable, customMessage].compactMap { $0 }
                
            Swift.print(strings.joined(separator: " "))
        }
        
        return self.handleEvents(
            receiveSubscription: events.contains(.subscription) ? { log(event: .subscription, $0) } : nil,
            receiveOutput: events.contains(.output) ? { log(event: .output, $0) } : nil,
            receiveCompletion: events.contains(.completion) ?{ log(event: .completion, $0) } : nil,
            receiveCancel: events.contains(.cancel) ? { log(event: .cancel, Void?.none) } : nil,
            receiveRequest: events.contains(.request) ? { log(event: .request, $0) } : nil
        ).eraseToAnyPublisher()
    }
}

extension Publishers {
    
    struct EventsToDebug: OptionSet {
        let rawValue: Int
        
        static let cancel       = EventsToDebug(rawValue: 1 << 0)
        static let completion   = EventsToDebug(rawValue: 1 << 1)
        static let output       = EventsToDebug(rawValue: 1 << 2)
        static let request      = EventsToDebug(rawValue: 1 << 3)
        static let subscription = EventsToDebug(rawValue: 1 << 4)
        
        static let all: EventsToDebug = [.cancel, .completion, .output, .request, .subscription]
    }
    
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

