//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.util {

import QFLib.Foundation.CMap;

public class CSystemIDBinder {

    private static var s_mapTag2ID : CMap;
    private static var s_mapID2Tag : CMap;

    static private function staticInit() : void {
        s_mapTag2ID = s_mapTag2ID || new CMap();
        s_mapID2Tag = s_mapID2Tag || new CMap();
    }

    static public function bind( tag : String, id : int ) : void {
        staticInit();
        if ( s_mapID2Tag.find( id ) ) {
            s_mapID2Tag[ id ] = tag;
        } else {
            s_mapID2Tag.add( id, tag );
        }

        if ( s_mapTag2ID.find( tag ) ) {
            s_mapTag2ID[ tag ] = id;
        } else {
            s_mapTag2ID.add( tag, id );
        }
    }

    static public function idByTag( tag : String ) : int {
        if ( !s_mapTag2ID )
            return 0;
        return s_mapTag2ID.find( tag );
    }

    static public function tagById( id : int ) : String {
        if ( !s_mapID2Tag )
            return null;
        return s_mapID2Tag.find( id );
    }

    public function CSystemIDBinder() {
    }

}
}
