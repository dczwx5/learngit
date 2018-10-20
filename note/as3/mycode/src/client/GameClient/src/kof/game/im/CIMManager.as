//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/2.
 */
package kof.game.im {

import QFLib.Interface.IUpdatable;

import flash.utils.Dictionary;

import kof.framework.CAbstractHandler;
import kof.framework.IDatabase;
import kof.game.currency.qq.data.netData.CQQClientDataManager;
import kof.game.im.data.CIMApplyData;
import kof.game.im.data.CIMChatData;
import kof.game.im.data.CIMConst;
import kof.game.im.data.CIMFriendsData;
import kof.game.im.data.CIMRecommendData;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.platform.tx.data.CTXData;
import kof.game.player.CPlayerSystem;
import kof.message.Friend.DealApplicationResponse;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;

public class CIMManager extends CAbstractHandler implements IUpdatable {

    private var _typeDic:Dictionary;

    public var getPhysicalStrengthCount : int //当天已领取体力次数

    private var _chatDic : Dictionary;

    private var _chatNewDic : Dictionary;

    public var curChatFriendsAry : Array ;

    public var newNotReadFriendsAry : Array ;//新消息未读的好友列表

    public var firstShowChatFriendID : int ;//展示的聊天好友

    public var searchFriendsAry : Array ;

    public var new_streng_notice_b : Boolean;//体力领取新提示

    public var new_apply_notice_b : Boolean;//好友申请新提示


    public function CIMManager() {
        super();
        _typeDic = new Dictionary();
        _typeDic[CIMConst.FRIENDS] = [];
        _typeDic[CIMConst.APPLY] = [];
        _typeDic[CIMConst.RECOMMEND] = [];
        _chatDic = new Dictionary();
        _chatNewDic = new Dictionary();
        curChatFriendsAry = [];
        newNotReadFriendsAry = [];
        searchFriendsAry = [];
    }
    public function update(delta:Number) : void {

    }
    public override function dispose() : void {
        super.dispose();
    }
    protected override function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        return ret;
    }

    // ====================================好友=================================================

    public function resetFriendsData():void{
        var ary : Array = _typeDic[ CIMConst.FRIENDS ];
        ary.splice( 0 , ary.length );
    }
    public function updateFriendsData(friendInfoList:Array) : void {
        for each (var data:Object in friendInfoList ){
            updateFriendsDataToDic(data);
        }
    }

    private function updateFriendsDataToDic(data:Object):void{
        var pCIMFriendsData:CIMFriendsData = getFriendsDataByID(data[CIMFriendsData._roleID]);
        if( !pCIMFriendsData ){
            pCIMFriendsData = new CIMFriendsData();
            pCIMFriendsData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
            _typeDic[CIMConst.FRIENDS ].push(pCIMFriendsData);
        }
        pCIMFriendsData.updateDataByData(data);
    }

    public function getFriendsDataByID(roleID:int):CIMFriendsData{
        var pCIMFriendsData : CIMFriendsData;
        var dataAry : Array = getListDataByType( CIMConst.FRIENDS );
        for each( pCIMFriendsData in dataAry ){
            if( pCIMFriendsData.roleID == roleID ){
                return pCIMFriendsData;
                break;
            }
        }
        return  null;
    }
    public function deleteFriendsData(friendInfoList:Array) : void {
        for each (var data:Object in friendInfoList ){
            var pCIMFriendsData:CIMFriendsData = getFriendsDataByID(data[CIMFriendsData._roleID]);
            if( !pCIMFriendsData )
                return;
            var dataAry : Array = getListDataByType( CIMConst.FRIENDS );
            dataAry.splice( dataAry.indexOf( pCIMFriendsData ), 1 );
            _pCUISystem.showMsgAlert( '已删除好友' + pCIMFriendsData.name , CMsgAlertHandler.NORMAL );
        }
    }

    public function getFriendsNum():int{
        return  (getListDataByType( CIMConst.FRIENDS ) as Array).length;
    }
    public function getOnlineFriendsNum():int{
        var num : int;
        var pCIMFriendsData : CIMFriendsData;
        var dataAry : Array = getListDataByType( CIMConst.FRIENDS );
        for each( pCIMFriendsData in dataAry ){
            if( pCIMFriendsData.isOnline == CIMConst.ONLINE ){
                num ++;
            }
        }
        return  num;
    }

    // ====================================申请=================================================

    public function resetApplyData():void{
        var ary : Array = _typeDic[ CIMConst.APPLY ];
        ary.splice( 0 , ary.length );
    }
    public function updateApplyData(friendInfoList:Array) : void {
        for each (var data:Object in friendInfoList ){
            updateApplyDataToDic(data);
        }
    }

    private function updateApplyDataToDic(data:Object):void{
        var pCIMApplyData:CIMApplyData = getApplyDataByID(data[CIMApplyData._roleID]);
        if( !pCIMApplyData ){
            pCIMApplyData = new CIMApplyData();
            pCIMApplyData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
            _typeDic[CIMConst.APPLY ].push(pCIMApplyData);
        }
        pCIMApplyData.updateDataByData(data);
    }

    public function getApplyDataByID(roleID:int):CIMApplyData{
        var pCIMApplyData : CIMApplyData;
        var dataAry : Array = getListDataByType( CIMConst.APPLY );
        for each( pCIMApplyData in dataAry ){
            if( pCIMApplyData.roleID == roleID ){
                return pCIMApplyData;
                break;
            }
        }
        return  null;
    }
    //处理 同意或拒绝好友申请响应
    public function updateApplyResponseData( response:DealApplicationResponse ) : void {
        var friendInfoList : Array = response.dataMap.friendInfoList;
        var applyList : Array = getListDataByType( CIMConst.APPLY );
        for each (var data:Object in friendInfoList ){
            var pCIMApplyData:CIMApplyData = getApplyDataByID( data[CIMApplyData._roleID] );
            if( pCIMApplyData ){
                applyList.splice( applyList.indexOf( pCIMApplyData ), 1 );
                if( response.dealType == CIMConst.AGREE )
                    _pCUISystem.showMsgAlert( '您同意了' + pCIMApplyData.name + '的好友申请', CMsgAlertHandler.NORMAL );
                else if( response.dealType == CIMConst.REFUSE )
                    _pCUISystem.showMsgAlert( '您拒绝了' + pCIMApplyData.name + '的好友申请', CMsgAlertHandler.NORMAL );
            }
        }
    }

    // ====================================推荐=================================================

    public function resetRecommendData():void{
        var ary : Array = _typeDic[ CIMConst.RECOMMEND ];
        ary.splice( 0 , ary.length );
    }

    public function initRecommendData(friendInfoList:Array) : void {
        for each (var data:Object in friendInfoList ){
            initRecommendDataToDic(data);
        }
    }

    private function initRecommendDataToDic(data:Object):void{
        var pCIMRecommendData:CIMRecommendData = getRecommendDataByID(data[CIMRecommendData._roleID]);
        if( !pCIMRecommendData ){
            pCIMRecommendData = new CIMRecommendData();
            pCIMRecommendData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
            _typeDic[CIMConst.RECOMMEND ].push(pCIMRecommendData);
        }
        pCIMRecommendData.updateDataByData(data);
    }


    public function updateRecommendData(friendInfoList:Array) : void {
        for each (var data:Object in friendInfoList ){
            updateRecommendDataToDic(data);
        }
    }

    private function updateRecommendDataToDic(data:Object):void{
        var pCIMRecommendData:CIMRecommendData = getRecommendDataByID(data[CIMRecommendData._roleID]);
        if( pCIMRecommendData ){
            pCIMRecommendData.updateDataByData(data);
        }
        _pCUISystem.showMsgAlert('已向' + data[CIMRecommendData._name] + '发送添加好友请求',CMsgAlertHandler.NORMAL);
    }



    public function getRecommendDataByID(roleID:int):CIMRecommendData{
        var pCIMRecommendData : CIMRecommendData;
        var dataAry : Array = getListDataByType( CIMConst.RECOMMEND );
        for each( pCIMRecommendData in dataAry ){
            if( pCIMRecommendData.roleID == roleID ){
                return pCIMRecommendData;
                break;
            }
        }
        return  null;
    }
// ====================================搜索的好友=================================================

    public function updateSearchFriendData( data : Object ):void{
        var pCIMFriendsData : CIMFriendsData;
        pCIMFriendsData = getSearchFriendsDataByID( data.roleID );
        if( !pCIMFriendsData ) {
            pCIMFriendsData = new CIMFriendsData();
            pCIMFriendsData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
            searchFriendsAry.push( pCIMFriendsData );
        }
        pCIMFriendsData.updateDataByData(data);
    }

    public function getSearchFriendsDataByID(roleID:int):CIMFriendsData{
        var pCIMFriendsData : CIMFriendsData;
        for each( pCIMFriendsData in searchFriendsAry ){
            if( pCIMFriendsData.roleID == roleID ){
                return pCIMFriendsData;
                break;
            }
        }
        return  null;
    }


//    // ====================================新消息提示=================================================


    //可以领取体力的数目
    public function get canGetStrengNum():int{
        var num : int ;
        var ary : Array = _typeDic[CIMConst.FRIENDS];
        var pCIMFriendsData:CIMFriendsData;
        for each( pCIMFriendsData in ary ){
            if( pCIMFriendsData.isGet == CIMConst.CAN_GET_STRENG  ){
                num ++;
            }
        }
        return num;
    }

    //申请列表的数目
    public function get applyNum():int{
        return _typeDic[CIMConst.APPLY ].length;
    }


    // ====================================聊天=================================================
    public function updateChatInfo( chatData : Object ):void{
       var pCIMChatData : CIMChatData = new CIMChatData();
        pCIMChatData.updateDataByData( chatData);
        var ary : Array = getChatInfoByRoleID( pCIMChatData.friendID );
        ary.push( pCIMChatData );
        if( !_chatNewDic[pCIMChatData.friendID] )
            _chatNewDic[pCIMChatData.friendID] = 0;
        _chatNewDic[pCIMChatData.friendID] ++;

    }

    public function getChatInfoByRoleID( friendsID :int ):Array{
        if( !_chatDic[friendsID] )
            _chatDic[friendsID] = [];
        return _chatDic[friendsID];
    }
   //未读的消息的数目
    public function getChatNew( friendsID :int ):int{
        if( !_chatNewDic[friendsID] )
            _chatNewDic[friendsID] = 0;
        return _chatNewDic[friendsID];
    }

    public function resetChatNew( friendsID :int ):void{
        if( _chatNewDic[friendsID] )
            _chatNewDic[friendsID] = 0;
    }


    //当前聊天的对象的集合，包括没有对话，只打开界面的好友
    public function addChatFriendsAry( friendID : int ):void{
        if( curChatFriendsAry.indexOf( friendID ) == -1 )
            curChatFriendsAry.push( friendID );
    }
    public function resetChatFriendsAry():void{
        curChatFriendsAry.splice( 0 , curChatFriendsAry.length );
    }

   //未读消息的好友的集合
    public function addNewNotReadFriendsAry( friendID : int ):void{
        if( newNotReadFriendsAry.indexOf( friendID ) == -1 )
            newNotReadFriendsAry.push( friendID );
    }
    public function removeNewNotReadFriendsAry( friendID : int ):void{
        if( newNotReadFriendsAry.indexOf( friendID ) != -1 )
            newNotReadFriendsAry.splice( newNotReadFriendsAry.indexOf( friendID ), 1 );
    }
   //将未读消息的好友的集合放到当天聊天的对象的集合当中
    public function addNewToChatFriendsAry():void{
        var friendID : int ;
        for each( friendID in newNotReadFriendsAry ){
            addChatFriendsAry( friendID );
        }
    }


    /*
     * type     0:都不是 1：蓝钻 2：黄钻
     subType  蓝钻的时候 1：豪华版年费蓝钻 2：年费蓝钻 3：豪华版蓝钻 4：普通蓝钻
     黄钻的时候 5：年费黄钻 6：普通黄钻
     level    等级
     * */

    public function getTxVipInfo( data:CPlatformBaseData ):Object{
        if( !data )
            return null;
        var obj : Object = {};
        obj.type = 0;

        var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var txData:CTXData = pPlayerSystem.platform.txData;
        if (txData) {
            if (txData.isQGame) {
                if( txData.isBlueVip ){
                    obj.type = 1;
                    if( txData.isSuperBlueVip && txData.isBlueYearVip ){
                        obj.subType = 1;//豪华版年费蓝钻
                    }else if( txData.isBlueYearVip ){
                        obj.subType = 2;//年费蓝钻
                    }else if( txData.isSuperBlueVip ){
                        obj.subType = 3;//豪华版蓝钻
                    }else {
                        obj.subType = 4;//普通蓝钻
                    }
                    obj.level = txData.blueVipLevel;
                }

            }else if( txData.isQZone ){//只显示黄钻
                if( txData.isYellowVip ){
                    obj.type = 2;
                    if( txData.isYellowYearVip  ){
                        obj.subType = 5;//年费黄钻
                    }else{
                        obj.subType = 6;//普通黄钻
                    }
                    obj.level = txData.yellowVipLevel;
                }
            }
        }

        return obj;

    }

    ///////////////////////

    public function getListDataByType(type:int = 0):Array{
        var ary:Array = _typeDic[type];
        ary.sortOn(["isOnline", "battleValue",'isGet'],
                [Array.NUMERIC | Array.DESCENDING, Array.NUMERIC | Array.DESCENDING, Array.NUMERIC | Array.CASEINSENSITIVE]);
        return _typeDic[type];
    }
    public function getFriendList() : Array {
        return getListDataByType(CIMConst.FRIENDS);
    }


    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _pQQClientDataManager() : CQQClientDataManager  {
        return _playerSystem.getBean( CQQClientDataManager  ) as CQQClientDataManager ;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
}
}
