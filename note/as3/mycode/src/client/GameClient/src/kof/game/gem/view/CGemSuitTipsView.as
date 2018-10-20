//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/27.
 */
package kof.game.gem.view {

import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.character.property.CBasePropertyData;
import kof.game.common.data.CAttributeBaseData;
import kof.game.common.tips.ITips;
import kof.game.gem.CGemHelpHandler;
import kof.game.gem.CGemManagerHandler;
import kof.game.gem.data.CGemConst;
import kof.game.gem.data.CGemData;
import kof.game.gem.data.CGemHoleData;
import kof.game.gem.data.CGemPageData;
import kof.game.player.data.CPlayerHeroData;
import kof.table.Gem;
import kof.table.Gem;
import kof.table.GemSuit;
import kof.ui.master.Gem.GemSuitInfoRenderUI;
import kof.ui.master.Gem.GemSuitTipsViewUI;
import kof.ui.master.jueseNew.HeroDetailInfoTipsUI;

import morn.core.components.Component;
import morn.core.components.Label;

public class CGemSuitTipsView extends CViewHandler implements ITips{

    private var m_pViewUI:GemSuitTipsViewUI;
    private var m_pTipsObj:Component;
    private var m_iPageType:int;

    private var m_pPropertyData:CBasePropertyData;

    public function CGemSuitTipsView()
    {
    }

    override public function get viewClass() : Array
    {
        return [ GemSuitTipsViewUI ];
    }

    public function addTips(component:Component, args:Array = null):void
    {
        if ( m_pViewUI == null )
        {
            m_pViewUI = new GemSuitTipsViewUI();
        }

        m_pTipsObj = component;

        if(args && args.length)
        {
            m_iPageType = args[0] as int;
        }

        _clear();

        var suitInfo:SuitInfo;
        var view:GemSuitInfoRenderUI;
        if(_haveNotAnySuit())// 第一级的
        {
            m_pViewUI.img_notActive.visible = true;
            m_pViewUI.view_notActiveSuit.visible = true;
            view = m_pViewUI.view_notActiveSuit;
            suitInfo = _getSuitInfoByLevel(0);

            if(suitInfo)
            {
                view.txt_targetInfo.text = "全部镶嵌"+suitInfo.suitLevel+"级宝石";
                view.txt_processInfo.text = "（"+suitInfo.currNum+"/"+CGemConst.MaxHoleNum+"）";
                view.txt_processInfo.color = 0xe8210d;
                view.txt_state.text = "未达成";
                view.txt_state.color = 0xe8210d;
                view.txt_combatLabel.color = 0x8098b9;
                view.txt_combat.text = suitInfo.combat.toString();
                view.txt_combat.color = 0xe8210d;

                _clearAttr(view);
                for(var i:int = 0; i < suitInfo.attrDatas.length; i++)
                {
                    var attrData:CAttributeBaseData = suitInfo.attrDatas[i];
                    var attrName:Label = view["txt_attrName"+(i+1) ] as Label;
                    var attrValue:Label = view["txt_attrValue"+(i+1) ] as Label;
                    attrName.visible = true;
                    attrName.text = attrData.attrNameCN;
                    attrName.color = 0x8098b9;
                    attrValue.visible = true;
                    attrValue.color = 0xe8210d;
                    attrValue.text = attrData.attrBaseValue.toString();
                }
            }

            m_pViewUI.txt_clickToLook.y = m_pViewUI.view_notActiveSuit.y + m_pViewUI.view_notActiveSuit.height + 3;
        }
        else if(_isReachMaxSuit())// 最高级的
        {
            m_pViewUI.view_max.visible = true;
            m_pViewUI.img_maxLevel.visible = true;
            view = m_pViewUI.view_max;
            suitInfo = _getSuitInfoByLevel(_helper.getSuitLevelByPage(m_iPageType));

            if(suitInfo)
            {
                view.txt_targetInfo.text = "全部镶嵌"+suitInfo.suitLevel+"级宝石";
                view.txt_processInfo.text = "（"+suitInfo.currNum+"/"+CGemConst.MaxHoleNum+"）";
                view.txt_processInfo.color = 0x70e324;
                view.txt_state.text = "已激活";
                view.txt_state.color = 0x70e324;
                view.txt_combatLabel.color = 0xffd940;
                view.txt_combat.text = suitInfo.combat.toString();
                view.txt_combat.color = 0xf0ecec;

                _clearAttr(view);
                for(i = 0; i < suitInfo.attrDatas.length; i++)
                {
                    attrData = suitInfo.attrDatas[i];
                    attrName = view["txt_attrName"+(i+1) ] as Label;
                    attrValue = view["txt_attrValue"+(i+1) ] as Label;
                    attrName.visible = true;
                    attrName.text = attrData.attrNameCN;
                    attrName.color = 0xbfdeed;
                    attrValue.visible = true;
                    attrValue.color = 0x70e324;
                    attrValue.text = attrData.attrBaseValue.toString();
                }
            }

            m_pViewUI.txt_clickToLook.y = m_pViewUI.img_maxLevel.y + m_pViewUI.img_maxLevel.height + 3;
        }
        else// 当前的和下一级的
        {
            m_pViewUI.view_currSuit.visible = true;
            view = m_pViewUI.view_currSuit;
            var currSuitLevel:int = _helper.getSuitLevelByPage(m_iPageType);
            suitInfo = _getSuitInfoByLevel(currSuitLevel);

            if(suitInfo)
            {
                view.txt_targetInfo.text = "全部镶嵌"+suitInfo.suitLevel+"级宝石";
                view.txt_processInfo.text = "（"+suitInfo.currNum+"/"+CGemConst.MaxHoleNum+"）";
                view.txt_processInfo.color = 0x70e324;
                view.txt_state.text = "已激活";
                view.txt_state.color = 0x70e324;
                view.txt_combatLabel.color = 0xffd940;
                view.txt_combat.text = suitInfo.combat.toString();
                view.txt_combat.color = 0xf0ecec;

                _clearAttr(view);
                for(i = 0; i < suitInfo.attrDatas.length; i++)
                {
                    attrData = suitInfo.attrDatas[i];
                    attrName = view["txt_attrName"+(i+1) ] as Label;
                    attrValue = view["txt_attrValue"+(i+1) ] as Label;
                    attrName.visible = true;
                    attrName.text = attrData.attrNameCN;
                    attrName.color = 0xbfdeed;
                    attrValue.visible = true;
                    attrValue.color = 0x70e324;
                    attrValue.text = attrData.attrBaseValue.toString();
                }
            }

            m_pViewUI.view_nextSuit.visible = true;
            view = m_pViewUI.view_nextSuit;
            suitInfo = _getSuitInfoByLevel(currSuitLevel+1);

            if(suitInfo)
            {
                view.txt_targetInfo.text = "全部镶嵌"+suitInfo.suitLevel+"级宝石";
                view.txt_processInfo.text = "（"+suitInfo.currNum+"/"+CGemConst.MaxHoleNum+"）";
                view.txt_processInfo.color = 0xe8210d;
                view.txt_state.text = "未达成";
                view.txt_state.color = 0xe8210d;
                view.txt_combatLabel.color = 0x8098b9;
                view.txt_combat.text = suitInfo.combat.toString();
                view.txt_combat.color = 0xe8210d;

                _clearAttr(view);
                for(i = 0; i < suitInfo.attrDatas.length; i++)
                {
                    attrData = suitInfo.attrDatas[i];
                    attrName = view["txt_attrName"+(i+1) ] as Label;
                    attrValue = view["txt_attrValue"+(i+1) ] as Label;
                    attrName.visible = true;
                    attrName.text = attrData.attrNameCN;
                    attrName.color = 0x8098b9;
                    attrValue.visible = true;
                    attrValue.color = 0xe8210d;
                    attrValue.text = attrData.attrBaseValue.toString();
                }
            }

            m_pViewUI.txt_clickToLook.y = m_pViewUI.view_nextSuit.y + m_pViewUI.view_nextSuit.height + 3;
        }

        m_pViewUI.img_bg.height = m_pViewUI.txt_clickToLook.y + m_pViewUI.txt_clickToLook.height + 10;
        App.tip.addChild(m_pViewUI);
    }

    /**
     * 尚未达成任何套装
     * @return
     */
    private function _haveNotAnySuit():Boolean
    {
        var suitLevel:int = _helper.getSuitLevelByPage(m_iPageType);
        return suitLevel == 0;
    }

    /**
     * 是否达到顶级套装
     * @return
     */
    private function _isReachMaxSuit():Boolean
    {
        var maxSuitLevel:int = _getMaxSuitLevel();
        var count:int = 0;
        if(_gemData && _gemData.pageListData)
        {
            var pageData:CGemPageData = _gemData.pageListData.getDataByPage(m_iPageType);
            if(pageData)
            {
                var arr:Array = pageData.gemHoleListData.list;
                for each(var holeData:CGemHoleData in arr)
                {
                    if(holeData.gemConfigID)
                    {
                        var gem:Gem = _gemTable.findByPrimaryKey(holeData.gemConfigID) as Gem;
                        var level:int = gem == null ? 0 : gem.level;
                        if(level >= maxSuitLevel)
                        {
                            count++;
                        }
                    }
                }
            }
        }

        if(count >= CGemConst.MaxHoleNum)
        {
            return true;
        }

        return false;
    }

    private function _getMaxSuitLevel():int
    {
        var arr:Array = _gemSuit.findByProperty("pageID", m_iPageType);
        if(arr && arr.length)
        {
            return (arr[arr.length-1] as GemSuit).suitLevel;
        }

        return 0;
    }

    /**
     * 套装信息，若果没有就默认第一套
     * @return
     */
    private function _getSuitInfoByLevel(suitLevel:int):SuitInfo
    {
        var suitInfo:SuitInfo = new SuitInfo();
        if(suitLevel)
        {
            suitInfo.suitLevel = suitLevel;
            suitInfo.currNum = _helper.getCurrNumBySuitLevel(m_iPageType, suitLevel);
            suitInfo.attrDatas = _helper.getSuitAttrByPageAndLevel(m_iPageType, suitLevel);
            suitInfo.combat = _calculateCombat(suitInfo.attrDatas);
        }
        else
        {
            var firstSuitLevel:int = _getFirstSuitLevel();
            suitInfo.suitLevel = firstSuitLevel;
            suitInfo.currNum = _helper.getCurrNumBySuitLevel(m_iPageType, firstSuitLevel);
            suitInfo.attrDatas = _helper.getSuitAttrByPageAndLevel(m_iPageType, firstSuitLevel);
            suitInfo.combat = _calculateCombat(suitInfo.attrDatas);
        }

        return suitInfo;
    }

    private function _getFirstSuitLevel():int
    {
        var arr:Array = _gemSuit.toArray();
        if(arr && arr.length)
        {
            return (arr[0] as GemSuit).suitLevel;
        }

        return 1;
    }

    private function _calculateCombat(attrs:Array):int
    {
        if(m_pPropertyData == null)
        {
            m_pPropertyData = new CBasePropertyData();
            m_pPropertyData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
        }

        m_pPropertyData.clearData();

        for each(var attrData:CAttributeBaseData in attrs)
        {
            if(attrData)
            {
                var obj:Object = {};
                obj[attrData.attrNameEN] = attrData.attrBaseValue;
                m_pPropertyData.updateDataByData(obj);
            }
        }

        return m_pPropertyData.getBattleValue();
    }

    private function _clear():void
    {
        m_pViewUI.img_maxLevel.visible = false;
        m_pViewUI.img_notActive.visible = false;
        m_pViewUI.view_max.visible = false;
        m_pViewUI.view_currSuit.visible = false;
        m_pViewUI.view_nextSuit.visible = false;
        m_pViewUI.view_notActiveSuit.visible = false;
    }

    private function _clearAttr(view:GemSuitInfoRenderUI):void
    {
        for(var i:int = 1; i <= 4; i++)
        {
            view["txt_attrName"+i ].visible = false;
            view["txt_attrValue"+i ].visible = false;
        }
    }

    public function hideTips():void
    {
        if(m_pViewUI)
        {
            m_pViewUI.remove();
        }
    }

    private function get _gemData():CGemData
    {
        return (system.getHandler(CGemManagerHandler) as CGemManagerHandler).gemData;
    }

    private function get _helper():CGemHelpHandler
    {
        return system.getHandler(CGemHelpHandler) as CGemHelpHandler;
    }

//table=================================================================================================================
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _gemSuit():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.GemSuit);
    }

    private function get _gemTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.Gem);
    }
}
}

class SuitInfo
{
    public var suitLevel:int;
    public var currNum:int;
    public var attrDatas:Array;
    public var combat:int;
}
