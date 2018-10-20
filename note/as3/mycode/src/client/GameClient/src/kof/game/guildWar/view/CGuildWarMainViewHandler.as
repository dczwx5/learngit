//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/17.
 */
package kof.game.guildWar.view {

import QFLib.Foundation.CTime;
import QFLib.Utils.HtmlUtil;

import com.greensock.TweenMax;

import flash.events.MouseEvent;

import kof.game.ActivityNotice.enums.EActivityState;

import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.hero.CHeroEmbattleListView;
import kof.game.embattle.CEmbattleEvent;
import kof.game.embattle.CEmbattleSystem;

import kof.game.guildWar.*;

import kof.game.KOFSysTags;
import kof.game.common.view.CTweenViewHandler;
import kof.game.guildWar.data.CGuildWarData;
import kof.game.guildWar.data.CStationData;
import kof.game.guildWar.enum.CGuildWarState;
import kof.game.guildWar.event.CGuildWarEvent;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.CPlayerSystem;
import kof.table.GuildWarSpaceTable;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.master.GuildWar.ClubLeagueUI;
import kof.util.TweenUtil;

import morn.core.components.Box;
import morn.core.components.Clip;

import morn.core.components.Component;

import morn.core.components.Dialog;
import morn.core.components.Image;
import morn.core.components.Image;
import morn.core.components.Label;
import morn.core.components.Label;
import morn.core.components.View;

import morn.core.handlers.Handler;

public class CGuildWarMainViewHandler extends CTweenViewHandler {

    private var m_bViewInitialized : Boolean;

    private var m_pViewUI : ClubLeagueUI;
    private var m_pCloseHandler : Handler;
    private var m_bIsTweening:Boolean;
    private var m_pEmbattleListView:CHeroEmbattleListView;
    private var m_arrStationView:Array = [];
    private var m_iBtnRefreshCountDown:int;// 刷新倒计时(s)
    private var m_iPanelRefreshCountDown:int;// 刷新倒计时(s)
    private var m_iCurrActState:int;// 当前活动状态

    public static const BtnRefreshTime:int = 3;
    public static const PanelRefreshTime:int = 10;

    public function CGuildWarMainViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();

        return ret;
    }

    override public function get viewClass() : Array
    {
        return [];
    }

    override protected function get additionalAssets():Array
    {
        return ["GuildWar.swf"];
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
                m_pViewUI = new ClubLeagueUI();
                m_pViewUI.btn_active.clickHandler = new Handler(_onClickActiveHandler);
                m_pViewUI.btn_reward.clickHandler = new Handler(_onClickRewardHandler);
                m_pViewUI.btn_gift.clickHandler = new Handler(_onClickGiftHandler);
                m_pViewUI.btn_refresh.clickHandler = new Handler(_onClickRefreshHandler);
                m_pViewUI.btn_energyRank.clickHandler = new Handler(_onClickEnergyRankHandler);
                m_pViewUI.btn_czbz.clickHandler = new Handler(_onClickEmbattleHandler);
//                m_pViewUI.btn_left.clickHandler = new Handler(_onClickLeftHandler);
//                m_pViewUI.btn_right.clickHandler = new Handler(_onClickRightHandler);
                m_pViewUI.btn_close.clickHandler = new Handler( _onClose );
                m_pViewUI.btn_baodi.clickHandler = new Handler( _onClickBaodiHandler );
                m_pViewUI.btn_firstOccupy.clickHandler = new Handler( _onClickFirstOccupyHandler );

                m_pViewUI.box_station.mask = m_pViewUI.img_mask;
                m_pViewUI.txt_leftTime.isHtml = true;

                for(var i:int = 1; i <= 6; i++)
                {
                    var stationView : View = m_pViewUI[ "view_station" + i ];
                    m_arrStationView.push(stationView)
                }

                _clear();

                CSystemRuleUtil.setRuleTips(m_pViewUI.img_ruleTip, CLang.Get("ClubFight"));

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function addDisplay() : void
    {
        if(m_pViewUI && m_pViewUI.parent)
        {
            uiCanvas.addDialog( m_pViewUI );
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
            callLater( _tweenShow );
        }
        else
        {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _tweenShow():void
    {
        setTweenData(KOFSysTags.GUILDWAR);
        showDialog(m_pViewUI, false, _addToDisplay);
    }

    private function _addToDisplay() : void
    {
        uiCanvas.addDialog( m_pViewUI );

        _initView();
        _addListeners();
        _reqStationInfo();
        _reqEmbattleInfo();
    }

    private function _reqStationInfo():void
    {
        (system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler).guildWarSpaceClubInfoRequest();
    }

    private function _addListeners():void
    {
        system.stage.getSystem(CEmbattleSystem).addEventListener(CEmbattleEvent.EMBATTLE_SUCC,_onEmbattleUpdateHandler);
        system.addEventListener(CGuildWarEvent.UpdateBaseInfo, _onBaseInfoUpdateHandler);
        system.addEventListener(CGuildWarEvent.UpdateStationInfo, _onStationInfoUpdateHandler);
        system.addEventListener(CGuildWarEvent.UpdateStationBoxRewardInfo, _onUpdateStationBoxRewardInfo);

        for each(var view:View in m_arrStationView)
        {
            view.addEventListener(MouseEvent.CLICK, _onClickStationHandler);
        }
    }

    private function _removeListeners():void
    {
        system.stage.getSystem(CEmbattleSystem).removeEventListener(CEmbattleEvent.EMBATTLE_SUCC,_onEmbattleUpdateHandler);
        system.removeEventListener(CGuildWarEvent.UpdateBaseInfo, _onBaseInfoUpdateHandler);
        system.removeEventListener(CGuildWarEvent.UpdateStationInfo, _onStationInfoUpdateHandler);
        system.removeEventListener(CGuildWarEvent.UpdateStationBoxRewardInfo, _onUpdateStationBoxRewardInfo);

        for each(var view:View in m_arrStationView)
        {
            view.removeEventListener(MouseEvent.CLICK, _onClickStationHandler);
        }
    }

    private function _reqEmbattleInfo():void
    {
        // 出战编制信息
        var embattleSystem:CEmbattleSystem = system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
        var heroList:Array = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.embattleManager.getHeroListByType(EInstanceType.TYPE_GUILD_WAR);
        if(heroList.length == 0)
        {
            embattleSystem.requestBestEmbattle(EInstanceType.TYPE_GUILD_WAR);
        }
    }

    private function _initView():void
    {
//        m_pViewUI.box_station.x = 6;
        m_iBtnRefreshCountDown = BtnRefreshTime;
        m_iPanelRefreshCountDown = PanelRefreshTime;

        _initStationInfo();
        _updateDisplay();
    }

    private function _updateDisplay():void
    {
        _updateLeftTopInfo();
        _updateTimeInfo();
        _updateEmbattleHeroList();
        _updateBaodiRewardInfo();
        _updateBtnState();

        schedule(1, _onScheduleHandler);
    }

//界面信息更新=========================================================================================================

    private function _initStationInfo():void
    {
        for(var i:int = 0; i < m_arrStationView.length; i++)
        {
            var view:View = m_arrStationView[i] as View;
            var stationId:int = i+1;
            view.dataSource = stationId;

            /*
            switch(stationId)
            {
                case 8:
                case 7:
                case 6:
                case 5:
                case 4:
                    view.img_bg.skin = "png.guildwar.img_station_d_03";
//                    view.img_line.skin = "png.guildwar.img_station_e_03";
                    view.clip_stationIcon.index = 2;
                    view.clip_energyBg.index = 2;
                    view.img_spaceNameBg.skin = "png.guildwar.img_station_c_03";
                    break;
                case 3:
                case 2:
                    view.img_bg.skin = "png.guildwar.img_station_d_02";
//                    view.img_line.skin = "png.guildwar.img_station_e_02";
                    view.clip_stationIcon.index = 1;
                    view.clip_energyBg.index = 1;
                    view.img_spaceNameBg.skin = "png.guildwar.img_station_c_02";
                    break;
                case 1:
                    view.img_bg.skin = "png.guildwar.img_station_d_01";
//                    view.img_line.skin = "png.guildwar.img_station_e_01";
                    view.clip_stationIcon.index = 0;
                    view.clip_energyBg.index = 0;
                    view.img_spaceNameBg.skin = "png.guildwar.img_station_c_01";
                    break;
            }

            _setPosition(view, stationId);
            */

            var spaceTableData:GuildWarSpaceTable = _helper.getSpaceTableData(stationId);
            (view["txt_stationName"] as Label).text = spaceTableData == null ? "" : spaceTableData.spaceName;
        }
    }

    /*
    private function _setPosition(view:StationInfoViewUI, stationId:int):void
    {
        switch(stationId)
        {
            case 1:
                view.img_bg.x = 30;
                view.img_bg.y = 10;
                break;
            case 2:
            case 3:
                view.img_bg.x = 63;
                view.img_bg.y = 20;
                break;
            case 4:
            case 5:
            case 6:
            case 7:
            case 8:
                view.img_bg.x = 64;
                view.img_bg.y = 29;
                view.txt_stationName.x = 58;
                view.txt_stationName.y = 175;
                view.img_spaceNameBg.x = 55;
                view.img_spaceNameBg.y = 170;
                view.box_name.x = 36;
                view.box_name.y = 183;
                view.box_energyNum.x = 93;
                view.box_energyNum.y = 230;
                view.clip_energyBg.x = 83;
                view.clip_energyBg.y = 227;
                break;
        }
    }
    */

    private function _updateLeftTopInfo():void
    {
        if(_guildWarData && _guildWarData.baseData)
        {
            if(_helper.isInActivityTime())
            {
                m_pViewUI.txt_winNum.text = _guildWarData.baseData.alwaysWin.toString();
                m_pViewUI.txt_winTitle.text = "当前连胜";
            }
            else
            {
                m_pViewUI.txt_winNum.text = _guildWarData.baseData.historyHighWin.toString();
                m_pViewUI.txt_winTitle.text = "最高连胜";
            }

            m_pViewUI.txt_energyNum.text = _guildWarData.baseData.totalScore.toString();
        }
    }

    private function _updateTimeInfo():void
    {
        var state:int = _helper.getActivityState();
        if(state == EActivityState.Type_NotStart)
        {
            if(_helper.isBefore48h())
            {
                m_pViewUI.txt_topInfo.text = "联赛即将开始";
                var timeStr:String = CTime.toDurTimeString(_guildWarData.baseData.startTime - CTime.getCurrServerTimestamp());
                m_pViewUI.txt_leftTime.text = HtmlUtil.color(timeStr, "#ffd940");

                schedule(1, _onScheduleHandler2);
            }
            else
            {
                if(_helper.isSameWeek())
                {
                    m_pViewUI.txt_leftTime.text = HtmlUtil.color("本周六20:30荣耀开启", "#ffd940");
                }
                else
                {
                    m_pViewUI.txt_leftTime.text = HtmlUtil.color("下周六20:30荣耀开启", "#ffd940");
                }

                unschedule(_onScheduleHandler2);
            }

            if(m_iCurrActState != state)
            {
                _updateBtnState();
            }
        }
        else if(state == EActivityState.Type_Processing)
        {
            m_pViewUI.txt_topInfo.text = "联赛剩余时间";
            timeStr = CTime.toDurTimeString(_guildWarData.baseData.endTime - CTime.getCurrServerTimestamp());
            m_pViewUI.txt_leftTime.text = HtmlUtil.color(timeStr, "#ff0000");

            schedule(1, _onScheduleHandler2);

            if(m_iCurrActState != state)
            {
                _updateBtnState();
            }
        }
        else
        {
            if(_helper.isInEnd3Min())
            {
                m_pViewUI.txt_topInfo.text = "等待结算时间";
                var endTime:Number = _guildWarData.baseData.endTime + 3*60*1000;
                timeStr = CTime.toDurTimeString(endTime - CTime.getCurrServerTimestamp());
                m_pViewUI.txt_leftTime.text = HtmlUtil.color(timeStr, "#ff0000");

                schedule(1, _onScheduleHandler2);
            }
            else
            {
                m_pViewUI.txt_topInfo.text = "联赛已结束";
                m_pViewUI.txt_leftTime.text = HtmlUtil.color("下周六20:30荣耀开启", "ffd940");

                unschedule(_onScheduleHandler2);
            }

            if(m_iCurrActState != state)
            {
                _updateBtnState();
            }
        }

        m_iCurrActState = state;
    }

    private function _onScheduleHandler(delta : Number):void
    {
        if(m_iBtnRefreshCountDown > 0)
        {
            m_iBtnRefreshCountDown--;
        }

        if(m_iPanelRefreshCountDown > 0)
        {
            m_iPanelRefreshCountDown--;

            if(m_iPanelRefreshCountDown == 0)
            {
                (system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler).guildWarSpaceClubInfoRequest();
                m_iPanelRefreshCountDown = PanelRefreshTime;
            }
        }
    }

    private function _onScheduleHandler2(delta : Number):void
    {
        _updateTimeInfo();
    }

    /**
     * 更新出战编制格斗家列表
     */
    private function _updateEmbattleHeroList():void
    {
        if (m_pEmbattleListView == null)
        {
            m_pViewUI.list_hero.mouseHandler = new Handler(function (e:MouseEvent, idx:int) : void {
                if (e.type == MouseEvent.CLICK) {
                    _onClickAddHandler();
                }
            });
            m_pEmbattleListView = new CHeroEmbattleListView(system, m_pViewUI.list_hero, EInstanceType.TYPE_GUILD_WAR, null, null, false, false, false);
        }
        m_pEmbattleListView.updateWindow();
    }

    /**
     * 保底奖励
     */
    private function _updateBaodiRewardInfo(e:CGuildWarEvent = null):void
    {
        if(_guildWarData && _guildWarData.baseData)
        {
            var winnerSpaceIds:Array = _guildWarData.baseData.winnerSpaceIds;
            var takeRewards:Array = _guildWarData.baseData.alreadyReceiveDaySpaceRewards;
            var totalScore:int = _guildWarData.baseData.totalScore;

            if(winnerSpaceIds && winnerSpaceIds.indexOf(-1) != -1
                && takeRewards && takeRewards.indexOf(-1) == -1 )
            {
                m_pViewUI.btn_baodi.visible = true;
            }
            else
            {
                m_pViewUI.btn_baodi.visible = false;
            }
        }
    }

    private function _updateBtnState():void
    {
        m_pViewUI.btn_active.visible = _helper.isInActivityTime();
        m_pViewUI.img_dian.visible = _helper.hasRewardTake();
        m_pViewUI.btn_refresh.visible = _helper.isInActivityTime();
        m_pViewUI.btn_firstOccupy.visible = _helper.isBeforeFirstActivity();
    }


//点击处理=============================================================================================================
    private function _onClickActiveHandler():void
    {
        var inspireView:CGuildWarInspireViewHandler = system.getHandler(CGuildWarInspireViewHandler)
                as CGuildWarInspireViewHandler;
        if(inspireView && !inspireView.isViewShow)
        {
            inspireView.addDisplay();
        }
    }

    private function _onClickGiftHandler():void
    {
        var giftAllotView:CGuildWarGiftAllotViewHandler = system.getHandler(CGuildWarGiftAllotViewHandler)
                as CGuildWarGiftAllotViewHandler;
        if(giftAllotView && !giftAllotView.isViewShow)
        {
            giftAllotView.addDisplay();
        }
    }

    private function _onClickRewardHandler():void
    {
        var rewardView:CGuildWarEnergyRewardViewHandler = system.getHandler(CGuildWarEnergyRewardViewHandler)
                as CGuildWarEnergyRewardViewHandler;
        if(rewardView && !rewardView.isViewShow)
        {
            rewardView.addDisplay();
        }
    }

    private function _onClickEnergyRankHandler():void
    {
        var energyRankView:CGuildWarEnergyRankViewHandler = system.getHandler(CGuildWarEnergyRankViewHandler)
                as CGuildWarEnergyRankViewHandler;
        if(energyRankView && !energyRankView.isViewShow)
        {
            energyRankView.addDisplay();
        }
    }

    private function _onClickRefreshHandler():void
    {
        if(m_iBtnRefreshCountDown > 0)
        {
            _uiSystem.showMsgAlert(m_iBtnRefreshCountDown + "s后可刷新", CMsgAlertHandler.WARNING);
        }
        else
        {
            (system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler).guildWarSpaceClubInfoRequest();

            m_iBtnRefreshCountDown = BtnRefreshTime;
            _uiSystem.showMsgAlert("刷新成功！", CMsgAlertHandler.NORMAL);
        }
    }

    private function _onClickEmbattleHandler():void
    {
        _openEmbattle();
    }

    //出站编制===========================================================================================================
    private function _openEmbattle():void
    {
        (system.getHandler(CGuildWarEmbattleHandler) as CGuildWarEmbattleHandler).openEmbattleView();
    }

    private function _onClickAddHandler():void
    {
        _openEmbattle();
    }

    private function _onClickLeftHandler():void
    {
        if(m_bIsTweening)
        {
            return;
        }

        m_bIsTweening = true;
        TweenMax.to(m_pViewUI.box_station, 0.5, {x:6, onComplete:onCompleteHandler});
        function onCompleteHandler():void
        {
            m_bIsTweening = false;
        }
    }

    private function _onClickRightHandler():void
    {
        if(m_bIsTweening)
        {
            return;
        }

        m_bIsTweening = true;
        TweenMax.to(m_pViewUI.box_station, 0.5, {x:-892, onComplete:onCompleteHandler});
        function onCompleteHandler():void
        {
            m_bIsTweening = false;
        }
    }

    private function _onClickBaodiHandler():void
    {
        (system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler).guildWarReceiveDaySpaceRewardRequest(-1);
    }

    private function _onClickFirstOccupyHandler():void
    {
        (system.getHandler(CGuildWarFirstOccupyViewHandler) as CGuildWarFirstOccupyViewHandler).addDisplay();
    }

//监听=============================================================================================================
    private function _onEmbattleUpdateHandler(e:CEmbattleEvent):void
    {
        _updateEmbattleHeroList();
    }

    private function _onBaseInfoUpdateHandler(e:CGuildWarEvent):void
    {
        _updateLeftTopInfo();
        _updateTimeInfo();
        _updateBaodiRewardInfo();
        _updateBtnState();
    }

    /**
     * 空间站列表
     * @param e
     */
    private function _onStationInfoUpdateHandler(e:CGuildWarEvent = null):void
    {
        if(_guildWarData && _guildWarData.stationListData)
        {
            for each(var view:View in m_arrStationView)
            {
                var stationId:int = view.dataSource as int;
                var stationData:CStationData = _guildWarData.stationListData.getStation(stationId);
                if(stationData)
                {
                    (view["txt_clubName"] as Label).text = stationData.clubName;
                    (view["txt_clubName"] as Label).x = 32;
                    (view["txt_energyNum"] as Label).text = stationData.clubScore.toString();
                    (view["img_clubIcon"] as Image).url = "icon/club/icon/" + stationData.clubSignID + ".png";
                    (view["img_energyIcon"] as Image).visible = true;
                    (view["box_clubName"] as Box).centerX = 0;
                    (view["img_occupy"] as Image).visible = _helper.isOccupyStation(stationId);

                    var box_rewardBox:Box = view["box_rewardBox"] as Box;
                    box_rewardBox.visible = _guildWarData.baseData.winnerSpaceIds.indexOf(stationId) != -1
                        && _guildWarData.baseData.alreadyReceiveDaySpaceRewards.indexOf(stationId) == -1;

                    var clip_rewardBox:Clip = view["clip_rewardBox"] as Clip;
                    if(box_rewardBox.visible)
                    {
                        TweenUtil.lighting(clip_rewardBox, 0.4, -1);
                    }
                    else
                    {
                        TweenMax.killTweensOf(clip_rewardBox);
                        clip_rewardBox.filters = null;
                    }
                }
                else
                {
                    (view["txt_clubName"] as Label).text = "暂无人占领";
                    (view["txt_clubName"] as Label).x = 49;
                    (view["img_clubIcon"] as Image).url = "";
                    (view["txt_energyNum"] as Label).text = "0";
                    (view["img_energyIcon"] as Image).visible = true;
                    (view["img_occupy"] as Image).visible = false;

                    (view["box_rewardBox"] as Box).visible = false;
                    clip_rewardBox = view["clip_rewardBox"] as Clip;
                    TweenMax.killTweensOf(clip_rewardBox);
                    clip_rewardBox.filters = null;
                }
            }
        }
    }

    /**
     * 空间战宝箱/保底奖励领取后更新
     * @param e
     */
    private function _onUpdateStationBoxRewardInfo(e:CGuildWarEvent):void
    {
        _onStationInfoUpdateHandler();

        _updateBaodiRewardInfo();
    }

    private function _onClickStationHandler(e:MouseEvent):void
    {
        var view:View = e.currentTarget as View;
        var target:Component = e.target as Component;

        if(view && view.dataSource)
        {
            var stationId:int = view.dataSource as int;
            if(stationId)
            {
                if(target && target == view["clip_rewardBox"])
                {
                    (system.getHandler(CGuildWarNetHandler) as CGuildWarNetHandler).guildWarReceiveDaySpaceRewardRequest(stationId);
                    return;
                }

                var stationView:CGuildWarStationViewHandler = system.getHandler(CGuildWarStationViewHandler)
                        as CGuildWarStationViewHandler;
                if(!stationView.isViewShow)
                {
                    stationView.stationId = stationId;
                    stationView.addDisplay();
                }
            }
        }
    }

//=================================================================================================================

    public function removeDisplay() : void
    {
        closeDialog(_remove);
    }

    private function _remove():void
    {
        if ( m_bViewInitialized )
        {
            _removeListeners();

            unschedule(_onScheduleHandler);
            unschedule(_onScheduleHandler2);

            if(m_bIsTweening)
            {
                TweenMax.killTweensOf(m_pViewUI.img_bg);
                m_bIsTweening = false;
            }

            if ( m_pViewUI && m_pViewUI.parent )
            {
                m_pViewUI.close( Dialog.CLOSE );
            }

//            m_pViewUI.box_station.x = 6;
            m_iBtnRefreshCountDown = BtnRefreshTime;
            m_iPanelRefreshCountDown = PanelRefreshTime;

            for each(var station:View in m_arrStationView)
            {
                if(station)
                {
                    var clip_rewardBox:Clip = station["clip_rewardBox"] as Clip;
                    if(TweenMax.isTweening(clip_rewardBox))
                    {
                        TweenMax.killTweensOf(clip_rewardBox);
                    }

                    clip_rewardBox.filters = null;
                }
            }

            CGuildWarState.reset();
        }
    }

    private function _onClose( type : String = null ) : void
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

    private function _clear():void
    {
        for each(var station:View in m_arrStationView)
        {
            if(station)
            {
                (station["txt_clubName"] as Label).text = "";
                (station["img_clubIcon"] as Image).url = "";
                (station["txt_energyNum"] as Label).text = "";
                (station["img_energyIcon"] as Image).visible = false;
                (station["img_occupy"] as Image).visible = false;
                (station["box_rewardBox"] as Box).visible = false;

                var clip_rewardBox:Clip = station["clip_rewardBox"] as Clip;
                if(TweenMax.isTweening(clip_rewardBox))
                {
                    TweenMax.killTweensOf(clip_rewardBox);
                }
                clip_rewardBox.filters = null;
                m_pViewUI.btn_baodi.visible = false;
            }
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

    private function get _helper():CGuildWarHelpHandler
    {
        return system.getHandler(CGuildWarHelpHandler) as CGuildWarHelpHandler;
    }

    private function get _guildWarData():CGuildWarData
    {
        return (system.getHandler(CGuildWarManager) as CGuildWarManager).data;
    }
}
}
