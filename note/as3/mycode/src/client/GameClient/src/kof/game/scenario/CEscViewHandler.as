//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/8/25.
 */
package kof.game.scenario {

import QFLib.Framework.CPostEffects;

import flash.events.Event;
import flash.events.MouseEvent;

import kof.framework.CViewHandler;
import kof.ui.CUISystem;
import kof.ui.demo.ScenarioESCUI;

public class CEscViewHandler extends CViewHandler {

    private var m_bViewInitialized:Boolean;
    private var m_escUI:ScenarioESCUI;

    public function CEscViewHandler( ) {
        super( false );
    }
    override public function get viewClass() : Array {
        return [ ScenarioESCUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;
        if ( !m_bViewInitialized ) {
            this.initialize();
        }
        return m_bViewInitialized;
    }

    protected function initialize() : void {
        if ( !m_escUI ) {
            m_escUI = new ScenarioESCUI();
            m_escUI.addEventListener( Event.ADDED_TO_STAGE, _onAddStage );
            m_escUI.addEventListener( Event.REMOVED_FROM_STAGE, _onRemoveStage );

            m_escUI.addEventListener( MouseEvent.CLICK, _onClickHandler );

            m_bViewInitialized = true;
        }
    }

    public function showEscView():void{
        if(onInitializeView()){
            var uiSystem:CUISystem = (uiCanvas as CUISystem);
            uiSystem.loadingLayer.addChild(m_escUI);

            _onStageResize();
        }
    }

    public function hideEscView():void{
        if(m_escUI && m_escUI.parent){
            m_escUI.parent.removeChild(m_escUI);
        }
    }

    private function _onAddStage( e : Event ) : void {
        system.stage.flashStage.addEventListener( Event.RESIZE, _onStageResize, false, 0, true );
    }

    private function _onRemoveStage( e : Event ) : void {
        system.stage.flashStage.removeEventListener( Event.RESIZE, _onStageResize );
    }

    private function _onClickHandler( e : MouseEvent ) : void {
        var scenarioMgr:CScenarioManager = (system.getBean(CScenarioManager) as CScenarioManager);
        if (scenarioMgr) {
            if(!scenarioMgr.isEscEnable){
                scenarioMgr.stopAllPart();
                //对话结束停止模糊效果（ESC快捷键也会调用）
                CPostEffects.getInstance().stop(CPostEffects.Blur);
            }
        }
    }

    private function _onStageResize( e : Event = null ) : void {
        if(m_escUI){
            m_escUI.box.width = system.stage.flashStage.stageWidth;
            m_escUI.box.height = system.stage.flashStage.stageHeight;
            m_escUI.box.centerX = 0;
            m_escUI.box.centerY = 0;
            m_escUI.img_esc.right = 75;
            m_escUI.img_esc.top = 50;
        }
    }
}
}
