//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/19.
 * Time: 12:08
 */
package kof.game.hook.net {

    import flash.events.Event;
    import flash.events.EventDispatcher;

    import kof.framework.INetworking;
    import kof.game.hook.net.data.CGetDropData;
    import kof.game.hook.net.data.CGetExpData;
    import kof.game.hook.net.data.CHookInfoData;
    import kof.message.HangUp.CancelHangUpResponse;
    import kof.message.HangUp.HangUpDropResponse;
    import kof.message.HangUp.HangUpExpResponse;
    import kof.message.HangUp.HangUpHeroResponse;
    import kof.message.HangUp.HangUpInfoResponse;
    import kof.message.HangUp.HangUpResponse;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/19
     */
    [Event(name)]
    public class CHookNetDataManager {
        private static var _instance : CHookNetDataManager = null;

        private var _hookInfodata : CHookInfoData = null;

        private var _hookGetExpData : CGetExpData = null;
        private var _hookGetDropData : CGetDropData = null;

        private var _eventDispacther : EventDispatcher = null;
        private var _addRecomeArray : Array = [];

        public function CHookNetDataManager( pricls : PriCls ) {
            _eventDispacther = new EventDispatcher();
            _hookInfodata = new CHookInfoData();
            _hookGetExpData = new CGetExpData();
            _hookGetDropData = new CGetDropData();
        }

        public function clearData() : void {
            _addRecomeArray = [];
            _hookInfodata.clearData();
            _str = "00:00:00";
        }

        public static function get instance() : CHookNetDataManager {
            if ( !_instance ) {
                _instance = new CHookNetDataManager( new PriCls() );
            }
            return _instance;
        }

        public function get addRecomeArray() : Array {
            return _addRecomeArray;
        }

        public function setCancelHookData( response : CancelHangUpResponse ) : void {
            _hookInfodata.decodeCancleData( response );
            _eventDispacther.dispatchEvent( new Event( "CancelHook" ) );
        }

        public function setHookInfoData( response : HangUpInfoResponse ) : void {
            if ( response.isMidnight ) {
                clearData();
            }
            _hookInfodata.decode( response );
            if ( _hookInfodata.addDrop.length > 0 ) {
                if ( _addRecomeArray.length > 100 ) {
                    _addRecomeArray.shift();
                }
                _addRecomeArray.push( _hookInfodata.addDrop );

            }
            _eventDispacther.dispatchEvent( new Event( "updateHookData" ) );
        }

        public function setHookGetExpData( response : HangUpExpResponse ) : void {
            _hookGetExpData.decode( response );
            _eventDispacther.dispatchEvent( new Event( "updateHookGetExpData" ) );
        }

        public function setHookGetDropData( response : HangUpDropResponse ) : void {
            _hookGetDropData.decode( response );
            _eventDispacther.dispatchEvent( new Event( "updateHookGetDropData" ) );
        }

        public function setHookHeroSuccess( response : HangUpHeroResponse ) : void {
            _eventDispacther.dispatchEvent( new Event( "setHeroSuccess" ) );
        }

        public function setHookSuccess( response : HangUpResponse ) : void {
            _eventDispacther.dispatchEvent( new Event( "hookSuccess" ) );
        }

        public function addEventListener( eventType : String, _callBackFunc : Function ) : void {
            _eventDispacther.addEventListener( eventType, _callBackFunc );
        }

        public function removeEventListener( eventType : String, _callBackFunc : Function ) : void {
            _eventDispacther.removeEventListener( eventType, _callBackFunc );
        }

        public function getExp() : int {
            return _hookGetExpData.exp;
        }

        public function getTotalProp() : Array {
            return _hookInfodata.dropItem;
        }

        public function getTodayDropItem() : Array {
            return _hookInfodata.todayDropItem;
        }


        private var _str : String = "";

        public function set totalTime( str : String ) : void {
            _str = str;
        }

        public function get totalTime() : String {
            return _str;
        }
    }
}
class PriCls {

}
