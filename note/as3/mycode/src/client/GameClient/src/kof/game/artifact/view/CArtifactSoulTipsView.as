//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2017/11/6.
 */
package kof.game.artifact.view {

import kof.game.artifact.*;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.game.artifact.data.CArtifactSoulData;
import kof.game.common.CLang;
import kof.table.ArtifactSoulInfo;
import kof.ui.demo.Currency.MoneyOneTipsUI;

import morn.core.components.TextArea;

public class CArtifactSoulTipsView {
    private var m_pTipsUI : MoneyOneTipsUI;
    public function CArtifactSoulTipsView() {
        m_pTipsUI = new MoneyOneTipsUI();

        var txtArea : TextArea = m_pTipsUI.getChildByName( "txtArea" ) as TextArea;
        if ( txtArea ) {
            txtArea.skin = null;
            txtArea.isHtml = true;
            txtArea.autoSize = "left";
        }
    }

    public function showTips( data:CArtifactSoulData, system:CArtifactSystem) : void {
        var artifactSoulInfoTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ARTIFACTSOULINFO);
        var soulInfo:ArtifactSoulInfo = (artifactSoulInfoTable.findByPrimaryKey(data.artifactSoulID) as ArtifactSoulInfo);
        var pTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.PASSIVE_SKILL_PRO);
        var txtArea : TextArea = m_pTipsUI.getChildByName( "txtArea" ) as TextArea;

        var obj:Object = {};
        obj.v1 = "<b>" + data.htmlName + "</b>";
        obj.v2 = data.getFighting(false);
        obj.v3 = pTable.findByPrimaryKey( soulInfo["propertyID"+(1)] ).name+"：+"+data.propertyValue[0];
        obj.v4 = pTable.findByPrimaryKey( soulInfo["propertyID"+(2)] ).name+"：+"+data.propertyValue[1];
        obj.v5 = pTable.findByPrimaryKey( soulInfo["propertyID"+(3)] ).name+"：+"+data.propertyValue[2];

        txtArea.text = CLang.Get( "tips_artifact_soul", obj);
        txtArea.height = txtArea.textField.textHeight + 40;
        m_pTipsUI.getChildByName( "bg" ).height = txtArea.height - 20;
        m_pTipsUI.getChildByName( "bg" ).width = txtArea.textField.textWidth + 40;
        App.tip.addChild( m_pTipsUI );
    }
}
}
