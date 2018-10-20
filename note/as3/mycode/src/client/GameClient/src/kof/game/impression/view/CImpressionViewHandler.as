//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/5/20.
 */
package kof.game.impression.view {

import QFLib.Utils.HtmlUtil;

import com.greensock.TweenMax;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.ColorTransform;
import flash.utils.Timer;
import flash.utils.setTimeout;

import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bag.CBagEvent;
import kof.game.bag.CBagSystem;

import kof.game.character.property.CBasePropertyData;
import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.CUIFactory;
import kof.game.common.view.CTweenViewHandler;
import kof.game.impression.CImpressionManager;
import kof.game.impression.data.CImpressionAttrData;
import kof.game.impression.data.CImpressionTotalLevelData;
import kof.game.impression.data.CImpressionTotalLevelData;
import kof.game.impression.data.CPlayerInfoData;
import kof.game.impression.util.CImpressionRenderUtil;
import kof.game.impression.util.CImpressionUtil;
import kof.game.impression.util.EImpressionAttrType;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.event.CPlayerEvent;
import kof.game.playerCard.util.CTransformSpr;
import kof.table.Impression;
import kof.ui.CMsgAlertHandler;
import kof.ui.IUICanvas;
import kof.ui.demo.BubblesDialogueUI;
import kof.ui.master.impression.ImpressionLevelAttrRenderUI;
import kof.ui.master.impression.ImpressionRoleHeadUI;
import kof.ui.master.impression.ImpressionUI;

import morn.core.components.Component;
import morn.core.components.Dialog;

import morn.core.components.Image;
import morn.core.components.List;

import morn.core.handlers.Handler;

/**
 * 亲密度主界面
 */
public class CImpressionViewHandler extends CTweenViewHandler
{

    private var m_pViewUI : ImpressionUI;
    private var m_pCloseHandler : Handler;
    private var m_bViewInitialized : Boolean;

    private var m_attrLabelArr:Array;// 收集总加成属性label
    private var m_currList:List;// 当前选择的list

    private var m_iLastSelIndex:int = -1;
    private var m_pLastSelList:List;
    private var m_pBubbleViewUI:BubblesDialogueUI;
    private var m_pTransformSpr:CTransformSpr;
    private var m_pTimer:Timer;
    private var m_bIsLastSelNotOpen:Boolean;
    private var m_nListMeasureWidth:Number = 0;

    private var m_pTotalLevelData:CImpressionTotalLevelData;

    public function CImpressionViewHandler()
    {
        super(false);
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && onInitialize();
        if ( loadViewByDefault ) {
            ret = ret && loadAssetsByView( viewClass );
            ret = ret && onInitializeView();
        }

        return ret;
    }

    override public function get viewClass() : Array
    {
        return [ ImpressionUI ];
    }

    override protected function get additionalAssets():Array
    {
        return ["frameclip_xz.swf", "frameclip_item2.swf", "frameclip_impression1.swf"];
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
                m_pViewUI = new ImpressionUI();

                m_pViewUI.closeHandler = new Handler( _onClose );
                m_pViewUI.list_role.renderHandler = new Handler(_outlistRenderHandler);
                m_pViewUI.list_role.doubleClickEnabled = true;
                m_pViewUI.list_role.dataSource = [];
//                (m_pViewUI.star.getChildAt(0) as List).renderHandler = new Handler(CImpressionRenderUtil.renderStar);

                m_pViewUI.list_heroAttr.renderHandler = new Handler(_heroAttrRenderHandler);

                m_attrLabelArr = [];
//                m_attrLabelArr[0] = m_pViewUI.txt_life;
//                m_attrLabelArr[1] = m_pViewUI.txt_attack;
//                m_attrLabelArr[2] = m_pViewUI.txt_defense;

                m_pBubbleViewUI = new BubblesDialogueUI();

                CSystemRuleUtil.setRuleTips(m_pViewUI.img_tip, CLang.Get("impression_rule"));

                m_pViewUI.img_role.mask = m_pViewUI.img_mask_hero;

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
        setTweenData(KOFSysTags.IMPRESSION);
        showDialog(m_pViewUI, false, _onShowEnd);
    }

    private function _onShowEnd():void
    {
        _initView();
        _addListeners();

        var displayView:CImpressionDisplayViewHandler = system.getHandler(CImpressionDisplayViewHandler) as CImpressionDisplayViewHandler;
        if(displayView.isViewShow)
        {
            displayView.addDisplay();
        }

        var succView:CImpressionUpSuccViewHandler = system.getHandler(CImpressionUpSuccViewHandler) as CImpressionUpSuccViewHandler;
        if(succView.isViewShow)
        {
            succView.addDisplay();
        }
    }

    public function removeDisplay() : void
    {
        closeDialog(_removeDisplayB);

    }
    private function _removeDisplayB() : void
    {
        if(m_bViewInitialized)
        {
            _removeListeners();

            if(m_pTimer)
            {
                m_pTimer.stop();
                m_pTimer = null;
            }

            if(TweenMax.isTweening(m_pViewUI.img_role))
            {
                TweenMax.killTweensOf(m_pViewUI.img_role);
            }

            if(m_pTransformSpr && TweenMax.isTweening(m_pTransformSpr))
            {
                TweenMax.killTweensOf(m_pTransformSpr);
            }

            m_iLastSelIndex = -1;

            unschedule(_hideRandomBubbleTalk);

            if((system.getHandler(CImpressionDisplayViewHandler) as CImpressionDisplayViewHandler).isViewShow)
            {
                (system.getHandler(CImpressionDisplayViewHandler) as CImpressionDisplayViewHandler).removeDisplay();
            }

            if(m_pTransformSpr)
            {
                m_pTransformSpr.dispose();
                m_pTransformSpr = null;
            }

            if(m_pViewUI.clip_opening.isPlaying)
            {
                m_pViewUI.clip_opening.stop();
            }

            m_bIsLastSelNotOpen = false;
            m_pTotalLevelData = null;
            m_nListMeasureWidth = 0;

            clear();
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

    private function _initView():void
    {
        m_pViewUI.list_role.visible = false;
        m_pViewUI.clip_select.visible = false;
        m_pViewUI.list_heroAttr.visible = false;
        m_pViewUI.box_upgradeTip.visible = false;

        _showOpenEffect();
        _updateRoleListInfo();
//        _updateTotalAddition();
        _updateTotalLevelAddition();

        delayCall(0.1, _defaultSelFirstOpen);

        _updatePageBtnState();

        m_pViewUI.addChild(m_pBubbleViewUI);
        m_pBubbleViewUI.visible = false;
    }

    private function _addListeners():void
    {
        m_pViewUI.btn_left.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_right.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);

        m_pViewUI.btn_communicate.addEventListener(MouseEvent.CLICK, _onBtnClickHandler);

        if(system.stage.getSystem(CBagSystem))
        {
            (system.stage.getSystem(CBagSystem) as CBagSystem).listenEvent(_onBagItemsChangeHandler);
        }

        system.stage.getSystem(CPlayerSystem ).addEventListener(CPlayerEvent.HERO_DATA,_onHeroDataUpdateHandler);
    }

    private function _removeListeners():void
    {
        m_pViewUI.btn_left.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);
        m_pViewUI.btn_right.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);

        m_pViewUI.btn_communicate.removeEventListener(MouseEvent.CLICK, _onBtnClickHandler);

        if(system.stage.getSystem(CBagSystem))
        {
            (system.stage.getSystem(CBagSystem) as CBagSystem).unListenEvent(_onBagItemsChangeHandler);
        }

        system.stage.getSystem(CPlayerSystem ).removeEventListener(CPlayerEvent.HERO_DATA,_onHeroDataUpdateHandler);

        if(m_pTimer)
        {
            m_pTimer.removeEventListener(TimerEvent.TIMER, _onTimerHandler);
        }
    }

    public function update():void
    {
        invalidate();
    }

    override protected function updateDisplay():void
    {
        super.updateDisplay();
    }

    /**
     * 开场特效
     */
    private function _showOpenEffect():void
    {
        m_pViewUI.clip_opening.visible = true;
        m_pViewUI.clip_opening.playFromTo(null, null, new Handler(_onAnimationComplHandler));
        function _onAnimationComplHandler():void
        {
            m_pViewUI.clip_opening.visible = false;
            m_pViewUI.clip_opening.gotoAndStop(1);

            m_pViewUI.list_role.visible = true;
            m_pViewUI.clip_select.visible = true;

            delayCall(0.2,_showRandomBubbleTalk);
        }
    }

    /**
     * 更新格斗家列表信息
     */
    private function _updateRoleListInfo():void
    {
        var manager:CImpressionManager = this.system.getBean(CImpressionManager) as CImpressionManager;
        if(manager)
        {
            var heroListDataArr:Array = manager.getHeroListData();
            m_pViewUI.list_role.totalPage = Math.ceil(heroListDataArr.length/3);
            m_pViewUI.list_role.dataSource = heroListDataArr;
            m_pViewUI.list_role.page = 0;

            _listItemLayout();
        }
    }

    /**
     * 设置每个item的位置
     */
    private function _listItemLayout():void
    {
        var list1:List = m_pViewUI.list_role.getCell(0) as List;
        var list2:List = m_pViewUI.list_role.getCell(1) as List;
        var list3:List = m_pViewUI.list_role.getCell(2) as List;

        list1.x = 0;
        list2.x = 217;
        list3.x = 434;

        for(var i:int = 0; i < 12; i++)
        {
            var cell:Component = list1.getCell(i);
            if(cell)
            {
                cell.x = CImpressionUtil.PosArr[i].x;
                cell.y = CImpressionUtil.PosArr[i].y;
            }

            cell = list2.getCell(i);
            if(cell)
            {
                cell.x = CImpressionUtil.PosArr[i+12].x;
                cell.y = CImpressionUtil.PosArr[i+12].y;
            }

            cell = list3.getCell(i);
            if(cell)
            {
                cell.x = CImpressionUtil.PosArr[i+12*2].x;
                cell.y = CImpressionUtil.PosArr[i+12*2].y;
            }
        }
    }

    /**
     * 收集总加成信息
     */
    private function _updateTotalAddition():void
    {
        var manager:CImpressionManager = system.getBean(CImpressionManager);
        var attrData:CBasePropertyData = manager.getTotalCollectAttr();
        if(attrData)
        {
            for(var i:int = 0; i < CImpressionUtil.Attrs.length; i++)
            {
                var attrName:String = CImpressionUtil.Attrs[i];
                if(attrData.hasOwnProperty(attrName))
                {
                    var attrValue:Number = attrData[attrName] * 0.01;
                    var numberStr:String = attrValue % 1 == 0 ? attrValue.toString() : attrValue.toFixed(2);
                    m_attrLabelArr[i ].text = numberStr + "%";
                }
            }
        }
    }

    /**
     * 总等级属性加成
     */
    private function _updateTotalLevelAddition():void
    {
        var totalLevelData:CImpressionTotalLevelData = CImpressionUtil.getImpressionTotalLevelData();
        if(totalLevelData)
        {
            var percent:int = totalLevelData.totalAddition * 0.01;
            m_pViewUI.txt_totalAddition.text = percent.toFixed(2) + "%";

            m_pViewUI.txt_totalLevelInfo.isHtml = true;
            m_pViewUI.txt_totalLevelInfo.text = HtmlUtil.color("当前好感度总等级：", "#ffffff");
            m_pViewUI.txt_totalLevelInfo.text += HtmlUtil.color(totalLevelData.currTotalLevel + "", "#8bf3ff");
            if(totalLevelData.nextTargetLevel)
            {
                m_pViewUI.txt_totalLevelInfo.text += HtmlUtil.color("（下一段激活所需等级为", "#ffffff");
                m_pViewUI.txt_totalLevelInfo.text += HtmlUtil.color(totalLevelData.nextTargetLevel + "", "#f3e4a1");
                m_pViewUI.txt_totalLevelInfo.text += HtmlUtil.color("）", "#ffffff");
            }
        }
        else
        {
            m_pViewUI.txt_totalLevelInfo.isHtml = true;
            m_pViewUI.txt_totalLevelInfo.text += HtmlUtil.color("当前好感度总等级：0", "#ffffff");
        }
    }

    /**
     * 重新计算总等级属性
     */
    private function _recalcuTotalLevelData():void
    {
        m_pTotalLevelData = CImpressionUtil.getImpressionTotalLevelData();
    }

    /**
     * 格斗家形象展示
     */
    private function _updateHeroImg():void
    {
        var isTweening:Boolean;
        if(TweenMax.isTweening(m_pViewUI.img_role))
        {
            TweenMax.killTweensOf(m_pViewUI.img_role);
            isTweening = true;
        }

        if(m_pTransformSpr && TweenMax.isTweening(m_pTransformSpr))
        {
            TweenMax.killTweensOf(m_pTransformSpr);
            isTweening = true;
        }

        if(_heroImg.url && !isTweening)
        {
            TweenMax.fromTo(m_pViewUI.img_role, 0.25, {alpha:1}, {alpha:0, onComplete:_onBeforeComplHandler});

            if(m_pTransformSpr)
            {
                TweenMax.fromTo(m_pTransformSpr, 0.25, {alpha:1, scale:1}, {alpha:0});
            }
        }
        else
        {
            _onBeforeComplHandler();
        }
    }

    private function _onBeforeComplHandler():void
    {
        if(selData)
        {
            if(selData.isGet && selData.isOpen)
            {
                _heroImg.url = "icon/role/peakgame/role_"+selData.roleId+".png";
            }
            else
            {
                _heroImg.url = "icon/role/peakgame2/role_"+selData.roleId+".png";
            }

            m_pViewUI.img_role_white.url = _heroImg.url;
            m_pViewUI.img_role_white.x = 0;
            m_pViewUI.img_role_white.y = 0;

            if(m_pTransformSpr == null)
            {
                m_pTransformSpr = CUIFactory.getDisplayObj(CTransformSpr) as CTransformSpr;
            }

            m_pTransformSpr.objWidth = 252;
            m_pTransformSpr.objHeight = 523;
            m_pTransformSpr.transformObj = m_pViewUI.img_role_white;
            m_pViewUI.box_role.addChild(m_pTransformSpr);
            m_pTransformSpr.alpha = 0;

            var colorTransform:ColorTransform = new ColorTransform();
            colorTransform.color = 0xFFFFFF;
            m_pViewUI.img_role_white.transform.colorTransform = colorTransform;
        }
        else
        {
            m_pViewUI.img_role.url = "";
            m_pViewUI.img_role_white.url = "";
        }

        TweenMax.fromTo(m_pViewUI.img_role, 0.3, {x:-252, alpha:0}, {x:0, alpha:1, onComplete:onCompleteHander});

        function onCompleteHander():void
        {
            if(m_pTransformSpr)
            {
                TweenMax.fromTo(m_pTransformSpr, 0.4, {alpha:1, scale:1}, {alpha:0, scale:1.1});
            }
        }
    }

    /**
     * 格斗家介绍及星级属性加成信息
     */
    private function _updateHeroDetailInfo():void
    {
        if(selData)
        {
            // 名字
            m_pViewUI.heroName.url = CPlayerPath.getUIHeroNamePath(selData.roleId);

            // 星级
            var pHeroData:CPlayerHeroData = CImpressionUtil.getHeroDataById(selData.roleId);
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
//            var pStarList:List = m_pViewUI.star.getChildAt(0) as List;
//            pStarList.dataSource = pDataArr;

            // 描述
            var impressionInfo:Impression = CImpressionUtil.getImpressionConfig(selData.roleId);
            if(impressionInfo && impressionInfo.description)
            {
                m_sContent = impressionInfo.description;
                m_iStrIndex = 0;
                m_pViewUI.desc.text = "";

                _updateDesc();
            }
            else
            {
                m_pViewUI.desc.text = "";
            }

            //属性
            var manager:CImpressionManager = system.getBean(CImpressionManager ) as CImpressionManager;
            var attrInfo:Object = manager.getAttrInfo(selData.roleId);

            if(attrInfo)
            {
                var attrNameEN:String;
                var attrNameCN:String;

                if(selData.isGet)
                {
                    // 当前星级
//                    m_pViewUI.txt_currAddLabel.visible = true;
//                    m_pViewUI.txt_currAddLabel.text = CLang.Get("impression_dqxj");
//                    m_pViewUI.currAddition.visible = true;
                    var currAttr:CBasePropertyData = attrInfo[EImpressionAttrType.Type_CurrStar + ""];
                    attrNameEN = _getAttrNameEN(currAttr);
                    attrNameCN = currAttr.getAttrNameCN(attrNameEN);
                    if(attrNameEN != "")
                    {
                        var attrValue:Number = currAttr[attrNameEN] * 0.01;
                        var numberStr:String = attrValue % 1 == 0 ? attrValue.toString() : attrValue.toFixed(1);
//                        m_pViewUI.currAddition.text = attrNameCN+" +" + numberStr + "%";
                    }

                    var heroData:CPlayerHeroData = CImpressionUtil.getHeroDataById(selData.roleId);
                    if(heroData.star == 7)// 满星
                    {
//                        m_pViewUI.txt_nextAddLabel.visible = false;
//                        m_pViewUI.fullAddition.visible = false;
                    }
                    else
                    {
                        var nextAttr:CBasePropertyData = attrInfo[EImpressionAttrType.Type_NextStar + ""];
                        attrNameEN = _getAttrNameEN(nextAttr);
                        attrNameCN = nextAttr.getAttrNameCN(attrNameEN);
                        if(attrNameEN != "")
                        {
//                            m_pViewUI.txt_nextAddLabel.visible = true;
//                            m_pViewUI.fullAddition.visible = true;
//                            m_pViewUI.txt_nextAddLabel.text = CLang.Get("impression_xyxj");
                            attrValue = nextAttr[attrNameEN] * 0.01;
                            numberStr = attrValue % 1 == 0 ? attrValue.toString() : attrValue.toFixed(1);
//                            m_pViewUI.fullAddition.text = attrNameCN+" +" + numberStr + "%";
                        }
                    }
                }
                else
                {
                    // 收集加成
                    var collectAttr:CBasePropertyData = attrInfo[EImpressionAttrType.Type_Collect + ""];
                    attrNameEN = _getAttrNameEN(collectAttr);
                    attrNameCN = collectAttr.getAttrNameCN(attrNameEN);
                    if(attrNameEN != "")
                    {
//                        m_pViewUI.txt_currAddLabel.visible = true;
//                        m_pViewUI.txt_currAddLabel.text = CLang.Get("impression_jssj");
                        attrValue = collectAttr[attrNameEN] * 0.01;
                        numberStr = attrValue % 1 == 0 ? attrValue.toString() : attrValue.toFixed(1);
//                        m_pViewUI.currAddition.text = attrNameCN+" +" + numberStr + "%";
                    }

                    // 满星级加成
//                    m_pViewUI.txt_nextAddLabel.visible = true;
//                    m_pViewUI.fullAddition.visible = true;
                    var fullAttr:CBasePropertyData = attrInfo[EImpressionAttrType.Type_FullStar+""];
                    attrNameEN = _getAttrNameEN(fullAttr);
                    attrNameCN = fullAttr.getAttrNameCN(attrNameEN);
                    if(attrNameEN != "")
                    {
//                        m_pViewUI.txt_nextAddLabel.text = CLang.Get("impression_mxjj");
                        attrValue = fullAttr[attrNameEN] * 0.01;
                        numberStr = attrValue % 1 == 0 ? attrValue.toString() : attrValue.toFixed(1);
//                        m_pViewUI.fullAddition.text = attrNameCN+" +" + numberStr + "%";
                    }
                }
            }
        }
    }

    private function _updateProgressInfo():void
    {
        if(selData == null)
        {
            return;
        }

        var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        var heroData:CPlayerHeroData = playerData.heroList.getHero(selData.roleId);

        if(heroData)
        {
            m_pViewUI.txt_level.text = "LV." + heroData.impressionLevel;
            var quality:int = heroData.playerBasic != null ? heroData.playerBasic.intelligence : 0;
            var maxExp:int = CImpressionUtil.getMaxExp(quality, heroData.impressionLevel);
            if(maxExp == 0)
            {
                m_pViewUI.progress_impression.value = 0;
                m_pViewUI.txt_progressInfo.text = "0/0";
            }
            else
            {
                if(TweenMax.isTweening(m_pViewUI.progress_impression))
                {
                    TweenMax.killTweensOf(m_pViewUI.progress_impression);
                }

                var progressValue:Number = heroData.impressionExp/maxExp;
                TweenMax.to(m_pViewUI.progress_impression, 0.3, {value:progressValue});

                m_pViewUI.txt_progressInfo.text = heroData.impressionExp + "/" + maxExp;
            }
        }
        else
        {
            m_pViewUI.progress_impression.value = 0;
            m_pViewUI.txt_progressInfo.text = "0/0";
        }
    }

    private function _updateHeroAttrInfo():void
    {
        if(selData)
        {
            var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
            var heroData:CPlayerHeroData = playerData.heroList.getHero(selData.roleId);
            if(heroData && heroData.impressionLevel > 0)
            {
                var arr:Array = CImpressionUtil.getAttrInfoWithCombat(heroData.prototypeID, heroData.impressionLevel);
                var resultArr:Array = [];
                for each(var attrData:CImpressionAttrData in arr)
                {
                    if(attrData.currTotalValue)
                    {
                        resultArr.push(attrData);
                    }
                }

                m_nListMeasureWidth = 0;
                m_pViewUI.list_heroAttr.dataSource = resultArr;
                m_pViewUI.list_heroAttr.visible = true;
                m_pViewUI.box_upgradeTip.visible = false;
            }
            else
            {
                m_pViewUI.box_upgradeTip.visible = true;
                m_pViewUI.list_heroAttr.visible = false;
            }
        }
    }

    private function _heroAttrRenderHandler(item:Component, index:int):void
    {
        var itemUI:ImpressionLevelAttrRenderUI = item as ImpressionLevelAttrRenderUI;
        var data:CImpressionAttrData = itemUI.dataSource as CImpressionAttrData;
        if(data)
        {
            itemUI.txt_attrName.text = data.attrNameCN + "：";

            if(m_pTotalLevelData == null)
            {
                m_pTotalLevelData = CImpressionUtil.getImpressionTotalLevelData();
            }

            var addPercent:Number = m_pTotalLevelData == null ? 0 : (m_pTotalLevelData.totalAddition*0.0001);
            var value:int = data.currTotalValue * (1 + addPercent);
            itemUI.txt_attrValue.text = "+" + value;
            itemUI.txt_extraAdd.isHtml = true;
            itemUI.txt_extraAdd.text = HtmlUtil.color("（等级加成", "#e4e4e4");
            itemUI.txt_extraAdd.text += HtmlUtil.color("+" + (value - data.currTotalValue), "#f8c712");
            itemUI.txt_extraAdd.text += HtmlUtil.color("）", "#e4e4e4");
            itemUI.txt_extraAdd.x = itemUI.txt_attrValue.x + itemUI.txt_attrValue.width;

            var width:Number = itemUI.txt_extraAdd.x + itemUI.txt_extraAdd.width;
            if(width > m_nListMeasureWidth)
            {
                m_nListMeasureWidth = width;
            }
        }
        else
        {
            itemUI.txt_attrName.text = "";
            itemUI.txt_attrValue.text = "";
            itemUI.txt_extraAdd.text = "";
        }

        var dataArr:Array = m_pViewUI.list_heroAttr.dataSource as Array;
        if(dataArr && index == dataArr.length - 1)
        {
            if((m_pViewUI.list_heroAttr.x + m_nListMeasureWidth) > m_pViewUI.width)
            {
                var diff:int = m_pViewUI.list_heroAttr.x + m_nListMeasureWidth - m_pViewUI.width;
                m_pViewUI.list_heroAttr.x -= diff;
            }
            else
            {
                if((691 + m_nListMeasureWidth) < m_pViewUI.width)
                {
                    m_pViewUI.list_heroAttr.x = 691;
                }
            }
        }
    }

    private function _updateLevelState():void
    {
        if(m_currList && m_currList.selection)
        {
            var heroItem:ImpressionRoleHeadUI = m_currList.selection as ImpressionRoleHeadUI;
            if(heroItem)
            {
                var data:CPlayerInfoData = heroItem.dataSource as CPlayerInfoData;
                if(data && selData && selData.roleId == data.roleId)
                {
                    heroItem.img_max.visible = CImpressionUtil.isReachMaxLevel(data.roleId);
                }
            }
        }
    }

    private var m_iStrIndex:int;
    private var m_sContent:String;
    private function _updateDesc(delta:Number = 0):void
    {
        if(m_pTimer == null)
        {
            m_pTimer = new Timer(10);
            m_pTimer.addEventListener(TimerEvent.TIMER, _onTimerHandler);
        }

        if(m_pTimer.running)
        {
            m_pTimer.stop();
        }
        m_pTimer.reset();
        m_pTimer.start();
    }

    private function _onTimerHandler(e:TimerEvent):void
    {
        var charStr:String = m_sContent.charAt(m_iStrIndex);
        m_pViewUI.desc.text += charStr;

        m_iStrIndex++;
        if(m_iStrIndex >= m_sContent.length)
        {
//            unschedule(_updateDesc);
            m_pTimer.stop();
            m_iStrIndex = 0;
        }
    }

    /**
     * 得攻、防、血三种属性中的一种
     * @return
     */
    private function _getAttrNameEN(attrData:CBasePropertyData):String
    {
        for each(var attrName:String in CImpressionUtil.Attrs)
        {
            if(attrData.hasOwnProperty(attrName) && attrData[attrName] != 0)
            {
                return attrName;
            }
        }

        return "";
    }

    private function _updateBtnState():void
    {
        if(selData)
        {
            if(selData.isGet)
            {
//                m_pViewUI.btn_train.visible = true;
//                m_pViewUI.btn_getHero.visible = false;
            }
            else
            {
//                m_pViewUI.btn_train.visible = false;
//                m_pViewUI.btn_getHero.visible = true;
            }
        }
    }

    /**
     * 翻页按钮状态
     */
    private function _updatePageBtnState():void
    {
        if(m_pViewUI.list_role.totalPage == 1)
        {
            m_pViewUI.btn_left.visible = false;
            m_pViewUI.btn_right.visible = false;
        }
        else
        {
            m_pViewUI.btn_left.visible = true;
            m_pViewUI.btn_right.visible = true;

            m_pViewUI.btn_left.disabled = m_pViewUI.list_role.page == 0;
            m_pViewUI.btn_right.disabled = m_pViewUI.list_role.page == m_pViewUI.list_role.totalPage-1;
        }
    }

    private function _outlistRenderHandler(item:Component, index:int):void
    {
        var listCell:List = item as List;
        if(listCell == null)
        {
            return;
        }

        listCell.mouseEnabled = true;
        listCell.mouseChildren = true;

        if(listCell.renderHandler == null)
        {
            listCell.renderHandler = new Handler(_innerListRenderHandler);
        }

        if(!listCell.hasEventListener(Event.SELECT))
        {
            listCell.addEventListener(Event.SELECT,_onListSelectHandler);
        }

        listCell.mouseHandler = new Handler(_onDBClickHandler);

        var datas:Array = listCell.dataSource as Array;
        if(datas)
        {
            listCell.dataSource = datas;
        }
    }

    private function _innerListRenderHandler(item:Component, index:int):void
    {
        var cell:ImpressionRoleHeadUI = item as ImpressionRoleHeadUI;
        if(cell == null)
        {
            return;
        }

        cell.mouseEnabled = true;
        cell.mouseChildren = false;

        var data:CPlayerInfoData = cell.dataSource as CPlayerInfoData;
        if(null != data)
        {
            cell.icon_image.mask = cell.hero_icon_mask;
            cell.icon_image.url = CPlayerPath.getHeroBigconPath(data.roleId);
            cell.icon_image.visible = data.isOpen;

            cell.img_notGet.visible = !data.isOpen;
            cell.img_black.visible = !data.isGet;
            cell.img_max.visible = CImpressionUtil.isReachMaxLevel(data.roleId);

            var heroData:CPlayerHeroData = CImpressionUtil.getHeroDataById(data.roleId);
            var qualIndex:int = heroData == null ? 0 : (heroData.impressionLevel / 25);
            cell.clip_qualityBg.index = qualIndex;

            if(data.isOpen && data.isGet)
            {
                cell.img_hongDian.visible = CImpressionUtil.isHeroCanUpgrade(data.roleId)
                        || CImpressionUtil.isCanTakeTaskReward(data.roleId);
            }
            else
            {
                cell.img_hongDian.visible = false;
            }
        }
        else
        {
            cell.icon_image.url = "";
            cell.img_notGet.visible = false;
            cell.img_black.visible = false;
            cell.img_hongDian.visible = false;
            cell.img_max.visible = false;
            cell.clip_qualityBg.index = 0;
        }
    }

    private function _onDBClickHandler(e:MouseEvent, index:int):void
    {
        if( e.type == MouseEvent.DOUBLE_CLICK)
        {
            var item:ImpressionRoleHeadUI = e.target as ImpressionRoleHeadUI;
            if(item)
            {
                var data:CPlayerInfoData = item.dataSource as CPlayerInfoData;
                if(data.isOpen)
                {
                    delayCall(0.05, onDelay);
                    function onDelay():void
                    {
                        var displayView:CImpressionDisplayViewHandler = system.getBean(CImpressionDisplayViewHandler);
                        if(!displayView.isViewShow)
                        {
                            displayView.addDisplay();
                        }
                        else
                        {
                            displayView.removeDisplay();
                        }
                    }
                }
            }
        }

    }

    private function _onListSelectHandler(e:Event):void
    {
        var list:List = e.target as List;

        if(list.selectedIndex == -1)
        {
            return;
        }

        m_currList = list;

        var cell:Component = list.getCell(list.selectedIndex);

        // 取消选中其他的list
        for each(var listCell:List in m_pViewUI.list_role.cells)
        {
            if(listCell && listCell != list && listCell.selectedIndex != -1)
            {
                listCell.selectedIndex = -1;
            }
        }

        var cellData:CPlayerInfoData = cell.dataSource as CPlayerInfoData;
        if(cellData && !cellData.isOpen)
        {
            var str:String = CLang.Get("impression_hero_notOpen");
            (system.stage.getSystem( IUICanvas ) as IUICanvas).showMsgAlert( str, CMsgAlertHandler.WARNING );

            m_bIsLastSelNotOpen = true;

            if(m_pLastSelList)
            {
                m_pLastSelList.selectedIndex = m_iLastSelIndex;
            }
            return;
        }

        m_iLastSelIndex = list.selectedIndex;
        m_pLastSelList = list;

        m_pViewUI.clip_select.x = m_pViewUI.list_role.x + list.x + list.selection.x + 33;
        m_pViewUI.clip_select.y = m_pViewUI.list_role.y + list.y + list.selection.y + 34;

        if(!m_bIsLastSelNotOpen)
        {
            _updateHeroImg();
            _updateHeroDetailInfo();
            _updateProgressInfo();
            _updateHeroAttrInfo();
            _updateBtnState();
        }

        m_bIsLastSelNotOpen = false;
    }

    /**
     * 默认选择第一个已开放的格斗家
     */
    private function _defaultSelFirstOpen():void
    {
        var list:List = m_pViewUI.list_role.getCell(m_pViewUI.list_role.startIndex) as List;
        if(list)
        {
            list.selectedIndex = -1;

            if(!list.hasEventListener(Event.SELECT))
            {
                list.addEventListener(Event.SELECT,_onListSelectHandler)
            }

            for(var i:int = 0; i < list.dataSource.length; i++)
            {
                var cellData:CPlayerInfoData = list.getItem(i) as CPlayerInfoData;
                if(cellData && cellData.isOpen)
                {
                    m_bIsLastSelNotOpen = false;

                    list.selectedIndex = i;

                    return;
                }
            }
        }
    }

    private function _onBtnClickHandler(e:MouseEvent):void
    {
        if( e.target == m_pViewUI.btn_left && m_pViewUI.list_role.page > 0)// 前一页
        {
            m_pViewUI.list_role.page -= 1;
            delayCall(0.1, _defaultSelFirstOpen);

            m_pBubbleViewUI.visible = false;

            _updatePageBtnState();
        }

        if( e.target == m_pViewUI.btn_right && m_pViewUI.list_role.page < m_pViewUI.list_role.totalPage-1)// 后一页
        {
            m_pViewUI.list_role.page += 1;
            delayCall(0.1, _defaultSelFirstOpen);

            m_pBubbleViewUI.visible = false;

            _updatePageBtnState();
        }

        if(e.target == m_pViewUI.btn_communicate)
        {
            var displayView:CImpressionDisplayViewHandler = system.getBean(CImpressionDisplayViewHandler);
            if(!displayView.isViewShow)
            {
                displayView.addDisplay();
            }
            else
            {
                displayView.removeDisplay();
            }
        }

        /*
        if( e.target == m_pViewUI.btn_getHero)// 获取途径
        {
            var pSystemBundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as
                    ISystemBundleContext;

            if ( pSystemBundleCtx )
            {
                var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID( "ROLE" ) );
                var vCurrent : Boolean = pSystemBundleCtx.getUserData( pSystemBundle, CBundleSystem.ACTIVATED, false );
                pSystemBundleCtx.setUserData( pSystemBundle, CBundleSystem.ACTIVATED, !vCurrent );
            }
        }

        if( e.target == m_pViewUI.btn_train)// 培养
        {
            var displayView:CImpressionDisplayViewHandler = system.getBean(CImpressionDisplayViewHandler);
            if(!displayView.isViewShow)
            {
                displayView.addDisplay();
            }
            else
            {
                displayView.removeDisplay();
            }
        }
        */
    }

    /**
     * 随机一个格斗家气泡说话
     */
    private function _showRandomBubbleTalk():void
    {
        var playerInfoData:CPlayerInfoData = CImpressionUtil.getRandomTalkHero(m_pViewUI.list_role.page);
        if(playerInfoData == null)
        {
            return;
        }

        var listIndex:int = playerInfoData.outerIndex;

        var list:List = m_pViewUI.list_role.getCell(listIndex) as List;

        var heroIndex:int = playerInfoData.innerIndex;
        var cell:Component = list.getCell(heroIndex);

        if(cell && cell.dataSource)
        {
            var xPos:int = m_pViewUI.list_role.x + list.x + cell.x-110;
            var yPos:int = m_pViewUI.list_role.y + list.y + cell.y-64;
            var talk:String = CImpressionUtil.getRandomBubbleTalk(CImpressionUtil.getHeroSex(cell.dataSource.roleId));

            if(!m_pBubbleViewUI.visible)
            {
                m_pBubbleViewUI.visible = true;
            }
            CImpressionUtil.showBubbleDialog(m_pBubbleViewUI,talk,xPos,yPos,0);
        }

        schedule(2,_hideRandomBubbleTalk);
    }

    private function _hideRandomBubbleTalk(delta : Number):void
    {
        m_pBubbleViewUI.visible = false;

        unschedule(_hideRandomBubbleTalk);
    }

    /**
     * 背包物品更新
     * @param e
     */
    private function _onBagItemsChangeHandler(e:CBagEvent = null):void
    {
        if( e && e.type == CBagEvent.BAG_UPDATE)
        {
            _updateRedPointTip();
        }
    }

    private function _updateRedPointTip():void
    {
        var arr:Array = m_pViewUI.list_role.dataSource as Array;
        var start:int = m_pViewUI.list_role.page*3;
        var end:int = (m_pViewUI.list_role.page+1)*3;
        arr = arr.slice(start,end);
        for(var i:int = 0; i < arr.length; i++)
        {
            var list:List = m_pViewUI.list_role.getCell(m_pViewUI.list_role.startIndex+i) as List;
            for each(var cell:ImpressionRoleHeadUI in list.cells)
            {
                var cellData:CPlayerInfoData = cell == null ? null : cell.dataSource as CPlayerInfoData;
                if(cellData && cellData.isOpen && cellData.isGet)
                {
                    cell.img_hongDian.visible = CImpressionUtil.isHeroCanUpgrade(cellData.roleId)
                            || CImpressionUtil.isCanTakeTaskReward(cellData.roleId);
                }
            }
        }
    }

    private function _onHeroDataUpdateHandler(e:CPlayerEvent):void
    {
        _updateRedPointTip();
        _recalcuTotalLevelData();
        _updateTotalLevelAddition();
        _updateProgressInfo();
        _updateHeroAttrInfo();
        _updateLevelState();
    }

    public function get isViewShow():Boolean
    {
        if(m_pViewUI && m_pViewUI.parent)
        {
            return true;
        }

        return false;
    }

    /**
     * 得选中hero的数据
     */
    public function get selData():CPlayerInfoData
    {
        if(m_currList)
        {
            return m_currList.getCell(m_currList.selectedIndex ).dataSource as CPlayerInfoData;
        }

        return null;
    }

    private function get _heroImg():Image
    {
        return m_pViewUI.img_role;
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    public function clear():void
    {
        m_pViewUI.img_role.url = "";
        m_pViewUI.img_role_white.url = "";
//        m_pViewUI.txt_life.text = "";
//        m_pViewUI.txt_attack.text = "";
//        m_pViewUI.txt_defense.text = "";
        m_pViewUI.heroName.url = "";
//        (m_pViewUI.star.getChildAt(0) as List).dataSource = [];
        m_pViewUI.desc.text = "";
//        m_pViewUI.currAddition.text = "";
//        m_pViewUI.fullAddition.text = "";
        m_pViewUI.list_role.dataSource = [];
        m_pBubbleViewUI.visible = false;
        m_pViewUI.clip_select.visible = false;
        m_pViewUI.list_heroAttr.visible = false;
        m_pViewUI.box_upgradeTip.visible = false;
    }

    override public function dispose() : void
    {
        super.dispose();

        m_pViewUI = null;
        m_pCloseHandler = null;
        m_bViewInitialized = false;

        if(m_attrLabelArr)
        {
            m_attrLabelArr.length = 0;
            m_attrLabelArr = null;
        }

        m_currList = null;

        m_iLastSelIndex = -1;
        m_pLastSelList = null;
        m_pBubbleViewUI = null;

        unschedule(_hideRandomBubbleTalk);
    }
}
}
