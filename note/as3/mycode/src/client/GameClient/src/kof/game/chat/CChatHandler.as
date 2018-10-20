//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun CNetwork Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.chat {

import kof.framework.INetworking;
import kof.game.chat.data.CChatData;
import kof.game.common.system.CNetHandlerImp;
import kof.message.CAbstractPackMessage;
import kof.message.Chat.BuyEmoticonRequest;
import kof.message.Chat.ChatRecordRequest;
import kof.message.Chat.ChatRecordResponse;
import kof.message.Chat.ChatRequest;
import kof.message.Chat.ChatResponse;
import kof.message.Chat.EmoticonListRequest;
import kof.message.Chat.EmoticonListResponse;
import kof.message.Chat.EmoticonUpdateResponse;

/**
 * 聊天系统控制器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CChatHandler extends CNetHandlerImp {

    public function CChatHandler() {
        super();
    }

    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        this.bind(ChatResponse, _networking_broadcastMessageHandler);
        this.bind(EmoticonListResponse, _onEmoticonListResponseHandler);
        this.bind(EmoticonUpdateResponse, _onEmoticonUpdateResponseHandler);
        this.bind(ChatRecordResponse, _onChatRecordResponseHandler);

        this.onEmoticonListRequest();
        this.onChatRecordRequest();

        return ret;
    }

    /**********************Request********************************/
    // 聊天请求
    public function broadcastMessage( idChannel : int, msg : String , type : int = 0, receiverID : int = 0 ,name : String = ''):void {
        var pckMsg:ChatRequest = new ChatRequest();

        pckMsg.channel = idChannel;
        pckMsg.message = msg;
        pckMsg.type = type;
        pckMsg.receiverID = receiverID;
        pckMsg.name = name;

        networking.send(pckMsg);

    }
    // 登录请求聊天记录
    public function onChatRecordRequest( ):void {
        var request:ChatRecordRequest = new ChatRecordRequest();
        request.decode([1]);

        networking.send(request);

    }
    // 表情包列表请求
    public function onEmoticonListRequest( ):void{
        var request:EmoticonListRequest = new EmoticonListRequest();
        request.decode([1]);

        networking.post(request);
    }
    // 买表情包请求
    public function onBuyEmoticonRequest( emoticonID : int ):void{
        var request:BuyEmoticonRequest = new BuyEmoticonRequest();
        request.decode([emoticonID]);

        networking.post(request);
    }

    /**********************Response********************************/
    // 聊天响应
    /** @private */
    private function _networking_broadcastMessageHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        // NOTE: update the data of domain model.
        // NOTE: notify the view handler to update view content.

        var response:ChatResponse = message as ChatResponse;
        var chatData:CChatData = new CChatData(system);
        chatData.initialData( response.chatMap );

        _pChatMessageList.push( chatData.channel, chatData );

        system.dispatchEvent( new CChatEvent( CChatEvent.CHAT_RESPONSE , chatData ));

    }

    // 登录聊天记录请求
    private final function _onChatRecordResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:ChatRecordResponse = message as ChatRecordResponse;
        var obj : Object;
        for each ( obj in response.chatRecordList ){
            var chatData:CChatData = new CChatData(system);
            chatData.initialData( obj );

            _pChatMessageList.push( chatData.channel, chatData );

        }
        system.dispatchEvent( new CChatEvent( CChatEvent.CHAT_RESPONSE , chatData ));
    }
    // 表情包列表响应
    private final function _onEmoticonListResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:EmoticonListResponse = message as EmoticonListResponse;
        var list:CChatMessageList = system.getBean(CChatMessageList) as CChatMessageList;
        list.initEmoticonList( response );
    }
    // 表情包变更响应
    private final function _onEmoticonUpdateResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:EmoticonUpdateResponse = message as EmoticonUpdateResponse;
        var list:CChatMessageList = system.getBean(CChatMessageList) as CChatMessageList;
        list.updateEmoticonList( response );
    }

    public override function dispose() : void {
        super.dispose();
        networking.unbind(ChatResponse);

    }

    private function get _pChatMessageList():CChatMessageList{
        return system.getBean( CChatMessageList ) as CChatMessageList;
    }

}
}

