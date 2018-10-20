//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/10/9.
 * Time: 12:21
 */
package kof.game.currency {

import kof.framework.CSystemHandler;
import kof.framework.INetworking;
import kof.game.currency.buyMoney.CBuyMoneyViewHandler;
import kof.game.currency.buyPower.CBuyPowerViewHandler;
import kof.game.currency.qq.data.netData.CQQClientDataManager;
import kof.message.CAbstractPackMessage;
import kof.message.Currency.BuyGoldRequest;
import kof.message.Currency.BuyGoldResponse;
import kof.message.Currency.BuyPhysicalStrengthRequest;
import kof.message.Currency.BuyPhysicalStrengthResponse;
import kof.message.Currency.NotRemindRequest;
import kof.message.Tencent.TencentGiftRequest;
import kof.message.Tencent.TencentGiftResponse;

    public class CCurrencyHandler extends CSystemHandler {
        public function CCurrencyHandler() {
            super();
        }

        public override function dispose() : void {
            super.dispose();
            _removeEventListeners();
        }

        override protected function onSetup() : Boolean {
            var ret : Boolean = super.onSetup();
            _addEventListeners();
            return ret;
        }

        private function _addEventListeners() : void {
            system.getBean( CBuyMoneyViewHandler ).addEventListener( CCurrencyEvent.BUY_GOLD, _buyGold );
            system.getBean( CBuyPowerViewHandler ).addEventListener( CCurrencyEvent.BUY_VIT, _buyVIT );
            system.getBean( CBuyPowerViewHandler ).addEventListener( CCurrencyEvent.NOT_REMIND, _notRemind );
//            system.getBean( CMonthCardViewHandler ).addEventListener( CCurrencyEvent.BUY_WEEK_OR_MONTH_CARD, _buyMonthCard );
//            system.getBean( CWeekCardViewHandler ).addEventListener( CCurrencyEvent.BUY_WEEK_OR_MONTH_CARD, _buyMonthCard );
            networking.bind( TencentGiftResponse ).toHandler( _onTencentGiftResponse );
            networking.bind( BuyGoldResponse ).toHandler( _onBuyGoldResponse );
            networking.bind( BuyPhysicalStrengthResponse ).toHandler( _onBuyPhysicalStrengthResponse );
        }

        private function _removeEventListeners() : void {
            system.getBean( CBuyMoneyViewHandler ).removeEventListener( CCurrencyEvent.BUY_GOLD, _buyGold );
            system.getBean( CBuyPowerViewHandler ).removeEventListener( CCurrencyEvent.BUY_VIT, _buyVIT );
            system.getBean( CBuyPowerViewHandler ).removeEventListener( CCurrencyEvent.NOT_REMIND, _notRemind );
//            system.getBean( CMonthCardViewHandler ).removeEventListener( CCurrencyEvent.BUY_WEEK_OR_MONTH_CARD, _buyMonthCard );
//            system.getBean( CWeekCardViewHandler ).removeEventListener( CCurrencyEvent.BUY_WEEK_OR_MONTH_CARD, _buyMonthCard );
        }

        private function _buyGold( e : CCurrencyEvent ) : void {
            requestBuyGold( e.data.count );
        }

        private function _buyVIT( e : CCurrencyEvent ) : void {
            requestBuyPower();
        }

        private function _notRemind( e : CCurrencyEvent ) : void {
            requestNotRemind( e.data.bool );
        }

//        private function _buyMonthCard( e : CCurrencyEvent ) : void {
//            requestBuyMonthCard( e.data.type );
//        }

        /**
         *
         *
         * */
        final public function requestBuyPower() : void {
            var buyPower : BuyPhysicalStrengthRequest = new BuyPhysicalStrengthRequest();
            buyPower.decode( [ 1 ] );
            networking.post( buyPower );
        }

        /**
         *count 点金次数
         *
         * */
        final public function requestBuyGold( count : int ) : void {
            var buyGold : BuyGoldRequest = new BuyGoldRequest();
            buyGold.decode( [ count ] );
            networking.post( buyGold );
        }

        /**
         * notRemindFlag true不再提醒，false要提醒
         *
         * */
        final public function requestNotRemind( notRemindFlag : Boolean ) : void {
            var notRemind : NotRemindRequest = new NotRemindRequest();
            notRemind.decode( [ notRemindFlag ] );
            networking.post( notRemind );
        }

//        /**
//         * @param type 1月卡2周卡
//         *
//         **/
//        private function requestBuyMonthCard( type : int ) : void {
//            var buyCard : BuyCardMonthRequest = new BuyCardMonthRequest();
//            buyCard.decode( [ type ] );
//            networking.post( buyCard );
//        }

        /**
         * @param giftType 礼包类型（1新手礼包，2每日礼包，3成长礼包）
         * @param type vip类型（1黄钻，2蓝钻，3大厅）
         * @param param （每日礼包中三个类型（1，2，3分别表示普通奖励，豪华奖励，年费奖励），等级礼包中传等级）
         *
         **/
        public function requestTencentGift( giftType : int, type : int, param : int ) : void {
            var requestGift : TencentGiftRequest = new TencentGiftRequest();
            requestGift.decode( [ giftType, type, param ] );
            networking.post( requestGift );
        }

        private function _onTencentGiftResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var tencentGiftResponse : TencentGiftResponse = message as TencentGiftResponse;
            tencentGiftResponse.gamePromptID;
            (system.getBean( CQQClientDataManager ) as CQQClientDataManager).update( tencentGiftResponse.tencentData );
        }
        /**点金手响应*/
        private function _onBuyGoldResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var buyGoldResponse : BuyGoldResponse = message as BuyGoldResponse;
            buyGoldResponse.gamePromptID;
        }
        /**购买体力响应*/
        private function _onBuyPhysicalStrengthResponse( net : INetworking, message : CAbstractPackMessage ) : void {
            var buyPhysicalStrength : BuyPhysicalStrengthResponse = message as BuyPhysicalStrengthResponse;
            buyPhysicalStrength.gamePromptID;
        }
    }
}
