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
//
//  MongoCollectionFlags.swift
//  SwiftMongoDB
//
//  Created by Dan Appel on 11/21/15.
//  Copyright © 2015 Dan Appel. All rights reserved.
//

import CMongoC

typealias QueryOptions = (skip: Int, limit: Int, batchSize: Int)

public enum QueryFlags {
    case None
    case TailableCursor
    case SlaveOK
    case OPLogReplay
    case NoCursorTimout
    case AwaitData
    case Exhaust
    case Partial

    internal var rawFlag: mongoc_query_flags_t {
        switch self {

        case .None: return MONGOC_QUERY_NONE
        case .TailableCursor: return MONGOC_QUERY_TAILABLE_CURSOR
        case .SlaveOK: return MONGOC_QUERY_SLAVE_OK
        case .OPLogReplay: return MONGOC_QUERY_OPLOG_REPLAY
        case .NoCursorTimout: return MONGOC_QUERY_NO_CURSOR_TIMEOUT
        case .AwaitData: return MONGOC_QUERY_AWAIT_DATA
        case .Exhaust: return MONGOC_QUERY_EXHAUST
        case .Partial: return MONGOC_QUERY_PARTIAL

        }
    }
}


public enum InsertFlags {
    case None
    case ContinueOnError

    internal var rawFlag: mongoc_insert_flags_t {
        switch self {
        case .None: return MONGOC_INSERT_NONE
        case .ContinueOnError: return MONGOC_INSERT_CONTINUE_ON_ERROR
        }
    }
}

public enum UpdateFlags {
    case None
    case Upsert
    case MultiUpdate

    internal var rawFlag: mongoc_update_flags_t {
        switch self {
        case .None: return MONGOC_UPDATE_NONE
        case .Upsert: return MONGOC_UPDATE_UPSERT
        case .MultiUpdate: return MONGOC_UPDATE_MULTI_UPDATE
        }
    }
}

public enum RemoveFlags {
    case None
    case SingleRemove

    internal var rawFlag: mongoc_remove_flags_t {
        switch self {
        case .None: return MONGOC_REMOVE_NONE
        case .SingleRemove: return MONGOC_REMOVE_SINGLE_REMOVE
        }
    }
}
