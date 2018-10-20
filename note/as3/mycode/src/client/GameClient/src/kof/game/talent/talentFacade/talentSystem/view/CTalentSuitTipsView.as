//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/14.
 */
package kof.game.talent.talentFacade.talentSystem.view {

import QFLib.Utils.HtmlUtil;

import kof.framework.CAppSystem;
import kof.framework.IDatabase;
import kof.game.common.data.CAttributeBaseData;
import kof.game.talent.talentFacade.CTalentFacade;
import kof.game.talent.talentFacade.CTalentHelpHandler;
import kof.game.talent.talentFacade.talentSystem.mediator.CAbstractTalentMediator;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentEmbedInfo;
import kof.table.TalentSoulSuit;
import kof.ui.demo.talentSys.TalentLVTipsUI;

import morn.core.components.Component;
import morn.core.components.Label;
import morn.core.handlers.Handler;

public class CTalentSuitTipsView extends CAbstractTalentView {

    private var _tipsUI : TalentLVTipsUI = null;

    public function CTalentSuitTipsView( mediator : CAbstractTalentMediator )
    {
        super( mediator );
        _mediator = mediator;
        _tipsUI = new TalentLVTipsUI();
    }

    override public function show( data : Object = null ) : void
    {
//        Foundation.Log.logErrorMsg( "TalentTips类型非法：" + data.data.talentTipsViewType );

        _tipsUI.txt_currInfo.text = "";
        _tipsUI.txt_nextInfo.text = "";
        _tipsUI.list_curr.dataSource = [];
        _tipsUI.list_next.dataSource = [];

        var suitArr:Array = _helper.getTipsSuitInfo(CTalentFacade.getInstance().currentPageType);
        if(suitArr)
        {
            var suitInfo:TalentSoulSuit;
            var embedInfo:CTalentEmbedInfo;
            if(suitArr.length >= 1)
            {
                suitInfo = suitArr[0] as TalentSoulSuit;
                embedInfo = _helper.getEmbedInfo(CTalentFacade.getInstance().currentPageType, suitInfo.soulLevel);
                _tipsUI.txt_currInfo.isHtml = true;
                var level:String = suitInfo.suitLevel+"级";
                _tipsUI.txt_currInfo.text = "<font color='#f7d343'><b>" + level + "</b></font>"
                    + HtmlUtil.color("套装【镶嵌", "#edf3d1")
                    + HtmlUtil.color(suitInfo.soulNum + "", "#f7d343")
                    + HtmlUtil.color("颗", "#edf3d1")
                    + HtmlUtil.color(suitInfo.soulLevel + "级", "#f7d343")
                    + HtmlUtil.color("斗魂可加成】 ", "#edf3d1");

                if(embedInfo)
                {
                    if(embedInfo.totalNum >= suitInfo.soulNum)
                    {
                        _tipsUI.txt_currInfo.text += HtmlUtil.color("("+suitInfo.soulNum+"/"+suitInfo.soulNum+")", "#d1fe");
                    }
                    else
                    {
                        _tipsUI.txt_currInfo.text += HtmlUtil.color("("+embedInfo.totalNum+"/"+suitInfo.soulNum+")", "#ff0000");
                    }
                }

                if(_tipsUI.list_curr.renderHandler == null)
                {
                    _tipsUI.list_curr.renderHandler = new Handler(_renderAttrHandler);
                }

                _tipsUI.list_curr.dataSource = _helper.getSuitAttrInfo(suitInfo);
            }

            if(suitArr.length >= 2)
            {
                suitInfo = suitArr[1] as TalentSoulSuit;
                embedInfo = _helper.getEmbedInfo(CTalentFacade.getInstance().currentPageType, suitInfo.soulLevel);
                _tipsUI.txt_nextInfo.isHtml = true;
                level = suitInfo.suitLevel+"级";
                _tipsUI.txt_nextInfo.text = "<font color='#f7d343'><b>" + level + "</b></font>"
                        + HtmlUtil.color("套装【镶嵌", "#edf3d1")
                        + HtmlUtil.color(suitInfo.soulNum + "", "#f7d343")
                        + HtmlUtil.color("颗", "#edf3d1")
                        + HtmlUtil.color(suitInfo.soulLevel + "级", "#f7d343")
                        + HtmlUtil.color("斗魂可加成】 ", "#edf3d1");

                if(embedInfo)
                {
                    if(embedInfo.totalNum >= suitInfo.soulNum)
                    {
                        _tipsUI.txt_nextInfo.text += HtmlUtil.color("("+suitInfo.soulNum+"/"+suitInfo.soulNum+")", "#d1fe");
                    }
                    else
                    {
                        _tipsUI.txt_nextInfo.text += HtmlUtil.color("("+embedInfo.totalNum+"/"+suitInfo.soulNum+")", "#ff0000");
                    }
                }

                if(_tipsUI.list_next.renderHandler == null)
                {
                    _tipsUI.list_next.renderHandler = new Handler(_renderAttrHandler);
                }

                _tipsUI.list_next.dataSource = _helper.getSuitAttrInfo(suitInfo);
            }
        }

        App.tip.addChild( _tipsUI );
    }

    private function _renderAttrHandler(item:Component, index:int):void
    {
        var attrName:Label = item.getChildByName("attrName") as Label;
        var attrValue:Label = item.getChildByName("attrValue") as Label;
        var attrData:CAttributeBaseData = item.dataSource as CAttributeBaseData;

        if(attrData)
        {
            attrName.text = attrData.getAttrNameCN();
            attrValue.text = "+" + attrData.attrBaseValue;
        }
        else
        {
            attrName.text = "";
            attrValue.text = "";
        }
    }

    override public function close() : void
    {
        if(_tipsUI.parent)
        {
            _tipsUI.parent.removeChild(_tipsUI);
        }
    }

    override public function update() : void
    {

    }

    private function get _system():CAppSystem
    {
        return CTalentFacade.getInstance().talentAppSystem;
    }

    private function get _dataBase():IDatabase
    {
        return _system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _helper():CTalentHelpHandler
    {
        return _system.getHandler(CTalentHelpHandler) as CTalentHelpHandler;
    }
}
}
