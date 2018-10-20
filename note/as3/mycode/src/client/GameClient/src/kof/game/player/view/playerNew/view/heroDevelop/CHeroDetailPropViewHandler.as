//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/1/3.
 */
package kof.game.player.view.playerNew.view.heroDevelop {

import com.greensock.TweenMax;

import flash.display.DisplayObjectContainer;

import kof.data.KOFTableConstants;

import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.character.property.CBasePropertyData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.common.data.CAttributeBaseData;
import kof.game.player.view.playerNew.util.CPlayerHelpHandler;
import kof.table.PassiveSkillPro;
import kof.ui.master.jueseNew.HeroDetailPropsUI;
import kof.ui.master.jueseNew.render.HeroDetailPropRenderUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;

public class CHeroDetailPropViewHandler extends CViewHandler {

    private var m_pViewUI : Component;

    private var m_pData:CPlayerHeroData;
    private var m_pPropData:CBasePropertyData;
    private var m_pParent:DisplayObjectContainer;

    private var m_arrAttrs:Array = ["CritChance","DefendCritChance","BlockHurtChance","RollerBlockChance","CritHurtChance",
                                "CritDefendChance","HurtAddChance","HurtReduceChance"];

    private var m_arrAttrs2:Array = ["AtkJobHurtAddChance","AtkJobHurtReduceChance","DefJobHurtAddChance","DefJobHurtReduceChance",
                                "TechJobHurtAddChance", "TechJobHurtReduceChance"];

    public function CHeroDetailPropViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    public function initializeView():void
    {
        _viewUI.list_baseAttr.renderHandler = new Handler(_renderAttr);
        _viewUI.list_extraAttr.renderHandler = new Handler(_renderAttr);
//        _viewUI.list_careerAttr.renderHandler = new Handler(_renderAttr);

        _viewUI.list_baseAttr.mask = _viewUI.img_baseMask;
        _viewUI.list_extraAttr.mask = _viewUI.img_extraMask;
//        _viewUI.list_careerAttr.mask = _viewUI.img_careerMask;
        _viewUI.mask = _viewUI.img_mask;
    }

    public function addDisplay() : void
    {
//        this.loadAssetsByView( viewClass, _showDisplay );

        _addToDisplay();
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
//            invalidate();
            callLater( _addToDisplay );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void
    {
        _viewUI.popupCenter = false;

        if(m_pParent)
        {
            m_pParent.addChild(m_pViewUI);
            m_pViewUI.x = 44-97+58;
            m_pViewUI.y = 30;
        }

        if(TweenMax.isTweening(_viewUI.img_mask))
        {
            TweenMax.killTweensOf(_viewUI.img_mask);
        }

        TweenMax.fromTo(_viewUI.img_mask, 0.5, {x:350, y:0, scale:0}, {x:0, y:0, scale:1});

        _initView();
        _addListeners();
    }

    private function _addListeners():void
    {
    }

    private function _removeListeners():void
    {
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            _updateBaseProps();
            _updateExtraProps();
            _updateCareerProps();
        }
    }

    /**
     * 基础属性
     */
    private function _updateBaseProps():void
    {
        if(m_pData)
        {
            var arr:Array = _playerHelper.getHeroDevelopAttrData(m_pData);
            _viewUI.list_baseAttr.dataSource = arr;
        }
        else
        {
            _viewUI.list_baseAttr.dataSource = [];
        }
    }

    /**
     * 附加属性
     */
    private function _updateExtraProps():void
    {
        var arr:Array = [];
        if(m_pPropData == null)
        {
            m_pPropData = new CBasePropertyData();
            m_pPropData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
        }

        if(m_pData)
        {
            for each(var attrName:String in m_arrAttrs)
            {
                var attrData:CAttributeBaseData = new CAttributeBaseData();
                attrData.attrBaseValue = m_pData.propertyData[attrName] as int;
                attrData.attrNameCN = m_pData.propertyData.getAttrNameCN(attrName);
                attrData.attrNameEN = attrName;
                attrData.type = 1;

                arr.push(attrData);
            }
        }

        _viewUI.list_extraAttr.dataSource = arr;
    }

    /**
     * 职业属性
     */
    private function _updateCareerProps():void
    {
//        var arr:Array = [];
//        if(m_pPropData == null)
//        {
//            m_pPropData = new CBasePropertyData();
//            m_pPropData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
//        }
//
//        if(m_pData)
//        {
//            for each(var attrName:String in m_arrAttrs2)
//            {
//                var attrData:CAttributeBaseData = new CAttributeBaseData();
//                attrData.attrBaseValue = m_pData.propertyData[attrName] as int;
//                attrData.attrNameCN = m_pData.propertyData.getAttrNameCN(attrName);
//                attrData.attrNameEN = attrName;
//                attrData.type = 1;
//                attrData.attrType = 1;
//
//                arr.push(attrData);
//            }
//        }

//        _viewUI.list_careerAttr.dataSource = arr;
    }

    private function _renderAttr(item:Component, index:int):void
    {
        if(!(item is HeroDetailPropRenderUI))
        {
            return;
        }

        var render:HeroDetailPropRenderUI = item as HeroDetailPropRenderUI;
        render.mouseEnabled = true;
        var data:CAttributeBaseData = render.dataSource as CAttributeBaseData;
        if(null != data)
        {
            render.txt_attrName.text = data.getAttrNameCN();

            if(data.type == 1)
            {
                var temp:int = data.attrBaseValue * 0.01 * 100;
                var num:Number = temp * 0.01;
                render.txt_attrValue.text = num + "%";
            }
            else
            {
                render.txt_attrValue.text = data.attrBaseValue.toString();
            }

//            render.txt_attrValue.x = data.attrType == 1 ? 121 : 94;

            if(item.toolTip == null)
            {
                var arr:Array = _passiveSkillPro.findByProperty("word", data.attrNameEN);
                if(arr && arr.length)
                {
                    item.toolTip = (arr[0] as PassiveSkillPro).PropertyDIS;
                }
            }
        }
        else
        {
            render.txt_attrName.text = "";
            render.txt_attrValue.text = "";
        }

//        TweenMax.fromTo(render.txt_attrName, 0.2, {x:10+197}, {x:10, delay:index*0.03});
//        TweenMax.fromTo(render.txt_attrValue, 0.2, {x:94+197}, {x:94, delay:index*0.03});
    }

    public function set data(value:*):void
    {
        m_pData = value as CPlayerHeroData;

        if(!m_pData.hasData)
        {
            return;
        }

        if(isViewShow)
        {
            _updateBaseProps();
            _updateExtraProps();
            _updateCareerProps();
        }
    }

    public function removeDisplay() : void
    {
        _removeListeners();

        if(TweenMax.isTweening(_viewUI.img_mask))
        {
            TweenMax.killTweensOf(_viewUI.img_mask);
        }

        TweenMax.to(_viewUI.img_mask, 0.5, {x:350, y:0, scale:0, onComplete:onCompleteHandler});

        function onCompleteHandler():void
        {
            if ( m_pViewUI && m_pViewUI.parent )
            {
                m_pViewUI.parent.removeChild(m_pViewUI);
            }
        }

        m_pData = null;
        m_pPropData = null;
        m_pParent = null;
        m_pViewUI = null;
    }

    private function get _playerHelper():CPlayerHelpHandler
    {
        return system.getHandler(CPlayerHelpHandler) as CPlayerHelpHandler;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    public function set parent(value:DisplayObjectContainer):void
    {
        m_pParent = value;
    }

    public function set viewUI(value:Component):void
    {
        m_pViewUI = value;
    }

    private function get _viewUI():HeroDetailPropsUI
    {
        return m_pViewUI as HeroDetailPropsUI;
    }

    private function get _passiveSkillPro():IDataTable
    {
        var dataBase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        return dataBase.getTable(KOFTableConstants.PASSIVE_SKILL_PRO);
    }
}
}
