//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/27.
 * Time: 18:28
 */
package kof.game.currency.qq.data.netData.vo {

    import QFLib.Foundation;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/27
     */
    public class CQQData {
        public var blue : CBlueDiamondData = null;
        public var yellow : CYellowDiamondData = null;
        public var lobby : CLobbyData = null;

        public function CQQData() {
            blue = new CBlueDiamondData();
            yellow = new CYellowDiamondData();
            lobby = new CLobbyData();
        }

        public function setdata( obj : Object ) : void {
            if ( obj ) {
                this.blue.setData( obj.blue );
                this.yellow.setData( obj.yellow );
                this.lobby.setData( obj.lobby );
            }
            else {
                Foundation.Log.logTraceMsg( "腾讯平台数据为null" );
            }
        }
    }
}
