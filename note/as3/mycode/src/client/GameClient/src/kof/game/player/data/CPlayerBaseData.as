//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2016/9/23.
 */
package kof.game.player.data {

    import QFLib.Foundation.CMap;

    import kof.data.CObjectData;

    public class CPlayerBaseData extends CObjectData {

        public function CPlayerBaseData() {
            super();
            backupDataClass = CPlayerBaseData;
            _data = _data || new CMap();
            _initialized = false;
        }

        final public function get isInitialized() : Boolean {
            return _initialized;
        }

        final public function setInitialized() : void {
            _initialized = true;
        }

        // 战队基本数据
        public function get ID() : Number {
            return _data[ _ID ];
        } // uniID
        public function get type() : int {
            return _data[ _type ];
        }

        // 充值活动通知ID
        public function get activityNoticeId():int
        {
            return _data[ _ActivityNoticeId ];
        }

//        public function get talentBattleValue() : int {
//            return _data[ "talentBattleValue" ];
//        }

//        public function get artifactBattleValue() : int {
//            return _data[ "artifactBattleValue" ];
//        }

        private var _initialized : Boolean;

        public static const _ID : String = "ID";
        public static const _type : String = "type";
        public static const _ActivityNoticeId : String = "activityNoticeId";







    }
}
