//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/3/28.
 */
package kof.game.player.view.skillup {

import kof.framework.CAppStage;
import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.message.CAbstractPackMessage;
import kof.message.Skill.AddSkillIfoModofyResponse;
import kof.message.Skill.BuySkillPointRequest;
import kof.message.Skill.BuySkillPointResponse;
import kof.message.Skill.OneKeyUpgrateSkillRequest;
import kof.message.Skill.OneKeyUpgrateSkillResponse;
import kof.message.Skill.SkillInfoModofyResponse;
import kof.message.Skill.SkillInfoRequest;
import kof.message.Skill.SkillInfoResponse;
import kof.message.Skill.SkillSlotBreakRequest;
import kof.message.Skill.SkillSlotBreakResponse;
import kof.message.Skill.SkillUpgrateRequest;
import kof.message.Skill.SkillUpgrateResponse;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;

public class CSkillUpHandler extends CNetHandlerImp {
    public function CSkillUpHandler() {
        super();
    }
    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        this.bind(SkillInfoResponse, _onSkillInfoResponseHandler);
        this.bind(SkillUpgrateResponse, _onSkillUpgrateResponseHandler);
        this.bind(SkillSlotBreakResponse, _onSkillSlotBreakResponseHandler);
        this.bind(SkillInfoModofyResponse, _onSkillInfoModofyResponseHandler);
        this.bind(AddSkillIfoModofyResponse, _onAddSkillIfoModofyResponseHandler);
        this.bind(BuySkillPointResponse, _onBuySkillPointResponseHandler);
        this.bind(OneKeyUpgrateSkillResponse, _onOneKeyUpgrateSkillResponseHandler);

//        this.onSkillInfoRequest();
        return ret;
    }
    protected override function enterStage( stage : CAppStage ) : void {
        // NOOP.
        super.enterStage(stage);
        this.onSkillInfoRequest();
    }
    /**********************Request********************************/

    /*技能信息请求*/
    public function onSkillInfoRequest( ):void{
        var request:SkillInfoRequest = new SkillInfoRequest();
        request.decode([1]);

        networking.post(request);
    }
    /*技能升级请求*/
    public function onSkillUpgrateRequest(ID :int , skillID : int ):void{
        var request:SkillUpgrateRequest = new SkillUpgrateRequest();
        request.decode([ID,skillID]);

        networking.post(request);
    }
    /*技能槽突破请求*/
    public function onSkillSlotBreakRequest( ID :int , skillID : int , skillSlotPosition : int ):void{
        var request:SkillSlotBreakRequest = new SkillSlotBreakRequest();
        request.decode([ID,skillID,skillSlotPosition]);

        networking.post(request);
    }
    /*购买技能点请求*/
    public function onBuySkillPointRequest( ):void{
        var request:BuySkillPointRequest = new BuySkillPointRequest();
        request.decode([1]);

        networking.post(request);
    }
    /*一键升级*/
    public function onOneKeyUpgrateSkillRequest( ID : int , skillID : int):void{
        var request:OneKeyUpgrateSkillRequest = new OneKeyUpgrateSkillRequest();
        request.decode([ID,skillID]);

        networking.post(request);
    }


    /**********************Response********************************/

    /*技能信息反馈*/
    private final function _onSkillInfoResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:SkillInfoResponse = message as SkillInfoResponse;
        _playerData.updateSkillListData(response);
        _playerSystem.dispatchEvent(new CPlayerEvent(CPlayerEvent.SKILL_DATA,null));

    }
    /*技能升级反馈*/
    private final function _onSkillUpgrateResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:SkillUpgrateResponse = message as SkillUpgrateResponse;
        if( !response.gamePromptID || response.gamePromptID == 0 )
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert("技能升级成功",CMsgAlertHandler.NORMAL );
        _playerSystem.dispatchEvent(new CPlayerEvent(CPlayerEvent.SKILL_LVUP,null));


    }
    /*技能槽突破反馈*/
    private final function _onSkillSlotBreakResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:SkillSlotBreakResponse = message as SkillSlotBreakResponse;
        if( !response.gamePromptID || response.gamePromptID == 0 )
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert("技能突破成功",CMsgAlertHandler.NORMAL);

        _playerSystem.dispatchEvent(new CPlayerEvent(CPlayerEvent.SKILL_BREAK,null));
    }
    /*技能信息变更反馈*/
    private final function _onSkillInfoModofyResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:SkillInfoModofyResponse = message as SkillInfoModofyResponse;
        _playerData.updateSkillData(response);
        _playerSystem.dispatchEvent(new CPlayerEvent(CPlayerEvent.SKILL_DATA,null));

    }
    /*获取技能反馈*/
    private final function _onAddSkillIfoModofyResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:AddSkillIfoModofyResponse = message as AddSkillIfoModofyResponse;
        _playerData.addSkillData(response);
        _playerSystem.dispatchEvent(new CPlayerEvent(CPlayerEvent.SKILL_ADD,null));

    }
    /*购买技能点反馈*/
    private final function _onBuySkillPointResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:BuySkillPointResponse = message as BuySkillPointResponse;
        if( !response.gamePromptID || response.gamePromptID == 0 ) {
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert("购买招式点成功",CMsgAlertHandler.NORMAL);
            _playerSystem.dispatchEvent(new CPlayerEvent(CPlayerEvent.SKILL_POINT,null));
        }

    }
    /*一键升级反馈*/
    private final function _onOneKeyUpgrateSkillResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:OneKeyUpgrateSkillResponse = message as OneKeyUpgrateSkillResponse;
        if( !response.gamePromptID || response.gamePromptID == 0 )
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert("一键升级成功",CMsgAlertHandler.NORMAL);
        _playerSystem.dispatchEvent(new CPlayerEvent(CPlayerEvent.SKILL_LVUP,null));

    }

    /////////////////////////////
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }
    private function get _playerData() : CPlayerData {
        return (_playerSystem.getBean(CPlayerManager) as CPlayerManager).playerData;
    }

}
}
