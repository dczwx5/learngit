//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/12/9.
 */
package kof.game.GMReport {

import kof.framework.INetworking;
import kof.game.GMReport.Event.CGMReportEvent;
import kof.game.common.system.CNetHandlerImp;
import kof.message.CAbstractPackMessage;
import kof.message.Suggestion.PlayerSuggestionRequest;
import kof.message.Suggestion.PlayerSuggestionResponse;

public class CGMReportNetHandler extends CNetHandlerImp {
    public function CGMReportNetHandler()
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

        bind( PlayerSuggestionResponse, _onGmReportResponseHandler );

        return true;
    }

    /**
     * 提交意见
     */
    public function gmReportRequest(type:int, content:String, qq:String = "", phone:String = "", time:Number = 0, fightUID:String = ""):void
    {
        var request:PlayerSuggestionRequest = new PlayerSuggestionRequest();
        request.type = type;
        request.content = content;
        request.qq = qq;
        request.phone = phone;
        request.time = time;
        request.fightUUID = fightUID;
        networking.post(request);
    }

    private final function _onGmReportResponseHandler( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : PlayerSuggestionResponse = message as PlayerSuggestionResponse;

        system.dispatchEvent(new CGMReportEvent(CGMReportEvent.ReportSucc, null));
    }
}
}
