//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Tim.Wei 2018-05-31
//----------------------------------------------------------------------------------------------------------------------
package kof.game.artifact.view.suit {

import QFLib.Utils.HtmlUtil;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.artifact.CArtifactManager;
import kof.game.artifact.data.CArtifactData;
import kof.game.common.CLang;
import kof.table.ArtifactColour;
import kof.table.ArtifactSuit;
import kof.table.PassiveSkillPro;
import kof.ui.master.Artifact.ArtifactSuitUI;

import morn.core.components.Box;
import morn.core.components.Dialog;
import morn.core.components.Label;
import morn.core.handlers.Handler;

/**
 *@author tim
 *@create 2018-05-31 10:27
 **/
public class CArtifactSuitViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var _m_uiView:ArtifactSuitUI;
    private var _m_pDataSource:CArtifactData;
    public function CArtifactSuitViewHandler() {
        super();
    }

    override public function get viewClass() : Array {
        return [ ArtifactSuitUI ];
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {

            if (!_m_uiView) {
                _m_uiView = new ArtifactSuitUI();
                _m_uiView.uiList.renderHandler = new Handler(renderHandlerFun);
                _m_uiView.uiList.scrollBar = _m_uiView.scrollBar;
                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    private function renderHandlerFun(item:Box, idx:int) : void {
        if (!(item is Box) || item.dataSource == null) {
            return ;
        }
        var suitCfg:ArtifactSuit = item.dataSource  as ArtifactSuit;
        var mgr:CArtifactManager = system.getBean(CArtifactManager) as CArtifactManager;
        (item.getChildByName("uiLabelFighting" ) as Label).text = mgr.getSuitFighting(suitCfg.ID ).toString();
        var proCfg : PassiveSkillPro;
        var pTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.PASSIVE_SKILL_PRO);
        for (var i:int = 0; i < 3; i++) {
            proCfg = pTable.findByPrimaryKey( suitCfg.propertyID[i]);
            (item.getChildByName("uiLabelAttr"+i) as Label).text = proCfg.name;
            (item.getChildByName("uiLabelAttrValue"+i) as Label).text = suitCfg.propertyValue[i];
        }

        var colorCfg:ArtifactColour = mgr.getColorCfg(suitCfg.qualityID + 1);
        var colorName:String = HtmlUtil.color(colorCfg.qualityColour, colorCfg.colour.replace("0x", "#"));
        (item.getChildByName("uiLabelTitle") as Label).text = CLang.Get("artifact_suit_view_title", {colorName: colorName});
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
            uiCanvas.addPopupDialog( _m_uiView );
            update(_m_pDataSource);
        }
    }

    public function removeDisplay() : void {
        if ( _m_uiView ) {
            _m_uiView.close( Dialog.CLOSE );
            _m_uiView.remove();
        }
    }

    public function update(data:CArtifactData):void {
        _m_pDataSource = data;
        if (!m_bViewInitialized) {
            return;
        }
        var databaseSystem:CDatabaseSystem = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem)
        var table:IDataTable = databaseSystem.getTable(KOFTableConstants.ARTIFACTSUIT);
        var arr:Array = table.findByProperty("artifactID", data.artifactID);
        arr.sortOn("ID", Array.NUMERIC);
        _m_uiView.uiList.dataSource = arr;
    }
}
}
