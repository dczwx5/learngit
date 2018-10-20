//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.chat {

import QFLib.Interface.IUpdatable;

import flash.utils.Dictionary;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.chat.data.CChatChannel;
import kof.game.chat.data.CChatConst;
import kof.game.chat.data.CChatData;
import kof.game.chat.data.CChatType;
import kof.game.currency.qq.data.netData.CQQClientDataManager;
import kof.game.platform.EPlatformType;
import kof.game.platform.tx.data.CTXData;
import kof.game.player.CPlayerSystem;
import kof.message.Chat.EmoticonListResponse;
import kof.message.Chat.EmoticonUpdateResponse;
import kof.table.ChatEmoticonShop;
import kof.table.ChatEmoticonShopChild;
import kof.table.ChatEmoticonSystem;
import kof.table.MarqueeInfo;

/**
 * Chat domain message list.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CChatMessageList extends CAbstractHandler implements IUpdatable {

    private static const MAX_RECORD_PER_CHANNEL:uint = 200;

    private var _channels:Dictionary;

    private var _defaulList :Array;

    private var _emoticonList : Array;

    public var chatEmoticonSystemTable:IDataTable;
    public var chatEmoticonShopTable:IDataTable;
    public var chatEmoticonShopChildTable:IDataTable;

    private var _emoticonShop : Dictionary;

    private static const MAX_MSG_NUM : int = 50;


    public function CChatMessageList() {
        super();
        _channels = new Dictionary();
        _emoticonShop = new Dictionary();
        _defaulList = [];
        _emoticonList = [];

        _channels[ CChatChannel.ALL] = [];//综合（所有频道）
        _channels[ CChatChannel.WORLD] = [];
        _channels[ CChatChannel.GUILD] = [];
        _channels[ CChatChannel.PERSONAL] = [];
        _channels[ CChatChannel.SYSTEM] = [];
        _channels[ CChatChannel.HORN] = [];
        _channels[ CChatChannel.GETITEM] = [];

    }
    public override function dispose() : void {
        super.dispose();
    }
    protected override function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        chatEmoticonSystemTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable( KOFTableConstants.CHAT_EMOTICON_SYSTEM );
        chatEmoticonShopTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable( KOFTableConstants.CHAT_EMOTICON_SHOP );
        chatEmoticonShopChildTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable( KOFTableConstants.CHAT_EMOTICON_SHOP_CHILD );
        for each( var pChatEmoticonShop : ChatEmoticonShop in chatEmoticonShopTable.toArray()){
            _emoticonShop[pChatEmoticonShop.ID] = [];
        }
        for each( var pChatEmoticonShopChild : ChatEmoticonShopChild in chatEmoticonShopChildTable.toArray()){
            _emoticonShop[pChatEmoticonShopChild.parentID].push(pChatEmoticonShopChild);
        }
        return ret;
    }



    public function get channels():Dictionary {
        return _channels;
    }

    public function getList(idChannel:int):Array {
        var msgList : Array ;
        if( _channels[idChannel].length > MAX_MSG_NUM )
            msgList = _channels[idChannel ].slice( _channels[idChannel ].length - MAX_MSG_NUM, _channels[idChannel ].length );
        return msgList || _channels[idChannel] as Array ;
    }

    public function push(idChannel:int, chatData:CChatData):void {
        var arr : Array = _channels[idChannel] as Array;
        if( !arr )
                return;
        arr.push(chatData);
        if ( arr.length > MAX_RECORD_PER_CHANNEL + int(MAX_RECORD_PER_CHANNEL * 0.25) ) {
            arr = arr.slice( arr.length - MAX_RECORD_PER_CHANNEL );
            _channels[idChannel] = arr;
        }
        if( idChannel != CChatChannel.GETITEM ){
            _channels[ CChatChannel.ALL].push(chatData);
            if (  _channels[ CChatChannel.ALL].length > MAX_RECORD_PER_CHANNEL + int(MAX_RECORD_PER_CHANNEL * 0.25) ) {
                _channels[ CChatChannel.ALL] =  _channels[ CChatChannel.ALL].slice(  _channels[ CChatChannel.ALL].length - MAX_RECORD_PER_CHANNEL );
            }
        }

    }

    /////////////////聊天表情///////////////

    public function initEmoticonList( response : EmoticonListResponse ) : void {
        for each( var obj : Object in response.emoticonList ){
            _emoticonList.push( obj.emoticonID );
        }
        _defaulList.push( CChatConst.SYSTEM );
//        _defaulList.push( CChatConst.SHOP, CChatConst.SYSTEM );
    }

    public function updateEmoticonList( response : EmoticonUpdateResponse ) : void {
        for each( var obj : Object in response.emoticonList ){
            if( obj.type == 1 ){
                _emoticonList.push( obj.emoticonID );
                _emoticonList.sort();
                system.dispatchEvent( new CChatEvent( CChatEvent.FACE_BUY_SUCC , obj.emoticonID ));
            }else if( obj.type == 2 ){
                _emoticonList.splice( _emoticonList.indexOf( obj.emoticonID ) , 1 );
            }
        }
    }

    public function get emoticonList():Array{
        return _defaulList.concat( _emoticonList );
    }
    public function isEmoticonBought( emoticonID : int ):Boolean{
        var bool : Boolean;
        if(_emoticonList.indexOf( emoticonID ) != -1 )
            bool = true;
        return bool;
    }
    public function isAFaceCode( ID :String ):Boolean{
        return getChatEmoticonSystemTableByID( ID ) || getChatEmoticonShopChildTableByID( ID );
    }
//    public function getFaceUrl( ID :String ):String{
//        if( getChatEmoticonSystemTableByID( ID ) )
//                return CChatConst.list_system_icon_url + getChatEmoticonSystemTableByID( ID ).iconID + ".png";
//        else if( getChatEmoticonShopChildTableByID( ID ) )
//                return CChatConst.list_shopface_icon_url  + getChatEmoticonShopChildTableByID( ID ).parentID + "/" + getChatEmoticonShopChildTableByID( ID ).iconID + ".png";
//        else
//                return "";
//    }

    //////////////////////////////////////////////////////


    public function addSystemMsg( msg : String = '',channelType:int = 2 ,marqueeInfo : MarqueeInfo = null ,responseData:Dictionary = null):void{
        var chatData : CChatData = new CChatData(system);
        chatData.message = msg;
        chatData.type = CChatType.ONLY_STR;
        chatData.channel = channelType ;
        chatData.marqueeInfo = marqueeInfo;
        chatData.responseData = responseData;
        _channels[ channelType ].push( chatData );
        if( channelType != CChatChannel.GETITEM )
            _channels[ CChatChannel.ALL ].push( chatData );
        system.dispatchEvent( new CChatEvent( CChatEvent.CHAT_RESPONSE ));
    }


    //////////////////////////////////////////////////////

    /*
     * type     0:都不是 1：蓝钻 2：黄钻
     subType  蓝钻的时候 1：豪华版年费蓝钻 2：年费蓝钻 3：豪华版蓝钻 4：普通蓝钻
     黄钻的时候 5：年费黄钻 6：普通黄钻
     level    等级
     * */

    public function getTxVipInfo( chatData:CChatData ):Object{
        if( !chatData )
                return null;
        var obj : Object = {};
        obj.type = 0;

        var txData:CTXData = (chatData.platformData as CTXData);
        if (!txData) return obj;

        if( _playerSystem.platform.txData.isQGame ){//只显示蓝钻
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

        }else if( _playerSystem.platform.txData.isQZone ){//只显示黄钻
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

        return obj;

    }
    // ======================================table================================================
    public function getChatEmoticonSystemTableByID(ID:String) : ChatEmoticonSystem{
        return chatEmoticonSystemTable.findByPrimaryKey(ID);
    }
    public function getChatEmoticonShopTableByID(ID:int) : ChatEmoticonShop{
        return chatEmoticonShopTable.findByPrimaryKey(ID);
    }
    public function getChatEmoticonShopChildTableByID(ID:String) : ChatEmoticonShopChild{
        return chatEmoticonShopChildTable.findByPrimaryKey(ID);
    }

    public function getChatEmoticonShopChildAryByParentID(parentID:int):Array{
        return _emoticonShop[parentID];
    }

    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }

    public function update(delta:Number) : void {

    }
}
}
