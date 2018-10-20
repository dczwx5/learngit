//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/3/8.
 */
package kof.game.yyVip.view {

import flash.events.Event;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.platform.EPlatformType;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.platform.yy.data.CYYData;
import kof.game.player.CPlayerSystem;
import kof.game.yyVip.CYYVipHelpHandler;
import kof.game.yyVip.CYYVipManager;
import kof.game.yyVip.CYYVipNetHandler;
import kof.game.yyVip.data.CYYVipRewardData;
import kof.game.yyWeChat.view.CYYWeChatViewHandler;
import kof.game.yyHall.data.CYYRewardData;
import kof.game.yyHall.view.CYYHallViewHandler;
import kof.table.YYVipDayWelfare;
import kof.table.YYVipLevelReward;
import kof.table.YYVipWeekWelfare;
import kof.ui.CUISystem;
import kof.ui.platform.yy.YYDayItemUI;
import kof.ui.platform.yy.YYMembersUI;

import morn.core.components.Component;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CYYVipViewHandler extends CViewHandler {
    private var m_pCloseHandler : Handler;
    private var m_bViewInitialized : Boolean;
    private var yyData:CYYVipRewardData;
    private var m_awardISelectedIndex:int;
    private var m_iSelectedIndex:int;
    private var m_pViewUI : YYMembersUI;
    private var m_level:int;
    public function CYYVipViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        _reqRewardsInfo();

        return ret;
    }

    /**
     * 登陆请求奖励状态信息
     */
    private function _reqRewardsInfo():void
    {
        // TODO
    }

    override public function get viewClass() : Array
    {
        return [YYMembersUI];
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
                yyData = (system.getBean(CYYVipManager) as CYYVipManager).data;

                m_pViewUI = new YYMembersUI();//创建UI实例
                m_pViewUI.list_reward.renderHandler = new Handler(_renderLevelReward);
                m_pViewUI.itemList.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system, 1));//传物品系统
                m_pViewUI.btn_open.clickHandler = new Handler(_onClickDownloadHandler);//立即开通
                m_pViewUI.getBtn.clickHandler = new Handler(_onTakeVipLevelHandler);
//                //m_pViewUI.tab.selectHandler//tab添加点击事件
//                m_pViewUI.list_reward.mask = m_pViewUI.img_mask;
                m_pViewUI.closeHandler = new Handler( _onClose );
                m_bViewInitialized = true;

//                (system.getBean(CYYHallNetHandler) as CYYHallNetHandler).platformRewardInfoYYRequest(1);
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

    private function _initView():void
    {
        if ( m_pViewUI )
        {
//            _initTabBarData();
            m_pViewUI.tab_award.selectedIndex = m_awardISelectedIndex;
            m_pViewUI.tab.selectedIndex = m_iSelectedIndex;
            _onTabAwardSelectedHandler();
            _onTabSelectedHandler();
        }
    }

    private function _addListeners():void
    {
        m_pViewUI.tab_award.addEventListener( Event.CHANGE, _onTabAwardSelectedHandler);
        m_pViewUI.tab.addEventListener( Event.CHANGE, _onTabSelectedHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.tab_award.removeEventListener( Event.CHANGE, _onTabAwardSelectedHandler);
        m_pViewUI.tab.removeEventListener( Event.CHANGE, _onTabSelectedHandler);
    }

    /**
     * 新服豪礼
     */
    private function _initTabAwardBarData():void
    {
        m_pViewUI.box_rewardNew.visible = true;
        m_pViewUI.list_reward.visible = false;
        m_pViewUI.tab.selectedIndex = 0;
        m_pViewUI.tab.labels = "YY会员1-3级,YY会员4-6级,YY会员7-8级";
    }

    /**
     * 日常福利
     */
    private function _initTabBarAwardDaysData():void
    {
        m_pViewUI.box_rewardNew.visible = false;
        m_pViewUI.list_reward.visible = true;
        m_pViewUI.tab.selectedIndex = 0;
        m_pViewUI.tab.labels = "每日礼包,每周礼包";
        _updateOpenRewards(1);
    }

    /**
     * 切换2种奖励页签处理
     * @param e
     */
    private function _onTabAwardSelectedHandler(e:Event = null):void {
//        m_pViewUI.list_reward.visible = m_pViewUI.tab.selectedIndex != 0;
//        m_pViewUI.box_rewardNew.visible = m_pViewUI.tab.selectedIndex == 0;

        switch ( m_pViewUI.tab_award.selectedIndex ) {
            case 0:
                _initTabAwardBarData();
                break;
            case 1:
                _initTabBarAwardDaysData();
                break;
        }
        _updateTabTipState();
    }
    /**
     * 切换页签处理
     * @param e
     */
    private function _onTabSelectedHandler(e:Event = null):void {
//        m_pViewUI.list_reward.visible = m_pViewUI.tab.selectedIndex != 0;
//        m_pViewUI.box_rewardNew.visible = m_pViewUI.tab.selectedIndex == 0;

        switch ( m_pViewUI.tab.selectedIndex ) {
            case 0:
                m_pViewUI.txt_packageName.text = "YY会员1-3级礼包";
                _updateOpenRewards(0);
                break;
            case 1:
                m_pViewUI.txt_packageName.text = "YY会员4-6级礼包";
                _updateOpenRewards(1);
                break;
            case 2:
                m_pViewUI.txt_packageName.text = "YY会员7-8级礼包";
                _updateOpenRewards(2);
                break;
        }
    }

    /**
     * 开通豪礼 会员1-3级 奖励
     */
    private function _updateOpenRewards(selectID:int):void
    {
        // TODO
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;//获取表系统
        if(m_pViewUI.tab_award.selectedIndex == 0)
        {
            // TODO
            var openTable:IDataTable = pDatabase.getTable(KOFTableConstants.YYVIPLEVELREWARD);//获取表系统

            var pRecord:YYVipLevelReward = openTable.findByPrimaryKey(selectID+1) as YYVipLevelReward;

            //读取对应表数据，并赋值给相应的数组
            var arr:Array = CRewardUtil.createByDropPackageID(system.stage, pRecord.rewardID ).list;
            m_level = pRecord.vipLevel;
            m_pViewUI.itemList.repeatX = arr.length;
            m_pViewUI.itemList.dataSource = arr;
            m_pViewUI.itemList.centerX = 0;
            //判断是否已经领取过
            if (yyData.isVipLevelReward(pRecord.vipLevel)) {
                m_pViewUI.getBtn.visible = false;
                m_pViewUI.getedImg.visible = true;
            }else{
                m_pViewUI.getBtn.visible = true;
                m_pViewUI.getedImg.visible = false;
                //判断是否达到领取条件
                var yyLevelPlayerSystem:CPlayerSystem = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem);
                if((yyLevelPlayerSystem.platform.data as CYYData).yyVipGrade < pRecord.vipLevel)
                {
                    ObjectUtils.gray(m_pViewUI.getBtn);
                    m_pViewUI.getBtn.disabled = true;
                    m_pViewUI.getBtn.mouseEnabled = false;
                }else{
                    ObjectUtils.gray(m_pViewUI.getBtn,false);
                    m_pViewUI.getBtn.disabled = false;
                    m_pViewUI.getBtn.mouseEnabled = true;
                }
            }
        }else{
            var pTable:IDataTable;
            if(m_pViewUI.tab.selectedIndex == 0)
            {
                pTable = pDatabase.getTable(KOFTableConstants.YYVIPDAYWELFARE);
            }else{
                pTable = pDatabase.getTable(KOFTableConstants.YYVIPWEEKWELFARE);
            }
            var pList:Array = pTable.toArray();
            m_pViewUI.list_reward.dataSource = pList;
        }
    }

    private function _onTakeVipLevelHandler():void
    {
        (system.getBean(CYYVipNetHandler) as CYYVipNetHandler).yYVipLevelRewardRequest(m_level);
    }

    private function _renderLevelReward(item:Component, index:int):void
    {
        if ( !(item is YYDayItemUI) )
        {
            return;
        }
        if (item.dataSource == null) {
            item.visible = false;
            return ;
        }
        item.visible = true;

        var render : YYDayItemUI = item as YYDayItemUI;
        render.mouseChildren = true;
        render.mouseEnabled = true;
        render.list_item.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system, 1));
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;//获取表系统
        ObjectUtils.gray(render.btn_get);
        render.btn_get.disabled = true;
        render.btn_get.mouseEnabled = false;
        //获取角色信息
        var yyLevelPlayerSystem:CPlayerSystem = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem);
        //日礼包
        if(m_pViewUI.tab.selectedIndex == 0)
        {
            var daysRecord:YYVipDayWelfare = item.dataSource as YYVipDayWelfare;
            var a:int = daysRecord.ID;
            //单个日礼包标题
            if(daysRecord.ID == 1)
            {
                render.txt_levelbag.text = "1-3级会员礼包";
            }else if(daysRecord.ID == 2)
            {
                render.txt_levelbag.text = "4-6级会员礼包";
            }else
            {
                render.txt_levelbag.text = "7-8级会员礼包";
            }
            //日礼包价格介绍
            render.txt_introduce.text = "" + daysRecord.value;
            if (yyData.isDaysReward(daysRecord.vipLevel)) {
                render.btn_get.label = "已领取";
            }else{
                //判断是否开通
                if((yyLevelPlayerSystem.platform.data as CYYData).yyVipGrade <= 0)
                {
                    render.btn_get.label = "开通并领取";
                }else if((yyLevelPlayerSystem.platform.data as CYYData).yyVipGrade < daysRecord.vipLevel)
                {
                    //判断等级是否足够
                    render.btn_get.label = "升级并领取";
                }else{
                    ObjectUtils.gray(render.btn_get,false);
                    render.btn_get.disabled = false;
                    render.btn_get.mouseEnabled = true;

                    render.btn_get.label = "立即领取";
                }
            }
            //读取对应表数据，并赋值给相应的数组
            var arr:Array = CRewardUtil.createByDropPackageID(system.stage, daysRecord.welfareID ).list;
            render.list_item.dataSource = arr;
            if(m_pViewUI.tab.selectedIndex == 0)
            {
                render.btn_get.clickHandler = new Handler(_onTakeDaysHandler, [daysRecord.vipLevel]);
            }else{
                render.btn_get.clickHandler = new Handler(_onTakeWeekHandler, [daysRecord.vipLevel]);
            }
        }else{
            //周礼包
            var weekRecord:YYVipWeekWelfare = item.dataSource as YYVipWeekWelfare;
            //单个周礼包标题
            if(weekRecord.ID == 1)
            {
                render.txt_levelbag.text = "1-3级会员礼包";
            }else if(weekRecord.ID == 2)
            {
                render.txt_levelbag.text = "4-6级会员礼包";
            }else
            {
                render.txt_levelbag.text = "7-8级会员礼包";
            }
            //周礼包价格介绍
            render.txt_introduce.text = "" + weekRecord.value;
            if (yyData.isWeekReward(weekRecord.vipLevel)) {
                render.btn_get.label = "已领取";
            }else{
                //判断是否开通
                if((yyLevelPlayerSystem.platform.data as CYYData).yyVipGrade <= 0)
                {
                    render.btn_get.label = "开通并领取";
                }else if((yyLevelPlayerSystem.platform.data as CYYData).yyVipGrade < weekRecord.vipLevel)
                {
                    //判断等级是否足够
                    render.btn_get.label = "升级并领取";
                }else{
                    ObjectUtils.gray(render.btn_get,false);
                    render.btn_get.disabled = false;
                    render.btn_get.mouseEnabled = true;

                    render.btn_get.label = "立即领取";
                }
            }
            //读取对应表数据，并赋值给相应的数组
            var dropPackageArr:Array = CRewardUtil.createByDropPackageID(system.stage, weekRecord.welfareID ).list;
            render.list_item.dataSource = dropPackageArr;
            if(m_pViewUI.tab.selectedIndex == 0)
            {
                render.btn_get.clickHandler = new Handler(_onTakeDaysHandler, [weekRecord.vipLevel]);
            }else{
                render.btn_get.clickHandler = new Handler(_onTakeWeekHandler, [weekRecord.vipLevel]);
            }
        }
    }

    private function _onClickDownloadHandler():void
    {
        var url:URLRequest = new URLRequest("http://hd.vip.yy.com/hdpage/act/1708actvip/");
        navigateToURL(url, "_blank");
    }

    //购买日礼包
    private function _onTakeDaysHandler(level:int):void
    {
        (system.getBean(CYYVipNetHandler) as CYYVipNetHandler).buyVipDayWelfareYYRequest(level);
    }
    //购买周礼包
    private function _onTakeWeekHandler(level:int):void
    {
        (system.getBean(CYYVipNetHandler) as CYYVipNetHandler).buyVipWeekWelfareYYRequest(level);
    }

    public function addBag():void
    {
        _updateTabTipState();
        m_pViewUI.getedImg.visible = true;
        m_pViewUI.getBtn.visible = false;

        var len:int = m_pViewUI.itemList.cells.length;
        for(var i:int = 0; i < len; i++)
        {
            var cell:Component = m_pViewUI.itemList.getCell(i);
            if(cell.visible)
            {
                //领取的物品飞到背包
                CFlyItemUtil.flyItemToBag(cell, cell.localToGlobal(new Point()), system);
            }
        }
    }

    /**
     * 日礼包领取动画
     * */
    public function addDaysBag(level:int):void
    {
        _updateTabTipState();
        for each (var cell:YYDayItemUI in m_pViewUI.list_reward.cells) {
            if ((cell.dataSource as YYVipDayWelfare) == null)
            {
                return;
            }
            if ((cell.dataSource as YYVipDayWelfare).vipLevel == level) {

                var len:int = cell.list_item.cells.length;
                //按钮置灰
                ObjectUtils.gray(cell.btn_get);
                cell.btn_get.disabled = true;
                cell.btn_get.mouseEnabled = false;
                cell.btn_get.label = "已领取";
                for(var i:int = 0; i < len; i++)
                {
                    var daysCell:Component = cell.list_item.getCell(i);
                    if(daysCell.visible)
                    {
                        //领取的物品飞到背包
                        CFlyItemUtil.flyItemToBag(daysCell, daysCell.localToGlobal(new Point()), system);
                    }
                }
            }
        }
    }
    /**
     * 周礼包领取动画
     * */
    public function addWeekBag(level:int):void
    {
        _updateTabTipState();
        for each (var cell:YYDayItemUI in m_pViewUI.list_reward.cells) {
            if ((cell.dataSource as YYVipWeekWelfare) == null)
            {
                return;
            }
            if ((cell.dataSource as YYVipWeekWelfare).vipLevel == level) {

                var len:int = cell.list_item.cells.length;
                //按钮置灰
                ObjectUtils.gray(cell.btn_get);
                cell.btn_get.disabled = true;
                cell.btn_get.mouseEnabled = false;
                cell.btn_get.label = "已领取";
                for(var i:int = 0; i < len; i++)
                {
                    var daysCell:Component = cell.list_item.getCell(i);
                    if(daysCell.visible)
                    {
                        //领取的物品飞到背包
                        CFlyItemUtil.flyItemToBag(daysCell, daysCell.localToGlobal(new Point()), system);
                    }
                }
            }
        }
    }

    // 小红点提示
    private function _updateTabTipState():void
    {
        _helper.updateAllReward(yyData);
        m_pViewUI.img_dian_0.visible = _helper.hasNewReward();
        m_pViewUI.img_dian_1.visible = _helper.hasDaysWeekReward();
        if(m_pViewUI.tab_award.selectedIndex == 0)
        {
            m_pViewUI.img_dian_2.visible = _helper.hasOneReward();
            m_pViewUI.img_dian_3.visible = _helper.hasTwoReward();
            m_pViewUI.img_dian_4.visible = _helper.hasThreeReward();
        }else{
            m_pViewUI.img_dian_2.visible = _helper.hasDaysReward();
            m_pViewUI.img_dian_3.visible = _helper.hasWeekReward();
            m_pViewUI.img_dian_4.visible = false;
        }
    }
    public function removeDisplay() : void
    {
        if ( m_bViewInitialized )
        {
            _removeListeners();

            if ( m_pViewUI && m_pViewUI.parent )
            {
                m_pViewUI.close( Dialog.CLOSE );
            }

            m_iSelectedIndex = 0;
            m_awardISelectedIndex = 0;
        }
    }

    private function _onClose( type : String ) : void
    {
        switch ( type )
        {
            default:
                if ( this.closeHandler )
                {
                    this.closeHandler.execute();
                }
                break;
        }
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

    private function get _helper():CYYVipHelpHandler
    {
        return system.getHandler(CYYVipHelpHandler) as CYYVipHelpHandler;
    }

    private function get _manager():CYYVipManager
    {
        return system.getHandler(CYYVipManager) as CYYVipManager;
    }

    public function get isViewShow():Boolean
    {
        return m_pViewUI && m_pViewUI.parent;
    }

    override public function dispose():void
    {
        super.dispose();

        m_pViewUI = null;
        m_pCloseHandler  = null;
        m_iSelectedIndex = 0;
        m_awardISelectedIndex = 0;
    }


}
}
