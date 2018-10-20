//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/21.
 */
package kof.game.systemnotice {

import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.utils.Dictionary;

import kof.SYSTEM_ID;
import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.im.data.CIMConst;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CLobbyViewHandler;
import kof.ui.master.newmsgtips.NewMsgTipsUI;

import morn.core.components.Box;
import morn.core.components.Component;

public class CSystemNoticeViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_newMsgTipsUI:NewMsgTipsUI;

    private var _noticeDic : Dictionary;
    private var _systemDic : Dictionary;

//    private var _type : String ;

    private var _typeAry : Array;


    public function CSystemNoticeViewHandler() {
        super( false );
    }
    override public function dispose() : void {
        super.dispose();

        m_newMsgTipsUI = null;
    }

    override public function get viewClass() : Array {
        return [ NewMsgTipsUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if ( !m_newMsgTipsUI ) {
                m_newMsgTipsUI = new NewMsgTipsUI();

                m_newMsgTipsUI.system_mail.visible = false;
                m_newMsgTipsUI.system_chat.visible = false;
                m_newMsgTipsUI.system_taskcallup.visible = false;
                m_newMsgTipsUI.system_im.visible = false;

                _noticeDic = new Dictionary();
                _noticeDic[ CSystemNoticeConst.SYSTEM_MAIL ] = m_newMsgTipsUI.system_mail;
                _noticeDic[ CSystemNoticeConst.SYSTEM_CHAT ] = m_newMsgTipsUI.system_chat;
                _noticeDic[ CSystemNoticeConst.SYSTEM_TASKCALLUP ] = m_newMsgTipsUI.system_taskcallup;
                _noticeDic[ CSystemNoticeConst.SYSTEM_IM ] = m_newMsgTipsUI.system_im;

                _systemDic = new Dictionary();
                _systemDic[ m_newMsgTipsUI.system_mail ] = KOFSysTags.MAIL;
                _systemDic[ m_newMsgTipsUI.system_chat ] = KOFSysTags.FRIEND_CHAT;
                _systemDic[ m_newMsgTipsUI.system_taskcallup ] = KOFSysTags.TASKCALLUP;
                _systemDic[ m_newMsgTipsUI.system_im ] = KOFSysTags.FRIEND;

                m_newMsgTipsUI.system_mail.addEventListener( MouseEvent.CLICK, _onClickHandler , false, 0, true);
                m_newMsgTipsUI.system_chat.addEventListener( MouseEvent.CLICK, _onClickHandler , false, 0, true);
                m_newMsgTipsUI.system_taskcallup.addEventListener( MouseEvent.CLICK, _onClickHandler , false, 0, true);
                m_newMsgTipsUI.system_im.addEventListener( MouseEvent.CLICK, _onClickHandler , false, 0, true);


                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay( type : String) : void {
        if( !_typeAry )
            _typeAry = [];
        if( _typeAry.indexOf( type) == -1 )
            _typeAry.push( type );
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void {
        if ( !parentCtn ) {
            callLater( _addToDisplay );
        } else {
            _addIcons();
        }
    }
    private function _addIcons():void{
        var type : String;
        for each ( type in _typeAry ){
            _addIcon( type );
        }
        _typeAry = [];
        parentCtn.addChild( m_newMsgTipsUI );

        (system as CSystemNoticeSystem).noticeIconResize();
    }

    private function _addIcon( type : String ):void{
        var disObj : DisplayObject;
        disObj = _noticeDic[ type ];

        var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var bundle : ISystemBundle =  bundleCtx.getSystemBundle( SYSTEM_ID(_systemDic[ disObj ]));
        var vCurrent : Boolean  = bundleCtx.getUserData( bundle, CBundleSystem.ACTIVATED ,false );
        if(vCurrent)
            return;

        disObj.visible = true;
        var x : int ;
        for each( disObj in _noticeDic ){
            if( disObj.visible ){
                disObj.x = x;
                x += disObj.width + 20;
                disObj.y = -12;
            }
        }
    }
    public function removeDisplay() : void {
        if ( m_newMsgTipsUI ) {
            m_newMsgTipsUI.remove();
        }
    }


    public function showNotice( type : String , sProperty : String = "activated" ):void{
        var disObj : DisplayObject;
        disObj = _noticeDic[ type ];

        var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var bundle : ISystemBundle =  bundleCtx.getSystemBundle( SYSTEM_ID(_systemDic[ disObj ]));
        var vCurrent : Boolean  = bundleCtx.getUserData( bundle, sProperty ,false);
        if(vCurrent)
                return;

        disObj.visible = true;
        var x : int ;
        for each( disObj in _noticeDic ){
            if( disObj.visible ){
                disObj.x = x;
                x += disObj.width + 20;
                disObj.y = -12;
            }
        }
    }

    private function _onClickHandler( evt:MouseEvent ):void{
        var disObj : DisplayObject = evt.currentTarget as DisplayObject;
        disObj.visible = false;
        var x : int ;
        var bool : Boolean = false;
        for each( var dObj : DisplayObject in _noticeDic ){
            if( dObj.visible ){
                dObj.x = x;
                x += dObj.width + 20;
                disObj.y = -12;
                bool = true;
            }
        }

        if( !bool )
            removeDisplay();

        var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var bundle : ISystemBundle =  bundleCtx.getSystemBundle( SYSTEM_ID(_systemDic[ disObj ]));
        var tab : int = 0;
        if( _systemDic[ disObj ] == KOFSysTags.FRIEND ){
            tab = CIMConst.APPLY;
        }
        bundleCtx.setUserData( bundle, CBundleSystem.TAB, [tab]  );
        bundleCtx.setUserData( bundle, CBundleSystem.ACTIVATED, true );
    }

    public function hideIcon( type : String ):void{
        if( !_noticeDic )
                return;
        var disObj : DisplayObject = _noticeDic[type];
        disObj.visible = false;
        var x : int ;
        var bool : Boolean = false;
        for each( var dObj : DisplayObject in _noticeDic ){
            if( dObj.visible ){
                dObj.x = x;
                x += dObj.width + 20;
                disObj.y = -12;
                bool = true;
            }
        }

        if( !bool )
            removeDisplay();
    }

    private function get parentCtn():Box{
        var pLobbySystem:CLobbySystem = system.stage.getSystem( CLobbySystem ) as CLobbySystem;
        var pLobbyViewHandler:CLobbyViewHandler = pLobbySystem.getBean(CLobbyViewHandler) as CLobbyViewHandler;
        if ( !pLobbyViewHandler.pMainUI )
            return null;
//        var notice:Box = pLobbyViewHandler.pMainUI.getChildByName("systemNotice") as Box;
        var notice:Box = pLobbyViewHandler.pMainUI.view_systemNotice.box_common as Box;
        return notice;
    }
}
}
