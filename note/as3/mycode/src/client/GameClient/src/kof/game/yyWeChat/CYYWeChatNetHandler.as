//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/3/9.
 */
package kof.game.yyWeChat {

import kof.framework.INetworking;
import kof.game.GMReport.Event.CGMReportEvent;
import kof.game.common.system.CNetHandlerImp;
import kof.game.yyHall.view.CYYHallViewHandler;
import kof.message.ActivationCode.ActivationCodeRequest;
import kof.message.ActivationCode.ActivationCodeResponse;
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
public class CYYWeChatNetHandler extends CNetHandlerImp {
    public function CYYWeChatNetHandler() {
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

        return true;
    }

    /**
     * 序列号请求
     */
    public function serialNumberRequest(info:String):void
    {
        var request:ActivationCodeRequest = new ActivationCodeRequest();
        request.cid = info;
        networking.post(request);
    }

}
}
