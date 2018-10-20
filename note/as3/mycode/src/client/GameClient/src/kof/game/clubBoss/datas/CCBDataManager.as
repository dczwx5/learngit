//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/23.
 * Time: 15:27
 */
package kof.game.clubBoss.datas {

import flash.events.Event;
import flash.events.EventDispatcher;

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.clubBoss.CClubBossSystem;
import kof.game.clubBoss.datas.vo.CCBBossTime;
import kof.game.clubBoss.datas.vo.CCBFight;
import kof.game.clubBoss.datas.vo.CCBMainUIInfo;
import kof.game.clubBoss.datas.vo.CCBRewardResultInfo;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.message.ClubBoss.ClubBossInfoResponse;
import kof.message.ClubBoss.ClubBossReviveResponse;
import kof.message.ClubBoss.ClubBossRewardInfoResponse;
import kof.message.ClubBoss.ClubBossStartFightResponse;
import kof.message.ClubBoss.ClubBossTimeResponse;
import kof.message.ClubBoss.DamageRewardResponse;
import kof.message.ClubBoss.IfGotDamageRewardResponse;
import kof.message.ClubBoss.JoinClubBossResponse;
import kof.message.ClubBoss.QueryClubBossInfoResponse;
import kof.message.ClubBoss.SetClubBossResponse;
import kof.table.ClubBossConstant;
import kof.table.ClubBossRankSingle;
import kof.table.ClubBossRevivePrice;
import kof.table.Item;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/10/23
 */
public class CCBDataManager {
    public var vec_BossInfo : Vector.<CCBMainUIInfo> = null;
    public var recordSelfDamage:Number=0;
    private var _cbFight : CCBFight = null;
    private var _cbBossTime : CCBBossTime = null;
    private var _cbRewardResult : CCBRewardResultInfo = null;
    private var _eventDispatch : EventDispatcher = null;
    private var _system : CClubBossSystem = null;
    //复活原因：0 自动复活，1 钻石复活
    public var revive : int = 0;
    //开战boss id
    public var fightBossId : Number = 0;
    //提示码
    public var promptID : Number = 0;
    //是否可以领取参与奖
    public var canGetRewardArr:Array = [];

    private var _clubBossContant : ClubBossConstant = null;
    private var _clubBossBaseTable:CDataTable = null;

    public function get cbRewardResult():CCBRewardResultInfo{
        return _cbRewardResult;
    }

    public function get cbFightData():CCBFight{
        return _cbFight;
    }

    public function CCBDataManager( sys : CClubBossSystem ) {
        this._system = sys;
        _eventDispatch = new EventDispatcher();
        vec_BossInfo = new <CCBMainUIInfo>[];
        _cbFight = new CCBFight();
        _cbBossTime = new CCBBossTime();
        _cbRewardResult = new CCBRewardResultInfo();

        _initDataTabel();
    }

    public function dispatchEvent( type : String ) : void {
        _eventDispatch.dispatchEvent( new Event( type ) );
    }

    public function addEventListener( type : String, callBackFunc : Function ) : void {
        _eventDispatch.addEventListener( type, callBackFunc );
    }

    public function removeEventListener( type : String, callBackFunc : Function ) : void {
        _eventDispatch.removeEventListener( type, callBackFunc );
    }

    public function setMainUIInfo( obj : QueryClubBossInfoResponse ) : void {
        vec_BossInfo.splice( 0, vec_BossInfo.length );
        var arr : Array = obj.dataList;
        var len : int = arr.length;
        var mainUIInfo : CCBMainUIInfo = null;
        for ( var i : int = 0; i < len; i++ ) {
            mainUIInfo = new CCBMainUIInfo();
            mainUIInfo.decode( arr[ i ] );
            vec_BossInfo.push( mainUIInfo );
        }
    }

    public function setTimeInfo( obj : ClubBossTimeResponse ) : void {
        _cbBossTime.setTime( obj );
    }

    public function setJoinFight( obj : JoinClubBossResponse ) : void {
        _cbFight.setJoinFight( obj );
    }

    public function setBossInFight( obj : ClubBossInfoResponse ) : void {
        _cbFight.setBossInfo( obj );
    }

    public function setRewardResult( obj : ClubBossRewardInfoResponse ) : void {
        _cbRewardResult.setRewardInfo( obj );
    }

    public function setRevive( obj : ClubBossReviveResponse ) : void {
        this.revive = obj.result;
    }

    //领取参与奖励
    public function setDamageReward( obj : DamageRewardResponse ) : void {
        this.promptID = obj.gamePromptID;
    }

    /**
     * 是否领过参与奖
     * {bossId:xx,ifGot:false/true}
     *
     * */
    public function setQueryCanGetReward(obj:IfGotDamageRewardResponse):void{
        canGetRewardArr = obj.dataList;
    }

    //布阵
    public function setClubBoss( obj : SetClubBossResponse ) : void {
        this.promptID = obj.gamePromptID;

    }

    public function setStartFight( obj : ClubBossStartFightResponse ) : void {
        this.fightBossId = obj.id;
    }


    public function getItemNuForBag( id : int ) : CBagData {
        return ((this._system.stage.getSystem( CBagSystem ) as CBagSystem).getBean( CBagManager ) as CBagManager).getBagItemByUid( id );
    }

    public function getItemTableData( itemID : int ) : Item {
        var itemTable : CDataTable;
        var pDatabaseSystem : CDatabaseSystem = _system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        itemTable = pDatabaseSystem.getTable( KOFTableConstants.ITEM ) as CDataTable;
        return itemTable.findByPrimaryKey( itemID );
    }

    public function getItemData( itemID : int ) : CItemData {
        var itemData : CItemData = (_system.stage.getSystem( CItemSystem ) as CItemSystem).getItem( itemID );
        return itemData;
    }

    public function get playerData() : CPlayerData {
        var playerManager : CPlayerManager = _system.stage.getSystem( CPlayerSystem ).getBean( CPlayerManager ) as CPlayerManager;
        var playerData : CPlayerData = playerManager.playerData;
        return playerData;
    }

    public function get clubBossConstant() : ClubBossConstant {
        return _clubBossContant;
    }

    public function get clubBossBaseTabel():CDataTable{
        return _clubBossBaseTable;
    }

    private function _initDataTabel() : void {
        var itemTable : CDataTable;
        var pDatabaseSystem : CDatabaseSystem = _system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        itemTable = pDatabaseSystem.getTable( KOFTableConstants.CLUBBOSSCONSTANT ) as CDataTable;
        _clubBossContant = itemTable.findByPrimaryKey( 1 );
        _clubBossBaseTable = pDatabaseSystem.getTable( KOFTableConstants.CLUBBOSSBASE ) as CDataTable;
    }

    public function revivePriceForCount( count : int ) : int {
        var pDatabaseSystem : CDatabaseSystem = this._system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        var cbReviveTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.CLUBBOSSREVIVEPRICE ) as CDataTable;
        var revivePrice : ClubBossRevivePrice = cbReviveTable.findByPrimaryKey( count ) as ClubBossRevivePrice
        return revivePrice.price;
    }

    public function getCBResultRewardRewardID() : Number {
        var rank : int = _cbRewardResult.rRank;
        var pDatabaseSystem : CDatabaseSystem = this._system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        var wbRankRewardTable : CDataTable = pDatabaseSystem.getTable( KOFTableConstants.CLUBBOSSRANKSINGLE ) as CDataTable;
        var rankRewardVec : Vector.<Object> = wbRankRewardTable.toVector();
        var len : int = rankRewardVec.length;
        for ( var i : int = 0; i < len; i++ ) {
            var wbRandkReward : ClubBossRankSingle = rankRewardVec[ i ] as ClubBossRankSingle;
            if ( rank >= wbRandkReward.rankMin && rank <= wbRandkReward.rankMax ) {
                return wbRandkReward.rewardID;
            }
        }
        return rankRewardVec[ i - 1 ].rewardID;
    }
}
}
