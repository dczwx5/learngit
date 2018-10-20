//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/27.
 * Time: 19:46
 */
package kof.game.currency.qq.data.netData {

    import QFLib.Foundation;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.external.ExternalInterface;

    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;
    import kof.data.KOFTableConstants;
    import kof.framework.CAppSystem;
    import kof.game.KOFSysTags;
    import kof.game.bag.CBagManager;
    import kof.game.bag.CBagSystem;
    import kof.game.bag.data.CBagData;
    import kof.game.currency.CCurrencyEvent;
    import kof.game.currency.qq.data.configData.CQQTableDataManager;
    import kof.game.currency.qq.data.netData.vo.CQQData;
    import kof.game.currency.qq.enums.EQQGiftType;
    import kof.game.item.CItemData;
    import kof.game.item.CItemSystem;
import kof.game.platform.tx.data.CTXData;
import kof.game.platform.tx.enum.ETXIdentityType;
import kof.game.player.CPlayerManager;
    import kof.game.player.CPlayerSystem;
    import kof.game.player.data.CPlayerData;
    import kof.game.player.event.CPlayerEvent;
    import kof.table.Item;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/27
     */
    public class CQQClientDataManager {
        private var _qqdata : CQQData = null;
        private var _system : CAppSystem = null;
        private var _eventDispatch : EventDispatcher = null;

        public function CQQClientDataManager( system : CAppSystem ) {
            this._system = system;
            _qqdata = new CQQData();
            _eventDispatch = new EventDispatcher();
            this._system.addEventListener( CPlayerEvent.PLAYER_DATA_INITIAL, _initQQData );//登录时初始化数据
            this._system.addEventListener(CPlayerEvent.PLAYER_LEVEL_UP, _playerUpChange); //战队升级
        }

        private function _playerUpChange(e:Event):void{
            _eventDispatch.dispatchEvent( new Event( CCurrencyEvent.UPDATE_QQData ) );
        }

        private function _updateGetRewarDStateForPlayerData( e : CPlayerEvent ) : void {
            _eventDispatch.dispatchEvent( new Event( CCurrencyEvent.UPDATE_QQData ) );
        }

        private function _initQQData( e : CPlayerEvent ) : void {
            this._system.removeEventListener( CPlayerEvent.PLAYER_DATA_INITIAL, _initQQData );
            _qqdata.setdata( this.playerData.systemData.channelInfo );
            _eventDispatch.dispatchEvent( new Event( CCurrencyEvent.UPDATE_QQData ) );
        }

        public function addEventListener( type : String, callBackFunc : Function ) : void {
            _eventDispatch.addEventListener( type, callBackFunc );
        }

        public function removeEventListener( type : String, callBackFunc : Function ) : void {
            _eventDispatch.removeEventListener( type, callBackFunc );
        }

        public function get qqData() : CQQData {
            return _qqdata;
        }

        public function update( obj : Object ) : void {
            _qqdata.setdata( obj );
            _eventDispatch.dispatchEvent( new Event( CCurrencyEvent.UPDATE_QQData ) );
        }

        public function getPlayerLevel() : int {
            return this.playerData.teamData.level;
        }

        public function get system() : CAppSystem {
            return _system;
        }

        private function get playerData() : CPlayerData {
            var playerManager : CPlayerManager = _system.getBean( CPlayerManager ) as CPlayerManager;
            var _playerData : CPlayerData = playerManager.playerData;
            return _playerData;
        }


        /**
         * 根据物品ID获取物品表数据
         * @ItemID 物品id
         * @return 返回的物品表数据
         *
         * */
        public function getItemForItemID( itemID : int ) : Item {
            var itemTable : CDataTable;
            var pDatabaseSystem : CDatabaseSystem = this._system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            itemTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
            return itemTable.findByPrimaryKey( itemID );
        }

        /**获取背包中的物品数量*/
        public final function getItemNuForBag( itemID : int ) : int {
            var bagData : CBagData = (this._system.stage.getSystem( CBagSystem ).getBean( CBagManager ) as CBagManager).getBagItemByUid( itemID );
            if ( bagData ) {
                return bagData.num;
            } else {
                return 0;
            }
        }

        /**根据itemID获取itemdata*/
        public final function getItemDataForItemID( itemID : int ) : CItemData {
            var itemData : CItemData = (this._system.stage.getSystem( CItemSystem ) as CItemSystem).getItem( itemID );
            return itemData;
        }

        /**
         * @param type 1 蓝钻 2黄钻 3 年费蓝钻 4 年费黄钻
         * */
        public function navigateToQQRecharge( type : int ) : void {
            if ( ExternalInterface.available ) {
                try {
                    ExternalInterface.call( "createPlatformVIP", type );
                } catch ( e : Error ) {
                    Foundation.Log.logErrorMsg( "Create platform VIP error caught: " + e.message );
                }
            }
        }
        /**跳转到蓝钻官网*/
        public function navigateToGuanWang() : void {
            if ( ExternalInterface.available ) {
                try {
                    ExternalInterface.call( "navigateToBlueVipDetails" );
                } catch ( e : Error ) {
                    Foundation.Log.logErrorMsg( "Create platform VIP error caught: " + e.message );
                }
            }
        }

        /**
         * @param
         * */
        public function hasGetReward( systags : String ) : Boolean {
            var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            var txData:CTXData = pPlayerSystem.platform.txData;
            if (!txData) {
                return false;
            }

            var identity : int = txData.getQQIdentity();
            var lvPrivilegeArr : Array = [];
            var playerLv : int = (_system.stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData.teamData.level;
            var alreadyCompareLv : int = 0;

            if ( systags == KOFSysTags.QQ_BLUE_DIAMOND && (identity == ETXIdentityType.BLUE || identity == ETXIdentityType.BLUE_YEAR
                    || identity == ETXIdentityType.SUPER_BLUE || identity == ETXIdentityType.SUPER_BLUE_YEAR ) ) {
                if ( !_qqdata.blue.blueFreshGift ) {
                    return true;
                }
                if ( txData.isSuperBlueYearVip) {
                    if ( _qqdata.blue.blueDailyGift.indexOf( false ) != -1 ) {
                        return true;
                    }
                }else if(txData.isBlueYearVip){
                    if ( _qqdata.blue.blueDailyGift[ 0 ] == false || _qqdata.blue.blueDailyGift[ 2 ] == false ) {
                        return true;
                    }
                } else if ( txData.isSuperBlueVip ) {
                    if ( _qqdata.blue.blueDailyGift[ 0 ] == false || _qqdata.blue.blueDailyGift[ 1 ] == false ) {
                        return true;
                    }
                } else if ( txData.isBlueVip ) {
                    if ( _qqdata.blue.blueDailyGift[ 0 ] == false ) {
                        return true;
                    }
                }

                lvPrivilegeArr = CQQTableDataManager.instance.getTencentLevelPrivilege( EQQGiftType.BLUE_DIAMOND );
                alreadyCompareLv = 0;
                for ( var i : int = 0; i < lvPrivilegeArr.length; i++ ) {
                    if ( lvPrivilegeArr[ i ].level ) {
                        var lv : int = Math.min( playerLv, lvPrivilegeArr[ i ].level );
                        if ( _qqdata.blue.blueLevelGift.indexOf( lv ) == -1 ) {
                            if ( playerLv < lv ) {
                                return false;
                            }
                        }
                        else {
                            continue;
                        }
                        alreadyCompareLv = lvPrivilegeArr[ i ].level;
                        if ( alreadyCompareLv > playerLv ) {
                            return false;
                        } else {
                            return true;
                        }
                    }
                }
            }
            else if ( systags == KOFSysTags.QQ_YELLOW_DIAMOND && (identity == ETXIdentityType.YELLOW || identity == ETXIdentityType.YELLOW_YEAR ) ) {
                if ( !_qqdata.yellow.yellowFreshGift ) {
                    return true;
                }
                if ( txData.isYellowYearVip ) {
                    if ( _qqdata.yellow.yellowDailyGift.indexOf( false ) != -1 ) {
                        return true;
                    }
                } else if ( txData.isYellowVip ) {
                    if ( _qqdata.yellow.yellowDailyGift[ 0 ] != false ) {
                        return true;
                    }
                }

                lvPrivilegeArr = CQQTableDataManager.instance.getTencentLevelPrivilege( EQQGiftType.YELLOW_DIAMOND );
                alreadyCompareLv = 0;
                for ( var j : int = 0; j < lvPrivilegeArr.length; j++ ) {
                    if ( lvPrivilegeArr[ j ].level ) {
                        var ylv : int = Math.min( playerLv, lvPrivilegeArr[ j ].level );
                        if ( _qqdata.yellow.yellowLevelGift.indexOf( ylv ) == -1 ) {
                            if ( playerLv < ylv ) {
                                return false;
                            }
                        } else {
                            continue;
                        }
                        alreadyCompareLv = lvPrivilegeArr[ j ].level;
                        if ( alreadyCompareLv > playerLv ) {
                            return false;
                        } else {
                            return true;
                        }
                    }
                }
            } else if ( systags == KOFSysTags.QQ_HALL ) {
                if ( !_qqdata.lobby.lobbyFreshGift ) {
                    return true;
                }

                if ( !_qqdata.lobby.lobbyDailyGift ) {
                    return true;
                }

                lvPrivilegeArr = CQQTableDataManager.instance.getTencentLevelPrivilege( EQQGiftType.YELLOW_DIAMOND );
                alreadyCompareLv = 0;
                for ( var k : int = 0; k < lvPrivilegeArr.length; k++ ) {
                    if ( lvPrivilegeArr[ k ].level ) {
                        var hlv : int = Math.min( playerLv, lvPrivilegeArr[ k ].level );
                        if ( _qqdata.lobby.lobbyLevelGift.indexOf( hlv ) == -1 ) {
                            if ( playerLv < hlv ) {
                                return false;
                            }
                        } else {
                            continue;
                        }
                        alreadyCompareLv = lvPrivilegeArr[ k ].level;
                        if ( alreadyCompareLv > playerLv ) {
                            return false;
                        } else {
                            return true;
                        }
                    }
                }
            }
            return false;
        }
    }
}