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
import kof.game.common.CAttributeUtil;
import kof.game.common.data.CAttributeBaseData;
import kof.game.gem.CGemHelpHandler;
import kof.table.GemSuit;
import kof.ui.CUISystem;
import kof.ui.master.Gem.GemSuitInfoRenderUI;
import kof.ui.master.Gem.GemSuitInfoViewUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;

/**
 * 所有等级套装属性预览界面
 */
public class CGemSuitAttrInfoViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : GemSuitInfoViewUI;
    private var m_pCloseHandler : Handler;

    private var m_iPageType:int;
    private var m_pPropertyData:CBasePropertyData;

    public function CGemSuitAttrInfoViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();

        return ret;
    }

    override public function get viewClass() : Array
    {
        return [GemSuitInfoViewUI];
    }

    override protected function onAssetsLoadCompleted() : void
    {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean
    {
        if ( !super.onInitializeView() )
        {
            return false;
        }

        if ( !m_bViewInitialized )
        {
            if ( !m_pViewUI )
            {
                m_pViewUI = new GemSuitInfoViewUI();

                m_pViewUI.list_attr.renderHandler = new Handler(_renderListHandler);

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        this.loadAssetsByView( viewClass, _showDisplay );
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
        uiCanvas.addPopupDialog( m_pViewUI );

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
        _updateAttrList();
    }

    private function _updateAttrList():void
    {
        var dataArr:Array = [];
        var arr:Array = _gemSuit.findByProperty("pageID", pageType);
        for each(var gemSuit:GemSuit in arr)
        {
            if(gemSuit)
            {
                var attrs:Array = CAttributeUtil.parseAttrStr(gemSuit.propertysAdd, system);
                var combat:int = _calculateCombat(attrs);

                var suitInfo:SuitInfo = new SuitInfo();
                suitInfo.attrDatas = attrs;
                suitInfo.combat = combat;
                suitInfo.suitLevel = gemSuit.suitLevel;
                dataArr.push(suitInfo);
            }
        }

        m_pViewUI.list_attr.dataSource = dataArr;
        delayCall(0.1, function():void
        {
            m_pViewUI.list_attr.scrollBar.scrollSize = 7;
        });
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

    private function _renderListHandler(item:Component, index:int):void
    {
        var suitView:GemSuitInfoRenderUI = item as GemSuitInfoRenderUI;
        if(suitView)
        {
            suitView.txt_state.visible = false;
            suitView.txt_processInfo.visible = false;
            var suitData:SuitInfo = suitView.dataSource as SuitInfo;
            if(suitData)
            {
                suitView.txt_targetInfo.text = "全部镶嵌"+suitData.suitLevel+"级宝石";
                suitView.txt_combat.text = suitData.combat+"";
                suitView.box_attr1.visible = suitData.attrDatas.length >= 1;
                var attrData:CAttributeBaseData;
                attrData = suitData.attrDatas.length >= 1 ? (suitData.attrDatas[0] as CAttributeBaseData) : null;
                suitView.txt_attrName1.text = attrData == null ? "" : attrData.attrNameCN;
                suitView.txt_attrValue1.text = attrData == null ? "" : attrData.attrBaseValue.toString();

                suitView.box_attr2.visible = suitData.attrDatas.length >= 2;
                attrData = suitData.attrDatas.length >= 2 ? (suitData.attrDatas[1] as CAttributeBaseData) : null;
                suitView.txt_attrName2.text = attrData == null ? "" : attrData.attrNameCN;
                suitView.txt_attrValue2.text = attrData == null ? "" : attrData.attrBaseValue.toString();

                suitView.box_attr3.visible = suitData.attrDatas.length >= 3;
                attrData = suitData.attrDatas.length >= 3 ? (suitData.attrDatas[2] as CAttributeBaseData) : null;
                suitView.txt_attrName3.text = attrData == null ? "" : attrData.attrNameCN;
                suitView.txt_attrValue3.text = attrData == null ? "" : attrData.attrBaseValue.toString();

                suitView.box_attr4.visible = suitData.attrDatas.length >= 4;
                attrData = suitData.attrDatas.length >= 4 ? (suitData.attrDatas[3] as CAttributeBaseData) : null;
                suitView.txt_attrName4.text = attrData == null ? "" : attrData.attrNameCN;
                suitView.txt_attrValue4.text = attrData == null ? "" : attrData.attrBaseValue.toString();
            }
            else
            {
                suitView.box_attr1.visible = false;
                suitView.box_attr2.visible = false;
                suitView.box_attr3.visible = false;
                suitView.box_attr4.visible = false;
            }
        }
    }

    public function removeDisplay() : void
    {
        if ( m_bViewInitialized )
        {
            _removeListeners();
        }
    }

    private function _onClose( type : String = null ) : void
    {
        removeDisplay();
    }

//property=============================================================================================================
    public function get closeHandler() : Handler
    {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void
    {
        m_pCloseHandler = value;
    }

    private function get _uiSystem():CUISystem
    {
        return system.stage.getSystem(CUISystem) as CUISystem;
    }

    private function get _helper():CGemHelpHandler
    {
        return system.getHandler(CGemHelpHandler) as CGemHelpHandler;
    }

    public function get pageType():int
    {
        return m_iPageType;
    }

    public function set pageType(value:int):void
    {
        m_iPageType = value;
    }

//==========================================table==================================================
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _gemSuit():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.GemSuit);
    }
}
}

class SuitInfo{
    public var attrDatas:Array;
    public var suitLevel:int;
    public var combat:int;
}
