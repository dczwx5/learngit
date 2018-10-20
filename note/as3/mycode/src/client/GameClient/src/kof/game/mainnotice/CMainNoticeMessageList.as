//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/5.
 */
package kof.game.mainnotice {

import QFLib.Graphics.RenderCore.starling.events.EventDispatcher;

import kof.game.mainnotice.data.CMainNoticeData;

public class CMainNoticeMessageList extends EventDispatcher {

    private static const MAX_RECORD:uint = 100;

    private var _list:Array;

    public function CMainNoticeMessageList() {
        super();
        _list = [];
    }

    public function push(mainNoticeData:CMainNoticeData):void {
        _list.push( mainNoticeData );
        if ( _list.length > MAX_RECORD + int(MAX_RECORD * 0.25) ) {
            _list = _list.slice( _list.length - MAX_RECORD );
        }
    }

    public function get list() : Array {
        return _list;
    }

    public function set list( value : Array ) : void {
        _list = value;
    }


}
}
