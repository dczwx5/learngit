//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/1/10.
 */
package kof.game.common.system {

import QFLib.Foundation.CMap;
import QFLib.Interface.IUpdatable;

import kof.data.KOFTableConstants;

import kof.framework.CSystemHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.ui.IUICanvas;

public class CNetHandlerImp extends CSystemHandler implements IUpdatable {
    public function CNetHandlerImp() {
        _isDispose = false;
    }

    public override function dispose() : void {
        if (_isDispose) return;
        super.dispose();

        if (_bindList) {
            _bindList.loop(function (netClass:Class, value:Handler) : void {
                networking.unbind(netClass);
                value.dispose();
            });
            _bindList = null;
        }

        _isDispose = true;
    }
    protected override function onSetup():Boolean {
        super.onSetup();
        _bindList = new CMap();
        _gamePromptTable = (system.stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.GAME_PROMPT);
        _uiCanvas = system.stage.getSystem(IUICanvas) as IUICanvas;
        return true;
    }
    public virtual function update(delta:Number) : void {
        if (_isDispose) return ;
    }

    // 协议绑定
    public function bind(netClass:Class, processFunc:Function) : void {
        var handler:Handler = new Handler();
        handler.handler = processFunc;
        handler.gamePromptTable = _gamePromptTable;
        handler.uiCanvas = _uiCanvas;
        handler.uiCanvas = _uiCanvas;
        handler.system = system;
        networking.bind(netClass).toHandler(handler.netHandler);

        _bindList.add(netClass, handler);

    }
    public function unbind(netClass:Class) : void {
        networking.unbind(netClass);
        var handler:Handler = _bindList.find(netClass);
        if (handler) {
            _bindList.remove(netClass);
            handler.dispose();
        }
    }

    public function isProtocolBusy(type:int) : Boolean {
        if (!_protocolStateMap) return false;
        var value:* = _protocolStateMap.find(type);
        if (!value) return false;
        return (value as int == _PROTOCOL_BUSY);
    }
    public function setProtocolBusy(type:int, v:Boolean) : void {
        if (!_protocolStateMap) {
            _protocolStateMap = new CMap();
        }

        var state:int;
        if (v) {
            state = _PROTOCOL_BUSY;
        } else {
            state = _PROTOCOL_IDLE;
        }
        var value:* = _protocolStateMap.find(type);
        if (!value) {
            _protocolStateMap.add(type, state);
        } else {
            _protocolStateMap[type] = state;
        }
    }

    private var _isDispose:Boolean;
    private var _bindList:CMap;
    private var _gamePromptTable:IDataTable;
    private var _uiCanvas:IUICanvas;

    private var _protocolStateMap:CMap; // 1 true, 2 false, 不使用0当false
    private var _PROTOCOL_BUSY:int = 1;
    private var _PROTOCOL_IDLE:int = 2;
}
}

import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.game.chat.CChatSystem;
import kof.game.common.data.CErrorData;
import kof.message.CAbstractPackMessage;
import kof.table.GamePrompt;
import kof.ui.CMsgAlertHandler;
import kof.ui.IUICanvas;

class Handler {
    public var handler:Function;
    public var gamePromptTable:IDataTable;
    public var uiCanvas:IUICanvas;
    public var system:CAppSystem;

    public function dispose() : void {
        uiCanvas = null;
        gamePromptTable = null;
        handler = null;
    }
    public function netHandler(net:INetworking, message:CAbstractPackMessage):void {
        var isError:Boolean = false;
        var errorData:CErrorData = new CErrorData(message);
        if (errorData.isError == false) {
            isError = false;
            handler(net, message, isError);
        } else {
            var record:GamePrompt = gamePromptTable.findByPrimaryKey(errorData.gamePromptID);
            if (record) {
                // show by record.type : 0 is info, 1 is error
                var content:String = record.content;
                if (errorData.contents && errorData.contents.length) {
                    var replaceKey:String;
                    for (var i:int = 0; i < errorData.contents.length; i++) {
                        replaceKey = "{" + i + "}";
                        content = content.replace(replaceKey, errorData.contents[i]);
                    }
                }
                if (record.type == 0) {
                    uiCanvas.showMsgAlert(content, CMsgAlertHandler.NORMAL);
                } else {
                    uiCanvas.showMsgAlert(content);
                }
                if (record.type == 0) {
                    isError = false;
                } else {
                    isError = true;
                }
                if( record.guide_type.length > 0 ){
                   var guildType : Array = record.guide_type.split(',');
                   for each ( var channelType : int in guildType ){
                       (system.stage.getSystem(CChatSystem) as CChatSystem).addSystemMsg( content, channelType );
                   }
                }
                handler(net, message, isError);
            }
        }
    }
}