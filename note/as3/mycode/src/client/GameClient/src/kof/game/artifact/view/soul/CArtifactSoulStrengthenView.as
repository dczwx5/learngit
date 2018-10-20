//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Tim.Wei 2018-05-26
//----------------------------------------------------------------------------------------------------------------------
package kof.game.artifact.view.soul {

import flash.events.Event;

import kof.framework.CViewHandler;
import kof.game.artifact.CArtifactEvent;
import kof.game.artifact.CArtifactManager;
import kof.game.artifact.data.CArtifactSoulData;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.common.view.CTweenViewHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.ui.master.Artifact.ArtifactStrengthenUI;

import morn.core.components.Dialog;

/**
 * 神灵强化窗口，包括洗炼、突破
 *@author tim
 *@create 2018-05-26 11:46
 **/
public class CArtifactSoulStrengthenView extends CTweenViewHandler{
    private var _m_data:CArtifactSoulData;
    private var _m_uiView:ArtifactStrengthenUI;
    private var _m_bViewInitialized : Boolean;
    private var _m_pPurifyPanel:CArtifactSoulPurifyPanel;//洗炼面板
    private var _m_pBreachPanel:CArtifactSoulBreachPanel;//突破面板

    public function CArtifactSoulStrengthenView() {
        super();
    }
    override public function get viewClass() : Array {
        return [ ArtifactStrengthenUI ];
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !_m_bViewInitialized ) {

            if (!_m_uiView) {
                _m_uiView = new ArtifactStrengthenUI();
                _m_bViewInitialized = true;
                _m_pPurifyPanel = new CArtifactSoulPurifyPanel(system, _m_uiView.uiViewPurity,this);
                _m_pBreachPanel = new CArtifactSoulBreachPanel(system, _m_uiView.uiViewBreach);
            }
        }

        return _m_bViewInitialized;
    }

    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    protected function addToDisplay() : void {
        if ( _m_uiView ){
//            uiCanvas.addPopupDialog( _m_uiView );
            showDialog(_m_uiView, false);
            _addEventListeners();
            updateView();
        }
    }

    public function removeDisplay() : void {
        if ( _m_uiView ) {
            _m_uiView.close( Dialog.CLOSE );
            _removeEventListeners();
            _m_uiView.remove();
        }
    }

    private function _addEventListeners():void {
        system.addEventListener(CArtifactEvent.ARTIFACTUPDATE, artifactUpdateFun);
        _m_pPurifyPanel.addEventListeners();
        _m_pBreachPanel.addEventListeners();
        (system.stage.getSystem(CBagSystem) as CBagSystem).listenEvent(_onBagItemsChangeHandler);
        (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).addEventListener(CPlayerEvent.PLAYER_ARTIFACT,_onPlayerDataHandler);

    }

    private function _removeEventListeners():void {
        system.removeEventListener(CArtifactEvent.ARTIFACTUPDATE, artifactUpdateFun);
        _m_pPurifyPanel.removeEventListeners();
        _m_pBreachPanel.removeEventListeners();
        (system.stage.getSystem(CBagSystem) as CBagSystem).unListenEvent(_onBagItemsChangeHandler);
        (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).removeEventListener(CPlayerEvent.PLAYER_ARTIFACT,_onPlayerDataHandler);
    }

    private function _onBagItemsChangeHandler(e:CBagEvent):void{
        if ( e.type == CBagEvent.BAG_UPDATE ) {
            updateView();
        }
    }

    private function _onPlayerDataHandler(e:CPlayerEvent):void{
        if ( e.type == CPlayerEvent.PLAYER_ARTIFACT ) {
            updateView();
        }
    }


    private function artifactUpdateFun(e:Event):void{
        _m_data = (system.getHandler(CArtifactManager) as CArtifactManager).getSoulData(_m_data.artifactID,_m_data.artifactSoulID);
        updateView();
    }

    public function update(data:CArtifactSoulData):void{
        _m_data = data;
    }

    private function updateView():void {
        _m_pPurifyPanel.update(_m_data);
        _m_pBreachPanel.update(_m_data);
        //显示名字
        _m_uiView.uiLabelName.text = _m_data.htmlName;
        _m_uiView.uiLabelName.stroke = _m_data.colorCfg.traceside;
    }
}
}
