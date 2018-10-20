//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/7/27.
 * Time: 12:20
 */
package kof.game.character.ai {

    import flash.events.Event;
    import flash.events.IEventDispatcher;

    public class CAIEvent extends Event {
        /**改变AI id的事件*/
        public static const CHANGE_AI_ID : String = "changeAIid";
        public static const REASET_AI_STATE : String = "resetAIState";
        public static const STOP_AUTO_FIGHT:String = "stopAutoFight";
        public static const START_AUTO_FIGHT:String = "startAutoFight";

        private var m_pData : Object = null;

        public function CAIEvent( type : String, data : Object = null ) {
            super( type );
            m_pData = data;
        }

        public function get data() : Object {
            return m_pData;
        }
    }
}
