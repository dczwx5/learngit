//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/7.
 */
package kof.game.instance.mainInstance {

import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.data.CChapterData;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceData;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.message.CAbstractPackMessage;
import kof.message.Instance.BuyInstanceCountRequest;
import kof.message.Instance.BuyInstanceCountResponse;
import kof.message.Instance.DrawAllStarRewardResponse;
import kof.message.Instance.DrawAllStarRewardResquest;
import kof.message.Instance.DrawInstanceRewardRequest;
import kof.message.Instance.DrawInstanceRewardResponse;
import kof.message.Instance.DrawStarRewardResponse;
import kof.message.Instance.DrawStarRewardResquest;
import kof.message.Instance.InstanceMessageRequest;
import kof.message.Instance.InstanceMessageResponse;
import kof.message.Instance.ModifyInstanceMessageResponse;
import kof.message.Instance.PassInstanceResponse;
import kof.message.Instance.SweepInfoResponse;
import kof.message.Instance.SweepInstanceRequest;

public class CMainInstanceHandler extends CNetHandlerImp {
    public function CMainInstanceHandler() {
        super();
    }

    public override function dispose() : void {
        super.dispose();
    }
    override protected function onSetup():Boolean {
        super.onSetup();

        // 业务
        bind(InstanceMessageResponse, _onInstanceInfoHandler);
        bind(DrawStarRewardResponse, _onChapterGetReward);
        bind(PassInstanceResponse, _onInstancePassRewardResponce);
        bind(ModifyInstanceMessageResponse, _onInstanceModifyRespone);
        bind(DrawInstanceRewardResponse, _onInstanceGetExtendsRewardResponse);
        bind(BuyInstanceCountResponse, _onBuyInstanceCountResponse);
        bind(SweepInfoResponse, _onSweepInfoHandler);
        bind(DrawAllStarRewardResponse, _onGetOneKeyRewardResponse);

        sendInstanceInfo();
        return true;
   }
    // ======================================S2C=============================================

    // =================================系统功能=====================================
    // 副本信息反馈, 通关哪些副本等.
    private final function _onInstanceInfoHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;

        var response:InstanceMessageResponse = message as InstanceMessageResponse;
        _instanceSystem.instanceManager.dataManager.instanceData.updateDataByData(response);
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.INSTANCE_DATA, _instanceSystem.instanceManager.dataManager.instanceData));
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.INSTANCE_DATA_INITIAL, _instanceSystem.instanceManager.dataManager.instanceData));

        // 写完第一关通关指引
        var instanceData:CChapterInstanceData = _instanceSystem.instanceManager.dataManager.instanceData.instanceList.getFirstInstance(EInstanceType.TYPE_MAIN);
        _instanceSystem.instanceManager.dataManager.instanceData.isFirstLevelPass = instanceData.isCompleted;
    }
    // 章节, 领取星级奖励反馈
    private final function _onChapterGetReward(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;

        var response:DrawStarRewardResponse = message as DrawStarRewardResponse;
        _instanceSystem.instanceManager.dataManager.instanceData.updateChapterRewardData(response);
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.CHAPTER_REWARD, _instanceSystem.instanceManager.dataManager.instanceData));
    }


    // 副本信息变更反馈
    private final function _onInstanceModifyRespone(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;

        // 首次完成副本
        var fightInstanceData:CChapterInstanceData = _instanceSystem.instanceManager.fightingInstanceMessage.instanceData;
        var isInstancePassBefore:Boolean = _instanceSystem.instanceManager.fightingInstanceMessage.isPassBefore;

        var pInstanceData:CInstanceData = _instanceSystem.instanceManager.dataManager.instanceData;
        var response:ModifyInstanceMessageResponse = message as ModifyInstanceMessageResponse;
        var lastOpenChapter:CChapterData = pInstanceData.getLastChapterData(EInstanceType.TYPE_MAIN);
        var isLastChapterFinish:Boolean = pInstanceData.instanceList.isChapterInstanceAllFinish(EInstanceType.TYPE_MAIN, lastOpenChapter.chapterID);

        pInstanceData.updateDataByData(response);

        // 首次完成副本
        if (!isInstancePassBefore && fightInstanceData && fightInstanceData.isCompleted) {
            var fightInstanceID:int = fightInstanceData.instanceID;
            var curInstanceID:int = 0;
            if (response.instanceMessageList && response.instanceMessageList.length > 0) {
                curInstanceID = response.instanceMessageList[0]["instanceID"];
                if (fightInstanceID == curInstanceID) {
                    // 首次完成副本
                    system.dispatchEvent(new CInstanceEvent(CInstanceEvent.INSTANCE_FIRST_PASS, fightInstanceData));
                    // 这里还有一个隐患, 如果打完某个剧情副本。(首通), 然后扫荡。也会有问题。只不过。剧情副本扫荡不会有该协议。所以没问题
                }
            }
        }


        if (lastOpenChapter) {
            var curOpenChapter:CChapterData = pInstanceData.getLastChapterData(EInstanceType.TYPE_MAIN);
            if (curOpenChapter.chapterID != lastOpenChapter.chapterID && curOpenChapter.chapterID > lastOpenChapter.chapterID) {
                // 章节完成, 开启新章节
                pInstanceData.mainChapterOpenFlag = true;
                system.dispatchEvent(new CInstanceEvent(CInstanceEvent.INSTANCE_CHAPTER_FINISH, pInstanceData));
            } else {
                // 章节完成 - 最后一章
                if (!isLastChapterFinish) {
                    var isCurChapterFinish:Boolean = pInstanceData.instanceList.isChapterInstanceAllFinish(EInstanceType.TYPE_MAIN, lastOpenChapter.chapterID);
                    if (isCurChapterFinish) {
                        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.INSTANCE_CHAPTER_FINISH, pInstanceData));
                    }
                }
            }
        }

        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.INSTANCE_MODIFY, pInstanceData));
    }

    // 领取副本宝箱奖励
    private final function _onInstanceGetExtendsRewardResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;

        var response:DrawInstanceRewardResponse = message as DrawInstanceRewardResponse;
        _instanceSystem.instanceManager.dataManager.instanceData.updateInstanceExtendsRewardData(response);
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.INSTANCE_GET_EXTENDS_REWARD, _instanceSystem.instanceManager.dataManager.instanceData));
    }

    // 购买副本次数反馈
    private final function _onBuyInstanceCountResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;

        var response:BuyInstanceCountResponse = message as BuyInstanceCountResponse;
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.INSTANCE_BUY_COUNT, _instanceSystem.instanceManager.dataManager.instanceData));
    }

    // 扫荡信息反馈
    private final function _onSweepInfoHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;

        var response:SweepInfoResponse = message as SweepInfoResponse;
        _instanceSystem.instanceManager.dataManager.instanceData.updateSweepData(response);
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.INSTANCE_SWEEP_DATA, _instanceSystem.instanceManager.dataManager.instanceData.lastSweepData));
    }

    // 通关副本信息反馈, 奖励
    private final function _onInstancePassRewardResponce(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;

        var response:PassInstanceResponse = message as PassInstanceResponse;
        var data:Object = {};
        data["level"] = response.level;
        data["star"] = response.star;
        data["passTime"] = response.passTime; // 1 : 时间的星级条件满足, 0 : 时间的星级条件不满足
        data["rewardList"] = response.rewardList;
        _instanceSystem.instanceManager.dataManager.instanceData.updateInstancePassRewardData(data);
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.INSTANCE_PASS_REWARD, _instanceSystem.instanceManager.dataManager.instanceData));
    }
    private final function _onGetOneKeyRewardResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:DrawAllStarRewardResponse = message as DrawAllStarRewardResponse;
        _instanceSystem.instanceManager.dataManager.instanceData.updateOneKeyRewardData(response.datas as Array);
        var updateList:Array = _instanceSystem.instanceManager.dataManager.instanceData.lastOneKeyReward.itemList;
        _instanceSystem.instanceManager.dataManager.instanceData.updateChapterRewardListData(updateList);
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.INSTANCE_GET_ONE_KEY_REWARD, _instanceSystem.instanceManager.dataManager.instanceData.lastSweepData));
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.INSTANCE_DATA, _instanceSystem.instanceManager.dataManager.instanceData));
    }

    // ======================================C2S=============================================

    // 获取副本信息
    public function sendInstanceInfo() : void {
        var request:InstanceMessageRequest = new InstanceMessageRequest();
        request.flag = true;
        networking.post(request);
    }
    //开始扫荡请求
    public function sendSweepInstance(instanceID:int, count:int) : void {
        if (instanceID <= 0 || count <= 0) return ;

        var request:SweepInstanceRequest = new SweepInstanceRequest();
        request.num = count;
        request.instanceID = instanceID;
        networking.post(request);
    }

    // 章节, 领取星级奖励请求
    public function sendChapterGetReward(chapterID:int, rewardIndex:int) : void {
        var request:DrawStarRewardResquest = new DrawStarRewardResquest();
        request.chapterID = chapterID;
        request.rewardIndex = rewardIndex;
        networking.post(request);
    }

    // 购买副本次数请求
    public function sendBuyInstanceCount(instanceID:int) : void {
        var request:BuyInstanceCountRequest = new BuyInstanceCountRequest();
        request.instanceID = instanceID;
        networking.post(request);
    }

    // 副本宝箱奖励请求
    public function sendGetExtendsReward(instanceID:int) : void {
        var request:DrawInstanceRewardRequest = new DrawInstanceRewardRequest();
        request.instanceID = instanceID;
        networking.post(request);
    }

    public var lastInstanceTypeByOneKeyReward:int; // 记录最后一次发请求的副本类型, 因为服务器回协议时，没带type
    public function sendGetOneKeyReward(instanceType:int) : void {
        lastInstanceTypeByOneKeyReward = instanceType;
        var request:DrawAllStarRewardResquest = new DrawAllStarRewardResquest();
        request.type = instanceType;
        networking.post(request);
//        testOneKeyRewardResponse();
    }


    private function get _instanceSystem() : CInstanceSystem {
        return system as CInstanceSystem;
    }
}
}