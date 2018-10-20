//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/5/4.
 * Time: 14:35
 */
package QFLib.AI.events {

    import flash.events.Event;

    /**
     * @author @yili@guoyiligo@qq.com
     * @date   2017/5/4
     */
    public class CAIEvent extends Event {
        public static const OVERRIDE_ACTION : String = "overrideAntion";
        public var data : Object = null;

        public function CAIEvent( type : String, data : Object ) {
            super( type );
            this.data = data;
        }
    }
}
