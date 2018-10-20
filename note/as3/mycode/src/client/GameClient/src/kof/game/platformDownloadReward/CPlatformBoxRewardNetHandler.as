//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/13.
 */
package kof.game.platformDownloadReward {

import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.platformDownloadReward.event.CPlatformBoxRewardEvent;
import kof.message.CAbstractPackMessage;
import kof.message.PlatformReward.GetBoxLoginReward2144Request;
import kof.message.PlatformReward.GetBoxLoginReward2144Response;
import kof.message.PlatformReward.PlatformRewardInfo2144Request;
import kof.message.PlatformReward.PlatformRewardInfo2144Response;

public class CPlatformBoxRewardNetHandler extends CNetHandlerImp {
    public function CPlatformBoxRewardNetHandler()
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

        bind( PlatformRewardInfo2144Response, _onPlatformRewardInfoResponse);
        bind( GetBoxLoginReward2144Response, _onGetPlatformRewardResponseHandler);

        return true;
    }

//==================================================================================>>
    /**
     * 2144平台礼包奖励信息
     */
    public function platformRewardInfo():void
    {
        var request:PlatformRewardInfo2144Request = new PlatformRewardInfo2144Request();
        request.info = 1;
        networking.post(request);
    }

    private final function _onPlatformRewardInfoResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : PlatformRewardInfo2144Response = message as PlatformRewardInfo2144Response;
        if(response)
        {
            _manager.rewardTakeState = response.boxLoginRewardState;

            system.dispatchEvent(new CPlatformBoxRewardEvent(CPlatformBoxRewardEvent.RewardInfo, null));
        }
    }
//<<===================================================================================


//==================================================================================>>
    /**
     * 领取2144平台礼包奖励
     */
    public function getPlatformReward():void
    {
        var request:GetBoxLoginReward2144Request = new GetBoxLoginReward2144Request();
        request.info = 1;
        networking.post(request);
    }

    private final function _onGetPlatformRewardResponseHandler( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GetBoxLoginReward2144Response = message as GetBoxLoginReward2144Response;
        if(response)
        {
            _manager.rewardTakeState = response.boxLoginRewardState;

            system.dispatchEvent(new CPlatformBoxRewardEvent(CPlatformBoxRewardEvent.GetRewardSucc, null));
        }
    }
//<<===================================================================================

    private function get _manager():CPlatformBoxRewardManager
    {
        return system.getHandler(CPlatformBoxRewardManager) as CPlatformBoxRewardManager;
    }
}
}
