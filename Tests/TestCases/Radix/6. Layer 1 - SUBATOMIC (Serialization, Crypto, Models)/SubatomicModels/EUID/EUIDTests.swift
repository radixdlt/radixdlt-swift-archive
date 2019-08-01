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

@testable import RadixSDK
import XCTest

class EUIDTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testEUIDFrom16Bytes() {
        XCTAssertNotThrowsAndEqual(
            try EUID(data: Data([Byte](repeating: 0x01, count: 16))),
            "01010101010101010101010101010101",
            "Should have possible to create EUID from 16 bytes"
        )
    }
    
    func testMinus1() {
        XCTAssertEqual(
            EUID(-1),
            "ffffffffffffffffffffffffffffffff"
        )
    }
    
    func testMinus2() {
        XCTAssertEqual(
            EUID(-2),
            "fffffffffffffffffffffffffffffffe"
        )
    }
    
    func testMinus3() {
        XCTAssertEqual(
            EUID(-3),
            "fffffffffffffffffffffffffffffffd"
        )
    }
    
    func testEUIDFrom15BytesThrowsError() {
        XCTAssertThrowsSpecificError(
            try EUID(data: Data([Byte](repeating: 0x01, count: 15))),
            InvalidStringError.tooFewCharacters(expectedAtLeast: 16, butGot: 15),
            "Should have possible to create EUID from 16 bytes"
        )
    }
    
    func testEUIDFrom16BytesThrowsError() {
        XCTAssertThrowsSpecificError(
            try EUID(data: Data([Byte](repeating: 0x01, count: 17))),
            InvalidStringError.tooManyCharacters(expectedAtMost: 16, butGot: 17),
            "Should have possible to create EUID from 16 bytes"
        )
    }
    
    func testShard() {
        func doTest(_ vector: ShardTestVector) {
            let euid = try! EUID(hexString: vector.euid)
            let expected = vector.shard
            XCTAssertEqual(euid.shard, expected)
        }
        
        euidAndShardTestVectors.forEach {
            doTest($0)
        }
    }
}

private typealias ShardTestVector = (euid: String, shard: Shard)
private let euidAndShardTestVectors: [ShardTestVector] = [
    (
        euid: "0102030405060708090a0b0c0d0e0f10",
        shard: 72623859790382856
    ),
    (
        euid: "02030405060708090a0b0c0d0e0f1011",
        shard: 144964032628459529
    ),
    (
        euid: "030405060708090a0b0c0d0e0f101112",
        shard: 217304205466536202
    ),
    (
        euid: "0405060708090a0b0c0d0e0f10111213",
        shard: 289644378304612875
    ),
    (
        euid: "05060708090a0b0c0d0e0f1011121314",
        shard: 361984551142689548
    ),
    (
        euid: "060708090a0b0c0d0e0f101112131415",
        shard: 434324723980766221
    ),
    (
        euid: "0708090a0b0c0d0e0f10111213141516",
        shard: 506664896818842894
    ),
    (
        euid: "08090a0b0c0d0e0f1011121314151617",
        shard: 579005069656919567
    ),
    (
        euid: "090a0b0c0d0e0f101112131415161718",
        shard: 651345242494996240
    ),
    (
        euid: "0a0b0c0d0e0f10111213141516171819",
        shard: 723685415333072913
    ),
    (
        euid: "0b0c0d0e0f101112131415161718191a",
        shard: 796025588171149586
    ),
    (
        euid: "0c0d0e0f101112131415161718191a1b",
        shard: 868365761009226259
    ),
    (
        euid: "0d0e0f101112131415161718191a1b1c",
        shard: 940705933847302932
    ),
    (
        euid: "0e0f101112131415161718191a1b1c1d",
        shard: 1013046106685379605
    ),
    (
        euid: "0f101112131415161718191a1b1c1d1e",
        shard: 1085386279523456278
    ),
    (
        euid: "101112131415161718191a1b1c1d1e1f",
        shard: 1157726452361532951
    ),
    (
        euid: "1112131415161718191a1b1c1d1e1f20",
        shard: 1230066625199609624
    ),
    (
        euid: "12131415161718191a1b1c1d1e1f2021",
        shard: 1302406798037686297
    ),
    (
        euid: "131415161718191a1b1c1d1e1f202122",
        shard: 1374746970875762970
    ),
    (
        euid: "1415161718191a1b1c1d1e1f20212223",
        shard: 1447087143713839643
    ),
    (
        euid: "15161718191a1b1c1d1e1f2021222324",
        shard: 1519427316551916316
    ),
    (
        euid: "161718191a1b1c1d1e1f202122232425",
        shard: 1591767489389992989
    ),
    (
        euid: "1718191a1b1c1d1e1f20212223242526",
        shard: 1664107662228069662
    ),
    (
        euid: "18191a1b1c1d1e1f2021222324252627",
        shard: 1736447835066146335
    ),
    (
        euid: "191a1b1c1d1e1f202122232425262728",
        shard: 1808788007904223008
    ),
    (
        euid: "1a1b1c1d1e1f20212223242526272829",
        shard: 1881128180742299681
    ),
    (
        euid: "1b1c1d1e1f202122232425262728292a",
        shard: 1953468353580376354
    ),
    (
        euid: "1c1d1e1f202122232425262728292a2b",
        shard: 2025808526418453027
    ),
    (
        euid: "1d1e1f202122232425262728292a2b2c",
        shard: 2098148699256529700
    ),
    (
        euid: "1e1f202122232425262728292a2b2c2d",
        shard: 2170488872094606373
    ),
    (
        euid: "1f202122232425262728292a2b2c2d2e",
        shard: 2242829044932683046
    ),
    (
        euid: "202122232425262728292a2b2c2d2e2f",
        shard: 2315169217770759719
    ),
    (
        euid: "2122232425262728292a2b2c2d2e2f30",
        shard: 2387509390608836392
    ),
    (
        euid: "22232425262728292a2b2c2d2e2f3031",
        shard: 2459849563446913065
    ),
    (
        euid: "232425262728292a2b2c2d2e2f303132",
        shard: 2532189736284989738
    ),
    (
        euid: "2425262728292a2b2c2d2e2f30313233",
        shard: 2604529909123066411
    ),
    (
        euid: "25262728292a2b2c2d2e2f3031323334",
        shard: 2676870081961143084
    ),
    (
        euid: "262728292a2b2c2d2e2f303132333435",
        shard: 2749210254799219757
    ),
    (
        euid: "2728292a2b2c2d2e2f30313233343536",
        shard: 2821550427637296430
    ),
    (
        euid: "28292a2b2c2d2e2f3031323334353637",
        shard: 2893890600475373103
    ),
    (
        euid: "292a2b2c2d2e2f303132333435363738",
        shard: 2966230773313449776
    ),
    (
        euid: "2a2b2c2d2e2f30313233343536373839",
        shard: 3038570946151526449
    ),
    (
        euid: "2b2c2d2e2f303132333435363738393a",
        shard: 3110911118989603122
    ),
    (
        euid: "2c2d2e2f303132333435363738393a3b",
        shard: 3183251291827679795
    ),
    (
        euid: "2d2e2f303132333435363738393a3b3c",
        shard: 3255591464665756468
    ),
    (
        euid: "2e2f303132333435363738393a3b3c3d",
        shard: 3327931637503833141
    ),
    (
        euid: "2f303132333435363738393a3b3c3d3e",
        shard: 3400271810341909814
    ),
    (
        euid: "303132333435363738393a3b3c3d3e3f",
        shard: 3472611983179986487
    ),
    (
        euid: "3132333435363738393a3b3c3d3e3f40",
        shard: 3544952156018063160
    ),
    (
        euid: "32333435363738393a3b3c3d3e3f4041",
        shard: 3617292328856139833
    ),
    (
        euid: "333435363738393a3b3c3d3e3f404142",
        shard: 3689632501694216506
    ),
    (
        euid: "3435363738393a3b3c3d3e3f40414243",
        shard: 3761972674532293179
    ),
    (
        euid: "35363738393a3b3c3d3e3f4041424344",
        shard: 3834312847370369852
    ),
    (
        euid: "363738393a3b3c3d3e3f404142434445",
        shard: 3906653020208446525
    ),
    (
        euid: "3738393a3b3c3d3e3f40414243444546",
        shard: 3978993193046523198
    ),
    (
        euid: "38393a3b3c3d3e3f4041424344454647",
        shard: 4051333365884599871
    ),
    (
        euid: "393a3b3c3d3e3f404142434445464748",
        shard: 4123673538722676544
    ),
    (
        euid: "3a3b3c3d3e3f40414243444546474849",
        shard: 4196013711560753217
    ),
    (
        euid: "3b3c3d3e3f404142434445464748494a",
        shard: 4268353884398829890
    ),
    (
        euid: "3c3d3e3f404142434445464748494a4b",
        shard: 4340694057236906563
    ),
    (
        euid: "3d3e3f404142434445464748494a4b4c",
        shard: 4413034230074983236
    ),
    (
        euid: "3e3f404142434445464748494a4b4c4d",
        shard: 4485374402913059909
    ),
    (
        euid: "3f404142434445464748494a4b4c4d4e",
        shard: 4557714575751136582
    ),
    (
        euid: "404142434445464748494a4b4c4d4e4f",
        shard: 4630054748589213255
    ),
    (
        euid: "4142434445464748494a4b4c4d4e4f50",
        shard: 4702394921427289928
    ),
    (
        euid: "42434445464748494a4b4c4d4e4f5051",
        shard: 4774735094265366601
    ),
    (
        euid: "434445464748494a4b4c4d4e4f505152",
        shard: 4847075267103443274
    ),
    (
        euid: "4445464748494a4b4c4d4e4f50515253",
        shard: 4919415439941519947
    ),
    (
        euid: "45464748494a4b4c4d4e4f5051525354",
        shard: 4991755612779596620
    ),
    (
        euid: "464748494a4b4c4d4e4f505152535455",
        shard: 5064095785617673293
    ),
    (
        euid: "4748494a4b4c4d4e4f50515253545556",
        shard: 5136435958455749966
    ),
    (
        euid: "48494a4b4c4d4e4f5051525354555657",
        shard: 5208776131293826639
    ),
    (
        euid: "494a4b4c4d4e4f505152535455565758",
        shard: 5281116304131903312
    ),
    (
        euid: "4a4b4c4d4e4f50515253545556575859",
        shard: 5353456476969979985
    ),
    (
        euid: "4b4c4d4e4f505152535455565758595a",
        shard: 5425796649808056658
    ),
    (
        euid: "4c4d4e4f505152535455565758595a5b",
        shard: 5498136822646133331
    ),
    (
        euid: "4d4e4f505152535455565758595a5b5c",
        shard: 5570476995484210004
    ),
    (
        euid: "4e4f505152535455565758595a5b5c5d",
        shard: 5642817168322286677
    ),
    (
        euid: "4f505152535455565758595a5b5c5d5e",
        shard: 5715157341160363350
    ),
    (
        euid: "505152535455565758595a5b5c5d5e5f",
        shard: 5787497513998440023
    ),
    (
        euid: "5152535455565758595a5b5c5d5e5f60",
        shard: 5859837686836516696
    ),
    (
        euid: "52535455565758595a5b5c5d5e5f6061",
        shard: 5932177859674593369
    ),
    (
        euid: "535455565758595a5b5c5d5e5f606162",
        shard: 6004518032512670042
    ),
    (
        euid: "5455565758595a5b5c5d5e5f60616263",
        shard: 6076858205350746715
    ),
    (
        euid: "55565758595a5b5c5d5e5f6061626364",
        shard: 6149198378188823388
    ),
    (
        euid: "565758595a5b5c5d5e5f606162636465",
        shard: 6221538551026900061
    ),
    (
        euid: "5758595a5b5c5d5e5f60616263646566",
        shard: 6293878723864976734
    ),
    (
        euid: "58595a5b5c5d5e5f6061626364656667",
        shard: 6366218896703053407
    ),
    (
        euid: "595a5b5c5d5e5f606162636465666768",
        shard: 6438559069541130080
    ),
    (
        euid: "5a5b5c5d5e5f60616263646566676869",
        shard: 6510899242379206753
    ),
    (
        euid: "5b5c5d5e5f606162636465666768696a",
        shard: 6583239415217283426
    ),
    (
        euid: "5c5d5e5f606162636465666768696a6b",
        shard: 6655579588055360099
    ),
    (
        euid: "5d5e5f606162636465666768696a6b6c",
        shard: 6727919760893436772
    ),
    (
        euid: "5e5f606162636465666768696a6b6c6d",
        shard: 6800259933731513445
    ),
    (
        euid: "5f606162636465666768696a6b6c6d6e",
        shard: 6872600106569590118
    ),
    (
        euid: "606162636465666768696a6b6c6d6e6f",
        shard: 6944940279407666791
    ),
    (
        euid: "6162636465666768696a6b6c6d6e6f70",
        shard: 7017280452245743464
    ),
    (
        euid: "62636465666768696a6b6c6d6e6f7071",
        shard: 7089620625083820137
    ),
    (
        euid: "636465666768696a6b6c6d6e6f707172",
        shard: 7161960797921896810
    ),

]
