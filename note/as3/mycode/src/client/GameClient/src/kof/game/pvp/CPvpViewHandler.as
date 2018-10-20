//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/10/19.
 */
package kof.game.pvp {

import flash.events.MouseEvent;

import kof.framework.CViewHandler;
import kof.ui.demo.PVP.PvpModeItemUI;
import kof.ui.demo.PVP.PvpModeUI;

import morn.core.components.Component;
import morn.core.components.Dialog;

import morn.core.components.Image;

import morn.core.events.UIEvent;

import morn.core.handlers.Handler;

import spine.Event;
import spine.Skin;

public class CPvpViewHandler extends CViewHandler {

    private var _pvpModeUI:PvpModeUI;

    private var m_pCloseHandler : Handler;
    private var m_bViewInitialized : Boolean;

    public function CPvpViewHandler() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
        // TODO: DISPOSE UI resources.
//        detachEventListeners();

        _pvpModeUI = null;
    }

//    override protected function onSetup():Boolean {
//        var ret : Boolean = super.onSetup();
//        ret = ret && this.loadAssets();
//        return ret;
//    }

//    private function loadAssets() : Boolean {
//        if (    !App.loader.getResLoaded( "pvp.swf" )
//        ) {
//            App.loader.loadAssets( [
//                        "pvp.swf"
//                    ],
//                    new Handler( _onAssetsCompleted ), null, null, true );
//            return false;
//        }
//        return true;
//    }

//    private function _onAssetsCompleted( ... args ) : void {
//        LOG.logTraceMsg( "load completed..." );
//        this.makeStarted();
//        this.initialize();
//    }
//    protected function initialize() : void {
//        if (!_pvpModeUI) {
//            _pvpModeUI = new PvpModeUI();
//            _pvpModeUI.closeHandler = new Handler( _onClose )
//        }
//    }

    private function _addEventListeners():void {
//        _pvpModeUI.btn_close.addEventListener(MouseEvent.CLICK ,hide , false , 0, true );
        _pvpModeUI.list.addEventListener(MouseEvent.CLICK, listClickFun, false, 0, true);
    }
    private function _removeEventListeners():void {
        if(_pvpModeUI){
//            _pvpModeUI.btn_close.removeEventListener(MouseEvent.CLICK , hide );
            _pvpModeUI.list.removeEventListener(MouseEvent.CLICK, listClickFun);
        }
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if ( !_pvpModeUI ) {
                _pvpModeUI = new PvpModeUI();

                _pvpModeUI.closeHandler = new Handler( _onClose );
                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void {
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

    override public function get viewClass() : Array {
        return [ PvpModeUI ];
    }

    private function _addToDisplay() : void {
        if ( _pvpModeUI ){
            uiCanvas.addDialog( _pvpModeUI );
            _addEventListeners();
            _pvpModeUI.list.renderHandler = new Handler(updateListIcon);
            _pvpModeUI.list.dataSource = ["0","1","2"];
        }
    }

    public function removeDisplay() : void {
        if ( _pvpModeUI ) {
            _pvpModeUI.close( Dialog.CLOSE );
            _removeEventListeners();
            _pvpModeUI.remove();
        }
    }

    private function listClickFun(e:MouseEvent):void{
        this.dispatchEvent(new CPvpEvent(CPvpEvent.QUERY_ROOM,{selectedIndex:_pvpModeUI.list.selectedIndex}));
        removeDisplay();
    }

    private function updateListIcon(item:Component, idx:int):void{
        if(!(item is PvpModeItemUI))
        {
            return;
        }
        if(item.dataSource)
        {
            (item as PvpModeItemUI)["icon_bg_"+idx ].visible = true;
        }
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
    }
}
}
