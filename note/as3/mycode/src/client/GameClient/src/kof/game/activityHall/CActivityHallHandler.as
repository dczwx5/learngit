/**
 * Created by Administrator on 2017/7/31.
 */
package kof.game.activityHall {

import kof.framework.INetworking;
import kof.game.activityHall.activeTask.CActiveTaskData;
import kof.game.activityHall.data.CActivityHallActivityType;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.common.system.CNetHandlerImp;
import kof.message.Activity.ActivityChangeResponse;
import kof.message.Activity.ActivityOpenHeroResponse;
import kof.message.Activity.ActivityStateDataResponse;
import kof.message.Activity.BuyDiscountGoodsRequest;
import kof.message.Activity.BuyDiscountGoodsResponse;
import kof.message.Activity.ConsumeActivityRequest;
import kof.message.Activity.ConsumeActivityResponse;
import kof.message.Activity.DiscounterRequest;
import kof.message.Activity.DiscounterResponse;
import kof.message.Activity.LivingTaskActivityDataRequest;
import kof.message.Activity.LivingTaskActivityDataResponse;
import kof.message.Activity.LivingTaskActivityUpdateEvent;
import kof.message.Activity.ReceiveConsumeActivityRequest;
import kof.message.Activity.ReceiveConsumeActivityResponse;
import kof.message.Activity.ReceiveLivingTaskActivityRewardRequest;
import kof.message.Activity.ReceiveLivingTaskActivityRewardResponse;
import kof.message.Activity.TotalRechargeRequest;
import kof.message.Activity.TotalRechargeResponse;
import kof.message.Activity.TotalRechargeRewardRequest;
import kof.message.Activity.TotalRechargeRewardResponse;
import kof.message.CAbstractPackMessage;
import kof.table.ActivityPreviewData;
import kof.table.TaskActivity;

public class CActivityHallHandler extends CNetHandlerImp {
    public function CActivityHallHandler() {
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        this.bind(ActivityChangeResponse,_onActivityChangeRespone);

        this.bind( ConsumeActivityResponse, _onConsumeActivityResponseHandler );
        this.bind( ReceiveConsumeActivityResponse, _onReceiveConsumeActivityResponseHandler );

        this.bind( TotalRechargeResponse, _onTotalRechargeResponseHandler );
        this.bind( TotalRechargeRewardResponse, _onTotalRechargeRewardResponseHandler );

        this.bind( DiscounterResponse, _onDiscounterResponseHandler );
        this.bind( BuyDiscountGoodsResponse, _onBuyDiscountGoodsResponseHandler );

        this.bind( ActivityStateDataResponse, _onActivityStateDataResponse );
        this.bind( ActivityOpenHeroResponse, _onActivityOpenHeroResponse );

        this.bind( LivingTaskActivityDataResponse, _onLivingTaskActivityDataResponseHandler );
        this.bind( ReceiveLivingTaskActivityRewardResponse, _onReceiveLivingTaskActivityRewardResponseHandler );
        this.bind( LivingTaskActivityUpdateEvent, _onLivingTaskActivityUpdateEventHandler );

        return ret;
    }

    /**
     * 活动状态变更时推送的消息
     * @param net
     * @param message
     * @param isError
     */
    private function _onActivityChangeRespone(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void
    {
        if (isError) return;
        var response:ActivityChangeResponse = message as ActivityChangeResponse;

        if(response)
        {
            _updateActivityState(response);
        }
    }

    private function _updateActivityState(response:ActivityChangeResponse):void
    {
        //收到变更后第一时间通知各系统，做好开关状态，已供下面的活动预览数据收集做保障
        system.dispatchEvent( new CActivityHallEvent( CActivityHallEvent.ActivityStateChanged, response ) );
        //=============add by Lune 0627======================================
        var activityType:int = activityHallDataManager.getActivityType(response.activityID);
        if(activityType == 0) return;
        var data : ActivityPreviewData = activityHallDataManager.getPreviewDataByType(activityType );
        if(data)
        {
            var args : Object = {};
            args.sysID = data.sysID;
            args.state = response.state;
            args.endTime = response.params.endTick;
            activityHallDataManager.updatePreviewDic(args);
        }
        //用于收集活动开启预览数据
        activityHallDataManager.updateActivityState(response.activityID, response.state, response.params);
        system.dispatchEvent( new CActivityHallEvent( CActivityHallEvent.ActivityHallActivityStateChanged ) );
    }

    /**
     * 登录时推送的活动状态数据
     * @param net
     * @param message
     * @param isError
     */
    private function _onActivityStateDataResponse( net : INetworking, message : CAbstractPackMessage , isError : Boolean) : void {
        if(isError) return;

        var response : ActivityStateDataResponse = message as ActivityStateDataResponse;
        if(response)
        {
            activityHallDataManager.updateActivityOpenHeros(response.onceStartedActivityIds);// 活动投放的格斗家

            for each(var info:Object in response.activityInfos)
            {
                var changeResponse:ActivityChangeResponse = new ActivityChangeResponse();
                changeResponse.activityID = info.activityID;
                changeResponse.state = info.state;
                changeResponse.params = info.params;

                _updateActivityState(changeResponse);
            }
        }
    }

    /**
     * 游戏进行中有新开启的活动时，更新活动投放的格斗家
     * @param net
     * @param message
     * @param isError
     */
    private function _onActivityOpenHeroResponse(net : INetworking, message : CAbstractPackMessage , isError : Boolean):void
    {
        if(isError) return;

        var response : ActivityOpenHeroResponse = message as ActivityOpenHeroResponse;
        if(response)
        {
            activityHallDataManager.updateActivityOpenHeros(response.onceStartedActivityIds);// 活动投放的格斗家
        }
    }

    //累计消费信息请求
    public function onConsumeActivityRequest( activityID : int ) : void {
        var request : ConsumeActivityRequest = new ConsumeActivityRequest();
        request.activityId = activityID;
        networking.post( request );
    }

    //累计消费信息返回
    private function _onConsumeActivityResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;

        var response : ConsumeActivityResponse = message as ConsumeActivityResponse;
        activityHallDataManager.consumeDiamond = response.consumeDiamond;
        activityHallDataManager.consumeDiamondType = response.diamondType;
        activityHallDataManager.consumeReceivedList = response.receive;
        system.dispatchEvent( new CActivityHallEvent( CActivityHallEvent.ConsumeActivityResponse ) );
    }

    //累计消费领取奖励请求
    public function onReceiveConsumeActivityRequest( diamond : int, activityId : int ) : void {
        var request : ReceiveConsumeActivityRequest = new ReceiveConsumeActivityRequest();
        request.diamond = diamond;
        request.activityId = activityId;

        networking.post( request );
    }

    //累计消费领取奖励返回
    private function _onReceiveConsumeActivityResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;

        var response : ReceiveConsumeActivityResponse = message as ReceiveConsumeActivityResponse;
        var list : Array = activityHallDataManager.consumeReceivedList;
        for ( var i : int = 0; i < list.length; i++ ) {
            if ( list[ i ].diamond == response.receive.diamond ) {
                list[ i ].count = response.receive.count;
                break;
            }
        }
        if ( i == list.length ) list.push( response.receive );
        system.dispatchEvent( new CActivityHallEvent( CActivityHallEvent.ReceiveConsumeActivityResponse, response.receive.diamond ) );
    }

    //累计充值信息请求
    public function onChargeActivityRequest() : void {
        var request : TotalRechargeRequest = new TotalRechargeRequest();
        request.id = 1;
        networking.post( request );
    }

    //累计充值信息返回
    private function _onTotalRechargeResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;

        var response : TotalRechargeResponse = message as TotalRechargeResponse;
        activityHallDataManager.chargeDiamond = response.totalRecharge;
        activityHallDataManager.chargeReceivedList = response.receiveMap;
        system.dispatchEvent( new CActivityHallEvent( CActivityHallEvent.TotalRechargeResponse ) );
    }

    //累计充值领取奖励请求
    public function onReceiveChargeActivityRequest( diamond : int, activityId : int ) : void {
        var request : TotalRechargeRewardRequest = new TotalRechargeRewardRequest();
        request.rechargeType = diamond;
//        request.activityId = activityId;

        networking.post( request );
    }

    //累计充值领取奖励返回
    private function _onTotalRechargeRewardResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;

        var response : TotalRechargeRewardResponse = message as TotalRechargeRewardResponse;
        var list : Array = activityHallDataManager.chargeReceivedList;
        for ( var i : int = 0; i < list.length; i++ ) {
            if ( list[ i ].rechargeValue == response.receiveMap.rechargeValue ) {
                list[ i ].count = response.receiveMap.count;
                break;
            }
        }
        if ( i == list.length ) list.push( response.receiveMap );
        system.dispatchEvent( new CActivityHallEvent( CActivityHallEvent.TotalRechargeRewardResponse, response.receiveMap.rechargeValue ) );
    }

    //特惠商店信息请求
    public function onDiscounterRequest() : void {
        var request : DiscounterRequest = new DiscounterRequest();
        request.info = 1;

        networking.post( request );
    }

    //特惠商店信息请求返回
    private function _onDiscounterResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;

        var response : DiscounterResponse = message as DiscounterResponse;
        activityHallDataManager.m_personalMap = response.personalMap;
        activityHallDataManager.m_serverMap = response.serverMap;
        system.dispatchEvent( new CActivityHallEvent( CActivityHallEvent.DiscounterResponse ) );
    }

    //特惠商店购买请求
    public function onBuyDiscountGoodsRequest( activityID : int, goodsID : Number, type : int, count : int ) : void {
        var request : BuyDiscountGoodsRequest = new BuyDiscountGoodsRequest();
        request.activityID = activityID;
        request.goodsID = goodsID;
        request.type = type;
        request.count = count;
        networking.post( request );
    }

    private function _onBuyDiscountGoodsResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;

        var response : BuyDiscountGoodsResponse = message as BuyDiscountGoodsResponse;
        if ( response.type == CActivityHallActivityType.SERVER_LIMIT ) activityHallDataManager.m_serverMap = response.Map;
        else if ( response.type == CActivityHallActivityType.PERSON_LIMIT ) activityHallDataManager.m_personalMap = response.Map;
        system.dispatchEvent( new CActivityHallEvent( CActivityHallEvent.BuyDiscountGoodsResponse, response.goodsID ) );
    }

    //活跃任务具体数据返回
    private function _onLivingTaskActivityDataResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;

        var response : LivingTaskActivityDataResponse = message as LivingTaskActivityDataResponse;
        //先清空原有
        activityHallDataManager.m_activeTaskDataArr.splice( 0, activityHallDataManager.m_activeTaskDataArr.length );
        var cfgInfos : Array = activityHallDataManager.getActiveTaskConfigs( response.activityId );
        var cfgInfo : TaskActivity;
        if ( cfgInfos && cfgInfos.length > 0 ) {
            for ( var i : int = 0; i < cfgInfos.length; i++ ) {
                cfgInfo = cfgInfos[ i ] as TaskActivity;
                var activeTaskData : CActiveTaskData = new CActiveTaskData();
                for ( var j : int = 0; j < response.actItems.length; j++ ) {
                    var obj : Object = response.actItems[ j ];
                    if ( cfgInfo.ID == obj.id ) {
                        activeTaskData.config = cfgInfo;
                        activeTaskData.currValue = obj.currVal;
                        activeTaskData.state = obj.state;
                        break;
                    }
                }
                activityHallDataManager.m_activeTaskDataArr.push( activeTaskData );
            }
            system.dispatchEvent( new CActivityHallEvent( CActivityHallEvent.ActiveTaskResponse ) );
        }
    }

    //活跃任务领取奖励返回
    private function _onReceiveLivingTaskActivityRewardResponseHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;

        var response : ReceiveLivingTaskActivityRewardResponse = message as ReceiveLivingTaskActivityRewardResponse;
        var activeTaskData : CActiveTaskData;
        for ( var i : int = 0; i < activityHallDataManager.m_activeTaskDataArr.length; i++ ) {
            activeTaskData = activityHallDataManager.m_activeTaskDataArr[ i ];
            if ( activeTaskData.config.activityId == response.activityId && activeTaskData.config.ID == response.received.id ) {
                activeTaskData.currValue = response.received.currVal;
                activeTaskData.state = response.received.state;
                break;
            }
        }
        system.dispatchEvent( new CActivityHallEvent( CActivityHallEvent.ActiveTaskRewardResponse, response.received.id ) );
    }

    //活跃任务更新事件
    private function _onLivingTaskActivityUpdateEventHandler( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        if ( isError ) return;

        var event : LivingTaskActivityUpdateEvent = message as LivingTaskActivityUpdateEvent;
        var activeTaskData : CActiveTaskData;
        for ( var i : int = 0; i < activityHallDataManager.m_activeTaskDataArr.length; i++ ) {
            activeTaskData = activityHallDataManager.m_activeTaskDataArr[ i ];
            if ( activeTaskData.config.activityId == event.activityId && activeTaskData.config.ID == event.actItem.id ) {
                activeTaskData.currValue = event.actItem.currVal;
                activeTaskData.state = event.actItem.state;
                break;
            }
        }
        system.dispatchEvent( new CActivityHallEvent( CActivityHallEvent.ActiveTaskUpdateEvent ) );
    }

    //活跃任务数据请求
    public function onLivingTaskActivityDataRequest() : void {
        var request : LivingTaskActivityDataRequest = new LivingTaskActivityDataRequest();
        request.flag = 1;
        networking.post( request );
    }

    //领取活跃任务奖励请求
    public function onReceiveLivingTaskActivityRewardRequest( activeId : int, itemId : int ) : void {
        var request : ReceiveLivingTaskActivityRewardRequest = new ReceiveLivingTaskActivityRewardRequest();
        request.activityId = activeId;
        request.itemId = itemId;
        networking.post( request );
    }

    private function get activityHallDataManager() : CActivityHallDataManager {
        return system.getBean( CActivityHallDataManager ) as CActivityHallDataManager;
    }
}
}
