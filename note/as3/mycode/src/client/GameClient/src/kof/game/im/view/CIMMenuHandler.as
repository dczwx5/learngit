//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/8.
 */
package kof.game.im.view {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import kof.SYSTEM_ID;
import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.status.CGameStatus;
import kof.game.im.CIMChatSystem;
import kof.game.im.CIMHandler;
import kof.game.im.CIMManager;
import kof.game.im.data.CIMApplyData;
import kof.game.im.data.CIMConst;
import kof.game.im.data.CIMFriendsData;
import kof.game.im.data.CIMRecommendData;
import kof.game.peakpk.CPeakpkSystem;
import kof.game.playerTeam.CPlayerTeamSystem;
import kof.ui.CUISystem;
import kof.ui.master.im.IMItemUI;
import kof.ui.master.im.IMMenuUI;

public class CIMMenuHandler extends CViewHandler {

    private var m_IMMenuUI:IMMenuUI;
    private var _pIMItemUI:IMItemUI;

    public function CIMMenuHandler() {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ IMMenuUI,IMItemUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if(!m_IMMenuUI){
            m_IMMenuUI = new IMMenuUI();
            m_IMMenuUI.menu.addEventListener(Event.CHANGE,_onMenuSelectedHandler, false, 0, true);
            m_IMMenuUI.menu.addEventListener(MouseEvent.ROLL_OUT, _onMenuRollHandler, false, 0, true);
        }

        return Boolean( m_IMMenuUI );
    }

    public function addDisplay( pIMItemUI:IMItemUI ) : void {
        _pIMItemUI = pIMItemUI;
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
    public function _addToDisplay( ):void {
        var labels:String;
        if( _pIMItemUI.dataSource is CIMFriendsData ){
            labels = CIMConst.CHAT_MEUN_LABEL + ',' + CIMConst.DELETE_MEUN_LABEL + ',' + CIMConst.PLAYER_INFO
                    + "," + CIMConst.FRIEND_PK;
//            labels = CIMConst.CHECK_MEUN_LABEL + ',' + CIMConst.CHAT_MEUN_LABEL + ',' + CIMConst.DELETE_MEUN_LABEL ;
        }else if( _pIMItemUI.dataSource is CIMApplyData ){
            labels = CIMConst.PLAYER_INFO ;
        }else if( _pIMItemUI.dataSource is CIMRecommendData ){
//            labels = CIMConst.CHECK_MEUN_LABEL ;
        }
        m_IMMenuUI.menu.labels = labels;
        var p:Point = _pIMItemUI.parent.localToGlobal(new Point(_pIMItemUI.parent.mouseX,_pIMItemUI.parent.mouseY));
        m_IMMenuUI.x = p.x - 40;
        m_IMMenuUI.y = p.y - 30;
        m_IMMenuUI.popupCenter = false;
        uiCanvas.addDialog( m_IMMenuUI );
    }

    private function _onMenuSelectedHandler(evt:Event):void{
        if( m_IMMenuUI.menu.labels == null )
                return;
        var selectedIndex:int = m_IMMenuUI.menu.selectedIndex;
        var label:String = m_IMMenuUI.menu.labels.split(",")[selectedIndex];
        if( selectedIndex != -1){
            m_IMMenuUI.remove();
            switch ( label ){
                case CIMConst.CHAT_MEUN_LABEL:
                    _imManager.firstShowChatFriendID = _pIMItemUI.dataSource.roleID;
                    _imManager.addChatFriendsAry( _pIMItemUI.dataSource.roleID );
                    ( _pIMChatSystem.getBean( CIMChatViewHandler ) as CIMChatViewHandler ).addDisplay();

                    var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
                    var bundle : ISystemBundle =  bundleCtx.getSystemBundle( SYSTEM_ID(KOFSysTags.FRIEND_CHAT ));
                    bundleCtx.setUserData( bundle, CBundleSystem.ACTIVATED, true );

                    break;
                case CIMConst.DELETE_MEUN_LABEL:
                    _pCUISystem.showMsgBox( '您确定删除好友'+  _pIMItemUI.dataSource.name + '吗?', onDelete );
                    function onDelete():void{
                        _imHandler.onDeleteFriendRequest( _pIMItemUI.dataSource.roleID );
                    }
                    break;
                case CIMConst.PLAYER_INFO:
                    var playerID : int ;
                    if( _pIMItemUI.dataSource is CIMFriendsData ){
                        playerID = ( _pIMItemUI.dataSource as CIMFriendsData ).roleID;
                    }else if( _pIMItemUI.dataSource is CIMApplyData ){
                        playerID = ( _pIMItemUI.dataSource as CIMApplyData ).roleID;
                    }
                    (system.stage.getSystem( CPlayerTeamSystem) as CPlayerTeamSystem ).showPlayerInfo( playerID );
                    break;
                case CIMConst.FRIEND_PK:
                    if (CGameStatus.checkStatus(system)) {
                        var imData:CIMFriendsData = _pIMItemUI.dataSource as CIMFriendsData;
                        // 发起切磋请求
                        (system.stage.getSystem( CPeakpkSystem) as CPeakpkSystem ).data.lastSendInviteData = imData;
                        CGameStatus.setStatus(CGameStatus.Status_PeakPKMatch);
                        (_pIMChatSystem.stage.getSystem(CPeakpkSystem) as CPeakpkSystem).netHandler.sendInvite(imData.roleID);
                    }
                    break;
            }
        }
    }

    private function _onMenuRollHandler(evt:MouseEvent):void{
        if(m_IMMenuUI)
            m_IMMenuUI.close();
    }

    public function hide(removed:Boolean = true):void {
        if(m_IMMenuUI)
            m_IMMenuUI.close();
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _imHandler():CIMHandler{
        return  system.getBean( CIMHandler ) as CIMHandler ;
    }
    private function get _imManager():CIMManager{
        return  system.getBean( CIMManager ) as CIMManager ;
    }
    private function get _pIMChatSystem():CIMChatSystem{
        return system.stage.getSystem( CIMChatSystem ) as CIMChatSystem;
    }
}
}
