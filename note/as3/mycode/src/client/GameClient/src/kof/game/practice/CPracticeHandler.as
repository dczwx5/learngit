//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2017/11/29.
 */
package kof.game.practice {

import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.message.CAbstractPackMessage;
import kof.message.Instance.ChangePracticeRobotHeroRequest;
import kof.message.Instance.ChangePracticeRobotHeroResponse;
import kof.message.Instance.ChangePracticeSelfHeroRequest;
import kof.message.Instance.ChangePracticeSelfHeroResponse;
import kof.message.Instance.PracticeHeroInfosResponse;
import kof.message.Instance.PracticeResetRequest;
import kof.message.Instance.StartPracticeRequest;
import kof.message.Instance.StartPracticeResponse;

public class CPracticeHandler extends CNetHandlerImp {
    public function CPracticeHandler() {
        super();
    }
    override protected function onSetup():Boolean
    {
        var ret:Boolean = super.onSetup();
        _addEventListeners();
        return ret;
    }

    private function _addEventListeners():void
    {
        networking.bind(PracticeHeroInfosResponse).toHandler(_onPracticeHeroInfosResponse);
        networking.bind(StartPracticeResponse).toHandler(_onStartPracticeResponse);
        networking.bind(ChangePracticeSelfHeroResponse).toHandler(_onChangePracticeSelfHeroResponse);
        networking.bind(ChangePracticeRobotHeroResponse).toHandler(_onChangePracticeRobotHeroResponse);
    }

    private function _onChangePracticeRobotHeroResponse(net:INetworking, message:CAbstractPackMessage):void{
        var response:ChangePracticeRobotHeroResponse = message as ChangePracticeRobotHeroResponse;
    }

    private function _onChangePracticeSelfHeroResponse(net:INetworking, message:CAbstractPackMessage):void{
        var response:ChangePracticeSelfHeroResponse = message as ChangePracticeSelfHeroResponse;
    }

    private function _onPracticeHeroInfosResponse(net:INetworking, message:CAbstractPackMessage):void{
        var response:PracticeHeroInfosResponse = message as PracticeHeroInfosResponse;
        (system as CPracticeSystem).heroList = response.opponentHeroList;
    }

    private function _onStartPracticeResponse(net:INetworking, message:CAbstractPackMessage):void{
        var response:StartPracticeResponse = message as StartPracticeResponse;
    }

    public function practiceResetRequest(type:int):void{
        var passedEvent:PracticeResetRequest = new PracticeResetRequest();

        passedEvent.flag = type;
        networking.post(passedEvent);
    }
    public function enterPractice():void{
        var passedEvent:StartPracticeRequest = new StartPracticeRequest();
        passedEvent.flag = 1;
        networking.post(passedEvent);
    }

    //更换自己角色
    public function changePracticeSelfHeroRequest(profession:int):void{
        var passedEvent:ChangePracticeSelfHeroRequest = new ChangePracticeSelfHeroRequest();
        passedEvent.profession = profession;
        networking.post(passedEvent);
    }

    //更换对手角色
    public function changePracticeRobotHeroRequest(ID:int):void{
        var passedEvent:ChangePracticeRobotHeroRequest = new ChangePracticeRobotHeroRequest();
        passedEvent.ID = ID;
        networking.post(passedEvent);
    }
}
}
