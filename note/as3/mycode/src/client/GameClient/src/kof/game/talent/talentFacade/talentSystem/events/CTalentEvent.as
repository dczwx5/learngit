//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/5/2.
 * Time: 16:16
 */
package kof.game.talent.talentFacade.talentSystem.events {

    import flash.events.Event;

    public class CTalentEvent extends Event {
        public static const UPDATE_DATA : String = "updateData";

        public static const ADD : String = "add";
        public static const DELETE : String = "delete";
        public static const REPLACE : String = "replace";
        public static const UpdateMeltInfo : String = "UpdateMeltInfo";

        public var data : Object = null;

        public function CTalentEvent( type : String, data : Object ) {
            super( type );
            this.data = data;
        }

    }
}
