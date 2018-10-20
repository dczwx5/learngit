//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/26.
 */
package kof.game.gem.view {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.common.CItemUtil;
import kof.game.gem.CGemHelpHandler;
import kof.game.gem.CGemManagerHandler;
import kof.game.gem.CGemNetHandler;
import kof.game.gem.data.CGemBagData;
import kof.game.item.CItemData;
import kof.game.item.data.CRewardData;
import kof.game.item.data.CRewardListData;
import kof.ui.CUISystem;
import kof.ui.master.Gem.GemEmbedBagViewUI;

import morn.core.components.Component;
import morn.core.components.Dialog;

import morn.core.handlers.Handler;

public class CGemEmbedBagViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : GemEmbedBagViewUI;
    private var m_pCloseHandler : Handler;

    private var m_iGemHoleConfigID:int;
    private var m_iXpos:int;
    private var m_iYpos:int;

    public function CGemEmbedBagViewHandler( bLoadViewByDefault : Boolean = false )
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
        return [GemEmbedBagViewUI];
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
                m_pViewUI = new GemEmbedBagViewUI();

                m_pViewUI.list_gem.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system));
                m_pViewUI.list_gem.selectHandler = new Handler(_onListSelectHandler);

                m_pViewUI.left_max_btn.clickHandler = new Handler(_onPageChange,[m_pViewUI.left_max_btn]);
                m_pViewUI.left_btn.clickHandler = new Handler(_onPageChange,[m_pViewUI.left_btn]);
                m_pViewUI.right_btn.clickHandler = new Handler(_onPageChange,[m_pViewUI.right_btn]);
                m_pViewUI.right_max_btn.clickHandler = new Handler(_onPageChange,[m_pViewUI.right_max_btn]);

                m_pViewUI.btn_unload.clickHandler = new Handler(_onUnloadHandler);
                m_pViewUI.btn_close.clickHandler = new Handler(_onCloseHandler);

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay(x:int, y:int) : void
    {
        m_iXpos = x;
        m_iYpos = y;

        if(m_pViewUI && m_pViewUI.parent)
        {
            uiCanvas.addDialog( m_pViewUI );

            m_pViewUI.x = x;
            m_pViewUI.y = y;

            _initView();
        }
        else
        {
            this.loadAssetsByView( viewClass, _showDisplay );
        }
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

        m_pViewUI.x = m_iXpos;
        m_pViewUI.y = m_iYpos;

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
        _updateGemList();
        _updatePageBtn();
    }

    private function _updateGemList():void
    {
        var rewardListData:CRewardListData = new CRewardListData();
        rewardListData.setToRootData(system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem);

        if(gemHoleConfigID)
        {
            var dataList:Array = [];
            var canEmbedArr:Array = _helper.getCanEmbedGems(gemHoleConfigID);
            for each(var bagData:CGemBagData in canEmbedArr)
            {
                var sourceID:int = bagData.gemConfigID;
                var num:int = bagData.gemNum;
                var rewardType:int = CRewardData.getTypeByID(sourceID);
                var rewardData:Object = CRewardData.buildData(rewardType, sourceID, num);
                dataList.push(rewardData);
            }

            rewardListData.updateDataByData(dataList);
        }

        m_pViewUI.list_gem.dataSource = rewardListData.list;
    }

    private function _updatePageBtn():void
    {
        m_pViewUI.list_gem.page = 0;

        var currPage:int = m_pViewUI.list_gem.page + 1;
        var maxPage:int = m_pViewUI.list_gem.totalPage;
        m_pViewUI.page.text = currPage + "/" + maxPage;
    }

    // 点击处理=============================================================================================================
    private function _onPageChange(btn:Component):void
    {
        var currPage:int = m_pViewUI.list_gem.page;
        var maxPage:int = m_pViewUI.list_gem.totalPage-1;
        if(btn == m_pViewUI.left_btn)
        {
            if(currPage > 0)
            {
                m_pViewUI.list_gem.page -= 1;
            }
        }

        if(btn == m_pViewUI.left_max_btn)
        {
            if(currPage > 0)
            {
                m_pViewUI.list_gem.page = 0;
            }
        }

        if(btn == m_pViewUI.right_btn)
        {
            if(currPage < maxPage)
            {
                m_pViewUI.list_gem.page += 1;
            }
        }

        if(btn == m_pViewUI.right_max_btn)
        {
            if(currPage < maxPage)
            {
                m_pViewUI.list_gem.page = maxPage;
            }
        }

        m_pViewUI.page.text = (m_pViewUI.list_gem.page + 1) + "/" + (maxPage + 1);
    }

    /**
     * 卸载宝石
     */
    private function _onUnloadHandler():void
    {
        if(gemHoleConfigID)
        {
            (system.getHandler(CGemNetHandler) as CGemNetHandler).gemTakeOffRequest(gemHoleConfigID);

            removeDisplay();
        }
    }

    private function _onListSelectHandler(index:int):void
    {
        if(index == -1)
        {
            return;
        }

        var cell:Component = m_pViewUI.list_gem.getCell(index);
        if(cell)
        {
            var data:CItemData = cell.dataSource as CItemData;
            if(data && gemHoleConfigID)
            {
                (system.getHandler(CGemNetHandler) as CGemNetHandler).gemEmbedReplaceRequest(gemHoleConfigID, data.ID);

                removeDisplay();
            }
        }
    }

    public function removeDisplay() : void
    {
        if ( m_bViewInitialized )
        {
            _removeListeners();

            m_pViewUI.list_gem.selectedIndex = -1;
            m_iGemHoleConfigID = 0;

//            m_pViewUI.remove();
            if ( m_pViewUI && m_pViewUI.parent )
            {
                m_pViewUI.close( Dialog.CLOSE );
            }
        }
    }

    private function _onCloseHandler() : void
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

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    public function set gemHoleConfigID(value:int):void
    {
        m_iGemHoleConfigID = value;
    }

    public function get gemHoleConfigID():int
    {
        return m_iGemHoleConfigID;
    }

    private function get _manager():CGemManagerHandler
    {
        return system.getHandler(CGemManagerHandler) as CGemManagerHandler;
    }

//==========================================table==================================================
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }

    private function get _gemTable():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.Gem);
    }

    private function get _gemPoint():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.GemPoint);
    }
}
}
