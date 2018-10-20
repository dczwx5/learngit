//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/5/25.
 */
package kof.game.impression.view {

import QFLib.Foundation.CTime;
import QFLib.Interface.IDisposable;
import QFLib.Utils.HtmlUtil;

import com.greensock.TimelineLite;

import com.greensock.TweenMax;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.setTimeout;

import kof.SYSTEM_ID;
import kof.framework.CAppSystem;
import kof.game.KOFSysTags;

import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CItemUtil;
import kof.game.common.CLang;
import kof.game.common.CRewardUtil;
import kof.game.common.CUIFactory;
import kof.game.common.view.event.CViewEvent;
import kof.game.impression.CImpressionHelpHandler;
import kof.game.impression.CImpressionNetHandler;
import kof.game.impression.data.CFoodData;
import kof.game.impression.data.CImpressionAttrData;
import kof.game.impression.data.CImpressionTaskData;
import kof.game.impression.data.CPlayerInfoData;
import kof.game.impression.event.EImpressionViewEventType;
import kof.game.impression.util.CImpressionRenderUtil;
import kof.game.impression.util.CImpressionState;
import kof.game.impression.util.CImpressionUtil;
import kof.game.impression.util.EImpressionTaskStateType;
import kof.game.impression.util.EImpressionUpdateType;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.game.item.view.tips.CItemTipsView;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.event.CPlayerEvent;
import kof.game.common.data.CAttributeBaseData;
import kof.game.playerCard.util.CTransformSpr;
import kof.game.task.data.CTaskData;
import kof.game.task.data.CTaskJumpConst;
import kof.game.task.data.CTaskStateType;
import kof.table.Impression;
import kof.table.ImpressionTitle;
import kof.table.Task;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.imp_common.ItemUIUI;
import kof.ui.master.impression.ImpressionAttrUI;
import kof.ui.master.impression.ImpressionFoodItemUI;
import kof.ui.master.impression.ImpressionUpgradeUI;

import morn.core.components.Button;

import morn.core.components.Component;
import morn.core.components.Image;
import morn.core.components.Label;
import morn.core.components.List;
import morn.core.handlers.Handler;

/**
 * 亲密度培养和属性展示部分
 */
public class CImpressionUpgradeView implements IDisposable
{
    private var m_pViewUI : ImpressionUpgradeUI;
    private var m_pData:CPlayerInfoData;
    private var m_pCurrTask:Task;
    private var m_pTimer:Timer;
    private var m_iOldLevel:int;
    private var m_iUpdateType:int;
    private var m_iOldProgressValue:int;

    private var m_pSystem:CAppSystem;

    public function CImpressionUpgradeView()
    {
    }

    public function initialize() : Boolean {
        if ( m_pViewUI )
        {
//            m_pViewUI.list_currAttr.renderHandler = new Handler(_renderAttrList);
            m_pViewUI.list_foodItem.renderHandler = new Handler(_renderItemList);
            m_pViewUI.list_foodItem.mouseHandler = new Handler(_listMouseHandler);
            m_pViewUI.list_taskReward.renderHandler = new Handler(CItemUtil.getItemRenderFunc(m_pSystem));
//            (m_pViewUI.star.getChildAt(0) as List).renderHandler = new Handler(CImpressionRenderUtil.renderStar);
//
//            m_pViewUI.box_nextInfo.mouseChildren = true;

            m_pViewUI.list_attr.renderHandler = new Handler(_renderAttrList);

            m_pViewUI.clip_progress.visible = false;
            m_pViewUI.frameClip_item.visible = false;
        }

//        m_pViewUI.progress_impression.bar.y += 1;

        m_pTimer = new Timer(1000,int.MAX_VALUE);

        return Boolean( m_pViewUI );
    }

    private function _addListeners():void
    {
        m_pViewUI.btn_oneKey.addEventListener(MouseEvent.CLICK, _onClickHandler);
        m_pViewUI.btn_goto.addEventListener(MouseEvent.CLICK, _onClickHandler);
        m_pViewUI.btn_takeReward.addEventListener(MouseEvent.CLICK, _onClickHandler);
        m_pViewUI.btn_recall.addEventListener(MouseEvent.CLICK, _onClickHandler);

        m_pSystem.stage.getSystem(CPlayerSystem ).addEventListener(CPlayerEvent.HERO_DATA,_onPlayerUpdateHandler);

        if(m_pSystem.stage.getSystem(CBagSystem))
        {
            (m_pSystem.stage.getSystem(CBagSystem) as CBagSystem).listenEvent(_onBagItemsChangeHandler);
        }

        if(m_pTimer)
        {
            m_pTimer.addEventListener(TimerEvent.TIMER,_onTimerEventHandler);
        }

//        m_pViewUI.box_nextInfo.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);

        var getHeroBtn:Button = m_pViewUI.box_progress.getChildByName("btn_getHero") as Button;
        getHeroBtn.addEventListener(MouseEvent.CLICK, _onGetHeroHandler);

        m_pViewUI.img_notGet.addEventListener(MouseEvent.ROLL_OVER, _onRollOverHandler);
        m_pViewUI.img_notGet.addEventListener(MouseEvent.ROLL_OUT, _onRollOutHandler);
        m_pViewUI.img_title.addEventListener(MouseEvent.ROLL_OVER, _onRollOverHandler);
        m_pViewUI.img_title.addEventListener(MouseEvent.ROLL_OUT, _onRollOutHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.btn_oneKey.removeEventListener(MouseEvent.CLICK, _onClickHandler);
        m_pViewUI.btn_goto.removeEventListener(MouseEvent.CLICK, _onClickHandler);
        m_pViewUI.btn_takeReward.removeEventListener(MouseEvent.CLICK, _onClickHandler);
        m_pViewUI.btn_recall.removeEventListener(MouseEvent.CLICK, _onClickHandler);

        m_pSystem.stage.getSystem(CPlayerSystem ).removeEventListener(CPlayerEvent.HERO_DATA,_onPlayerUpdateHandler);

        if(m_pSystem.stage.getSystem(CBagSystem))
        {
            (m_pSystem.stage.getSystem(CBagSystem) as CBagSystem).unListenEvent(_onBagItemsChangeHandler);
        }

        if(m_pTimer)
        {
            m_pTimer.removeEventListener(TimerEvent.TIMER,_onTimerEventHandler);
        }

//        m_pViewUI.box_nextInfo.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);

        var getHeroBtn:Button = m_pViewUI.box_progress.getChildByName("btn_getHero") as Button;
        getHeroBtn.removeEventListener(MouseEvent.CLICK, _onGetHeroHandler);

        m_pViewUI.img_notGet.removeEventListener(MouseEvent.ROLL_OVER, _onRollOverHandler);
        m_pViewUI.img_notGet.removeEventListener(MouseEvent.ROLL_OUT, _onRollOutHandler);
        m_pViewUI.img_title.removeEventListener(MouseEvent.ROLL_OVER, _onRollOverHandler);
        m_pViewUI.img_title.removeEventListener(MouseEvent.ROLL_OUT, _onRollOutHandler);
    }

    public function set data(value:*):void
    {
        clear();

        m_pData = value as CPlayerInfoData;
        if(m_pData)
        {
            m_iUpdateType = EImpressionUpdateType.Type_Select;
            updateDisplay();
        }
    }

    protected function updateDisplay():void
    {
        clear();

        updateTitle();
        _updateTitleTips();
        updateName();
        updateStar();
        updateCurrAndNextAttr();
        updateHeroDesc();
        updateProgressInfo();
        updateBtnState();
        updateFoodItemInfo();
        updateTaskInfo();
        updateAdvanceInfo();
    }

    /**
     * 称号
     */
    private function updateTitle():void
    {
        if(heroImpressionLevel == 0)
        {
            m_pViewUI.img_notGet.visible = true;
            m_pViewUI.img_title.visible = false;
            return;
        }

        var heroData:CPlayerHeroData = _heroData;
        if(heroData)
        {
            var sex:int = heroData.playerBasic != null ? heroData.playerBasic.gender : 0;
            var tTitleInfo:ImpressionTitle = CImpressionUtil.getTitleInfoByLevelAndSex(heroImpressionLevel,sex);
            if(tTitleInfo)
            {
                m_pViewUI.img_notGet.visible = false;
                m_pViewUI.img_title.visible = true;
                m_pViewUI.img_title.skin = "png.impression." + tTitleInfo.icon;
            }
        }
    }

    /**
     * 名字
     */
    private function updateName():void
    {
//        m_pViewUI.img_heroName.url = CPlayerPath.getUIHeroNamePath(m_pData.roleId);
    }

    /**
     * 星级
     */
    private function updateStar():void
    {
        var pHeroData:CPlayerHeroData = CImpressionUtil.getHeroDataById(m_pData.roleId);
        var iStar:int = pHeroData == null ? 0 : pHeroData.star;
        var pDataArr:Array = [];
        for(var i:int = 0; i < 7; i++)
        {
            if(i < iStar)
            {
                pDataArr[i] = 1;
            }
            else
            {
                pDataArr[i] = 2;
            }
        }
//        var pStarList:List = m_pViewUI.star.getChildAt(0) as List;
//        pStarList.dataSource = pDataArr;
    }

    /**
     * 当前和下级属性
     */
    private function updateCurrAndNextAttr():void
    {
        /*
        if(_heroData && _heroData.hasData)
        {
            m_pViewUI.box_currAttrInfo.visible = true;
            m_pViewUI.box_nextInfo.visible = true;

            var currArr:Array = CImpressionUtil.getCurrTotalAttr(m_pData.roleId,heroImpressionLevel);
            m_pViewUI.list_currAttr.dataSource = currArr;

            var commonTitleBg:Image = m_pViewUI.box_nextInfo.getChildByName("img_commonTitleBg") as Image;
            var fullTitleBg:Image = m_pViewUI.box_nextInfo.getChildByName("img_fullTitleBg") as Image;
            var fullLevelLabel:Label = m_pViewUI.box_nextInfo.getChildByName("txt_fullLevel") as Label;
            var nextLevelLabel:Label = m_pViewUI.box_nextInfo.getChildByName("txt_next") as Label;
            var expandBtn:Button = m_pViewUI.box_nextInfo.getChildByName("btn_expand") as Button;
            var nextList:List = m_pViewUI.box_nextInfo.getChildByName("list_next") as List;
            var nextListBg:Image = m_pViewUI.box_nextInfo.getChildByName("img_listBg") as Image;

            if(CImpressionUtil.isFullLevel(_heroData))
            {
                commonTitleBg.visible = false;
                fullTitleBg.visible = true;
                fullLevelLabel.visible = true;
                nextLevelLabel.visible = false;
                expandBtn.visible = false;
                nextList.visible = false;
                nextListBg.visible = false;
            }
            else
            {
                commonTitleBg.visible = true;
                fullTitleBg.visible = false;
                fullLevelLabel.visible = false;
                nextLevelLabel.visible = true;
                expandBtn.visible = true;

                if(nextList.renderHandler == null)
                {
                    nextList.renderHandler = new Handler(_renderAttrList);
                }
                var nextArr:Array = CImpressionUtil.getNextAttr(heroImpressionLevel+1,m_pData.roleId);
                nextList.dataSource = nextArr;
            }

            if(m_iUpdateType == EImpressionUpdateType.Type_Select)
            {
                nextList.visible = false;
                nextListBg.visible = false;
            }
        }
        else
        {
            m_pViewUI.box_currAttrInfo.visible = false;
            m_pViewUI.box_nextInfo.visible = false;
        }
        */

        if(_heroData)
        {
            var arr:Array = CImpressionUtil.getAttrInfoWithCombat(_heroData.prototypeID, heroImpressionLevel);
            m_pViewUI.list_attr.dataSource = arr;
        }
        else
        {
            m_pViewUI.list_attr.dataSource = [];
        }
    }

    private function get _additionAttr():Array
    {
        return CImpressionUtil.getNextAttr(heroImpressionLevel + 1, m_pData.roleId);
    }

    /**
     * 简介
     */
    private function updateHeroDesc():void
    {
        /*
        if(_heroData && _heroData.hasData)
        {
            m_pViewUI.box_introduce.visible = false;
        }
        else
        {
            m_pViewUI.box_introduce.visible = true;
            var textArea_desc:Label = m_pViewUI.box_introduce.getChildByName("textArea_desc") as Label;
            var impression:Impression = CImpressionUtil.getImpressionConfig(m_pData.roleId);
            textArea_desc.text = impression == null ? "" : impression.description;
        }
        */
    }

    /**
     * 好感度等级和进度信息
     */
    private function updateProgressInfo():void
    {
        m_pViewUI.txt_level.text = "LV." + heroImpressionLevel;

        var progressLabel:Label = m_pViewUI.box_progress.getChildByName("txt_progressInfo") as Label;

        if(_heroData)
        {
            var quality:int = _heroData.playerBasic != null ? _heroData.playerBasic.intelligence : 0;
            var maxExp:int = CImpressionUtil.getMaxExp(quality,heroImpressionLevel);
            if(maxExp == 0)
            {
                m_pViewUI.progress_impression.value = 0;
                progressLabel.text = "0/0";
            }
            else
            {
//                m_pViewUI.progress_impression.value = heroImpressionExp/maxExp;
                if(TweenMax.isTweening(m_pViewUI.progress_impression))
                {
                    TweenMax.killTweensOf(m_pViewUI.progress_impression);
                }

                var progressValue:Number = heroImpressionExp/maxExp;
                TweenMax.to(m_pViewUI.progress_impression, 0.3, {value:progressValue});

                progressLabel.text = heroImpressionExp+"/"+maxExp;
            }
        }
        else
        {
            m_pViewUI.progress_impression.value = 0;
            progressLabel.text = "0/0";
        }

        if(m_iUpdateType == EImpressionUpdateType.Type_Select)
        {
            m_iOldProgressValue = heroImpressionExp;
            m_pViewUI.txt_progressAddValue.text = "";
        }
        else if(m_iUpdateType == EImpressionUpdateType.Type_Data)
        {
            var addValue:int = heroImpressionExp - m_iOldProgressValue;
            if(addValue > 0)
            {
                _showProgressAddValue(addValue);
            }

            m_iOldProgressValue = heroImpressionExp;
        }
    }

    private var m_pTimeline:TimelineLite;
    private var m_pTransformSpr:CTransformSpr;
    private function _showProgressAddValue(value:int):void
    {
        m_pViewUI.txt_progressAddValue.text = "+" + value;

        if(m_pTimeline)
        {
            m_pTimeline._kill();
            m_pTimeline.clear();
        }

        if(m_pTransformSpr == null)
        {
            m_pViewUI.txt_progressAddValue.x = 131;
            m_pViewUI.txt_progressAddValue.y = 8;

            m_pTransformSpr = CUIFactory.getDisplayObj(CTransformSpr) as CTransformSpr;
            m_pTransformSpr.transformObj = m_pViewUI.txt_progressAddValue;
            m_pViewUI.box_progress.addChild(m_pTransformSpr);
        }

        if(m_pTimeline == null)
        {
            m_pTimeline = new TimelineLite();
        }

        m_pTimeline.append(TweenMax.fromTo(m_pTransformSpr, 0.2, {alpha:1, scale:2, y:30}, {scale:1}));
        m_pTimeline.append(TweenMax.to(m_pTransformSpr, 0.3, {y:10}));
        m_pTimeline.append(TweenMax.to(m_pTransformSpr, 0.2, {alpha:0, delay:0.2}));
    }

    /**
     * 格斗家获取按钮状态
     */
    private function updateBtnState():void
    {
        var btn_oneKey:Button = m_pViewUI.box_progress.getChildByName("btn_oneKey") as Button;
        var btn_getHero:Button = m_pViewUI.box_progress.getChildByName("btn_getHero") as Button;
        if(_heroData && _heroData.hasData)
        {
            btn_oneKey.visible = !CImpressionUtil.isFullLevel(_heroData);
            btn_getHero.visible = false;
        }
        else
        {
            btn_oneKey.visible = false;
            btn_getHero.visible = true;
        }
    }

    /**
     * 美食物品信息
     */
    private function updateFoodItemInfo():void
    {

        var list_foodItem:List = m_pViewUI.box_food.getChildByName("list_foodItem") as List;
        var img_bg:Image = m_pViewUI.box_food.getChildByName("img_bg") as Image;

        var dataArr:Array = CImpressionUtil.getFoodItems(m_pData.roleId);
        list_foodItem.dataSource = dataArr;

//        if(CImpressionUtil.isFullLevel(_heroData))
//        {
//            m_pViewUI.box_food.addChildAt(img_bg,1);
//        }
//        else
//        {
//            m_pViewUI.box_food.addChildAt(img_bg,0);
//        }
    }

    /**
     * 当前任务及任务预告信息
     */
    private function updateTaskInfo():void
    {
        var txt_taskTitle:Label = m_pViewUI.box_task.getChildByName("txt_taskTitle") as Label;
        var txt_content:Label = m_pViewUI.box_task.getChildByName("txt_content") as Label;
        var txt_timeLimit:Label = m_pViewUI.box_task.getChildByName("txt_timeLimit") as Label;
        var txt_costDiamond:Label = m_pViewUI.box_task.getChildByName("txt_costDiamond") as Label;
        var img_currency:Image = m_pViewUI.box_task.getChildByName("img_currency") as Image;
        m_pViewUI.img_dian.visible = false;
        m_pViewUI.txt_taskProcess.visible = false;

        var heroData : CPlayerHeroData = CImpressionUtil.getHeroDataById( m_pData.roleId );
        if ( heroData && heroData.impressionTask )
        {
            var taskData : CImpressionTaskData = new CImpressionTaskData( heroData.impressionTask );
            if ( taskData.id )// 当前任务
            {
                var tTask : Task = CImpressionUtil.getTaskById( taskData.id );
                switch ( taskData.state ) {
                    case EImpressionTaskStateType.Type_Running:
                        txt_taskTitle.text = CLang.Get("impression_smrw");
                        txt_content.text = tTask.desc;
                        m_pCurrTask = tTask;
                        m_pViewUI.btn_goto.visible = tTask.link;
                        m_pViewUI.txt_taskProcess.visible = true;
                        m_pViewUI.txt_taskProcess.isHtml = true;
                        if(heroData.impressionTask.hasOwnProperty("conditionValue"))
                        {
                            m_pViewUI.txt_taskProcess.text = HtmlUtil.color("("+heroData.impressionTask.conditionValue+
                                "/"+int(tTask.conditionParm[0])+")","#f54d4d");
                        }
                        else
                        {
                            m_pViewUI.txt_taskProcess.text = "";
                        }
                        m_pViewUI.txt_taskProcess.x = txt_content.x + txt_content.width;

                        if(tTask.completeTime)// 限时任务
                        {
                            var currTime:Number = CTime.getCurrServerTimestamp();
                            var expiredTime:Number = taskData.time;
                            if(currTime < expiredTime)
                            {
                                _updateLeftTime(expiredTime-currTime);

                                if(!m_pTimer.running)
                                {
                                    m_pTimer.start();
                                }
                            }
                            else// 任务召回
                            {
                                txt_timeLimit.visible = false;
                                m_pViewUI.btn_goto.visible = false;
                                m_pViewUI.btn_recall.visible = true;
                                txt_costDiamond.visible = true;
                                img_currency.visible = true;
                                txt_costDiamond.text = tTask.costNum.toString();
                                img_currency.url = CImpressionUtil.getCurrencyIcon(tTask.costID);
                            }
                        }
                        break;
                    case EImpressionTaskStateType.Type_Complete:
                        txt_taskTitle.text = CLang.Get("impression_smrw");
                        txt_content.text = tTask.desc;
                        m_pCurrTask = tTask;
                        m_pViewUI.btn_takeReward.visible = true;
                        m_pViewUI.img_dian.visible = true;
                        m_pViewUI.txt_taskProcess.visible = true;
                        m_pViewUI.txt_taskProcess.isHtml = true;
                        if(heroData.impressionTask.hasOwnProperty("conditionValue"))
                        {
                            m_pViewUI.txt_taskProcess.text = HtmlUtil.color("("+heroData.impressionTask.conditionValue+
                                    "/"+int(tTask.conditionParm[0])+")","#00ff00");
                        }
                        else
                        {
                            m_pViewUI.txt_taskProcess.text = "";
                        }
                        m_pViewUI.txt_taskProcess.x = txt_content.x + txt_content.width;
                        break;
                }

                m_pViewUI.list_taskReward.visible = tTask.reward;
                _updateTaskReward( tTask );
            }

            _updateNextTaskInfo( taskData.id );// 任务预告
        }
        else
        {
            _updateNextTaskInfo(0);
        }
    }

    /**
     * 任务奖励信息
     * @param taskInfo
     */
    private function _updateTaskReward(taskInfo:Task):void
    {
        if(taskInfo && taskInfo.reward)
        {
            var rewardData:CRewardListData = CRewardUtil.createByDropPackageID(m_pSystem.stage,taskInfo.reward);
            if(rewardData)
            {
                m_pViewUI.list_taskReward.dataSource = rewardData.list;
            }
        }
    }

    /**
     * 任务预告
     */
    private function _updateNextTaskInfo(taskId:int):void
    {
        var txt_extraInfo:Label = m_pViewUI.box_task.getChildByName("txt_extraInfo") as Label;
        var txt_taskTitle:Label = m_pViewUI.box_task.getChildByName("txt_taskTitle") as Label;
        var txt_content:Label = m_pViewUI.box_task.getChildByName("txt_content") as Label;
        var txt_noTask:Label = m_pViewUI.box_task.getChildByName("txt_noTask") as Label;
        if(taskId > 0)// 当前有任务
        {
            var nextTaskInfo:Object = CImpressionUtil.getNextTaskInfoByCurrId(m_pData.roleId,taskId);
            if(nextTaskInfo)
            {
                txt_extraInfo.isHtml = true;
                txt_extraInfo.text = CLang.Get("impression_xyc",{v1:nextTaskInfo.needLevel});
            }
            else
            {
                txt_extraInfo.text = CLang.Get("impression_zwky");
            }
        }
        else// 当前无任务
        {
            var taskArr:Array = CImpressionUtil.getTaskInfo(m_pData.roleId);
            var hasNextTask:Boolean;
            var needLevel:int;

            for each(var info:Object in taskArr)
            {
                var tTask:Task = info.taskInfo;
                needLevel = info.needLevel;

                if(tTask)
                {
                    if(heroImpressionLevel < needLevel)
                    {
                        txt_taskTitle.text = CLang.Get("impression_smjl");
                        txt_content.text = CLang.Get("impression_wcsm");
                        m_pViewUI.list_taskReward.visible = tTask.reward;
                        _updateTaskReward(tTask);

                        txt_extraInfo.isHtml = true;
                        txt_extraInfo.text = CLang.Get("impression_xyc",{v1:needLevel});
                        hasNextTask = true;
                        break;
                    }
                }
            }

            txt_noTask.visible = !hasNextTask;
        }
    }

    /**
     * 执行任务
     */
    private function executeTask():void
    {
        var pCTaskData : CTaskData = new CTaskData();
        var data:Object = CTaskData.createObjectData(m_pCurrTask.ID,m_pCurrTask.type,CTaskStateType.CAN_DO,m_pCurrTask.condition,m_pCurrTask.conditionParm);
        pCTaskData.updateDataByData(data);
        pCTaskData.task = m_pCurrTask;
        if( pCTaskData )
        {
            if( pCTaskData.state == CTaskStateType.CAN_DO )
            {
                var bundleCtx : ISystemBundleContext = m_pSystem.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
                var bundle : ISystemBundle = bundleCtx.getSystemBundle( SYSTEM_ID( CTaskJumpConst.getJumpPare( pCTaskData.task.condition ) ) );
                bundleCtx.setUserData( bundle, CBundleSystem.ACTIVATED, true );

                (m_pSystem.getHandler(CImpressionDisplayViewHandler) as CImpressionDisplayViewHandler).removeDisplay();
                bundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.IMPRESSION));
                bundleCtx.setUserData( bundle, CBundleSystem.ACTIVATED, false );
            }
        }
    }

    /**
     * 提升成功称号奖励信息
     */
    private function updateAdvanceInfo():void
    {
        if(m_iUpdateType == EImpressionUpdateType.Type_Select)
        {
            m_iOldLevel = heroImpressionLevel;
            _helper.addAttr = _additionAttr;
        }
        else if(m_iUpdateType == EImpressionUpdateType.Type_Data)
        {
            var sex:int = _heroData.playerBasic != null ? _heroData.playerBasic.gender : 0;
            var oldInfo:ImpressionTitle = CImpressionUtil.getTitleInfoByLevelAndSex(m_iOldLevel,sex);
            var newInfo:ImpressionTitle = CImpressionUtil.getTitleInfoByLevelAndSex(heroImpressionLevel,sex);
            if(oldInfo != newInfo)
            {
                var succView:CImpressionUpSuccViewHandler = m_pSystem.getBean(CImpressionUpSuccViewHandler)
                        as CImpressionUpSuccViewHandler;
                if(succView)
                {
                    succView.data = newInfo;
                    succView.roleId = m_pData.roleId;
                    succView.addDisplay();
                }
            }

            if(m_iOldLevel != heroImpressionLevel)// 提升成功
            {
                _showTipInfo(CLang.Get("impression_upgradeSucc"),CMsgAlertHandler.NORMAL);
                m_iOldLevel = heroImpressionLevel;

                _propChangeTip();
                _helper.addAttr = _additionAttr;

                m_pViewUI.clip_progress.visible = true;
                m_pViewUI.clip_progress.playFromTo(null, null, new Handler(_onAnimationComplHandler));
                function _onAnimationComplHandler():void
                {
                    m_pViewUI.clip_progress.visible = false;
                    m_pViewUI.clip_progress.gotoAndStop( 1 );
                }
            }
        }
    }

    private function _propChangeTip():void
    {
        if(_helper.addAttr && _helper.addAttr.length)
        {
            for each(var attrData:CAttributeBaseData in _helper.addAttr)
            {
//                _showTipInfo(attrData.getAttrNameCN() + " + " + attrData.attrBaseValue, CMsgAlertHandler.NORMAL);
                (m_pSystem.stage.getSystem(IUICanvas) as CUISystem).showPropMsgAlert(attrData.getAttrNameCN(), attrData.attrBaseValue, CMsgAlertHandler.NORMAL);
            }
        }
    }

    private function _renderAttrList(item:Component, index:int):void
    {
        var cell:ImpressionAttrUI = item as ImpressionAttrUI;
        if(cell == null)
        {
            return;
        }

        cell.mouseEnabled = false;
        cell.mouseChildren = false;
        var data:CImpressionAttrData = cell.dataSource as CImpressionAttrData;
        if(null != data)
        {
            if(data.attrNameEN)
            {
                cell.txt_attrName.text = data.attrNameCN;
                cell.txt_attrValue.text = data.currTotalValue + "";
                var diff:int = data.nextTotalValue - data.currTotalValue;
                if(diff > 0)
                {
                    cell.txt_nextValue.text = data.nextTotalValue + "(+" + diff + ")";
                }
                else
                {
                    cell.txt_nextValue.text = data.nextTotalValue.toString();
                }
            }
            else
            {
                cell.txt_attrName.text = "战斗力";
                cell.txt_attrValue.text = data.currCombat.toString();
                diff = data.nextCombat - data.currCombat;
                if(diff > 0)
                {
                    cell.txt_nextValue.text = data.nextCombat + "(+" + diff + ")";
                }
                else
                {
                    cell.txt_nextValue.text = data.nextCombat.toString();
                }
            }
        }
        else
        {
            cell.txt_attrName.text = "";
            cell.txt_attrValue.text = "";
            cell.txt_nextValue.text = "";
        }
    }

    private function _renderItemList(item:Component, index:int):void
    {
        var cell:ImpressionFoodItemUI = item as ImpressionFoodItemUI;
        if(cell == null)
        {
            return;
        }

        cell.mouseEnabled = true;
        cell.mouseChildren = true;
        cell.img_mask.visible = false;
        var itemData:CFoodData = cell.dataSource as CFoodData;
        if(null != itemData)
        {
//            cell.txt_foodName.isHtml = true;
//            cell.txt_foodName.text = itemData.nameWithColor;
            cell.item_food.img.url = itemData.iconBig;
            cell.item_food.clip_bg.index = itemData.quality;

            if(itemData.num > 0)
            {
                cell.item_food.txt_num.text = itemData.num+"";

//                cell.item_food.disabled = !m_pData.isGet;
                cell.img_mask.visible = !m_pData.isGet;
                cell.btn_use.disabled = false;
            }
            else
            {
                cell.item_food.txt_num.text = "";
//                cell.item_food.disabled = true;
                cell.img_mask.visible = true;
                cell.btn_use.disabled = true;
            }

            cell.item_food.mouseEnabled = true;

            cell.item_food.dataSource = itemData;
            cell.item_food.box_effect.visible = itemData.effect;
            cell.item_food.clip_effect.autoPlay = itemData.effect;
        }
        else
        {
            cell.item_food.txt_num.text = "";
            cell.item_food.img.url = "";
            cell.item_food.box_effect.visible = false;
            cell.item_food.clip_effect.autoPlay = false;
        }

        cell.btn_use.visible = _heroData != null;

        cell.item_food.toolTip = new Handler( _showTips, [cell.item_food] );
    }

    /**
     * 物品tips
     * @param item
     */
    private function _showTips(item:ItemUIUI):void
    {
        (m_pSystem.stage.getSystem(CItemSystem) as CItemSystem).addTips(CItemTipsView,item);
    }

    private function _onClickHandler(e:MouseEvent):void
    {
        if( e.target == m_pViewUI.btn_oneKey)// 一键提升
        {
            if(CImpressionState.isInLevelUpgrade)
            {
                _showTipInfo(CLang.Get("clientLockTips"),CMsgAlertHandler.WARNING);
                return;
            }

            var arr:Array = m_pViewUI.list_foodItem.dataSource as Array;
            if(!CImpressionUtil.isPropEnough(arr))
            {
                _showTipInfo(CLang.Get("impression_prop_not_enough"),CMsgAlertHandler.WARNING);
                return;
            }

            if(CImpressionUtil.isFullLevel(_heroData))
            {
                _showTipInfo(CLang.Get("impression_fullLevel"),CMsgAlertHandler.WARNING);
                return;
            }

            var data:Object = {};
            data["roleId"] = m_pData.roleId;
            data["itemId"] = 0;
            m_pSystem.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT,EImpressionViewEventType.ImpressionUpgrade,data));
        }

        if( e.target == m_pViewUI.btn_goto)// 前往任务
        {
            executeTask();
        }

        if( e.target == m_pViewUI.btn_takeReward)// 领取任务奖励
        {
            (m_pSystem.getBean(CImpressionNetHandler) as CImpressionNetHandler).impressionTaskRewardRequest(m_pData.roleId);
        }

        if( e.target == m_pViewUI.btn_recall)// 任务召回
        {
            (m_pSystem.getBean(CImpressionNetHandler) as CImpressionNetHandler).impressionTaskRecallRequest(m_pData.roleId);
        }
    }

    private function _listMouseHandler(e:Event, index:int):void
    {
//        if( e.target is Button || e.target is ImpressionFoodItemUI)
//        {
            switch ( e.type)
            {
                case MouseEvent.CLICK:
                    if(CImpressionState.isInLevelUpgrade)
                    {
                        _showTipInfo(CLang.Get("clientLockTips"),CMsgAlertHandler.WARNING);
                        return;
                    }

                    var data:Object = {};
                    data["roleId"] = m_pData.roleId;
                    var cell:ImpressionFoodItemUI = m_pViewUI.list_foodItem.getCell(index) as ImpressionFoodItemUI;
                    var itemData:CFoodData = cell.dataSource as CFoodData;
                    data["itemId"] = itemData.ID;

                    if(!m_pData.isGet)
                    {
                        _showTipInfo(CLang.Get("impression_hero_notGet"),CMsgAlertHandler.WARNING);
                        return;
                    }

                    if(!CImpressionUtil.isPropEnough([itemData]))
                    {
                        _showTipInfo(CLang.Get("impression_prop_not_enough"),CMsgAlertHandler.WARNING);
                        return;
                    }

                    if(CImpressionUtil.isFullLevel(_heroData))
                    {
                        _showTipInfo(CLang.Get("impression_fullLevel"),CMsgAlertHandler.WARNING);
                        return;
                    }

                    m_pSystem.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT,EImpressionViewEventType.ImpressionUpgrade,data));

                    _playUseItemEffect(index);
                    break;
            }
//        }
    }

    private function _playUseItemEffect(index:int):void
    {
        m_pViewUI.frameClip_item.visible = true;
        m_pViewUI.frameClip_item.x = 39 + 120 * index;
        m_pViewUI.frameClip_item.playFromTo(null, null, new Handler(_onAnimationComplHandler));
        function _onAnimationComplHandler():void
        {
            m_pViewUI.frameClip_item.visible = false;
            m_pViewUI.frameClip_item.gotoAndStop(1);
        }
    }

    /**
     * 亲密度提升后更新
     * @param e
     */
    private function _onPlayerUpdateHandler(e:CPlayerEvent):void
    {
        m_iUpdateType = EImpressionUpdateType.Type_Data;
        updateDisplay();
    }

    /**
     * 飘字提示
     * @param str
     * @param type
     */
    private function _showTipInfo(str:String, type:int):void
    {
        (m_pSystem.stage.getSystem( IUICanvas ) as IUICanvas).showMsgAlert( str, type );
    }

    /**
     * 背包物品更新
     * @param e
     */
    private function _onBagItemsChangeHandler(e:CBagEvent):void
    {
        updateFoodItemInfo();
    }

    private function _onTimerEventHandler(e:TimerEvent):void
    {
        var heroData : CPlayerHeroData = CImpressionUtil.getHeroDataById( m_pData.roleId );
        if ( heroData && heroData.impressionTask )
        {
            var taskData : CImpressionTaskData = new CImpressionTaskData( heroData.impressionTask );
            if ( taskData.id )// 当前任务
            {
                var currTime:Number = CTime.getCurrServerTimestamp();
                var expiredTime:Number = taskData.time;
                if(currTime < expiredTime)
                {
                    _updateLeftTime(expiredTime - currTime);
                }
                else
                {
                    m_pTimer.stop();
                    m_pTimer.reset();
                    setTimeout(_onTimeCompl,50);
                }
            }
        }
    }

    private function _onTimeCompl():void
    {
        updateTaskInfo();
    }

    private function _updateLeftTime(leftTime:Number):void
    {
        var timeStr:String = CTime.toDurTimeString(leftTime);
        if(!m_pViewUI.txt_timeLimit.visible)
        {
            m_pViewUI.txt_timeLimit.visible = true;
        }
        m_pViewUI.txt_timeLimit.text = "任务倒计时："+timeStr;
    }

    private function _onBtnClickHandler(e:MouseEvent):void
    {
        if(CImpressionUtil.isFullLevel(_heroData))
        {
            return;
        }

//        var nextList:List = m_pViewUI.box_nextInfo.getChildByName("list_next") as List;
//        var nextListBg:Image = m_pViewUI.box_nextInfo.getChildByName("img_listBg") as Image;
//        nextList.visible = !nextList.visible;
//        nextListBg.visible = !nextListBg.visible;
    }

    private function _onGetHeroHandler(e:MouseEvent):void
    {
        var pSystemBundleCtx : ISystemBundleContext = m_pSystem.stage.getSystem( ISystemBundleContext ) as
                ISystemBundleContext;

        if ( pSystemBundleCtx )
        {
            var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( "ROLE" ) );
            var vCurrent : Boolean = pSystemBundleCtx.getUserData( pSystemBundle, "activated", false );
            pSystemBundleCtx.setUserData( pSystemBundle, "activated", !vCurrent );
        }
    }

    private function _onRollOverHandler(e:MouseEvent):void
    {
        _updateTitleTips();

//        if(e.target == m_pViewUI.img_notGet)
//        {
//            m_pViewUI.img_notGet.toolTip = "好感度等级1级，可激活新好感度称号并获得奖励。";
//        }
//        else if( e.target == m_pViewUI.img_title)
//        {
//            var heroData:CPlayerHeroData = _heroData;
//            if(heroData)
//            {
//                var sex:int = heroData.playerBasic != null ? heroData.playerBasic.gender : 0;
//                var tTitleInfo:ImpressionTitle = CImpressionUtil.getTitleInfoByLevelAndSex(heroImpressionLevel,sex);
//                if(tTitleInfo)
//                {
//                    var nextLevel:int = tTitleInfo.level + 30;
//                    if(nextLevel > CImpressionUtil.getTitleMaxLevel())
//                    {
//                        m_pViewUI.img_title.toolTip = null;
//                    }
//                    else
//                    {
//                        m_pViewUI.img_title.toolTip = "好感度等级" + nextLevel + "级，可激活新好感度称号并获得奖励。";
//                    }
//                }
//                else
//                {
//                    m_pViewUI.img_title.toolTip = null;
//                }
//            }
//        }
    }

    private function _updateTitleTips():void
    {
        m_pViewUI.img_notGet.toolTip = "好感度等级1级，可激活新好感度称号并获得奖励。";

        var heroData:CPlayerHeroData = _heroData;
        if(heroData)
        {
            var sex:int = heroData.playerBasic != null ? heroData.playerBasic.gender : 0;
            var tTitleInfo:ImpressionTitle = CImpressionUtil.getTitleInfoByLevelAndSex(heroImpressionLevel,sex);
            if(tTitleInfo)
            {
                var nextLevel:int = tTitleInfo.level + 30;
                if(nextLevel > CImpressionUtil.getTitleMaxLevel())
                {
                    m_pViewUI.img_title.toolTip = null;
                }
                else
                {
                    m_pViewUI.img_title.toolTip = "好感度等级" + nextLevel + "级，可激活新好感度称号并获得奖励。";
                }
            }
            else
            {
                m_pViewUI.img_title.toolTip = null;
            }
        }
    }

    private function _onRollOutHandler(e:MouseEvent):void
    {
    }

    public function show():void
    {
        _addListeners();
    }

    public function hide():void
    {
        _removeListeners();

        if(m_pTimer)
        {
            m_pTimer.stop();
            m_pTimer.reset();
        }

        _helper.addAttr = null;

        if(m_pTimeline)
        {
            m_pTimeline._kill();
            m_pTimeline.clear();
            m_pTimeline = null;
        }

        if(m_pTransformSpr)
        {
            m_pTransformSpr.dispose();
            m_pTransformSpr = null;
        }
    }

    public function clear():void
    {
        if(m_pTimer)
        {
            m_pTimer.stop();
            m_pTimer.reset();
        }

//        m_pViewUI.img_heroName.url = "";
        m_pViewUI.img_notGet.visible = false;
        m_pViewUI.img_title.visible = false;
//        m_pViewUI.box_currAttrInfo.visible = false;
//        m_pViewUI.box_nextInfo.visible = false;
//        m_pViewUI.box_introduce.visible = false;
        m_pViewUI.list_attr.dataSource = [];
        m_pViewUI.txt_level.text = "";
//        m_pViewUI.progress_impression.value = 0;
        m_pViewUI.list_foodItem.dataSource = [];
//        m_pViewUI.textArea_desc.text = "";
        m_pViewUI.btn_goto.visible = false;
        m_pViewUI.btn_takeReward.visible = false;
        m_pViewUI.img_dian.visible = false;
        m_pViewUI.btn_recall.visible = false;

        var txt_taskTitle:Label = m_pViewUI.box_task.getChildByName("txt_taskTitle") as Label;
        txt_taskTitle.text = "";
        var txt_extraInfo:Label = m_pViewUI.box_task.getChildByName("txt_extraInfo") as Label;
        txt_extraInfo.text = "";
        var txt_content:Label = m_pViewUI.box_task.getChildByName("txt_content") as Label;
        txt_content.text = "";
        var txt_timeLimit:Label = m_pViewUI.box_task.getChildByName("txt_timeLimit") as Label;
        txt_timeLimit.text = "限时完成倒计时：";
        txt_timeLimit.visible = false;
        var txt_costDiamond:Label = m_pViewUI.box_task.getChildByName("txt_costDiamond") as Label;
        txt_costDiamond.text = "";
        var txt_noTask:Label = m_pViewUI.box_task.getChildByName("txt_noTask") as Label;
        txt_noTask.visible = false;
        var img_currency:Image = m_pViewUI.box_task.getChildByName("img_currency") as Image;
        img_currency.url = "";
        var list_taskReward:List = m_pViewUI.box_task.getChildByName("list_taskReward") as List;
        list_taskReward.dataSource = [];

        m_pCurrTask = null;
    }

    public function get isViewShow():Boolean
    {
        if(m_pViewUI && m_pViewUI.parent)
        {
            return true;
        }

        return false;
    }

    public function set viewUI(value:Component):void
    {
        m_pViewUI = value as ImpressionUpgradeUI;
    }

    /**
     * 选中格斗家的亲密度等级
     */
    public function get heroImpressionLevel():int
    {
        if(m_pData && _heroData)
        {
            return _heroData.impressionLevel;
        }

        return 0;
    }

    /**
     * 选中格斗家的亲密度进度
     */
    public function get heroImpressionExp():int
    {
        if(m_pData && _heroData)
        {
            return _heroData.impressionExp;
        }

        return 0;
    }

    private function get _heroData():CPlayerHeroData
    {
        if(m_pData)
        {
            var manager:CPlayerManager = m_pSystem.stage.getSystem(CPlayerSystem ).getBean(CPlayerManager) as CPlayerManager;
            var playerData:CPlayerData = manager.playerData;
            var heroData:CPlayerHeroData = playerData.heroList.getHero(m_pData.roleId) as CPlayerHeroData;

            return heroData;
        }

        return null;
    }

    public function set system(value:CAppSystem):void
    {
        m_pSystem = value;
    }

    public function get _helper():CImpressionHelpHandler
    {
        return m_pSystem.getHandler(CImpressionHelpHandler) as CImpressionHelpHandler;
    }

    public function dispose() : void
    {
    }
}
}
