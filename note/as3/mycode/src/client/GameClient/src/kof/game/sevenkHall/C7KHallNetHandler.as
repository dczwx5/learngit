//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/1/18.
 */
package kof.game.sevenkHall {

import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.sevenkHall.event.C7K7KEvent;
import kof.message.CAbstractPackMessage;
import kof.message.PlatformReward.EverydayReward7k7kRequest;
import kof.message.PlatformReward.EverydayReward7k7kResponse;
import kof.message.PlatformReward.LevelUpReward7k7kRequest;
import kof.message.PlatformReward.LevelUpReward7k7kResponse;
import kof.message.PlatformReward.NewPlayerReward7k7kRequest;
import kof.message.PlatformReward.NewPlayerReward7k7kResponse;
import kof.message.PlatformReward.PlatformRewardInfo7k7kRequest;
import kof.message.PlatformReward.PlatformRewardInfo7k7kResponse;

public class C7KHallNetHandler extends CNetHandlerImp {
    public function C7KHallNetHandler()
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

        bind( PlatformRewardInfo7k7kResponse, _on7K7KRewarsInfoResponseHandler);
        bind( EverydayReward7k7kResponse, _onEveryDayResponseHandler);
        bind( NewPlayerReward7k7kResponse, _onNewRewardResponseHandler);
        bind( LevelUpReward7k7kResponse, _onLevelRewardResponseHandler);

        return true;
    }

//==================================================================================>>
    /**
     * 7k7k奖励状态信息
     */
    public function get7K7KRewardsInfo():void
    {
        var request:PlatformRewardInfo7k7kRequest = new PlatformRewardInfo7k7kRequest();
        request.info = 1;
        networking.post(request);
    }

    private final function _on7K7KRewarsInfoResponseHandler( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : PlatformRewardInfo7k7kResponse = message as PlatformRewardInfo7k7kResponse;

        (system.getHandler(C7KHallManager) as C7KHallManager).updateRewardsState(response);

        system.dispatchEvent(new C7K7KEvent(C7K7KEvent.UpdateAllRewardInfo, null));

    }
//<<===================================================================================


//====================================================================================>>
    /**
     * 7k7k领取每日奖励
     */
    public function takeEveryDayReward(vipType:int):void
    {
        var request:EverydayReward7k7kRequest = new EverydayReward7k7kRequest();
        request.vipType = vipType;
        networking.post(request);
    }

    private final function _onEveryDayResponseHandler( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : EverydayReward7k7kResponse = message as EverydayReward7k7kResponse;

        (system.getHandler(C7KHallManager) as C7KHallManager).updateDailyRewardState(response);

        system.dispatchEvent(new C7K7KEvent(C7K7KEvent.UpdateDailyRewardState, null));

    }
//<<===================================================================================


//====================================================================================>>
    /**
     * 7k7k领取新手奖励
     */
    public function takeNewReward():void
    {
        var request:NewPlayerReward7k7kRequest = new NewPlayerReward7k7kRequest();
        request.info = 1;
        networking.post(request);
    }

    private final function _onNewRewardResponseHandler( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : NewPlayerReward7k7kResponse = message as NewPlayerReward7k7kResponse;

        (system.getHandler(C7KHallManager) as C7KHallManager).updateNewRewardState(response);

        system.dispatchEvent(new C7K7KEvent(C7K7KEvent.UpdateNewRewardState, null));

    }
//<<===================================================================================


//====================================================================================>>
    /**
     * 7k7k领取等级奖励
     */
    public function takeLevelReward(level:int):void
    {
        var request:LevelUpReward7k7kRequest = new LevelUpReward7k7kRequest();
        request.level = level;
        networking.post(request);
    }

    private final function _onLevelRewardResponseHandler( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : LevelUpReward7k7kResponse = message as LevelUpReward7k7kResponse;

        (system.getHandler(C7KHallManager) as C7KHallManager).updateLevelRewardState(response);

        system.dispatchEvent(new C7K7KEvent(C7K7KEvent.UpdateLevelRewardState, response.level));
    }
//<<===================================================================================
}
}
