//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/25.
 */
package kof.game.club {

import QFLib.Foundation.CTime;
import QFLib.Interface.IUpdatable;

import flash.utils.Dictionary;

import kof.SYSTEM_ID;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.club.data.CClubApplyData;
import kof.game.club.data.CClubBagRecordData;
import kof.game.club.data.CClubConst;
import kof.game.club.data.CClubFundData;
import kof.game.club.data.CClubInfoData;
import kof.game.club.data.CClubMemberData;
import kof.game.club.data.CClubSendBagRankData;
import kof.game.club.data.CClubWelfareBagData;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.message.Club.ApplyClubResponse;
import kof.message.Club.ClubInfoResponse;
import kof.message.Club.ClubRankListResponse;
import kof.message.Club.LuckyBagInfoListResponse;
import kof.message.Club.OpenClubResponse;
import kof.message.Club.RechargeLuckyBagResponse;
import kof.table.ClubUpgradeBasic;
import kof.table.LuckyBagConfig;
import kof.table.SpecialReward;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;

public class CClubManager extends CAbstractHandler implements IUpdatable{

    public var needShowClubView : Boolean;//是否在打开俱乐部的时候弹出俱乐部大厅

    public var clubID : String = '';

    public var clubLevel : int;

    public var clubName : String = '';

    public var clubList : Array;//不是全部的俱乐部列表数据，只是当前页的

    public var clubListNum : int;//全部的俱乐部数量

    public var curClubListPage : int;//当前俱乐部列表页码

    public var totalClubListPages : int;//俱乐部的总页数

    public var clubRankListNum : int;//全部的俱乐部排行榜数量

    public var curClubRankListPage : int;//当前俱乐部排行榜页码

    public var totalClubRankListPages : int;//俱乐部排行榜的总页数

    public var clubState : int; //是否加入公会状态 0未加入俱乐部 1，已加入俱乐部

    public var clubPosition : int ; //职位

    public var selfClubData : CClubInfoData;//俱乐部基本信息

    public var selfClubMemBerList : Array;//俱乐部成员列表

    public var selfClubApplyList : Array;//俱乐部申请信息

    public var getClubRewardSign : Boolean;//是否领取俱乐部管理福利

    public var selfClubFundData : CClubFundData;//俱乐部基金信息

    public var systemWelfareBagAry : Array;//系统福袋列表

    public var userWelfareBagAry : Array;//玩家福袋列表

    public var systemBagLogList : Array;//系统福袋日志列表（可能是金币，钻石，道具其中的一种 ）

    public var singleUserBagLogList : Array;//玩家发的单个福袋记录

    public var userSendBagRankList : Array;//玩家发福袋排行记录（可能是金币，钻石，道具其中的一种 ）

    public var sendBagCounts : int;//已发福袋次数

    public var getUserBagCounts : int;//已抢玩家福袋次数

    public var nextJoinClubTime : Number;//下次加入俱乐部的时间，CD

    public var nextInviteTime : Number;//下次发布邀请的时间，CD

    public var playerLuckyBagState : int;//玩家福袋可抢状态 0无 1有

    public var showClubGameViewFlg : Boolean;

    public var isOpenClub : Boolean;//是否需要打开俱乐部大厅的标志

    public var rechargeLuckyBagAry : Array;//充值福袋信息

    private var _pBasicTable : IDataTable;
    private var _dimondInvestCount : int;//至尊投资次数
    private var _checkWelBagState : Boolean;//俱乐部定时福袋
    public function get isInClub():Boolean{
        if( clubID == '')
                return false;
        return true;
    }
    public function CClubManager() {
        super();

        clubList = [];
        selfClubMemBerList = [];
        selfClubApplyList = [];
        systemWelfareBagAry = [];
        userSendBagRankList = [];
        userWelfareBagAry = [];
        systemBagLogList = [];
        singleUserBagLogList = [];
        rechargeLuckyBagAry = [];
    }
    protected override function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        _pBasicTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBUPGRADEBASIC );
        return ret;
    }
    public function update(delta:Number) : void {

    }
   //////////////俱乐部列表 （未加入俱乐部） ///////////////////////////////////////////////////////////////////
    public function updateClubOpenInfo( response:OpenClubResponse ):void{
        clubState = response.type;
        clubPosition = response.position;
        clubListNum = response.clubNum;
        getClubRewardSign = response.getClubRewardSign;
        if( clubState == CClubConst.NOT_IN_CLUB ){
            updateClubList( response.clubDataMap );
            curClubListPage = 1;
            totalClubListPages = Math.ceil( clubListNum / 5 );
            nextJoinClubTime = response.nextJoinClubTime ;
        }else if( clubState == CClubConst.IN_CLUB  ){
            updateClubInfoData( response.clubDate );
        }
    }
    //////////////俱乐部排行榜列表 （已加入俱乐部） ///////////////////////////////////////////////////////////////////
    public function updateClubListInfo( pages : int ,clubNum : int,  dataMap: Array ):void{
        curClubListPage = pages;
        clubListNum = clubNum;
        totalClubListPages = Math.ceil( clubListNum / 5 );
        updateClubList( dataMap );
    }
    public function updateClubRankListInfo( pages : int ,clubNum : int,  dataMap: Array ):void{
        curClubRankListPage = pages;
        clubRankListNum = clubNum;
        totalClubRankListPages = Math.ceil( clubRankListNum / 6 );
        updateClubList( dataMap );
    }
    public function updateClubList( clubDataMap : Array ):void{
        clubList.splice( 0 , clubList.length );
        for each (var data:Object in clubDataMap ){
            updateClubListItemDataToDic(data);
        }
    }
    private function updateClubListItemDataToDic(data:Object):void{
        if( !data[CClubInfoData._id])
                return;
        var pClubListItemData:CClubInfoData = getClubListItemDataByID(data[CClubInfoData._id]);
        if( !pClubListItemData ){
            pClubListItemData = new CClubInfoData(system);
            clubList.push( pClubListItemData );
        }
        pClubListItemData.updateDataByData(data);
    }
    public function getClubListItemDataByID(id:String):CClubInfoData{
        var pClubListItemData : CClubInfoData;
        for each( pClubListItemData in clubList ){
            if( pClubListItemData.id == id ){
                return pClubListItemData;
                break;
            }
        }
        return  null;
    }

    /////////////俱乐部信息（已加入俱乐部）//////////////////////////////////////////////////////////////
    public function updateClubInfo( response:ClubInfoResponse ):void{
         switch ( response.infoType ){
             case 0 :{
                 updateClubInfoData( response.clubInfoMap );
                 break;
             }
             case 1 :{
                 updateMemberListData( response.clubInfoMap.playerInfoList );
                 break;
             }
             case 2 :{
                 updateClubApplyData( response.clubInfoMap.applicationList );
                 break;
             }
         }
    }
    //基本信息
    public function updateClubInfoData( data : Object ):void{
        if( !selfClubData )
            selfClubData = new CClubInfoData(system);
        selfClubData.updateDataByData( data );
        updateClubLog( selfClubData.logList );

        clubID  = selfClubData.id;
        clubLevel  = selfClubData.level;
        clubName  = selfClubData.name;
        nextInviteTime  = selfClubData.nextInviteTime;
    }
    //成员信息
    public function updateMemberListData( playerInfoList : Array ):void{
        selfClubMemBerList.splice( 0 , selfClubMemBerList.length );
        for each (var data:Object in playerInfoList ){
            updateMemberListItemDataToDic( data );
        }
        selfClubMemBerList.sort( sortMember );
    }

    private function sortMember(a:CClubMemberData,b:CClubMemberData):int{
        if( a.position > b.position ){
            return -1;
        }else if(a.position < b.position){
            return 1;
        }else{
            if( a.lastOutLineTime < 0 &&  b.lastOutLineTime > 0 ){
                return -1;
            }else if( a.lastOutLineTime > 0 &&  b.lastOutLineTime < 0 ){
                return 1;
            }else{
                if( a.lastOutLineTime > b.lastOutLineTime ){
                    return -1;
                }else if(a.lastOutLineTime< b.lastOutLineTime){
                    return 1;
                }else{
                    return 0;
                }
            }
        }
    }

    private function updateMemberListItemDataToDic(data:Object):void{
        var pClubMemberData:CClubMemberData = getClubMemberDataByID(data[CClubMemberData._roleID]);
        if( !pClubMemberData ){
            pClubMemberData = new CClubMemberData();
            selfClubMemBerList.push( pClubMemberData );
        }
        pClubMemberData.updateDataByData(data);
        if( pClubMemberData.roleID == _playerData.ID ){
            clubPosition = pClubMemberData.position;
        }
    }

    public function getClubMemberDataByID(roleID:int):CClubMemberData{
        var pClubMemberData : CClubMemberData;
        for each( pClubMemberData in selfClubMemBerList ){
            if( pClubMemberData.roleID == roleID ){
                return pClubMemberData;
                break;
            }
        }
        return  null;
    }
    //申请信息
    public function updateClubApplyData( applicationList : Array ):void{
        selfClubApplyList.splice( 0 , selfClubApplyList.length );
        for each (var data:Object in applicationList ){
            updateApplyListItemDataToDic( data );
        }
    }
    private function updateApplyListItemDataToDic(data:Object):void{
        var pClubApplyData:CClubApplyData = getClubApplyDataByID(data[CClubApplyData._roleID]);
        if( !pClubApplyData ){
            pClubApplyData = new CClubApplyData();
            selfClubApplyList.push( pClubApplyData );
        }
        pClubApplyData.updateDataByData(data);
    }

    public function getClubApplyDataByID(roleID:int):CClubApplyData{
        var pClubApplyData : CClubApplyData;
        for each( pClubApplyData in selfClubApplyList ){
            if( pClubApplyData.roleID == roleID ){
                return pClubApplyData;
                break;
            }
        }
        return  null;
    }


    public function updateApplyInfo( response : ApplyClubResponse ):void{
        if( response.joinSign == CClubConst.NOT_IN_CLUB ){
            if( response.clubInfoMap && response.clubInfoMap.name )
                _pCUISystem.showMsgAlert('您已成功向俱乐部' + response.clubInfoMap.name  + '发送申请' ,CMsgAlertHandler.NORMAL);
            updateClubListItemDataToDic( response.clubInfoMap );
            system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_APPLY_SUCC_AND_WAITING ));

        }else if(  response.joinSign == CClubConst.IN_CLUB ){
            system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_APPLY_SUCC_AND_IN ));
            var str : String = '您已成功加入俱乐部' + response.clubInfoMap.name;
            _pCUISystem.showMsgBox( str,okFun);
            function okFun():void{
                var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
                var bundle : ISystemBundle =  bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.GUILD));
                bundleCtx.setUserData( bundle, CBundleSystem.ACTIVATED, true );
            }

        }
    }

    //公会日志
    private var _logDic : Dictionary;
    public function updateClubLog( logList : Array ):void{
        _logDic = null;
        _logDic = new Dictionary();
        logList.sortOn( 'createTime',Array.DESCENDING|Array.NUMERIC );
        var logObj : Object;
        var date : Date;
        var logDicAry : Array = [];
        for each( logObj in logList ){
            date = new Date( logObj.createTime );
            if( !_logDic[date.month + '' + date.date]){
                _logDic[date.month + '' + date.date] = [];
                logDicAry.push(  _logDic[date.month + '' + date.date] );
            }
            _logDic[date.month + '' + date.date ].push( logObj );
        }

        system.dispatchEvent( new CClubEvent( CClubEvent.CLUB_LOG_RESPONSE ,logDicAry ));
    }

    public function get logDic() : Dictionary {
        return _logDic;
    }



    /////////////////////////////俱乐部基金//////////////////////////////////////////////

    public function updateClubFundData( clubFundMap:Object ):void{
        if( !selfClubFundData )
            selfClubFundData = new CClubFundData();
        selfClubFundData.updateDataByData( clubFundMap );
        if( selfClubData ){
            selfClubData.level = selfClubFundData.level;
            clubLevel  = selfClubData.level;
        }

    }




    ////////////////////俱乐部福袋///////////////////////////////////////////////////////

    //福袋
    public function updateBagList( response:LuckyBagInfoListResponse ):void{
        var data:Object;
        if( response.type == CClubConst.CLUB_BAG_LIST ){
            systemWelfareBagAry.splice( 0 , systemWelfareBagAry.length );
            checkWelBagState = false;
            for each ( data in response.luckBagList ){
                if(data.luckyBagState == CClubConst.CLUB_BAG_CAN_GET)//说明有可领取的定时福袋
                {
                    checkWelBagState = true;
                }
                updateSystemBagListItemDataToDic( data );
            }
        }else if( response.type == CClubConst.USER_BAG_LIST || response.type == CClubConst.RECHARGE_BAG_LIST){
            userWelfareBagAry.splice( 0 , userWelfareBagAry.length );
            for each ( data in response.luckBagList ){
                updateUserBagListItemDataToDic( data );
            }
        }
    }

    public function updateSystemBagListItemDataToDic(data:Object):void{
        var pClubWelfareBagData : CClubWelfareBagData = getClubSystemBagDataByID(data[CClubWelfareBagData._ID]);
        if( !pClubWelfareBagData ){
            pClubWelfareBagData = new CClubWelfareBagData();
            systemWelfareBagAry.push( pClubWelfareBagData );
        }
        pClubWelfareBagData.updateDataByData(data);
    }

    public function getClubSystemBagDataByID(ID:String):CClubWelfareBagData{
        var pClubWelfareBagData : CClubWelfareBagData;
        for each( pClubWelfareBagData in systemWelfareBagAry ){
            if( pClubWelfareBagData.ID == ID ){
                return pClubWelfareBagData;
                break;
            }
        }
        return  null;
    }
    public function getClubSystemBagDataByType( type:int ):CClubWelfareBagData{
        var pClubWelfareBagData : CClubWelfareBagData;
        for each( pClubWelfareBagData in systemWelfareBagAry ){
            if( pClubWelfareBagData.itemType == type ){
                return pClubWelfareBagData;
                break;
            }
        }
        return  null;
    }
    public function updateUserBagListItemDataToDic(data:Object):void{
        var pClubWelfareBagData : CClubWelfareBagData = getClubUserBagDataByID(data[CClubWelfareBagData._ID]);
        if( !pClubWelfareBagData ){
            pClubWelfareBagData = new CClubWelfareBagData();
            userWelfareBagAry.push( pClubWelfareBagData );
        }
        pClubWelfareBagData.updateDataByData(data);
    }

    public function getClubUserBagDataByID(ID:String):CClubWelfareBagData{
        var pClubWelfareBagData : CClubWelfareBagData;
        for each( pClubWelfareBagData in userWelfareBagAry ){
            if( pClubWelfareBagData.ID == ID ){
                return pClubWelfareBagData;
                break;
            }
        }
        return  null;
    }

    //系统福袋日志 可能是金币，钻石，道具其中的一种
    public function updateSystemBagLogList( list:Array ):void{
        systemBagLogList.splice( 0 , systemBagLogList.length );
            for each (var data:Object in list ){
                updateSystemBagLogListItemDataToDic( data );
            }
    }

    public function updateSystemBagLogListItemDataToDic(data:Object):void{
        var pClubBagRecordData : CClubBagRecordData = new CClubBagRecordData();
        systemBagLogList.push( pClubBagRecordData );
        pClubBagRecordData.updateDataByData(data);
    }
    //玩家发的单个福袋记录
    public function updatesingleUserBagLogList( list:Array ):void{
        singleUserBagLogList.splice( 0 , singleUserBagLogList.length );
            for each (var data:Object in list ){
                singleUserBagLogListItemDataToDic( data );
            }
    }

    public function singleUserBagLogListItemDataToDic(data:Object):void{
        var pClubBagRecordData : CClubBagRecordData = new CClubBagRecordData();
        singleUserBagLogList.push( pClubBagRecordData );
        pClubBagRecordData.updateDataByData(data);
    }

    //发福袋排行
    public function updateUserSendBagRankList( list:Array ):void{
        userSendBagRankList.splice( 0 , userSendBagRankList.length );
        for each (var data:Object in list ){
            updateUserSendBagRankListItemDataToDic( data );
        }
        userSendBagRankList.sortOn(["totalValue","totalCounts"], [Array.NUMERIC|Array.DESCENDING, Array.NUMERIC|Array.DESCENDING]);
    }
    public function updateUserSendBagRankListItemDataToDic(data:Object):void{
        var pClubSendBagRankData : CClubSendBagRankData = new CClubSendBagRankData();
        userSendBagRankList.push( pClubSendBagRankData );
        pClubSendBagRankData.updateDataByData(data);
    }

    //手气记录
    private var _bagLogDic : Dictionary;
    public function updateSelfBagLog( logList : Array ):void{
        _bagLogDic = null;
        _bagLogDic = new Dictionary();
        logList.sortOn( 'time',Array.DESCENDING|Array.NUMERIC );
        var logObj : Object;
        var date : Date;
        var logDicAry : Array = [];
        for each( logObj in logList ){
            date = new Date( logObj.time );
            if( !_bagLogDic[date.month + '' + date.date]){
                _bagLogDic[date.month + '' + date.date] = [];
                logDicAry.push( _bagLogDic[date.month + '' + date.date] );
            }
            _bagLogDic[date.month + '' + date.date ].push( logObj );
        }

        system.dispatchEvent( new CClubEvent( CClubEvent.PLAYER_LUCKY_BAG_RECORD_RESPONSE, logDicAry ) );

    }
    public function get bagLogDic() : Dictionary {
        return _bagLogDic;
    }

    ////////////////////////俱乐部小玩法////////////////////

    public var oldLatticeNumber : Array = [];
    public var latticeNumber : Array = [];

    public var totalBuyResetCounts : int;//花钱改转总次数次数
    public var buyResetCounts : int;//花钱计数
    public var playGameCounts : int;//转一转次数
    public var resetCounts : int;//重新改转次数
    public var bestPlayerName : String = '';
    public var maxBestPlayCounts : int ;
    public var skipAnimationSetting : int ;


    public function get isBestGameResult():Boolean{
        var isBest : Boolean = true;
        for( var index : int = 0 ; index < latticeNumber.length ; index ++ ){
            if(  int( latticeNumber[index]) != 6 ){
                isBest = false;
                break;
            }
        }
        return isBest;
    }
    public function get bestGameResultNum():int{
        var num : int;
        for( var index : int = 0 ; index < latticeNumber.length ; index ++ ){
            if(  int( latticeNumber[index]) == 6 ){
                num++;
            }
        }
        return num;
    }

    public function getSpecialRewardByNum( imgCounts : int ):SpecialReward{
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.SPECIALREWARD );
        var totalAry : Array = pTable.toArray();
        var specialReward : SpecialReward ;
        for each( specialReward in totalAry ){
            if( specialReward.imgCounts == imgCounts ){
                return specialReward;
            }
        }
        return null;
    }










    ///////////////////table////////////////////////////////////////////////////////

    public function getUserBagListByType( type : int ):Array{
        var ary : Array = [];
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.LUCKYBAGCONFIG );
        var totalAry : Array = pTable.toArray();
        var luckyBagConfig : LuckyBagConfig ;
        for each( luckyBagConfig in totalAry ){
            if( luckyBagConfig.type == CClubConst.USER_BAG_LIST && luckyBagConfig.subtype == type ){
                ary.push( luckyBagConfig );
            }
        }

        return ary;
    }

    public function getClubUpgradeBasicByLevel(lvl : int) : ClubUpgradeBasic
    {
        var result : ClubUpgradeBasic = _pBasicTable.findByPrimaryKey( lvl );
        return result;
    }

    public function set dimondInvestCount(value : int) : void
    {
        _dimondInvestCount = value;
    }
    public function get dimondInvestCount() : int
    {
        return _dimondInvestCount;
    }
    ///////////////////////////////////////////////////////////////////////////
    /**
     * 代码补充，俱乐部定时福袋序号
     */
    public function get clubWelBagIndex() : int
    {
        //修正通过时间获取索引的bug，测试通过登录在线然后改时间会导致在可领取的时间段
        //的索引和时间不一致，所以在可领奖时优先通过奖励id来自动选择索引而非时间
        //================add by Lune 0720===========================================
        if(checkWelBagState)
        {
            var pClubWelfareBagData : CClubWelfareBagData;
            for each( pClubWelfareBagData in systemWelfareBagAry ){
                if( pClubWelfareBagData.luckyBagState == CClubConst.CLUB_BAG_CAN_GET ){
                    return pClubWelfareBagData.configID;
                }
            }
            return 1;
        }
        else
        {
            var _selectedIndex : int;
            var date : Date = new Date( CTime.getCurrServerTimestamp() );
            if( date.hours == 10 && date.minutes >= 0 && date.minutes <= 59 ){
                _selectedIndex  = 1;
            }else if( date.hours == 13 && date.minutes >= 0 && date.minutes <= 59 ){
                _selectedIndex  = 2;
            }else if( date.hours >= 20 && date.hours <= 21 && date.minutes >= 0 && date.minutes <= 59 ){
                _selectedIndex  = 3;
            }
            return _selectedIndex;
        }

    }

    /**
     * 是否有可领俱乐部定时福袋
     */
    public function set checkWelBagState(value : Boolean) : void
    {
        _checkWelBagState = value;
    }
    public function get checkWelBagState() : Boolean
    {
        return _checkWelBagState;
    }


    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }


}
}
