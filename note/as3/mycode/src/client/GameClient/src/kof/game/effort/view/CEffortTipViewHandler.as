//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Leo.Li 2018/5/31
//----------------------------------------------------------------------------------------------------------------------
package kof.game.effort.view {

import kof.framework.CViewHandler;
import kof.game.character.property.CBasePropertyData;
import kof.game.common.tips.ITips;
import kof.game.common.view.CTweenViewHandler;
import kof.ui.master.arena.ArenaRoleEmbattleTipsUI;
import kof.ui.master.effortHall.EffortAttrItemUI;
import kof.ui.master.effortHall.EffortTotalRewardTipsUI;

import morn.core.components.Box;

import morn.core.components.Component;
import morn.core.handlers.Handler;

/**
 * @author Leo.Li
 * @date 2018/5/31
 */
public class CEffortTipViewHandler extends CViewHandler implements ITips {

    private var _m_pViewUI:EffortTotalRewardTipsUI;

    public function CEffortTipViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    public function addTips(box:Component, args:Array = null):void
    {
        if ( !_m_pViewUI ) _m_pViewUI = new EffortTotalRewardTipsUI();

        var currentProperty:CBasePropertyData = args[0];
        var currentNum:int = args[1];
        var nextProperty:CBasePropertyData = args[2];
        var nextNum:int = args[3];
        var max:int = currentNum > nextNum ? currentNum:nextNum;

        _m_pViewUI.kofNum0.num = currentProperty.getBattleValue();
        _m_pViewUI.kofNum1.num = nextProperty.getBattleValue();

        _m_pViewUI.attrs_box0.list_attrs.repeatY = currentNum;
        _m_pViewUI.attrs_box1.list_attrs.repeatY = nextNum;

        var index:int;
        currentProperty.data.loop(
                function _inner(key:String,val:int):void
                {
                    (_m_pViewUI.attrs_box0.list_attrs.getCell(index) as EffortAttrItemUI).txt_attrDesc.text = currentProperty.getAttrNameCN(key);
                    (_m_pViewUI.attrs_box0.list_attrs.getCell(index) as EffortAttrItemUI).txt_attrLabel.text = "+"+val.toString();
                    (_m_pViewUI.attrs_box0.list_attrs.getCell(index) as EffortAttrItemUI).txt_attrAddLabel.visible = false;
                    index++;
                }
        );
        index = 0;
        nextProperty.data.loop(
                function _inner1(key:String,val:int):void
                {
                    (_m_pViewUI.attrs_box1.list_attrs.getCell(index) as EffortAttrItemUI).txt_attrDesc.text = currentProperty.getAttrNameCN(key);
                    (_m_pViewUI.attrs_box1.list_attrs.getCell(index) as EffortAttrItemUI).txt_attrLabel.text = "+"+val.toString();
                    (_m_pViewUI.attrs_box1.list_attrs.getCell(index) as EffortAttrItemUI).txt_attrAddLabel.text = "("+(val - currentProperty.data.find(key)).toString()+")";
                    index++;
                }
        );

        _m_pViewUI.img_bg.height = 132 + (max * 20)

        //1行 高度 144，一行 20

        App.tip.addChild(_m_pViewUI);
    }

    public function hideTips():void
    {
        if(_m_pViewUI)
        {
            _m_pViewUI.remove();
        }
    }

}
}
