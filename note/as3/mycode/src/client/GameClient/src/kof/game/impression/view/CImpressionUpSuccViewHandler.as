//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/5/25.
 */
package kof.game.impression.view {

import flash.events.MouseEvent;
import flash.geom.Point;

import kof.framework.CViewHandler;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.impression.util.CImpressionRenderUtil;
import kof.game.impression.util.CImpressionUtil;
import kof.game.item.data.CRewardListData;
import kof.game.player.data.CPlayerHeroData;
import kof.table.ImpressionTitle;
import kof.ui.master.impression.ImpressionUpSuccUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;

public class CImpressionUpSuccViewHandler extends CViewHandler{

    private var m_pViewUI : ImpressionUpSuccUI;
    private var m_pData:ImpressionTitle;
    private var m_iRoleId:int;

    private var m_bViewInitialized : Boolean;

    public function CImpressionUpSuccViewHandler()
    {
        super (false);
    }

    override public function get viewClass() : Array
    {
        return [ImpressionUpSuccUI];
    }

    override protected function get additionalAssets() : Array
    {
        return ["frameclip_hgjj.swf"];
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
                m_pViewUI = new ImpressionUpSuccUI();
                m_pViewUI.list_reward.renderHandler = new Handler(CImpressionRenderUtil.renderItem);
                m_pViewUI.closeHandler = new Handler( _onClose );

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
            invalidate();
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
        if(m_pViewUI.parent == null)
        {
            _initView();
            _addListeners();
        }

        uiCanvas.addPopupDialog( m_pViewUI );
    }

    private function _addListeners():void
    {
        m_pViewUI.btn_confirm.addEventListener(MouseEvent.CLICK,onBtnClickHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.btn_confirm.removeEventListener(MouseEvent.CLICK,onBtnClickHandler);
    }

    private function _initView():void
    {
        _startAnimation();
    }

    private function _startAnimation():void
    {
        m_pViewUI.clip_titleEffect.playFromTo(null,null,new Handler(_onAnimationComplHandler));
        function _onAnimationComplHandler():void
        {
        }
    }

    public function set data(value:*):void
    {
        m_pData = value as ImpressionTitle;
    }

    override protected function updateDisplay():void
    {
        if(m_pData)
        {
            _updateTitleInfo();
            _updateRewardInfo();
            _updateNameInfo();
        }
    }

    private function _updateTitleInfo():void
    {
        var heroData:CPlayerHeroData = CImpressionUtil.getHeroDataById(m_iRoleId);
        if(heroData)
        {
            var sex:int = heroData.playerBasic != null ? heroData.playerBasic.gender : 0;
            var tTitleInfo:ImpressionTitle = CImpressionUtil.getTitleInfoByLevelAndSex(heroData.impressionLevel,sex);
            if(tTitleInfo)
            {
                m_pViewUI.img_title.visible = true;
                m_pViewUI.img_title.skin = "png.impression." + tTitleInfo.icon;
            }
        }
    }

    private function _updateRewardInfo():void
    {
        var rewardListData:CRewardListData = CRewardUtil.createByDropPackageID(system.stage, int(m_pData.prize));
        if(rewardListData)
        {
            if(m_pViewUI.list_reward)
            {
                m_pViewUI.list_reward.dataSource = rewardListData.list;
            }
        }
    }

    private function _updateNameInfo():void
    {
        var heroName:String = CImpressionUtil.getHeroName(m_iRoleId);
        m_pViewUI.txt_info.text = CLang.Get("impression_lswl",{v1:heroName});
    }

    private function _onClose( type : String = null ) : void
    {
        hide();
    }

    private function onBtnClickHandler(e:MouseEvent):void
    {
        if( e.target == m_pViewUI.btn_confirm)
        {
            _flyItem();
            hide();
        }
    }

    private function _flyItem():void
    {
        var len:int = m_pViewUI.list_reward.dataSource.length;
        for(var i:int = 0; i < len; i++)
        {
            var item:Component = m_pViewUI.list_reward.getCell(i) as Component;
            CFlyItemUtil.flyItemToBag(item, item.localToGlobal(new Point()), system);
        }
    }

    public function hide() : void
    {
        _removeListeners();

        if ( m_pViewUI && m_pViewUI.parent)
        {
            m_pViewUI.close();
        }
    }

    public function clear():void
    {

    }

    public function get isViewShow():Boolean
    {
        if(m_pViewUI && m_pViewUI.parent)
        {
            return true;
        }

        return false;
    }

    public function set roleId(value:int):void
    {
        m_iRoleId = value;
    }

    override public function dispose() : void
    {
        super.dispose();
    }
}
}
