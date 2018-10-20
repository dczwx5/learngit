//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.switching.view {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;

import kof.framework.CViewHandler;
import kof.framework.events.CEventPriority;
import kof.game.bundle.ISystemBundleContext;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CLobbyViewHandler;
import kof.ui.master.NoviceTutor.NTComingUI;

import morn.core.components.Component;
import morn.core.components.Label;

/**
 * 功能开启预告显示逻辑
 *
 * @author jeremy@qifun.com
 */
public class CSwitchingComingViewHandler extends CViewHandler {

    /** @private */
    private var m_pComingUI : NTComingUI;
    /** @private */
    private var m_bSlideOut : Boolean;
    /** @private */
    private var m_pContentBox : DisplayObject;
    /** @private */
    private var m_pDetailBox : DisplayObject;
    /** @private */
    private var m_fScrollSpeed : Number;
    /** @private */
    private var m_bShow : Boolean;

    /** @private */
    private var m_iCondMinLevel : int;

    /** @private */
    private var m_pNoticeDesc : String;
    private var m_sBundleName : String;
    private var m_sIconUrl : String;
    private var m_pConditionDescList : Array;

    /** Creates a new CSwitchingComingViewHandler */
    public function CSwitchingComingViewHandler() {
        super( false );
    }

    override public function dispose() : void {
        super.dispose();

        m_pComingUI = null;
        m_pDetailBox = null;
        m_pContentBox = null;
        m_pConditionDescList = null;
    }

    /** @inheritDoc */
    override public function get viewClass() : Array {
        return [ NTComingUI ];
    }

    override protected function get additionalAssets() : Array {
        return [ "main.swf" ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitialize() : Boolean {
        if ( !super.onInitialize() )
            return false;

        m_fScrollSpeed = 100.0;
        return true;
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_pComingUI ) {
            m_pComingUI = new NTComingUI();

            m_pComingUI.left = 0;
//            m_pComingUI.centerY = -80;
            m_pComingUI.top = 165;

            m_pContentBox = m_pComingUI.getChildByName( "contentBox" );

            if ( m_pContentBox is DisplayObjectContainer )
                m_pDetailBox = DisplayObjectContainer( m_pContentBox ).getChildByName( "contentBox" );

//            m_pComingUI.listConditionDesc.renderHandler = new Handler( _onConditionDescRender );

            m_pComingUI.btnSlideIn.addEventListener( MouseEvent.CLICK, _btnSlideIn_mouseClickEventHandler, false, CEventPriority.DEFAULT, true );
            m_pComingUI.btnSlideOut.addEventListener( MouseEvent.CLICK, _btnSlideOut_mouseClickEventHandler, false, CEventPriority.DEFAULT, true );

            this.slideOut = true;
            this.slideDetail( false );

            if ( m_pContentBox ) {
                m_pContentBox.addEventListener( MouseEvent.MOUSE_OVER, _fxIconBg_mouseOverEventHandler, false, CEventPriority.DEFAULT, true );
                m_pContentBox.addEventListener( MouseEvent.MOUSE_OUT, _all_mouseOutEventHandler, false, CEventPriority.DEFAULT, true );
            }
        }

        return Boolean( m_pComingUI );
    }

    override protected virtual function onShutdown() : Boolean {
        if ( !super.onShutdown() )
            return false;

        if ( m_pContentBox ) {
            m_pContentBox.removeEventListener( MouseEvent.MOUSE_OVER, _fxIconBg_mouseOverEventHandler );
            m_pContentBox.removeEventListener( MouseEvent.MOUSE_OUT, _all_mouseOutEventHandler );
        }

        return true;
    }

    [Autowired]
    public function onBundleStart( ctx : ISystemBundleContext ) : void {
        void(ctx);
    }

    private function _onConditionDescRender( item : Component, idx : int ) : void {
        if ( !item ) return;
        var label : Label = item.getChildByName( 'labelDisplay' ) as Label;
        if ( !label )
            return;

        if ( item.dataSource is String ) {
            label.text = String( item.dataSource );
        }
    }

    private function _fxIconBg_mouseOverEventHandler( event : MouseEvent ) : void {
        slideDetail( true );
    }

    private function _all_mouseOutEventHandler( event : MouseEvent ) : void {
        slideDetail( false );
    }

    private function _btnSlideOut_mouseClickEventHandler( event : MouseEvent ) : void {
        this.slideOut = true;
    }

    private function _btnSlideIn_mouseClickEventHandler( event : MouseEvent ) : void {
        this.slideOut = false;
    }

    //----------------------------------
    // Properties
    //----------------------------------

    final public function get noticeDesc() : String {
        return m_pNoticeDesc;
    }

    final public function set noticeDesc( value : String ) : void {
        if ( m_pNoticeDesc == value )
            return;
        m_pNoticeDesc = value;
        invalidateData();
    }

    final public function get bundleName() : String {
        return m_sBundleName;
    }

    final public function set bundleName( value : String ) : void {
        if ( m_sBundleName == value )
            return;
        m_sBundleName = value;
        invalidateData();
    }

    final public function get iconUrl() : String {
        return m_sIconUrl;
    }

    final public function set iconUrl( value : String ) : void {
        if ( m_sIconUrl == value )
            return;
        m_sIconUrl = value;
        invalidateData();
    }

    final public function get conditionDescList() : Array {
        return m_pConditionDescList;
    }

    final public function set conditionDescList( value : Array ) : void {
        m_pConditionDescList = value;
        invalidateData();
    }

    final public function get condMinLevel() : int {
        return m_iCondMinLevel;
    }

    final public function set condMinLevel( value : int ) : void {
        m_iCondMinLevel = value;
        invalidateData();
    }

    override protected function updateData() : void {
        super.updateData();

        if ( m_pComingUI ) {
            m_pComingUI.iconComp.url = iconUrl;
            m_pComingUI.iconComp.clipY = 1;
            if ( iconUrl ) {
                var idx : int = iconUrl.lastIndexOf( '.' );
                if ( idx > -1 ) {
                    if ( iconUrl.substr( idx, 4 ) == "btn_" ) {
                        m_pComingUI.iconComp.clipY = 3;
                    }
                }
            }

//            m_pComingUI.listConditionDesc.dataSource = conditionDescList;
//            m_pComingUI.lblConditionDesc.text = conditionDescList && conditionDescList.length > 0 ? conditionDescList[0].toString() : "";
            m_pComingUI.numLevelCond.num = this.condMinLevel;
            m_pComingUI.txtDesc.text = noticeDesc;
            m_pComingUI.txtName.text = bundleName;
        }
    }

    override protected function updateDisplay() : void {
        super.updateDisplay();

        if ( !m_pComingUI )
            return;

        if ( this.slideOut ) {
            m_pComingUI.btnSlideIn.visible = !(m_pComingUI.btnSlideOut.visible = false);
        } else {
            m_pComingUI.btnSlideIn.visible = !(m_pComingUI.btnSlideOut.visible = true);
        }

        if ( m_pContentBox ) {
            m_pContentBox.visible = m_pComingUI.btnSlideIn.visible;
        }
    }

    public function addDisplay() : void {
        this.m_bShow = true;
        this.loadAssetsByView( this.viewClass, _addDisplay );
    }

    private function _addDisplay() : void {
        if ( this.onInitializeView() ) {
            this.invalidate();

            var vParentUI : DisplayObjectContainer = _parentDisplayDetecting()
            if ( !vParentUI )
                return;

            if ( m_pComingUI ) {
                vParentUI.addChild( m_pComingUI );
            }
        }
    }

    private function _parentDisplayDetecting() : DisplayObjectContainer {
        var pLobbySys : CLobbySystem = system.stage.getSystem( CLobbySystem ) as CLobbySystem;
        if ( !pLobbySys )
            return null;

        var pLobbyViewHandler : CLobbyViewHandler = pLobbySys.getHandler( CLobbyViewHandler ) as CLobbyViewHandler;
        if ( !pLobbyViewHandler )
            return null;

        if ( !pLobbyViewHandler.pMainUI && m_bShow ) {
            callLater( _addDisplay );
            return null;
        }

        if ( pLobbyViewHandler.pMainUI ) {
            var pLeftContainer : DisplayObjectContainer = pLobbyViewHandler.pMainUI.getChildByName( 'left' ) as DisplayObjectContainer;
            if ( pLeftContainer ) {
                return pLeftContainer;
            }
        }

        return pLobbyViewHandler.pMainUI;
    }

    public function removeDisplay() : void {
        m_bShow = false;
        if ( m_pComingUI && m_pComingUI.parent ) {
            m_pComingUI.parent.removeChild( m_pComingUI );
        }
    }

    public function get slideOut() : Boolean {
        return m_bSlideOut;
    }

    public function set slideOut( value : Boolean ) : void {
        if ( m_bSlideOut == value )
            return;
        m_bSlideOut = value;
        this.invalidate();
    }

    /** @private */
    protected function slideDetail( value : Boolean ) : void {
        if ( !m_pDetailBox )
            return;

        m_pDetailBox.visible = value;
    }

}
}

// vim:ft=as3 tw=120 sw=4 ts=4 expandtab
