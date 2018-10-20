//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/12/9.
 */
package kof.game.yyHall {

import kof.framework.INetworking;
import kof.game.GMReport.Event.CGMReportEvent;
import kof.game.common.system.CNetHandlerImp;
import kof.game.yyHall.view.CYYHallViewHandler;
import kof.game.yyVip.CYYVipManager;
import kof.game.yyVip.CYYVipSystem;
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

public class CYYHallNetHandler extends CNetHandlerImp {
    public function CYYHallNetHandler()
    {
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

//        bind( PlayerSuggestionResponse, _onGmReportResponseHandler );

        return true;
    }

    /**
     * 添加接收消息侦听
     */
    private function _addNetListeners():void
    {
        networking.bind(PlatformRewardInfoYYResponse).toHandler(_platformRewardInfoYYResponse);
        networking.bind(NewPlayerRewardYYResponse).toHandler(_newPlayerRewardYYResponse);
        networking.bind(LoginRewardYYResponse).toHandler(_loginRewardYYResponse);
        networking.bind(GameLevelRewardYYResponse).toHandler(_gameLevelRewardYYResponse);
        networking.bind(YYLevelRewardResponse).toHandler(_yYLevelRewardResponse);
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
        (system.getBean(CYYHallManager) as CYYHallManager).data.updateData(response);
        //主界面图标小红点
        (system as CYYHallSystem).openMainfunction();

        //把数据存储下来
        (system.stage.getSystem(CYYVipSystem ).getBean(CYYVipManager) as CYYVipManager).data.updateData(response);
        //主界面图标小红点
        (system.stage.getSystem(CYYVipSystem ) as CYYVipSystem).openMainfunction();
//        (system.getBean(CYYHallViewHandler) as CYYHallViewHandler).addDisplay();
        //刷新更新数据后的界面
//        (system.getBean(CYYHallViewHandler) as CYYHallViewHandler)._updateyyState();
    }
    /**
     * YY新手礼包奖励请求
     */
    public function newPlayerRewardYYRequest(info:int):void
    {
//        CArenaState.isInWorship = true;

        var request:NewPlayerRewardYYRequest = new NewPlayerRewardYYRequest();
        request.info = info;
        networking.post(request);
    }
    /**
     * YY新手礼包奖励响应
     */
    private final function _newPlayerRewardYYResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:NewPlayerRewardYYResponse = message as NewPlayerRewardYYResponse;

        //把数据存储下来
        (system.getBean(CYYHallManager) as CYYHallManager).data.newPlayerRewardState = response.receiveState;
        //主界面图标小红点
        (system.stage.getSystem(CYYVipSystem ) as CYYVipSystem).openMainfunction();
        //调用动画
        (system.getBean(CYYHallViewHandler) as CYYHallViewHandler).addBag();
    }

    /**
     * YY登录礼包奖励请求
     */
    public function loginRewardYYRequest(loginDays:int):void
    {
        var request:LoginRewardYYRequest = new LoginRewardYYRequest();
        request.loginDays = loginDays;
        networking.post(request);
    }

    /**
     * YY登录礼包奖励响应
     */
    private final function _loginRewardYYResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:LoginRewardYYResponse = message as LoginRewardYYResponse;

        //把数据存储下来
        (system.getBean(CYYHallManager) as CYYHallManager).data.loginRewardState.push(response.loginDays);
        //主界面图标小红点
        (system.stage.getSystem(CYYVipSystem ) as CYYVipSystem).openMainfunction();
        //调用动画
        (system.getBean(CYYHallViewHandler) as CYYHallViewHandler).addDaysBag(response.loginDays);
    }

    /**
     * YY游戏等级礼包奖励请求
     */
    public function gameLevelRewardYYRequest(gameLevel:int):void
    {
        var request:GameLevelRewardYYRequest = new GameLevelRewardYYRequest();
        request.gameLevel = gameLevel;
        networking.post(request);
    }

    /**
     * YY游戏等级礼包奖励响应
     */
    private final function _gameLevelRewardYYResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:GameLevelRewardYYResponse = message as GameLevelRewardYYResponse;

        //把数据存储下来
        (system.getBean(CYYHallManager) as CYYHallManager).data.gameLevelRewardState.push(response.gameLevel);
        //主界面图标小红点
        (system.stage.getSystem(CYYVipSystem ) as CYYVipSystem).openMainfunction();
        //调用动画
        (system.getBean(CYYHallViewHandler) as CYYHallViewHandler).addLevelRewardBag(response.gameLevel);
    }
    /**
     * YY等级礼包奖励请求
     */
    public function yYLevelRewardRequest(yyLevel:int):void
    {
        var request:YYLevelRewardRequest = new YYLevelRewardRequest();
        request.yyLevel = yyLevel;
        networking.post(request);
    }

    /**
     * YY等级礼包奖励响应
     */
    private final function _yYLevelRewardResponse(net:INetworking,message:CAbstractPackMessage):void
    {
        var response:YYLevelRewardResponse = message as YYLevelRewardResponse;
        //把数据存储下来
        (system.getBean(CYYHallManager) as CYYHallManager).data.yyLevelRewardState.push(response.yyLevel);
        //主界面图标小红点
        (system.stage.getSystem(CYYVipSystem ) as CYYVipSystem).openMainfunction();
        //调用动画
        (system.getBean(CYYHallViewHandler) as CYYHallViewHandler).addYYLevelRewardBag(response.yyLevel);
    }
    /**
     * 提交意见
     */
    public function gmReportRequest(type:int, content:String, qq:String = "", phone:String = "", time:Number = 0):void
    {
        var request:PlayerSuggestionRequest = new PlayerSuggestionRequest();
        request.type = type;
        request.content = content;
        request.qq = qq;
        request.phone = phone;
        request.time = time;
        networking.post(request);
    }

//    private final function _onGmReportResponseHandler( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
//    {
//        if (isError) return ;
//
//        var response : PlayerSuggestionResponse = message as PlayerSuggestionResponse;
//
//        system.dispatchEvent(new CGMReportEvent(CGMReportEvent.ReportSucc, null));
//    }
}
}
