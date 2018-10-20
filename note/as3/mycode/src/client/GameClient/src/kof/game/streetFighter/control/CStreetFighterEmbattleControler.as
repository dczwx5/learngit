//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/25.
 */
package kof.game.streetFighter.control {

import kof.game.common.CLang;
import kof.game.common.data.CErrorData;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.streetFighter.enum.EStreetFighterViewEventType;

public class CStreetFighterEmbattleControler extends CStreetFighterControler {
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.removeEventListener(CViewEvent.HIDE, _onHide);
    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.addEventListener(CViewEvent.HIDE, _onHide);

    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        var errorData:CErrorData = null;
        var win:CViewBase;
        var embattleSystem:CEmbattleSystem;
//        var pSystemBundleCtx : ISystemBundleContext;
//        var pSystemBundle : ISystemBundle;
        switch (subType) {
            case EStreetFighterViewEventType.EMBATTLE_ONE_KEY_CLICK :
                bestEmbattleReqeust();
                break;

        }
    }

    public function removeHeroFromEmbattle(heroUID:Number) : void {
        var emListData:CEmbattleListData = playerData.embattleManager.getByType(EInstanceType.TYPE_STREET_FIGHTER);
        var pos:int = emListData.getPosByHero(heroUID);
        if (pos == -1) return ;

        emListData.removeByPos(pos);
        _wnd.invalidate(); // 先本地刷新一下
        (system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem).requestEmbattle(EInstanceType.TYPE_STREET_FIGHTER);
    }

    public function isHeroInEmbattle(heroUID:Number) : Boolean {
        var emListData:CEmbattleListData = playerData.embattleManager.getByType(EInstanceType.TYPE_STREET_FIGHTER);
        var pos:int = emListData.getPosByHero(heroUID);
        return pos != -1;
    }
    public function setHeroInEmbattle(heroUID:Number, heroID:int) : void {
        var emListData:CEmbattleListData = playerData.embattleManager.getByType(EInstanceType.TYPE_STREET_FIGHTER);
        var pos:int = emListData.getPosByHero(heroUID);
        if (pos != -1) return ; // 已在阵容

        if (emListData.list.length >= embattleMaxCount) {
            uiCanvas.showMsgAlert(CLang.Get("common_embattle_full"));
            return ; // 上阵人数已满
        }

        var setPos:int = 1;
        for (var i:int = 1; i <= embattleMaxCount; i++) {
            if (emListData.getByPos(i) == null) {
                setPos = i;
                break;
            }
        }

        var objData:Object = CEmbattleData.getCreateData(heroUID, heroID, setPos);
        emListData.adddData(objData);
        _wnd.invalidate(); // 先本地刷新一下
        (system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem).requestEmbattle(EInstanceType.TYPE_STREET_FIGHTER);
    }

    private function _onHide(e:CViewEvent) : void {

    }

}
}
