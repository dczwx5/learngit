//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/6/1.
 */
package kof.game.loading {

import kof.framework.CViewHandler;
import kof.ui.CUISystem;
import kof.ui.Loading.ScenarioLoadingViewUI;

import morn.core.handlers.Handler;

public class CScenarioLoadingViewHandler extends CViewHandler {

    private var m_pUI : ScenarioLoadingViewUI;
    private var _downTime:int = 0;
    private var _callStartFun:Function;
    private var _callBackFun:Function;

    public function CScenarioLoadingViewHandler() {
        super( true );
    }

    override public function dispose() : void {
        super.dispose();

        m_pUI = null;
    }

    override public function get viewClass() : Array {
        return [ ScenarioLoadingViewUI ];
    }

    public function playStartAnimation( callBackFun:Function = null ):void{

        _callStartFun = callBackFun;

        var pUISystem : CUISystem = system.stage.getSystem( CUISystem ) as CUISystem;
        if ( pUISystem && m_pUI.parent == null ) {
            m_pUI.framClip_loading.x = 0;
            m_pUI.framClip_loading.y = 0;

            m_pUI.framClip_loading.skin = "frameclip_guochang02";
            m_pUI.framClip_loading.playFromTo(null,null,new Handler(_onPlayStartComplete));

            var width:int = pUISystem.stage.flashStage.stageWidth;
            var height:int = pUISystem.stage.flashStage.stageHeight;
//            if( width > 1500){
                m_pUI.box_loading.scaleX = width / 1500;
//            }
//            if( height > 900){
                m_pUI.box_loading.scaleY = height / 900;
//            }

            pUISystem.loadingLayer.addChildAt( m_pUI, 0 );
        }
    }

    public function playEndAnimation( callBackFun:Function = null ):void{

        _callBackFun = callBackFun;

        var pUISystem : CUISystem = system.stage.getSystem( CUISystem ) as CUISystem;
        if ( pUISystem && m_pUI.parent ) {
            m_pUI.framClip_loading.x = 0;
            m_pUI.framClip_loading.y = 0;

            m_pUI.framClip_loading.gotoAndStop(0);
            m_pUI.framClip_loading.skin = "frameclip_guochang01";
            m_pUI.framClip_loading.playFromTo(null,null,new Handler(_onPlayComplete));

            var width:int = pUISystem.stage.flashStage.stageWidth;
            var height:int = pUISystem.stage.flashStage.stageHeight;
//            if( width > 1500){
                m_pUI.box_loading.scaleX = width / 1500;
//            }
//            if( height > 900){
                m_pUI.box_loading.scaleY = height / 900;
//            }
        }
    }

    public function remove() : void {
        if(m_pUI){
            _removeDisplay();
        }
    }

    /* private function loadAssets() : Boolean { */
        /* if (!App.loader.getResLoaded( "frameclip_scenario_start.swf" )) { */
            /* App.loader.loadAssets([ "frameclip_scenario_start.swf"], new Handler( _onAssetsCompleted ), null, null, false ); */
            /* return false; */
        /* } */
        /* return true; */
    /* } */

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        m_pUI = m_pUI || new ScenarioLoadingViewUI();
//        m_pUI.framClip_loading.interval = 60;
        return Boolean( m_pUI );
    }

    override protected function updateData() : void {
        super.updateData();
    }

    private function _onPlayStartComplete():void{
        if(_callStartFun){
            _callStartFun.apply();
        }
    }

    private function _onPlayComplete():void {
        _removeDisplay();
    }

    private function _removeDisplay() : void {
        if ( m_pUI && m_pUI.parent )
        {
            m_pUI.parent.removeChild( m_pUI );
            if(_callBackFun){
                _callBackFun.apply();
            }
        }

    }

}
}
