//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/3.
 * Time: 15:07
 */
package kof.game.sign.signFacade.signSystem.net {

    import kof.game.sign.signFacade.CSignFacade;
    import kof.game.sign.signFacade.signSystem.CSignEvent;
    import kof.game.sign.signFacade.signSystem.net.data.CSignData;
    import kof.message.SignIn.UpdateSignInSystemResponse;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/3
     */
    public class CSignNetDataManager {
        private static var _instance : CSignNetDataManager = null;
        private var _signData : CSignData = null;

        public function CSignNetDataManager( cls : PriCls ) {
            _signData = new CSignData();
        }

        public static function getInstance() : CSignNetDataManager {
            if ( !_instance ) {
                _instance = new CSignNetDataManager( new PriCls() );
            }
            return _instance;
        }

        public function updateSignData( obj : UpdateSignInSystemResponse ) : void {
            _signData.setSignData( obj );
            CSignFacade.getInstance().dispatchEvent( CSignEvent.UPDATE_DATA );
            CSignFacade.getInstance().showGamePrompt( obj.gamePromptID );
        }

        /**获取最近应该领取的累积天数奖励的索引
         * 用于打开签到界面显示的累积签到奖励
         * */
        public function getGetNearTotalDaysRewardIndex() : int {
            var len : int = totalSignInDaysReward.length;
            var temp : int = 0;
            for ( var i : int = 0; i < len; i++ ) {
                if ( totalSignInDaysReward[ i ] == 0 ) {
                    return i;
                }
            }
            return len - 1;
        }

        /**根据索引获取连续签到奖励的状态
         * 0未领 1领取
         * */
        public function getGetTotalDaysRewardStateForIndex( daysIndex : int ) : int {
            return totalSignInDaysReward[ daysIndex ];
        }

        /**当前的月数*/
        public function get month() : int {
            return _signData.month;
        }

        /**连续签到的天数*/
        public function get sumDays() : int {
            return _signData.sumDays;
        }

        /**实际连续签到的天数*/
        public function get totalSignInDays() : int {
            return _signData.totalSignInDays;
        }

        /**各个累积天数领奖的状态*/
        public function get totalSignInDaysReward() : Array {
            return _signData.totalSignInDaysReward;
        }

        /**当天签到状态*/
        public function get signInState() : int {
            return _signData.signInState;
        }

        /**获得vip奖励状态 0未领 1已领 2无vip奖励*/
        public function get getVipRewardState() : int {
            return _signData.getVipRewardState;
        }

        /**是否是新服签到奖励*/
        public function get isNewServer() : Boolean {
            return _signData.isNewServer;
        }
    }
}

class PriCls {

}