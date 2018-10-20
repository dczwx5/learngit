//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/3/8.
 */
package kof.game.yyVip {

import kof.framework.INetworking;
import kof.game.GMReport.Event.CGMReportEvent;
import kof.game.common.system.CNetHandlerImp;
import kof.game.yyHall.view.CYYHallViewHandler;
import kof.game.yyVip.view.CYYVipViewHandler;
import kof.message.CAbstractPackMessage;
import kof.message.PlatformReward.BuyVipDayWelfareYYRequest;
import kof.message.PlatformReward.BuyVipDayWelfareYYResponse;
import kof.message.PlatformReward.BuyVipWeekWelfareYYRequest;
import kof.message.PlatformReward.BuyVipWeekWelfareYYResponse;
import kof.message.PlatformReward.GameLevelRewardYYRequest;
import kof.message.PlatformReward.GameLevelRewardYYResponse;
import kof.message.PlatformReward.LoginRewardYYRequest;
import kof.message.PlatformReward.LoginRewardYYResponse;
import kof.message.PlatformReward.NewPlayerRewardYYRequest;
import kof.message.PlatformReward.NewPlayerRewardYYResponse;
import kof.message.PlatformReward.PlatformRewardInfoYYRequest;
import kof.message.PlatformReward.PlatformRewardInfoYYResponse;
import kof.message.PlatformReward.YYLevelRewardRequest;
import kof.message.PlatformReward.YYLevelRewardResponse;
import kof.message.PlatformReward.YYVipLevelRewardRequest;
import kof.message.PlatformReward.YYVipLevelRewardResponse;
import kof.message.Suggestion.PlayerSuggestionRequest;
import kof.message.Suggestion.PlayerSuggestionResponse;
public class CYYVipNetHandler extends CNetHandlerImp {
    public function CYYVipNetHandler() {
        super();
    }

    public override function dispose() : void
    {
        super.dispose();
    }

    override protected function onSetup() : Boolean
    {
        super.onSetup();

        var ret:Boolean = super.onSetup();
        _addNetListeners();

        return true;
    }


    /**
     * 添加接收消息侦听
     */
    private function _addNetListeners():void
    {
//        networking.bind(PlatformRewardInfoYYResponse).toHandler(_platformRewardInfoYYResponse);
        networking.bind(YYVipLevelRewardResponse).toHandler(_yYVipLevelRewardResponse);
        networking.bind(BuyVipDayWelfareYYResponse).toHandler(_buyVipDayWelfareYYResponse);
        networking.bind(BuyVipWeekWelfareYYResponse).toHandler(_buyVipWeekWelfareYYResponse);
    }

    /**
     * YY平台奖励信息请求
     */
    public function platformRewardInfoYYRequest(info:int = 1):void
    {
        var request:PlatformRewardInfoYYRequest = new PlatformRewardInfoYYRequest();
        request.info = info;
        networking.post(request);
    }

    /**
     * YY平台奖励信息响应
     */
    private final function _platformRewardInfoYYResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:PlatformRewardInfoYYResponse = message as PlatformRewardInfoYYResponse;
        //把数据存储下来
        (system.getBean(CYYVipManager) as CYYVipManager).data.updateData(response);
        //主界面图标小红点
        (system as CYYVipSystem).openMainfunction();
//        (system.getBean(CYYHallViewHandler) as CYYHallViewHandler).addDisplay();
        //刷新更新数据后的界面
//        (system.getBean(CYYHallViewHandler) as CYYHallViewHandler)._updateyyState();
    }

    /**
     * YY会员等级礼包奖励请求
     */
    public function yYVipLevelRewardRequest(vipLevel:int):void
    {
        var request:YYVipLevelRewardRequest = new YYVipLevelRewardRequest();
        request.vipLevel = vipLevel;
        networking.post(request);
    }

    /**
     * YY会员等级礼包奖励响应
     */
    private final function _yYVipLevelRewardResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:YYVipLevelRewardResponse = message as YYVipLevelRewardResponse;
        //把数据存储下来
        (system.getBean(CYYVipManager) as CYYVipManager).data.yyVipLevelRewardState.push(response.vipLevel);
        //调用动画
        (system.getBean(CYYVipViewHandler) as CYYVipViewHandler).addBag();
    }
    /**
     * 购买YY会员日常礼包请求
     */
    public function buyVipDayWelfareYYRequest(vipLevel:int):void
    {
        var request:BuyVipDayWelfareYYRequest = new BuyVipDayWelfareYYRequest();
        request.vipLevel = vipLevel;
        networking.post(request);
    }
    /**
     * 购买YY会员日常礼包响应
     */
    private final function _buyVipDayWelfareYYResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:BuyVipDayWelfareYYResponse = message as BuyVipDayWelfareYYResponse;
        //把数据存储下来
        (system.getBean(CYYVipManager) as CYYVipManager).data.dayWelfareState.push(response.vipLevel);
        //调用动画
        (system.getBean(CYYVipViewHandler) as CYYVipViewHandler).addDaysBag(response.vipLevel);
    }
    /**
     * 购买YY会员周礼包请求
     */
    public function buyVipWeekWelfareYYRequest(vipLevel:int):void
    {
        var request:BuyVipWeekWelfareYYRequest = new BuyVipWeekWelfareYYRequest();
        request.vipLevel = vipLevel;
        networking.post(request);
    }
    /**
     * 购买YY会员周礼包响应
     */
    private final function _buyVipWeekWelfareYYResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:BuyVipWeekWelfareYYResponse = message as BuyVipWeekWelfareYYResponse;
        //把数据存储下来
        (system.getBean(CYYVipManager) as CYYVipManager).data.weekWelfareState.push(response.vipLevel);
        //调用动画
        (system.getBean(CYYVipViewHandler) as CYYVipViewHandler).addWeekBag(response.vipLevel);
    }

}
}
