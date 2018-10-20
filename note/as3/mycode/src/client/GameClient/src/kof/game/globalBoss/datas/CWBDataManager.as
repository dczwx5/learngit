//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/28.
 * Time: 11:32
 */
package kof.game.globalBoss.datas {

    import QFLib.Foundation;

    import flash.events.Event;
    import flash.events.EventDispatcher;

    import kof.data.CDataTable;
    import kof.data.CDatabaseSystem;

    import kof.data.KOFTableConstants;
    import kof.framework.CAppSystem;
    import kof.game.bag.CBagManager;
    import kof.game.bag.CBagSystem;
    import kof.game.bag.data.CBagData;

    import kof.game.globalBoss.datas.vo.CWBData;
    import kof.game.globalBoss.datas.vo.CWBFightData;
    import kof.game.player.CPlayerManager;
    import kof.game.player.CPlayerSystem;
    import kof.game.player.data.CPlayerData;
    import kof.message.WorldBoss.DrawBossTreasureResponse;
    import kof.message.WorldBoss.JoinWorldBossResponse;
    import kof.message.WorldBoss.QueryWorldBossInfoResponse;
    import kof.message.WorldBoss.QueryWorldBossTreasureInfoResponse;
    import kof.message.WorldBoss.RefreshVirtualPlayerResponse;
    import kof.message.WorldBoss.ReviveResponse;
    import kof.message.WorldBoss.WorldBossInfoResponse;
    import kof.message.WorldBoss.WorldBossInspireResponse;
    import kof.message.WorldBoss.WorldBossRewardInfoResponse;
    import kof.message.WorldBoss.WorldBossStartFightResponse;
    import kof.table.GamePrompt;
    import kof.table.Item;
    import kof.table.VipLevel;
    import kof.table.WorldBossChatContent;
    import kof.table.WorldBossConstant;
    import kof.table.WorldBossRankReward;
    import kof.table.WorldBossRevivePrice;
    import kof.table.WorldBossRewardGold;
    import kof.ui.CUISystem;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/28
     */
    public class CWBDataManager {
        private var _pWBData : CWBData = null;
        private var _pWBFightData : CWBFightData = null;
        private var _eventDispatcher : EventDispatcher = null;
        private var _appSystem : CAppSystem = null;

        public function CWBDataManager( system : CAppSystem ) {
            _pWBData = new CWBData();
            _pWBFightData = new CWBFightData();
            _eventDispatcher = new EventDispatcher();
            this._appSystem = system;
        }

        public function get bCanJoinFight() : Boolean {
            return _pWBData.startFight;
        }

        public function get sLastHighDamageName() : String {
            return _pWBData.name;
        }
        public function get lastFinaLDamagePlayer() : String {
            return _pWBData.lastFinaLDamagePlayer;
        }
        public function get rankRewardedTimes() : int {
            return _pWBData.rankRewardedTimes;
        }

        public function get wbData() : CWBData {
            return _pWBData;
        }

        public function get wbFightData() : CWBFightData {
            return _pWBFightData;
        }

        public function getGoldReward( damageValue : Number ) : Number {
            var pDatabaseSystem : CDatabaseSystem = this._appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var wbRewardTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.WORLD_BOSS_REWARD_GOLD ) as CDataTable;
            var len : int = wbRewardTable.toVector().length;
            var wbRewardTableVec : Vector.<Object> = wbRewardTable.toVector();
            var goldNu : Number = 0;
            var alreadyCompareDamage : Number = 0;
            for ( var i : int = 0; i < len; i++ ) {
                var wordRewardGold : WorldBossRewardGold = wbRewardTableVec[ i ] as WorldBossRewardGold;
                var damage : Number = wordRewardGold.damage;
                goldNu += Math.min( damageValue - alreadyCompareDamage, damage - alreadyCompareDamage ) * wordRewardGold.ratio;
                alreadyCompareDamage = damage;
                if ( damageValue <= alreadyCompareDamage ) {
                    break;
                }
            }
            if ( goldNu > worldBossConstant.maxRewardGold ) {
                goldNu = worldBossConstant.maxRewardGold;
            }
            return int( goldNu );
        }

        private function _worldBossRewardGold( index : int ) : WorldBossRewardGold {
            var pDatabaseSystem : CDatabaseSystem = this._appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var wbRewardTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.WORLD_BOSS_REWARD_GOLD ) as CDataTable;
            return wbRewardTable.findByPrimaryKey( index );
        }

        public function revivePriceForCount( count : int ) : int {
            var pDatabaseSystem : CDatabaseSystem = this._appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var wbRewardTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.WORLD_BOSS_REVIVE_PRICE ) as CDataTable;
            var revivePrice : WorldBossRevivePrice = wbRewardTable.findByPrimaryKey( count ) as WorldBossRevivePrice
            return revivePrice.price;
        }

        public function vipLevelTable() : CDataTable {
            var pDatabaseSystem : CDatabaseSystem = this._appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var wbVipLevelTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.VIP_LEVEL ) as CDataTable;
            return wbVipLevelTable;
        }

        public function vipPrivilegeTable() : CDataTable {
            var pDatabaseSystem : CDatabaseSystem = this._appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var wbVipPrivilegeTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.VIPPRIVILEGE ) as CDataTable;
            return wbVipPrivilegeTable;
        }

        public function getWorldBossRankRewardRewardID() : Number {
            var rank : int = wbData.rank;
            var pDatabaseSystem : CDatabaseSystem = this._appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var wbRankRewardTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.WORLD_BOSS_RANK_REWARD ) as CDataTable;
            var rankRewardVec : Vector.<Object> = wbRankRewardTable.toVector();
            var len : int = rankRewardVec.length;
            for ( var i : int = 0; i < len; i++ ) {
                var wbRandkReward : WorldBossRankReward = rankRewardVec[ i ] as WorldBossRankReward;
                if ( rank >= wbRandkReward.rankMin && rank <= wbRandkReward.rankMax ) {
                    return wbRandkReward.rewardID;
                }
            }
            return rankRewardVec[ i - 1 ].rewardID;
        }

        public function get worldBossConstant() : WorldBossConstant {
            var pDatabaseSystem : CDatabaseSystem = this._appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var wbInstanceTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.WORLD_BOSS_CONSTANT ) as CDataTable;
            return wbInstanceTable.findByPrimaryKey( 1 );
        }

        public function getWorldBossChatContentForState( state : int ) : String {
            var pDatabaseSystem : CDatabaseSystem = this._appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var wbChatContentTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.WORLD_BOSS_CHAT_CONTENT ) as CDataTable;
            var wbChatContent : Vector.<Object> = wbChatContentTable.toVector();
            var targetState : Array = [];
            for ( var i : int = 0; i < wbChatContent.length; i++ ) {
                if ( state == wbChatContent[ i ].state ) {
                    targetState.push( wbChatContent[ i ] );
                }
            }
            var len : int = targetState.length;
            if ( len > 0 ) {
                var index : int = Math.random() * len;
                return targetState[ index ].content;
            }
            return "";
        }

        public function getTreasureBuyPrice( state : int ) : int {
            var pDatabaseSystem : CDatabaseSystem = this._appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var wbInstanceTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.WORLD_BOSS_CONSTANT ) as CDataTable;
            return wbInstanceTable.findByPrimaryKey( state );
        }

        public function getItemForItemID( id : int ) : Item {
            var pDatabaseSystem : CDatabaseSystem = this._appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            var itemTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
            return itemTable.findByPrimaryKey( id );
        }

        public function getItemNuForBag( id : int ) : CBagData {
            return ((this._appSystem.stage.getSystem( CBagSystem ) as CBagSystem).getBean( CBagManager ) as CBagManager).getBagItemByUid( id );
        }

        public function updateRevive( data : ReviveResponse ) : void {
            _pWBFightData.result = data.result;
            _eventDispatcher.dispatchEvent( new Event( "revive" ) );
        }

        public function startFight( data : WorldBossStartFightResponse ) : void {
            _eventDispatcher.dispatchEvent( new Event( "startFight" ) );
        }

        /**世界Boss场内信息*/
        public function updateWorldBossInfo( data : WorldBossInfoResponse ) : void {
            _pWBFightData.bossHP = data.bossHP;
            _pWBFightData.selfData = null;

            var playerManager : CPlayerManager = _appSystem.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            // 移除无排名数据, 找出自己的数据
            var newList:Array = new Array();
            var dataList:Array = data.rank;
            for (var i:int = 0; i < dataList.length; i++) {
                var dataObject:Object = dataList[i];
                if (dataObject["rank"] > 0) {
                    newList[newList.length] = dataObject;
                }
                if (playerData.ID == dataObject["roleId"]) {
                    _pWBFightData.selfData = dataObject;
                }
            }
            // 不需要重新排序
            _pWBFightData.rank = newList;
            _pWBFightData.rankBase = data.rank;

            _eventDispatcher.dispatchEvent( new Event( "UpdateWBInfo" ) );
        }

        //roleId damage name heroId
        private function _compareDamage( a : Object, b : Object ) : int {
            if ( a.damage > b.damage ) {
                return -1;
            } else if ( a.damage < b.damage ) {
                return 1;
            } else {
                return 0;
            }
        }

        /**结算信息*/
        public function updateRewardInfo( data : WorldBossRewardInfoResponse ) : void {
            _pWBData.rank = data.rank;
            _pWBData.damage = data.damage;
            _pWBData.lastDamage = data.lastDamage;
            _eventDispatcher.dispatchEvent( new Event( "WBResult" ) );
        }

        public function updateVirtualPlayer( data : RefreshVirtualPlayerResponse ) : void {

        }

        /**鼓舞次数*/
        public function updateInspire( data : WorldBossInspireResponse ) : void {
//            showGamePrompt(data)
            _pWBData.goldInspireTimes = data.goldInspireTimes;
            _pWBData.diamondInsoireTimes = data.diamondInspireTimes;
            _eventDispatcher.dispatchEvent( new Event( "inspireResponse" ) );
        }

        /**更新世界boss主界面*/
        public function updateOpenView( data : QueryWorldBossInfoResponse ) : void {
            _pWBData.level = data.level;
            _pWBData.name = data.name;
            _pWBData.state = data.state;
            _pWBData.startTime = data.startTime;
            _pWBData.rankRewardedTimes = data.rankRewardedTimes;
            _pWBData.lastFinaLDamagePlayer = data.lastFinaLDamagePlayer;
            _eventDispatcher.dispatchEvent( new Event( "openView" ) );
        }

        /**更新探宝界面信息*/
        public function updateTreasureInfo( data : QueryWorldBossTreasureInfoResponse ) : void {
            _pWBData.remainderTimes = data.remainderTimes;
            _pWBData.alreadyBuyTimes = data.alreadyBuyTimes;
            _pWBData.totalTimes = data.totalTimes;
            _eventDispatcher.dispatchEvent( new Event( "treasureInfo" ) );
        }

        /**更新探宝操作响应数据*/
        public function updateDrawTreasure( data : DrawBossTreasureResponse ) : void {
            _pWBData.index = data.index;
            _eventDispatcher.dispatchEvent( new Event( "drawTreasure" ) );
        }

        /**加入战斗响应数据*/
        public function updateJoinFight( data : JoinWorldBossResponse ) : void {
            _pWBData.startFight = data.startFight;
            _pWBData.startTime = data.startTime;
            _pWBData.goldInspireTimes = data.goldInspireTimes;
            _pWBData.diamondInsoireTimes = data.diamondInsoireTimes;
            _pWBData.diamondReviveTimes = data.diamondReviveTimes;
            _eventDispatcher.dispatchEvent( new Event( "updateJoinFight" ) );
            _eventDispatcher.dispatchEvent( new Event( "inspireResponse" ) );
        }

        public function addEventListener( type : String, callBackFunc : Function ) : void {
            _eventDispatcher.addEventListener( type, callBackFunc );
        }

        public function removeEventListener( type : String, callBackFunc : Function ) : void {
            _eventDispatcher.removeEventListener( type, callBackFunc );
        }

        /**
         * 显示错误提示
         * @param gamePromptID 提示码
         * */
        public function showGamePrompt( gamePromptID : int , responseContent:Array) : void {
            if ( gamePromptID != 0 ) {
                var gamePrompt : GamePrompt = this._gamePromptTable.findByPrimaryKey( gamePromptID ) as GamePrompt;
                if ( gamePrompt ) {
                    var msg : String = _matchMsg(gamePrompt.content,responseContent);
                    (_appSystem.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert( msg );
                } else {
                    Foundation.Log.logErrorMsg( "错误提示表中没有错误码：" + gamePromptID );
                }
            }
        }

        private function _matchMsg(msg:String,param:Array):String{
            for(var i:int=0;i<param.length;i++){
                msg = msg.replace("{"+i+"}",param[i]);
            }
            return msg;
        }

        /**获取错误提示表*/
        private function get _gamePromptTable() : CDataTable {
            var pDatabaseSystem : CDatabaseSystem = this._appSystem.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
            return pDatabaseSystem.getTable( KOFTableConstants.GAME_PROMPT ) as CDataTable;
        }

        /**格式化*/
        private function _format( str : String, ... args ) : String {
            for ( var i : int = 0; i < args.length; i++ ) {
                str = str.replace( new RegExp( "\\{" + i + "\\}", "g" ), args[ i ] );
            }
            return str;
        }

        public function get playerData() : CPlayerData {
            var playerManager : CPlayerManager = _appSystem.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
            var playerData : CPlayerData = playerManager.playerData;
            return playerData;
        }

        /**探宝次数红点*/
        public function judgeTreasureRedPoint() : Boolean {
            if ( _pWBData.remainderTimes > 0 ) {
                return true;
            } else if ( _pWBData.totalTimes >= worldBossConstant.accRewardCount ) {
                return true;
            }
            return false;
        }
    }
}
