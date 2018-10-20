//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/9/27.
 */
package kof.game.welfarehall.view {

import flash.net.URLRequest;
import flash.net.navigateToURL;

import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CLang;
import kof.game.common.CLogUtil;
import kof.game.welfarehall.CWelfareHallHandler;
import kof.game.welfarehall.CWelfareHallManager;
import kof.game.welfarehall.data.CAdvertisementData;
import kof.table.BundleEnable;
import kof.ui.CMsgAlertHandler;
import kof.ui.IUICanvas;
import kof.ui.master.LogPush.LogPushmainUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CAdvertisingViewHandler extends CViewHandler {

    private var m_pViewUI : LogPushmainUI;
    private var m_bViewInitialized : Boolean;

    public function CAdvertisingViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
//        _reqInfo();

        return ret;
    }

    override public function get viewClass() : Array
    {
        return [LogPushmainUI];
    }
    override protected function get additionalAssets() : Array {
        return [
            "logpush.swf"
        ];
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
                m_pViewUI = new LogPushmainUI();
                m_pViewUI.tab_title.selectHandler = new Handler(_selectTab);
                m_pViewUI.btn_join.clickHandler = new Handler(_btnClick);
                m_pViewUI.btn_close.clickHandler = new Handler(removeDisplay);
                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
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
        if(!_advertisingData || _advertisingData.contents.length == 0) return;//如果数据有误，直接不弹出界面
        if(m_pViewUI.parent == null)
        {
            uiCanvas.addDialog(m_pViewUI);
        }
        var tagStr : String = "";
        for(var i : int = 0; i < _advertisingData.contents.length; i++)
        {
            if(tagStr != "")
                tagStr = tagStr + "," + _advertisingData.contents[i].title;
            else
                tagStr = _advertisingData.contents[i].title;
        }
        if(tagStr == "")
        {
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" there is no title" );
            return;
        }//说明传的数据有误，必须要有标题
        m_pViewUI.tab_title.labels = tagStr;
        m_pViewUI.tab_title.selectedIndex = 0;
    }

    private function _selectTab(index : int) : void
    {
        if(_advertisingData.imgs.length == 0)  return;
        if(index > _advertisingData.imgs.length) index = 0;
        var info : Object = _advertisingData.imgs[index];
        m_pViewUI.img_link.url = "icon/logpush/" + info.img;
        m_pViewUI.btn_join.dataSource = info.link;
        m_pViewUI.btn_join.label = "";

        CLogUtil.recordLinkLog(system, 20001 + index*2);
    }

    private function _btnClick():void
    {
        var dataStr : String = m_pViewUI.btn_join.dataSource as String;
        if(!dataStr || dataStr =="") return;
        var pTable : IDataTable = (system.stage.getSystem( IDatabase ) as IDatabase).getTable( KOFTableConstants.BUNDLE_ENABLE );
        var arr : Array = pTable.toArray();
        var bool : Boolean = false;
        for each ( var v : BundleEnable in arr ) {
            if ( v.ID == int(dataStr) )
                bool = true;
        }
        if(bool)//内部跳转
        {
            var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
            var bundle : ISystemBundle =  bundleCtx.getSystemBundle( int(dataStr));
            if(bundle)
                bundleCtx.setUserData( bundle, CBundleSystem.ACTIVATED, true );
            else
            {
                var strMsg : String = CLang.Get("advertising");
                (system.stage.getSystem( IUICanvas ) as IUICanvas).showMsgAlert( strMsg, CMsgAlertHandler.WARNING );
            }

        }
        else//外部链接
        {
            var urlRes : URLRequest = new URLRequest(dataStr);
            navigateToURL(urlRes,"_blank");
        }

        CLogUtil.recordLinkLog(system, 20002 + m_pViewUI.tab_title.selectedIndex*2);
    }

    public function removeDisplay():void
    {
        if (m_pViewUI && m_pViewUI.parent)
        {
            m_pViewUI.close(Dialog.CLOSE);
        }
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    private function get _welfareManager():CWelfareHallManager
    {
        return system.getHandler( CWelfareHallManager ) as CWelfareHallManager;
    }

    private function get _advertisingData():CAdvertisementData
    {
        var listData:Vector.<CAdvertisementData> = _welfareManager.advertisementListData;
        if(listData && listData.length)
        {
            return listData[0];
        }

        return null;
    }
}
}
