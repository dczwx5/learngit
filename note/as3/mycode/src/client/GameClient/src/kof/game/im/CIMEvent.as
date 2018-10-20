//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/5.
 */
package kof.game.im {

import flash.events.Event;

public class CIMEvent extends Event {

    public static const SEARCH_FRIEND_RESPONSE : String = "_search_friend_response";

    public static const FRIENDINFO_LIST_RESPONSE : String = "_friendinfo_list_response";

    public static const APPLY_LIST_RESPONSE : String = "_apply_list_response";

    public static const FRIEND_RECOMMEND_LIST_RESPONSE : String = "_friend_recommend_list_response";

    public static const NEW_NOTICE_RESPONSE : String = "_new_notice_response";

    public static const CHAT_INFO_RESPONSE : String = "_chat_info_response";

    public function CIMEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        this.data = data;
    }

    public var data:Object;
}
}
