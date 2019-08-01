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

/// https://radixdlt.atlassian.net/wiki/spaces/RDOC/pages/425787406/Error+formats#Errorformats-Radixerrorcodes
public enum RadixErrorCode: Int, Swift.Error, Decodable, Equatable {
    case atomCollision          = 1010
    case atomIllegalState       = 1011
    case atomUnsuitablePeer     = 1012
    case atomValidationError    = 1013
    case atomUnknownError       = 1014
    
    case invalidArgument        = 1040
    case failedPrecondition     = 1041
    case outOfRange             = 1042
    case unauthorized           = 1043
    case notFound               = 1044
    case endpointRetired        = 1045
    case limitExceeded          = 1046
    case nodeUnknown            = 1050
    case nodeInternal           = 1051
    case nodeOffline            = 1052
    case nodeUnavailable        = 1053
}
