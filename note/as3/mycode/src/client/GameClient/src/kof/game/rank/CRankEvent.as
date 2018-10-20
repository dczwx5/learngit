//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/7/25.
 */
package kof.game.rank {

import flash.events.Event;

public class CRankEvent extends Event{

    public static const RANK_DATA_UPDATE:String = "rank_data_update";

    public static const LIKE_DATA_UPDATE:String = "like_data_update";

    public function CRankEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
    }

    public var data:Object;
}
}
