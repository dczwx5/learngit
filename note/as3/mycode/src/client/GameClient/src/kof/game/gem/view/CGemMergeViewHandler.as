//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/7/5.
 */
package kof.game.gem.view {

import QFLib.Utils.HtmlUtil;

import kof.framework.CViewHandler;
import kof.framework.IDatabase;
import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.gem.CGemHelpHandler;
import kof.game.gem.CGemManagerHandler;
import kof.game.gem.CGemNetHandler;
import kof.game.gem.data.CGemBagData;
import kof.game.gem.data.CGemBagData;
import kof.game.gem.data.CGemCategoryListCellData;
import kof.game.gem.data.CGemCategoryListData;
import kof.game.gem.data.CGemData;
import kof.game.gem.event.CGemEvent;
import kof.game.item.CItemData;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardData;
import kof.game.item.view.tips.CItemTipsView;
import kof.table.Gem;
import kof.table.Gem;
import kof.table.Gem;
import kof.ui.CUISystem;
import kof.ui.master.Gem.GemMergeWinUI;
import kof.ui.master.Gem.GemOperateInfoViewUI;

import morn.core.components.Component;
import morn.core.components.Dialog;

import morn.core.handlers.Handler;

/**
 * 宝石合成界面
 */
public class CGemMergeViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : GemMergeWinUI;

    private var m_bIsFrist:Boolean = true;
    private var m_pTabList:CGemTabList;

    private var m_pCurrSelData:CGemCategoryListCellData;

    private static const _GemNum:int = 6;

    public function CGemMergeViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array
    {
        return [GemMergeWinUI];
    }

    override protected function get additionalAssets():Array
    {
        return ["frameclip_item.swf"];
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
                m_pViewUI = new GemMergeWinUI();
                m_pViewUI.btn_close.clickHandler = new Handler( _onCloseHandler );
                m_pViewUI.btn_add.clickHandler = new Handler(_onAddHandler);
                m_pViewUI.btn_reduce.clickHandler = new Handler(_onReduceHandler);
                m_pViewUI.btn_max.clickHandler = new Handler(_onMaxHandler);
                m_pViewUI.btn_upgrade.clickHandler = new Handler(_onUpgradeHandler);

                CSystemRuleUtil.setRuleTips(m_pViewUI.img_tip, CLang.Get("gemMerge_rule"));

//                for(var i:int = 1; i <= CGemConst.MaxHoleNum; i++)
//                {
//                    (m_pViewUI["view_gemInfo" + i ] as GemOperateInfoViewUI).dataSource = i;
//                }

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
        uiCanvas.addDialog( m_pViewUI );

        _initView();
        _addListeners();
    }

    private function _addListeners():void
    {
        system.addEventListener(CGemEvent.UpdateGemCategoryList, _onGemBagUpdateHandler);
    }

    private function _removeListeners():void
    {
        system.removeEventListener(CGemEvent.UpdateGemCategoryList, _onGemBagUpdateHandler);
    }

    private function _initView():void
    {
        if(m_pTabList == null)
        {
            m_pTabList = new CGemTabList(this);
            m_pTabList.renderHandler = new Handler(_updateMergeInfo);
            m_pTabList.activeFirstTab();
        }
        else
        {
//            if (m_bIsFrist)
//            {
//                m_bIsFrist = false;
                m_pTabList.resetState();
                m_pTabList.activeFirstTab();
                m_pTabList.updateTipInfo();
//            }
        }

        m_pViewUI.checkBox_skip.visible = false;
        m_pViewUI.box_consumeInfo.visible = false;
        m_pViewUI.input_num.restrict = "0-9";
    }

    private function _onCloseHandler():void
    {
        removeDisplay();
    }

    public function removeDisplay():void
    {
        if ( m_bViewInitialized )
        {
            _removeListeners();

            m_pViewUI.close(Dialog.CLOSE);

            for(var i:int = 0; i < _GemNum; i++)
            {
                var view:GemOperateInfoViewUI = m_pViewUI["view_gem" + i] as GemOperateInfoViewUI;
                _clear(view);
            }

            m_pCurrSelData = null;
        }
    }

    /**
     * 切换tab时更新右边的合成信息
     * @param tabData tab标签数据
     */
    private function _updateMergeInfo(tabData:CGemCategoryListCellData) : void
    {
        m_pCurrSelData = tabData;

        for(var i:int = 0; i < _GemNum; i++)
        {
            var view:GemOperateInfoViewUI = m_pViewUI["view_gem"+i] as GemOperateInfoViewUI;
            if(view)
            {
                if(i == 0)
                {
                    view.dataSource = tabData.resultGem;
                }
                else if(i == 1)
                {
                    view.dataSource = tabData.stuffGem;
                }
                else
                {
                    view.dataSource = null;
                }

                _updateSingleGemHole(view, i);
            }
        }

        if(tabData && tabData.resultGem && tabData.stuffGem)
        {
//            m_pViewUI.box_consumeInfo.visible = tabData.stuffGem.consumeCount > 0;
            m_pViewUI.txt_consume.text = tabData.stuffGem.consumeCount + "";
            m_pViewUI.txt_succRate.visible = m_pViewUI.box_numInfo.visible;

            m_pViewUI.box_consume.centerX = 0;

            if(m_pViewUI.box_numInfo.visible)
            {
                m_pViewUI.input_num.text = "1";
            }
        }
        else
        {
            m_pViewUI.box_consumeInfo.visible = false;
            m_pViewUI.txt_succRate.visible = false;
        }
    }

    /**
     * 更新单个宝石孔
     * @param view
     * @param index
     */
    private function _updateSingleGemHole(view:GemOperateInfoViewUI, index:int):void
    {
        _clear(view);

        var data:Gem = view.dataSource as Gem;
        if(data)
        {
            view.img_lock.visible = false;
            view.img_gem.visible = true;
            view.img_gem.url = index == 0 ? ("icon/gem/big/" + data.icon + ".png") : ("icon/gem/small/" + data.icon + ".png");
            view.img_gem.y = index == 0 ? 0 : 14;

            view.txt_noGem.visible = index == 1;
            if(index == 1)// 材料宝石
            {
                var ownNum:int = _helper.getOwnGemNum(data.ID);
                view.txt_noGem.isHtml = true;
                var str:String = ownNum < data.consumeCount ? HtmlUtil.color(ownNum+"", "#ff0000") : HtmlUtil.color(ownNum+"", "#00ff00");
                view.txt_noGem.text = str + HtmlUtil.color("/" + data.consumeCount, "#ffffff");
            }

            if(view.img_gem.toolTip == null)
            {
                var dateBase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
                var itemData:CItemData = CRewardData.CreateRewardData(data.ID, 1, dateBase);
                view.img_gem.toolTip = new Handler( _showItemTips, [view.img_gem, itemData] );
            }
        }
    }

    private function _clear(view:GemOperateInfoViewUI, holeIndex:int = 0):void
    {
        view.img_gem.url = "";
        view.txt_noGem.visible = false;
        view.txt_clickEmbed.visible = false;
        view.img_lock.visible = true;
        view.btn_levelUp.visible = false;
        view.frameClip_levelUp.autoPlay = false;
        view.frameClip_levelUp.stop();
        view.frameClip_levelUp.visible = false;
        view.frameClip_embed.autoPlay = false;
        view.frameClip_embed.stop();
        view.frameClip_embed.visible = false;
        view.btn_add.visible = false;
        view.btn_add.clickHandler = null;
        view.btn_levelUp.clickHandler = null;
//        view.dataSource = null;
        view.img_gem.toolTip = null;
    }

// 点击事件==============================================================================================================
    private function _onAddHandler():void
    {
        var currValue:int = int(m_pViewUI.input_num.text);
        if(m_pCurrSelData && m_pCurrSelData.isCanMerge)
        {
//            var consumeNum:int = m_pCurrSelData.stuffGem.consumeCount;
//            var ownNum:int = _helper.getOwnGemNum(m_pCurrSelData.stuffGem.ID);
//            if(ownNum >= consumeNum)
//            {
//                var maxNum:int = int(ownNum / consumeNum);
//                if(currValue >= maxNum)
//                {
//                    return;
//                }
//            }

            if(currValue >= m_pCurrSelData.canMergeNum)
            {
                return;
            }
        }

        m_pViewUI.input_num.text = (currValue + 1) + "";
    }

    private function _onReduceHandler():void
    {
        var currValue:int = int(m_pViewUI.input_num.text);
        if(currValue > 1)
        {
            m_pViewUI.input_num.text = (currValue - 1) + "";
        }
    }

    private function _onMaxHandler():void
    {
        if(m_pCurrSelData && m_pCurrSelData.isCanMerge)
        {
//            var ownNum:int = _helper.getOwnGemNum(m_pCurrSelData.stuffGem.ID);
//            var consumeNum:int = m_pCurrSelData.stuffGem.consumeCount;
//            if(ownNum >= consumeNum)
//            {
//                var maxNum:int = int(ownNum / consumeNum);
//                m_pViewUI.input_num.text = maxNum + "";
//            }

            m_pViewUI.input_num.text = m_pCurrSelData.canMergeNum + "";
        }
    }

    private function _onUpgradeHandler():void
    {
        if(m_pCurrSelData && m_pCurrSelData.stuffGem)
        {
            if(!m_pCurrSelData.isCanMerge)
            {
                _uiSystem.showMsgAlert("道具不足，无法合成");
                return;
            }

            var currValue:int = int(m_pViewUI.input_num.text);
//            var maxNum:int;
//
//            var ownNum:int = _helper.getOwnGemNum(m_pCurrSelData.stuffGem.ID);
//            var consumeNum:int = m_pCurrSelData.stuffGem.consumeCount;
//            if(ownNum >= consumeNum)
//            {
//                maxNum = int(ownNum / consumeNum);
//            }

            if(currValue > m_pCurrSelData.canMergeNum)
            {
                _uiSystem.showMsgAlert("不能超过最大值");
                return;
            }

            if(currValue <= 0)
            {
                _uiSystem.showMsgAlert("输入不合法");
                return;
            }

            (system.getHandler(CGemNetHandler) as CGemNetHandler).gemMergeRequest(m_pCurrSelData.stuffGem.ID, currValue);
        }
    }

// 监听=================================================================================================================
    /**
     * 宝石包更新
     * @param e
     */
    private function _onGemBagUpdateHandler(e:CGemEvent = null):void
    {
        categoryListData.updateHeadAndListData();

        m_pTabList.updateTipInfo();

        _updateMergeInfo(m_pCurrSelData);
    }

    private function _showItemTips(item:Component, itemData:CItemData) : void
    {
        (system.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView, item, [itemData]);
    }

    private function get _uiSystem():CUISystem
    {
        return system.stage.getSystem(CUISystem) as CUISystem;
    }

    private function get _helper():CGemHelpHandler
    {
        return system.getHandler(CGemHelpHandler) as CGemHelpHandler;
    }

    private function get _gemData():CGemData
    {
        return (system.getHandler(CGemManagerHandler) as CGemManagerHandler).gemData;
    }

    public function get viewUI():GemMergeWinUI
    {
        return m_pViewUI;
    }

    public function get categoryListData():CGemCategoryListData
    {
        return (system.getHandler(CGemManagerHandler) as CGemManagerHandler).gemCategoryListData;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }
}
}
