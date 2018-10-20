//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/5/31.
 * Time: 11:35
 */
package kof.game.sign.signFacade {

    import flash.events.EventDispatcher;

    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;

    import kof.framework.CAppSystem;
    import kof.framework.INetworking;
    import kof.game.bag.CBagManager;
    import kof.game.bag.CBagSystem;
    import kof.game.bag.data.CBagData;
    import kof.game.item.CItemData;
    import kof.game.item.CItemSystem;
    import kof.game.sign.CSignSystem;
    import kof.game.sign.signFacade.signSystem.CSignEvent;
    import kof.game.sign.signFacade.signSystem.net.CSignNet;
    import kof.game.sign.signFacade.signSystem.net.CSignNetDataManager;
    import kof.game.sign.signFacade.signSystem.view.CSignView;
    import kof.table.GamePrompt;
    import kof.table.Item;
    import kof.table.NewServerReward;
    import kof.table.SignInReward;
    import kof.table.TotalSignInReward;
    import kof.table.TotalSignInReward;
    import kof.ui.CUISystem;
    import kof.ui.IUICanvas;

    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/5/31
     */
    public class CSignFacade {
        private static var _instance : CSignFacade = null;
        private var _signView : CSignView = null;
        private var _signNet : CSignNet = null;

        private var _signAppSystem : CAppSystem = null;

        private var _eventDispatcher : EventDispatcher = null;

        public function CSignFacade( cls : PrivateCls ) {
            _eventDispatcher = new EventDispatcher();
            addEventListener();
        }

        public function dispose() : void {
            _signView.dispose();
            _signView = null;
            _signNet = null;
            _signAppSystem = null;
        }

        public static function getInstance() : CSignFacade {
            if ( !_instance ) {
                _instance = new CSignFacade( new PrivateCls() );
            }
            return _instance;
        }

        public function initSignView() : Boolean {
            _signView = new CSignView();
            if ( _signView ) {
                return true;
            } else {
                return false;
            }
        }

        public function initlializeNet() : void {
            _signNet = new CSignNet();
        }

        public function show() : void {
            _signNet.openSignInSystemRequest();
            _signView.show();
        }

        public function close() : void {
            _signView.close();
        }

        public function set signViewUIContainer( container : IUICanvas ) : void {
            _signView.uiContainer = container;
        }

        public function set signAppSystem( signAppSys : CAppSystem ) : void {
            this._signAppSystem = signAppSys;
        }

        public function get signAppSystem() : CAppSystem {
            return this._signAppSystem;
        }

        public function set closeHandler( closeHandler : Handler ) : void {
            _signView.closeHanlder = closeHandler;
        }

        public final function set netWork( network : INetworking ) : void {
            _signNet.network = network;
        }

        public final function dispatchEvent( eventType : String ) : void {
            _eventDispatcher.dispatchEvent( new CSignEvent( eventType ) );
        }

        private final function addEventListener() : void {
            _eventDispatcher.addEventListener( CSignEvent.UPDATE_DATA, _updateView );
        }

        private final function _updateView( e : CSignEvent ) : void {
            if ( _signView && _signView.isShow ) {
                _signView.update();
            }
            if ( CSignNetDataManager.getInstance().signInState == 1 ) {
                var totalSignInReward : TotalSignInReward = CSignFacade.getInstance().getSumSignInReward( CSignNetDataManager.getInstance().getGetNearTotalDaysRewardIndex() );
                var sumDays : int = CSignNetDataManager.getInstance().sumDays;
                var daysIndex : int = CSignFacade.getInstance().getTotalDaysIndexForTotalDays( totalSignInReward.totalDays );
                var daysState : int = CSignNetDataManager.getInstance().getGetTotalDaysRewardStateForIndex( daysIndex );
                if ( sumDays >= totalSignInReward.totalDays ) {
                    if ( daysState == 0 ) {
                        (_signAppSystem as CSignSystem).updateSystemRedPoint( true );
                    } else {
                        (_signAppSystem as CSignSystem).updateSystemRedPoint( false );
                    }
                } else {
                    (_signAppSystem as CSignSystem).updateSystemRedPoint( false );
                }

            } else {
                (_signAppSystem as CSignSystem).updateSystemRedPoint( true );
            }
        }

        /**
         * network相关
         * 签到请求
         **/
        public final function commonSignRequest() : void {
            _signNet.commonSignRequest();
        }

        //
        public final function getVipSignInRewardRequest() : void {
            _signNet.getVipSignInRewardRequest();
        }

        public final function getTotalSignInRewardRequest( days : int ) : void {
            _signNet.getTotalSignInDaysRewardRequest( days );
        }

        public final function showGamePrompt( gamePromptID : int ) : void {
            if ( gamePromptID != 0 ) {
                var msg : String = (this._gamePromptTable.findByPrimaryKey( gamePromptID ) as GamePrompt).content;
                (_signAppSystem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( msg );
            }
        }

        public final function openSignInSystemRequest() : void {
            _signNet.openSignInSystemRequest();
        }

        private function get _gamePromptTable() : CDataTable {
            var pDatabaseSystem : CDatabaseSystem = this._signAppSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            return pDatabaseSystem.getTable( KOFTableConstants.GAME_PROMPT ) as CDataTable;
        }

        //---------------------------
        //---------数据表相关---------
        //---------------------------
        /**新服奖励数据表*/
        public function get newServerRewardTable() : CDataTable {
            var newServerRewardTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this._signAppSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            newServerRewardTable = pDatabaseSystem.getTable( KOFTableConstants.NEW_SERVER_REWARD ) as CDataTable;
            return newServerRewardTable;
        }

        /**
         * 指定月份的登录奖励
         * @param month 要获取的月份
         * @return 返回指定月份的数据表集合
         *
         **/
        public function getSignInRewardForMonth( month : int ) : Array {
            var signInRewardTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this._signAppSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            signInRewardTable = pDatabaseSystem.getTable( KOFTableConstants.SIGNIN_REWARD ) as CDataTable;
            var arr : Array = [];
            var len : int = signInRewardTable.toVector().length;
            for ( var i : int = 0; i < len; i++ ) {
                var signInReward : SignInReward = signInRewardTable.findByPrimaryKey( i + 1 );
                if ( month == signInReward.month ) {
                    arr.push( signInReward );
                }
            }
            arr.sort( _sortSignInReward );
            return arr;
        }

        private function _sortSignInReward( item1 : SignInReward, item2 : SignInReward ) : int {
            if ( item1.days < item2.days ) {
                return -1;
            } else if ( item1.days == item2.days ) {
                return 0;
            } else {
                return 1;
            }
        }

        /**
         * 根据物品ID获取物品表数据
         * @ItemID 物品id
         * @return 返回的物品表数据
         *
         * */
        public function getItemForItemID( itemID : int ) : Item {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this._signAppSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
            return itemTable.findByPrimaryKey( itemID );
        }

        /**
         * 累积签到天数奖励表数据
         * @param daysIndex 连续签到天数索引
         * @return 返回对应表数据（如果没有对应的数据，显示一下个最近要领取的奖励）
         *
         * */
        public function getSumSignInReward( daysIndex : int ) : TotalSignInReward {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this._signAppSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.TOTAL_SIGNIN_REWARD ) as CDataTable;
            var len : int = itemTable.toVector().length;
            var vec : Vector.<Object> = itemTable.toVector();
            vec.sort( _sortTotalSignInReward );
            return vec[ daysIndex ] as TotalSignInReward;
        }

        public function getPreSumSignInReward( daysIndex : int ) : TotalSignInReward {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this._signAppSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.TOTAL_SIGNIN_REWARD ) as CDataTable;
            var len : int = itemTable.toVector().length;
            var vec : Vector.<Object> = itemTable.toVector();
            vec.sort( _sortTotalSignInReward );
            var totalSignInReward : TotalSignInReward = null;
            if ( daysIndex - 1 > -1 ) {
                totalSignInReward = vec[ daysIndex - 1 ] as TotalSignInReward;
            } else {
                totalSignInReward = vec[ 0 ] as TotalSignInReward;
            }
            return totalSignInReward;
        }

        public function getNextSumSignInReward( daysIndex : int ) : TotalSignInReward {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this._signAppSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.TOTAL_SIGNIN_REWARD ) as CDataTable;
            var len : int = itemTable.toVector().length;
            var vec : Vector.<Object> = itemTable.toVector();
            vec.sort( _sortTotalSignInReward );
            var totalSignInReward : TotalSignInReward = null;
            if ( daysIndex + 1 < len ) {
                totalSignInReward = vec[ daysIndex + 1 ] as TotalSignInReward;
            } else {
                totalSignInReward = vec[ len - 1 ] as TotalSignInReward;
            }
            return totalSignInReward;
        }

        private function _sortTotalSignInReward( item1 : TotalSignInReward, item2 : TotalSignInReward ) : int {
            if ( item1.totalDays < item2.totalDays ) {
                return -1;
            } else if ( item1.totalDays > item2.totalDays ) {
                return 1;
            } else {
                return 0;
            }
        }

        /**
         *根据连续签到天数获取对应的数组索引
         * */
        public final function getTotalDaysIndexForTotalDays( days : int ) : int {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this._signAppSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.TOTAL_SIGNIN_REWARD ) as CDataTable;
            var len : int = itemTable.toVector().length;
            var vec : Vector.<Object> = itemTable.toVector();
            vec.sort( _sortTotalSignInReward );
            for ( var i : int = 0; i < len; i++ ) {
                var totalSignInReward : TotalSignInReward = vec[ i ] as TotalSignInReward;
                if ( totalSignInReward.totalDays == days ) {
                    return i;
                }
            }
            return null;
        }

        /**获取背包中的物品数量*/
        public final function getItemNuForBag( itemID : int ) : int {
            var bagData : CBagData = (this._signAppSystem.stage.getSystem( CBagSystem ).getBean( CBagManager ) as CBagManager).getBagItemByUid( itemID );
            if ( bagData ) {
                return bagData.num;
            } else {
                return 0;
            }
        }

        /**根据itemID获取itemdata*/
        public final function getItemDataForItemID( itemID : int ) : CItemData {
            var itemData : CItemData = (this._signAppSystem.stage.getSystem( CItemSystem ) as CItemSystem).getItem( itemID );
            return itemData;
        }
    }
}

class PrivateCls {

}