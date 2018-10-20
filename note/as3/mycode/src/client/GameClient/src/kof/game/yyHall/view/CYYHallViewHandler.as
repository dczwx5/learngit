//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/12/9.
 */
package kof.game.yyHall.view {

import com.greensock.TweenMax;

import flash.events.Event;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import kof.data.KOFTableConstants;

import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.common.CFlyItemUtil;
import kof.game.common.CItemUtil;
import kof.game.common.CRewardUtil;
import kof.game.platform.yy.data.CYYData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.yyHall.CYYHallHelpHandler;
import kof.game.yyHall.CYYHallManager;
import kof.game.yyHall.CYYHallNetHandler;
import kof.game.yyHall.data.CYYRewardData;
import kof.message.PlatformReward.PlatformRewardInfoYYResponse;
import kof.table.YYGameLevelReward;
import kof.table.YYLevelReward;
import kof.table.YYLoginReward;
import kof.table.YYRewardConfig;
import kof.table.YYVipDayWelfare;
import kof.table.YYVipLevelReward;
import kof.ui.CUISystem;
import kof.ui.platform.yy.YYPrivilegeUI;
import kof.ui.platform.yy.YYRewardRenderUI;

import morn.core.components.Component;

import morn.core.components.Dialog;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CYYHallViewHandler extends CViewHandler {

    private var m_bViewInitialized : Boolean;
    private var yyData:CYYRewardData;
    private var m_pViewUI : YYPrivilegeUI;
    private var m_pCloseHandler : Handler;
    private var m_iSelectedIndex:int;
    private var m_state:int;
    private var m_i:int = 7;
    public function CYYHallViewHandler( bLoadViewByDefault : Boolean = false )
    {
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
        return [YYPrivilegeUI];
    }

    override protected function get additionalAssets():Array
    {
        return ["yy.swf", "frameclip_item.swf", "frameclip_item2.swf"];
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
                yyData = (system.getBean(CYYHallManager) as CYYHallManager).data;

                m_pViewUI = new YYPrivilegeUI();//创建UI实例
                m_pViewUI.list_reward.renderHandler = new Handler(_renderLevelReward);
                m_pViewUI.list_rewardNew.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system, 1));//传物品系统
                m_pViewUI.btn_downLoad.clickHandler = new Handler(_onClickDownloadHandler);//下载按钮
                m_pViewUI.btn_takeNew.clickHandler = new Handler(_onTakeNewHandler);//立即领取
                //m_pViewUI.tab.selectHandler//tab添加点击事件
                m_pViewUI.list_reward.mask = m_pViewUI.img_mask;
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

    private function _addListeners():void
    {
        m_pViewUI.tab.addEventListener( Event.CHANGE, _onTabSelectedHandler);
//        system.addEventListener(C7K7KEvent.UpdateAllRewardInfo, _onRewardsInfoUpdateHandler);
//        system.addEventListener(C7K7KEvent.UpdateDailyRewardState, _onDailyRewardStateHandler);
//        system.addEventListener(C7K7KEvent.UpdateNewRewardState, _onNewRewardStateHandler);
//        system.addEventListener(C7K7KEvent.UpdateLevelRewardState, _onLevelRewardStateHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.tab.removeEventListener( Event.CHANGE, _onTabSelectedHandler);
//        system.removeEventListener(C7K7KEvent.UpdateAllRewardInfo, _onRewardsInfoUpdateHandler);
//        system.removeEventListener(C7K7KEvent.UpdateDailyRewardState, _onDailyRewardStateHandler);
//        system.removeEventListener(C7K7KEvent.UpdateNewRewardState, _onNewRewardStateHandler);
//        system.removeEventListener(C7K7KEvent.UpdateLevelRewardState, _onLevelRewardStateHandler);
    }

    private function _initView():void
    {
        if ( m_pViewUI )
        {
            _initTabBarData();
            _updateyyState();
            m_pViewUI.tab.selectedIndex = m_iSelectedIndex;
            _onTabSelectedHandler();
        }
    }

    private function _initTabBarData():void
    {
        m_pViewUI.tab.labels = "新手礼包,登录礼包,等级礼包,YY贵族礼包";
    }
    //更新yy整个界面的显示状态
    public function _updateyyState():void
    {
        //按钮置灰
        if(yyData.newPlayerRewardState == 1)
        {
            ObjectUtils.gray(m_pViewUI.btn_takeNew);
            m_pViewUI.btn_takeNew.disabled = true;
            m_pViewUI.btn_takeNew.mouseEnabled = false;
        }else
        {
            ObjectUtils.gray(m_pViewUI.btn_takeNew,false);
            m_pViewUI.btn_takeNew.disabled = false;
            m_pViewUI.btn_takeNew.mouseEnabled = true;
        }
        //小红点
        _updateTabTipState();
    }
    // 小红点提示
    private function _updateTabTipState():void
    {
//        if(yyData.loginRewardState == null || yyData.gameLevelRewardState == null ||
//                yyData.yyLevelRewardState == null)
//        {
//            return;
//        }
//        if(yyData.newPlayerRewardState == 1)
//        {
//            _helper.updateNewReward(false);
//        }else{
//            _helper.updateNewReward(true);
//        }
//        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;//获取表系统
//
//        //表里的登录数组长度 == 领取的登录天数数组长度？&& 天数达到可领取天数，小红点是否消失
//        var pTable:IDataTable = pDatabase.getTable(KOFTableConstants.YYLOGINREWARD);
//        if(pTable.tableMap.length != yyData.loginRewardState.length &&
//                yyData.isGetLoginReward(yyData.loginDays))
//        {
//            _helper.updateLoginReward(true);
//        }else{
//            _helper.updateLoginReward(false);
//        }
//
//        //表里的等级数组长度 == 领取的等级数组长度？&& 等级达到可领取等级，小红点是否消失
//        var levelTable:IDataTable = pDatabase.getTable(KOFTableConstants.YYGAMELEVELREWARD);
//        var levelPlayerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
//        if(levelTable.tableMap.length != yyData.gameLevelRewardState.length &&
//                yyData.isGetGameLevelReward(levelPlayerData.teamData.level))
//        {
//            _helper.updateLevelReward(true);
//        }else{
//            _helper.updateLevelReward(false);
//        }
//
//        //表里的贵族等级数组长度 == 领取的贵族等级数组长度？判断小红点是否消失
//        var yyTable:IDataTable = pDatabase.getTable(KOFTableConstants.YYLEVELREWARD);
//        var yyLevelPlayerSystem:CPlayerSystem = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem);
//        if(yyTable.tableMap.length != yyData.yyLevelRewardState.length &&
//                yyData.isGetYYLevelRewardState((yyLevelPlayerSystem.platform.data as CYYData).yyLevel))
//        {
//            _helper.updateGuizuReward(true);
//        }else{
//            _helper.updateGuizuReward(false);
//        }
        _helper.updateAllReward(yyData);
        m_pViewUI.img_dian_0.visible = _helper.hasNewReward();
        m_pViewUI.img_dian_1.visible = _helper.hasLoginReward();
        m_pViewUI.img_dian_2.visible = _helper.hasLevelReward();
        m_pViewUI.img_dian_3.visible = _helper.hasGuizuReward();
    }
    /**
     * 切换页签处理
     * @param e
     */
    private function _onTabSelectedHandler(e:Event = null):void
    {
        m_pViewUI.list_reward.visible = m_pViewUI.tab.selectedIndex != 0;
        m_pViewUI.box_rewardNew.visible = m_pViewUI.tab.selectedIndex == 0;

        switch(m_pViewUI.tab.selectedIndex)
        {
            case 0:
                _updateNewRewards();
                break;
            case 1:
                _updateEveryDayRewards();
                break;
            case 2:
                _updateLevelRewards();
                break;
            case 3:
                _updateYYNobleRewards();
                break;
        }
    }

    /**
     * 新手奖励 1
     */
    private function _updateNewRewards():void
    {
        // TODO
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;//获取表系统
        var pTable:IDataTable = pDatabase.getTable(KOFTableConstants.YYREWAEDCONFIG);//获取表系统

        var pRecord:YYRewardConfig = pTable.findByPrimaryKey(1) as YYRewardConfig;//获取表系统里的ID为1的一整行

        //读取对应表数据，并赋值给相应的数组
        var arr:Array = CRewardUtil.createByDropPackageID(system.stage, pRecord.newPlayerReward ).list;
        m_pViewUI.list_rewardNew.repeatX = arr.length;
        m_pViewUI.list_rewardNew.dataSource = arr;
        m_pViewUI.list_rewardNew.centerX = 0;
        if(yyData.newPlayerRewardState == 1)
        {
            ObjectUtils.gray(m_pViewUI.btn_takeNew);
            m_pViewUI.btn_takeNew.disabled = true;
            m_pViewUI.btn_takeNew.mouseEnabled = false;
        }else
        {
            ObjectUtils.gray(m_pViewUI.btn_takeNew,false);
            m_pViewUI.btn_takeNew.disabled = false;
            m_pViewUI.btn_takeNew.mouseEnabled = true;
        }
    }

    /**
     * 每日奖励 2
     */
    private function _updateEveryDayRewards():void
    {
        // TODO
        m_state = 2;
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;//获取表系统
        var pTable:IDataTable = pDatabase.getTable(KOFTableConstants.YYLOGINREWARD);
        var pList:Array = pTable.toArray();
        m_pViewUI.list_reward.dataSource = pList;
    }

    /**
     * 等级奖励
     */
    private function _updateLevelRewards():void
    {
        // TODO
        m_state = 3;
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;//获取表系统
        var pTable:IDataTable = pDatabase.getTable(KOFTableConstants.YYGAMELEVELREWARD);
        var pList:Array = pTable.toArray();
        m_pViewUI.list_reward.dataSource = pList;
    }

    /**
     * YY贵族奖励
     */
    private function _updateYYNobleRewards():void
    {
        // TODO
        m_state = 4;
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;//获取表系统
        var pTable:IDataTable = pDatabase.getTable(KOFTableConstants.YYLEVELREWARD);
        var pList:Array = pTable.toArray();
        m_pViewUI.list_reward.dataSource = pList;
    }

    private function _renderLevelReward(item:Component, index:int):void
    {
        if ( !(item is YYRewardRenderUI) )
        {
            return;
        }
        if (item.dataSource == null) {
            item.visible = false;
            return ;
        }
        item.visible = true;

        var render : YYRewardRenderUI = item as YYRewardRenderUI;
        render.mouseChildren = true;
        render.mouseEnabled = true;
        render.list_item.renderHandler = new Handler(CItemUtil.getItemRenderFunc(system, 1));
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;//获取表系统
        if( m_state == 2){
//            var pTable:IDataTable = pDatabase.getTable(KOFTableConstants.YYLOGINREWARD);//获取表系统里的表
            var pRecord:YYLoginReward = item.dataSource as YYLoginReward;//用item直接赋值\\
//            var yyData:CYYRewardData = (system.getBean(CYYHallManager) as CYYHallManager).data;
            //判断是否领取过
            if (yyData.isLoginReward(pRecord.days)) {
                render.img_hasTake.visible = true;
                render.btn_take.visible = false;
            }else{
                render.img_hasTake.visible = false;
                render.btn_take.visible = true;
                //判断是否达到领取条件
                if(yyData.loginDays < pRecord.days)
                {
                    ObjectUtils.gray(render.btn_take);
                    render.btn_take.disabled = true;
                    render.btn_take.mouseEnabled = false;
                }else{
                    ObjectUtils.gray(render.btn_take,false);
                    render.btn_take.disabled = false;
                    render.btn_take.mouseEnabled = true;
                }
            }
            //读取对应表数据，并赋值给相应的数组
            var arr:Array = CRewardUtil.createByDropPackageID(system.stage, pRecord.rewardID ).list;
            render.list_item.dataSource = arr;
            render.txt_title.text = "使用YY游戏大厅,累积登录" + "<b><font color = '#fffe5e'>"
                + pRecord.days + "</b></font>" + "天可领取";

            render.btn_take.clickHandler = new Handler(_onTakeDaysHandler, [pRecord.days]);

        }else if( m_state == 3){
//            var pTable3:IDataTable = pDatabase.getTable(KOFTableConstants.YYGAMELEVELREWARD);
//            var pRecord3:YYGameLevelReward = pTable3.findByPrimaryKey(1) as YYGameLevelReward;
            var pRecord3:YYGameLevelReward = item.dataSource as YYGameLevelReward;

            var arr3:Array = CRewardUtil.createByDropPackageID(system.stage, pRecord3.rewardID ).list;
            render.list_item.dataSource = arr3;
            render.txt_title.text = "使用YY游戏大厅,且游戏角色达到" + "<b><font color = '#fffe5e'>"
                   + pRecord3.gameLevel + "</b></font>" + "级可领取";

            render.btn_take.clickHandler = new Handler(_onLevelRewardHandler, [pRecord3.gameLevel]);
            //判断游戏等级奖励是否已经被领取过
            if (yyData.isGameLevelReward(pRecord3.gameLevel)) {
                render.img_hasTake.visible = true;
                render.btn_take.visible = false;
            }else{
                render.img_hasTake.visible = false;
                render.btn_take.visible = true;
                //方法1
                var levelPlayerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
                //方法2
//                var pPlayerSystem:CPlayerSystem = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem);
//                var pPlayerData:CPlayerData = pPlayerSystem.playerData;
                //判断是否达到领取条件
                if(levelPlayerData.teamData.level < pRecord3.gameLevel)
                {
                    ObjectUtils.gray(render.btn_take);
                    render.btn_take.disabled = true;
                    render.btn_take.mouseEnabled = false;
                }else{
                    ObjectUtils.gray(render.btn_take,false);
                    render.btn_take.disabled = false;
                    render.btn_take.mouseEnabled = true;
                }
            }

        }else if( m_state == 4){
//            var pTable4:IDataTable = pDatabase.getTable(KOFTableConstants.YYLEVELREWARD);
//            var pRecord4:YYLevelReward = pTable4.findByPrimaryKey(1) as YYLevelReward;
            var pRecord4:YYLevelReward = item.dataSource as YYLevelReward;

            var arr4:Array = CRewardUtil.createByDropPackageID(system.stage, pRecord4.rewardID).list;
            render.list_item.dataSource = arr4;
            render.txt_title.text = "YY等级达到" + "<b><font color = '#fffe5e' bold = 'true'>"
                    + pRecord4.level + "</b></font>" + "级可领取";
            render.btn_take.clickHandler = new Handler(_onVipLevelRewardHandler, [pRecord4.ID]);
//            render.btn_take.clickHandler = new Handler(_onVipLevelRewardHandler, [pRecord4.level]);
            //判断YY贵族等级奖励是否已经被领取过
            if (yyData.isYYLevelRewardState(pRecord4.ID)) {
                render.img_hasTake.visible = true;
                render.btn_take.visible = false;
            }else{
                render.img_hasTake.visible = false;
                render.btn_take.visible = true;
                //判断是否达到领取条件
                var yyLevelPlayerSystem:CPlayerSystem = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem);
                if((yyLevelPlayerSystem.platform.data as CYYData).yyLevel < pRecord4.ID)
                {
                    ObjectUtils.gray(render.btn_take);
                    render.btn_take.disabled = true;
                    render.btn_take.mouseEnabled = false;
                }else{
                    ObjectUtils.gray(render.btn_take,false);
                    render.btn_take.disabled = false;
                    render.btn_take.mouseEnabled = true;
                }
            }

        }
//        TweenMax.fromTo(render, 0.3, {x:666}, {x:0, delay:0.1*index});
    }

    private function _onClickDownloadHandler():void
    {
        var url:URLRequest = new URLRequest("http://wan.yy.com/yygame.html");
        navigateToURL(url, "_blank");
    }

    private function _onTakeNewHandler():void
    {
        //判断是否已经领取过了，发送新手礼包领取消息
        if(yyData.newPlayerRewardState == 2)
        {
            (system.getBean( CYYHallNetHandler ) as CYYHallNetHandler).newPlayerRewardYYRequest( 1 );
        }
    }
    public function addBag():void
    {
        _updateTabTipState();
        //按钮置灰
        ObjectUtils.gray(m_pViewUI.btn_takeNew);
        m_pViewUI.btn_takeNew.disabled = true;
        m_pViewUI.btn_takeNew.mouseEnabled = false;

        var len:int = m_pViewUI.list_rewardNew.cells.length;
        for(var i:int = 0; i < len; i++)
        {
            var cell:Component = m_pViewUI.list_rewardNew.getCell(i);
            if(cell.visible)
            {
                //领取的物品飞到背包
                CFlyItemUtil.flyItemToBag(cell, cell.localToGlobal(new Point()), system);
            }
        }
    }
    /**
     * 登录天数礼包领取动画
     * */
    public function addDaysBag(loginDays:int):void
    {
        _updateTabTipState();
        for each (var cell:YYRewardRenderUI in m_pViewUI.list_reward.cells) {
            if ((cell.dataSource as YYLoginReward) == null)
            {
                return;
            }
            if ((cell.dataSource as YYLoginReward).days == loginDays) {

                var len:int = cell.list_item.cells.length;
                //按钮置灰
                cell.img_hasTake.visible = true;
                cell.btn_take.visible = false;
                for(var i:int = 0; i < len; i++)
                {
//                    var daysCell:Component = m_pViewUI.list_reward.getCell(i + m_pViewUI.list_reward.startIndex);
//                    if ((cell.dataSource as YYLoginReward).days == loginDays) {
//                        CFlyItemUtil.flyItemToBag(daysCell, daysCell.localToGlobal(new Point()), system);
//                    }
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
     * 等级礼包领取动画
     * */
    public function addLevelRewardBag(gameLevel:int):void
    {
        _updateTabTipState();
        for each (var cell:YYRewardRenderUI in m_pViewUI.list_reward.cells) {
            if ((cell.dataSource as YYGameLevelReward) == null)
            {
                return;
            }
            if ((cell.dataSource as YYGameLevelReward).gameLevel == gameLevel) {

                var len:int = cell.list_item.cells.length;
                //按钮置灰
                cell.img_hasTake.visible = true;
                cell.btn_take.visible = false;
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
     * YY贵族礼包领取动画
     * */
    public function addYYLevelRewardBag(yyLevel:int):void
    {
        _updateTabTipState();
        for each (var cell:YYRewardRenderUI in m_pViewUI.list_reward.cells) {
            if ((cell.dataSource as YYLevelReward) == null)
            {
                return;
            }
            if ((cell.dataSource as YYLevelReward).ID == yyLevel) {

                var len:int = cell.list_item.cells.length;
                //按钮置灰
                cell.img_hasTake.visible = true;
                cell.btn_take.visible = false;
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
    private function _onTakeDaysHandler(days:int):void
    {
        (system.getBean(CYYHallNetHandler) as CYYHallNetHandler).loginRewardYYRequest(days);
    }
    private function _onLevelRewardHandler(level:int):void
    {
        (system.getBean(CYYHallNetHandler) as CYYHallNetHandler).gameLevelRewardYYRequest(level);
    }
    private function _onVipLevelRewardHandler(level:int):void
    {
        (system.getBean(CYYHallNetHandler) as CYYHallNetHandler).yYLevelRewardRequest(level);
    }
    public function alreadyReceive(i:int):void
    {
//        m_pViewUI.list_reward.getItem(i).img_hasTake.visible = false;
    }
// 监听=================================================================================================================
    private function _onRewardsInfoUpdateHandler():void
    {
        // TODO
    }

    /**
     * 领取每日奖励后更新按钮状态
     * @param e
     */
    private function _onDailyRewardStateHandler():void
    {
        // TODO
    }

    /**
     * 领取新手奖励后更新按钮状态
     * @param e
     */
    private function _onNewRewardStateHandler():void
    {
        // TODO
    }

    /**
     * 领取等级奖励后更新按钮状态
     * @param e
     */
    private function _onLevelRewardStateHandler():void
    {
        // TODO
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

    private function get _helper():CYYHallHelpHandler
    {
        return system.getHandler(CYYHallHelpHandler) as CYYHallHelpHandler;
    }

    private function get _manager():CYYHallManager
    {
        return system.getHandler(CYYHallManager) as CYYHallManager;
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
    }
}
}
