//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/4/7.
 */
package kof.game.loading {

import kof.framework.CViewHandler;
import kof.ui.CUISystem;
import kof.ui.Loading.PVPLoadingViewUI;

import morn.core.handlers.Handler;

public class CPVPLoadingViewHandler extends CViewHandler {

    private var m_pUI : PVPLoadingViewUI;

    public function CPVPLoadingViewHandler() {
        super( true ); // load view by default to call onInitializeView
    }

    override public function dispose() : void {
        super.dispose();

        _removeDisplay();

        m_pUI = null;
    }

    /* private function loadAssets() : Boolean { */
    /* if ( !App.loader.getResLoaded( "frameclip_guochang.swf" ) ) { */
    /* App.loader.loadSWF( "frameclip_guochang.swf", new Handler( _onAssetsCompleted ), null, null, false ); */
    /* return false; */
    /* } */
    /* return true; */
    /* } */

    override public function get viewClass() : Array {
        return [ PVPLoadingViewUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        m_pUI = m_pUI || new PVPLoadingViewUI();
        return Boolean( m_pUI );
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();

        if ( ret ) {
            this._removeDisplay();
        }

        return ret;
    }

    override protected function updateData() : void {
        super.updateData();
    }

    override protected function updateDisplay() : void {
        super.updateDisplay();

        if ( !m_pUI ) {
            invalidateDisplay();
            return;
        }

        this._addDisplay();
    }

    public function show() : void {
        invalidateDisplay();
    }

    public function remove() : void {
        if ( m_pUI && m_pUI.parent ) {
            m_pUI.framClip_loading.playFromTo( null, null, new Handler( _removeDisplay ) );
        }
    }

    private function _addDisplay() : void {
        var pUISystem : CUISystem = system.stage.getSystem( CUISystem ) as CUISystem;
        if ( pUISystem && m_pUI.parent == null ) {
            m_pUI.framClip_loading.gotoAndStop( 0 );
            var width:int = pUISystem.stage.flashStage.stageWidth;
            var height:int = pUISystem.stage.flashStage.stageHeight;
//            if( width > 1500){
                m_pUI.box_loading.scaleX = width / 1500;
//            }
//            if( height > 900){
                m_pUI.box_loading.scaleY = height / 900;
//            }
            pUISystem.loadingLayer.addChild( m_pUI );
        }
    }

    private function _removeDisplay() : void {
        if ( m_pUI && m_pUI.parent )
            m_pUI.parent.removeChild( m_pUI );
    }
}
}
