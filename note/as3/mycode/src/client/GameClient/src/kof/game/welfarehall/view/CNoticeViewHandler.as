//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/9/26.
 */
package kof.game.welfarehall.view {

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.IDatabase;
import kof.table.UpdateNoticeConfig;
import kof.ui.master.welfareHall.AdvertisementUI;
import kof.ui.master.welfareHall.WelfareHallUI;

import morn.core.handlers.Handler;

public class CNoticeViewHandler extends CWelfarePanelBase {

    private var m_pViewUI : AdvertisementUI;
    private var m_bViewInitialized : Boolean;
    private var m_listImgArr:Array = [];
    private var m_iCurrIndex:int;

    public function CNoticeViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [AdvertisementUI];
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
                m_pViewUI = new AdvertisementUI();

                m_pViewUI.btn_left.clickHandler = new Handler(_onClickLeftHandler);
                m_pViewUI.btn_right.clickHandler = new Handler(_onClickRightHandler);

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    override public function addDisplay() : void
    {
        this.loadAssetsByView(viewClass, _showDisplay);
    }

    protected function _showDisplay() : void
    {
        if ( onInitializeView() )
        {
            _addToDisplay();
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void
    {
        if(m_pViewUI)
        {
            _mainUI.ctn.addChild(m_pViewUI);
        }

        _initView();
//        _addListeners();
    }

    private function _initView():void
    {
        m_listImgArr = _updateNoticeConfig.toArray();
        m_iCurrIndex = 0;

        updateDisplay();
    }

    override protected function updateDisplay():void
    {
        _updateImg();
        _updateBtnState();
    }

    override public function removeDisplay():void
    {
        if(m_bViewInitialized)
        {
            m_pViewUI.remove();
        }

        m_listImgArr.length = 0;
        m_iCurrIndex = 0;
    }

    private function _updateImg():void
    {
        var info:UpdateNoticeConfig = m_listImgArr[m_iCurrIndex];
        var url:String = info.imgSource + info.imgName;
        m_pViewUI.img_bg.url = url;
    }

    private function _updateBtnState():void
    {
        m_pViewUI.btn_left.disabled = m_iCurrIndex == 0;
        m_pViewUI.btn_right.disabled = m_iCurrIndex == m_listImgArr.length - 1;
    }

    private function _onClickLeftHandler():void
    {
        m_iCurrIndex--;
        updateDisplay();
    }

    private function _onClickRightHandler():void
    {
        m_iCurrIndex++;
        updateDisplay();
    }

    private function get _mainUI():WelfareHallUI
    {
        return (system.getBean( CWelfareHallViewHandler ) as CWelfareHallViewHandler).welfareHallUI;
    }

    private function get _updateNoticeConfig():IDataTable
    {
        var dataBase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        return dataBase.getTable(KOFTableConstants.UPDATENOTICECONFIG);
    }

}
}
