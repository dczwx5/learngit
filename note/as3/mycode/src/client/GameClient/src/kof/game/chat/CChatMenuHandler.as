//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/8/15.
 */
package kof.game.chat {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import kof.framework.CViewHandler;
import kof.game.GMReport.CGMReportData;
import kof.game.GMReport.CGMReportSystem;
import kof.game.GMReport.Event.CGMReportEvent;
import kof.game.chat.data.CChatData;
import kof.game.chat.data.CChatMenuConst;
import kof.game.im.CIMHandler;
import kof.game.im.CIMSystem;
import kof.game.im.data.CIMConst;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.playerTeam.CPlayerTeamSystem;
import kof.ui.chat.ChatItemUI;
import kof.ui.chat.ChatMenuUI;

import morn.core.components.Dialog;

public class CChatMenuHandler extends CViewHandler {

    private var _chatMenuUI : ChatMenuUI;

    private var _chatItemUI : ChatItemUI;

    private var _chatData:CChatData;

    public function CChatMenuHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    public function show( chatItemUI : ChatItemUI ) : void {
        _chatItemUI = chatItemUI;
        _chatData = chatItemUI.dataSource as CChatData;
        if ( !_chatMenuUI ) {
            _chatMenuUI = new ChatMenuUI();
            _chatMenuUI.height = 130;
        }
        _addEventListeners();
        var p : Point = _chatItemUI.parent.localToGlobal( new Point( _chatItemUI.parent.mouseX, _chatItemUI.parent.mouseY ) );
        _chatMenuUI.x = p.x - 30;
        if( p.y + _chatMenuUI.height + 40 > system.stage.flashStage.stageHeight ){
            _chatMenuUI.y = p.y - _chatMenuUI.height + 15;
        }else{
            _chatMenuUI.y = p.y - 30;
        }
        _chatMenuUI.popupCenter = false;
        uiCanvas.addDialog( _chatMenuUI );
    }
    private function _onMenuSelectedHandler( evt : Event ) : void {
        var selectedIndex : int = _chatMenuUI.menu.selectedIndex;
        if( selectedIndex < 0 )
                return;
        _onMenuCloseHandler();
        var label : String = CChatMenuConst.LABELS[selectedIndex];
        switch( label ){
            case CChatMenuConst.MAKE_FRIENDS:{
                if( _chatData.marqueeRoleID > 0 ){
                    _pIMHandler.onAddFriendRequest( [_chatData.marqueeRoleID],CIMConst.SINGLE );
                } else if( _playerData.ID == _chatData.senderID ){
                    _pIMHandler.onAddFriendRequest( [_chatData.receiverID],CIMConst.SINGLE );
                }else{
                    _pIMHandler.onAddFriendRequest( [_chatData.senderID],CIMConst.SINGLE );
                }
                break;
            }
            case CChatMenuConst.TEAM_INVITATION:{
                break;
            }
            case CChatMenuConst.TEAM_APPLY:{
                break;
            }
            case CChatMenuConst.CLUB_INVITATION:{
                break;
            }
            case CChatMenuConst.CLUB_APPLY:{
                break;
            }
            case CChatMenuConst.PRIVATE_CHAT:{
                _pChatViewHandler.onPrivateChat();
                callLater( setPrivateChatDatae );
                break;
            }
            case CChatMenuConst.GM_REPORT:{
                var reportData:CGMReportData = new CGMReportData();
                if( _chatData.marqueeRoleID > 0 ){
                    reportData.playerName = _chatData.marqueeRoleName;
                }else{
                    reportData.playerName = _chatData.senderName;
                }
                (system.stage.getSystem(CGMReportSystem) as CGMReportSystem).dispatchEvent(new CGMReportEvent(CGMReportEvent.OpenReportWin, reportData));
                break;
            }
            case CChatMenuConst.PLAYER_INFO:{
                if( _chatData.marqueeRoleID > 0 ){
                    (system.stage.getSystem( CPlayerTeamSystem) as CPlayerTeamSystem ).showPlayerInfo( _chatData.marqueeRoleID );
                }else{
                    (system.stage.getSystem( CPlayerTeamSystem) as CPlayerTeamSystem ).showPlayerInfo( _chatData.senderID );
                }

                break;
            }
        }

    }
    private function setPrivateChatDatae():void{
        _pChatInputViewHandler.txtInput.clear();
        var senderName : String;
        if( _chatData.marqueeRoleID > 0 ){
            senderName = _chatData.marqueeRoleName;
        } else if( _playerData.ID == _chatData.senderID ){
            senderName = _chatData.receiverName;
        }else{
            senderName = _chatData.senderName;
        }
        //因为传过去的名字不需要s1.
//        senderName = StringUtil.remove( senderName , senderName.slice(0,senderName.indexOf('.') + 1)  );
        _pChatInputViewHandler.txtInput.append( '/' + senderName  + ' ');
        _pChatInputViewHandler.setPrivateChatDatae( _chatData );
        system.stage.flashStage.focus = _pChatInputViewHandler.txtInput;
    }
    public function _onMenuCloseHandler( evt : * = null) : void {
        if ( _chatMenuUI )
            _chatMenuUI.close( Dialog.CLOSE );
        _removeEventListeners();
    }
    private function _addEventListeners():void{
        _removeEventListeners();
        if( _chatMenuUI ){
            _chatMenuUI.menu.addEventListener( Event.CHANGE, _onMenuSelectedHandler, false, 0, true );
            _chatMenuUI.menu.addEventListener( MouseEvent.ROLL_OUT, _onMenuCloseHandler, false, 0, true );
            system.stage.flashStage.addEventListener(MouseEvent.CLICK, _onMenuCloseHandler, false, 0, true );
            system.stage.flashStage.addEventListener(Event.RESIZE, _onMenuCloseHandler, false, 0, true );

        }
    }
    private function _removeEventListeners():void{
        if( _chatMenuUI ){
            _chatMenuUI.menu.removeEventListener( Event.CHANGE, _onMenuSelectedHandler );
            _chatMenuUI.menu.removeEventListener( MouseEvent.ROLL_OUT, _onMenuCloseHandler );
            system.stage.flashStage.removeEventListener(MouseEvent.CLICK, _onMenuCloseHandler );
            system.stage.flashStage.removeEventListener(Event.RESIZE, _onMenuCloseHandler );
        }
    }

    private function get _pChatInputViewHandler():CChatInputViewHandler{
        return system.getBean( CChatInputViewHandler ) as CChatInputViewHandler;
    }
    private function get _pChatViewHandler():CChatViewHandler{
        return system.getBean( CChatViewHandler ) as CChatViewHandler;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _pIMHandler() : CIMHandler {
        return _pIMSystem.getBean( CIMHandler ) as CIMHandler ;
    }
    private function get _pIMSystem() : CIMSystem {
        return system.stage.getSystem( CIMSystem ) as CIMSystem;
    }
}
}
