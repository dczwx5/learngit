//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/8/2.
 */
package kof.game.resourceInstance.view {

import kof.game.common.CLang;
import kof.ui.demo.Currency.MoneyOneTipsUI;

import morn.core.components.TextArea;

public class CResourceInstanceOpenLevelTipsView {
    private var m_pTipsUI : MoneyOneTipsUI;
    public function CResourceInstanceOpenLevelTipsView() {
        m_pTipsUI = new MoneyOneTipsUI();

        var txtArea : TextArea = m_pTipsUI.getChildByName( "txtArea" ) as TextArea;
        if ( txtArea ) {
            txtArea.skin = null;
            txtArea.isHtml = true;
            txtArea.autoSize = "left";
        }
    }

    public function showTips( isPassLevel:Boolean,openLevel:Boolean,level:int,index:int ) : void {
        var txtArea : TextArea = m_pTipsUI.getChildByName( "txtArea" ) as TextArea;
        var v2Color:String = isPassLevel ? "00ff00" : "ff0000";
        var v3Color:String = openLevel ? "00ff00" : "ff0000";
        var v4String:String = CLang.GOLD_INSTANCE_LEVEL_NAME[index];
        txtArea.text = CLang.Get( "tips_gold_instance_open", {v1:level,v2:v2Color,v3:v3Color,v4:v4String});
        txtArea.height = txtArea.textField.textHeight + 40;
        m_pTipsUI.getChildByName( "bg" ).height = txtArea.height - 20;
        m_pTipsUI.getChildByName( "bg" ).width = txtArea.width - 40;
        App.tip.addChild( m_pTipsUI );
    }
}
}
