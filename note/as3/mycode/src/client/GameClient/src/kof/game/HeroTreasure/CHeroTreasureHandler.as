//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Demi.Liu on 2018-05-28.
 */
package kof.game.HeroTreasure {

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.game.HeroTreasure.CHeroTreasureHandler;
import kof.game.HeroTreasure.enum.EHeroTreasureActivityState;
import kof.game.activityHall.data.CActivityHallActivityType;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.common.system.CNetHandlerImp;
import kof.game.limitActivity.enum.ELimitActivityState;
import kof.message.Activity.ActivityChangeResponse;
import kof.message.CAbstractPackMessage;
import kof.message.FighterTreasure.DrawTreasureRequest;
import kof.message.FighterTreasure.DrawTreasureResponse;
import kof.message.FighterTreasure.TreasureOpenRequest;
import kof.message.FighterTreasure.TreasureOpenResponse;
import kof.table.GamePrompt;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;

/**
 *@author Demi.Liu
 *@data 2018-05-28
 */
public class CHeroTreasureHandler extends CNetHandlerImp {
    public function CHeroTreasureHandler() {
        super();
    }

    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        networking.bind(TreasureOpenResponse ).toHandler( _onTreasureOpenResponseHandler);
        networking.bind(DrawTreasureResponse ).toHandler( _onDrawTreasureResponseHandler);

        _addEventListener();
        return ret;
    }

    private function _addEventListener() : void
    {
        activityHallSystem.addEventListener(CActivityHallEvent.ActivityStateChanged, _onActivityStateRespone);
    }

    /**********************Request********************************/

    /**打开抽宝藏页面请求*/
    public function onTreasureOpenRequest( ):void{
        var request:TreasureOpenRequest = new TreasureOpenRequest();
        request.decode([1]);

        networking.post(request);
    }

    /**抽宝藏请求*/
    //optional int32 poolId = 1; //卡池ID
    //optional int32 count = 2; //消耗数量
    public function onDrawTreasureRequest(poolId:int, count:int ):void{
        var request:DrawTreasureRequest = new DrawTreasureRequest();
        request.decode([poolId,count]);

        networking.post(request);
    }

    /**********************Response********************************/

    /**打开抽宝藏页面反馈*/
    private final function _onTreasureOpenResponseHandler(net:INetworking, message:CAbstractPackMessage):void {
        var response:TreasureOpenResponse = message as TreasureOpenResponse;
        _heroTreasureManager.setActivityTime(response.duration);
    }

    /**抽宝藏反馈*/
    private final function _onDrawTreasureResponseHandler(net:INetworking, message:CAbstractPackMessage):void {
        var response:DrawTreasureResponse = message as DrawTreasureResponse;
        if(response.promptId == 0)
        {
            _heroTreasureManager.poolId = response.poolId;
            if(response.poolId == CHeroTreasureManager.POOTYPE_THREE){//十连抽
                _heroTreasureManager.setRewardListData(response.rewards);
            }else{
                _heroTreasureManager.setRewardIndex(response.rewards);
            }

            system.dispatchEvent(new CHeroTreasureEvent(CHeroTreasureEvent.drawTreasureResponse,null));
        }
        else
        {
            _showErrorMsg(response.promptId);
        }
    }

    private function get _heroTreasureManager():CHeroTreasureManager{
        return system.getBean(CHeroTreasureManager) as CHeroTreasureManager;
    }

    private function _showErrorMsg(gamePromptID:int):void
    {
        var gamePromptTable:IDataTable = (system.stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.GAME_PROMPT);
        var tableData:GamePrompt = gamePromptTable.findByPrimaryKey(gamePromptID) as GamePrompt;
        if(tableData)
        {
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(tableData.content,CMsgAlertHandler.WARNING);
        }
    }

    private function get activityHallSystem() : CActivityHallSystem {
        return system.stage.getSystem(CActivityHallSystem) as CActivityHallSystem;
    }

    public function get heroTreasureManager():CHeroTreasureManager
    {
        return system.getBean(CHeroTreasureManager) as CHeroTreasureManager;
    }

    //================================================
    /**
     * 活动状态变更
     * @param event
     */
    private function _onActivityStateRespone(event:CActivityHallEvent):void{
        var response:ActivityChangeResponse = event.data as ActivityChangeResponse;
        if(!response) return;

        var activityType:int = heroTreasureManager.getActivityType(response.activityID);
        if(activityType == CActivityHallActivityType.HERO_TREASURE)
        {
            heroTreasureManager.updateActivityState(response);
            //1准备中2进行中3已完成4已结束5已关闭/
            heroTreasureManager.curActivityId = response.activityID;
            heroTreasureManager.curActivityState = response.state;
            if(response.params){
                heroTreasureManager.startTime = response.params.startTick;
                heroTreasureManager.endTime = response.params.endTick;
            }

            if(response.state >= EHeroTreasureActivityState.ACTIVITY_STATE_PREPARE && response.state < EHeroTreasureActivityState.ACTIVITY_STATE_END){
                heroTreasureManager.openHeroTreasureActivity();
            }else if(response.state == EHeroTreasureActivityState.ACTIVITY_STATE_CLOSE  || response.state == EHeroTreasureActivityState.ACTIVITY_STATE_END){
                heroTreasureManager.closeHeroTreasureActivity();
                heroTreasureManager.curActivityId = 0;
            }
        }
    }

    //===============================================

}
}
