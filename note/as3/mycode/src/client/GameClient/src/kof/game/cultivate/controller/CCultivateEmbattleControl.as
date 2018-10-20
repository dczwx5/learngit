//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.cultivate.controller {

import flash.events.Event;

import kof.game.common.CLang;
import kof.game.cultivate.data.cultivate.CCultivateLevelData;
import kof.game.cultivate.enum.ECultivateViewEventType;
import kof.game.common.data.CErrorData;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.embattle.CEmbattleEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerHeroData;

public class CCultivateEmbattleControl extends CCultivateControlerBase {
    public function CCultivateEmbattleControl() {
    }

    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.removeEventListener(CViewEvent.HIDE, _onHide);
        var pEmbattleSystem:CEmbattleSystem = (system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem);
        if (pEmbattleSystem) {
            pEmbattleSystem.removeEventListener(CEmbattleEvent.EMBATTLE_DATA, _onEmbattleData);
        }
    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.addEventListener(CViewEvent.HIDE, _onHide);
        var pEmbattleSystem:CEmbattleSystem = (system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem);
        if (pEmbattleSystem) {
            pEmbattleSystem.addEventListener(CEmbattleEvent.EMBATTLE_DATA, _onEmbattleData);
        }
    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        var errorData:CErrorData = null;
        var win:CViewBase;

        switch (subType) {
            case ECultivateViewEventType.EMBATTLE_CLICK_STRATEGY :
                _processBuff(true);
                break;

            case ECultivateViewEventType.EMBATTLE_FIGHT :
                // fight
                var culLevelData:CCultivateLevelData = e.data as CCultivateLevelData;
                if (_isLevelPass(culLevelData)) {
                    uiCanvas.showMsgAlert(CLang.Get("common_has_pass_level"));
                    return ;
                }
                if (!_isCurrentFightLevel(culLevelData)) {
                    if (climpData.cultivateData.levelList.curOpenLevelIndex > culLevelData.layer) {
                        uiCanvas.showMsgAlert(CLang.Get("cultivate_hass_pass"));
                    } else if (climpData.cultivateData.levelList.curOpenLevelIndex < culLevelData.layer) {
                        uiCanvas.showMsgAlert(CLang.Get("cultivate_not_open"));
                    }
                    return ;
                }
                processFight();
                break;
        }
    }

    // =======================

    public function removeHeroFromEmbattle(heroUID:Number) : void {
        var emListData:CEmbattleListData = playerData.embattleManager.getByType(EInstanceType.TYPE_CLIMP_CULTIVATE);
        var pos:int = emListData.getPosByHero(heroUID);
        if (pos == -1) return ;

        emListData.removeByPos(pos);
        _wnd.invalidate(); // 先本地刷新一下
        (system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem).requestEmbattle(EInstanceType.TYPE_CLIMP_CULTIVATE);
    }
    public function setHeroInEmbattle(heroUID:Number, heroID:int) : void {
        var emListData:CEmbattleListData = playerData.embattleManager.getByType(EInstanceType.TYPE_CLIMP_CULTIVATE);
        var pos:int = emListData.getPosByHero(heroUID);
        if (pos != -1) return ; // 已在阵容

        if (emListData.list.length >= 2) {
            uiCanvas.showMsgAlert(CLang.Get("common_embattle_full"));
            return ; // 上阵人数已满
        }
        var setPos:int = 1;
        if (emListData.getByPos(1) == null) {
            setPos = 1;
        } else {
            emListData.getByPos(2) == null;
            setPos = 2;
        }

//        var emData:CEmbattleData = new CEmbattleData();
        var objData:Object = CEmbattleData.getCreateData(heroUID, heroID, setPos);
//        emData.updateDataByData(objData);
        emListData.adddData(objData);
        _wnd.invalidate(); // 先本地刷新一下
        (system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem).requestEmbattle(EInstanceType.TYPE_CLIMP_CULTIVATE);
    }
    private function _onEmbattleData(e:CEmbattleEvent) : void {
        //
        _wnd.invalidate();
    }

    private function _onHide(E:Event) : void {
        var heroList:Array = playerData.heroList.list;
        for each (var heroData:CPlayerHeroData in heroList) {
            heroData.extendsData = null;
        }
    }

}
}
