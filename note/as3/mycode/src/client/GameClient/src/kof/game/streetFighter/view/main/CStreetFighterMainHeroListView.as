//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/23.
 */
package kof.game.streetFighter.view.main {

import flash.events.Event;
import flash.events.MouseEvent;

import kof.game.common.view.CChildView;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.enum.EStreetFighterViewEventType;
import kof.game.streetFighter.view.CStreetFighterViewUtil;
import kof.ui.master.StreetFighter.StreetFighterUI;

import morn.core.components.Component;

import morn.core.handlers.Handler;


public class CStreetFighterMainHeroListView extends CChildView {
    public function CStreetFighterMainHeroListView() {
    }
    protected override function _onCreate() : void {

    }
    protected override function _onDispose() : void {
        // can not call super._onDispose in this class
    }
    protected override function _onShow():void {
        // can not call super._onShow in this class
        _ui.heroList.renderHandler = new Handler(_onRenderHeroItem);
        _ui.heroList.mouseHandler = new Handler(_onOpenEmbattleView);
    }

    protected override function _onHide() : void {
        // can not call super._onHide in this class
        _ui.heroList.renderHandler = null;
    }
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var embattleData:CEmbattleListData = _playerData.embattleManager.getByType(EInstanceType.TYPE_STREET_FIGHTER);
        if (_streetData.alreadyStartFight == false) {
            if (embattleData.childList.length == 0) {
                // 空数据 , 需要自动布阵
                _ui.heroList.dataSource = [];
                sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStreetFighterViewEventType.MAIN_AUTO_SET_BEST_EMBATTLE));
            } else {
                _ui.heroList.dataSource = embattleData.childList;
            }
        } else {
            _ui.heroList.dataSource = embattleData.childList;
        }

        return true;
    }

    private function _onRenderHeroItem(comp:Component, idx:int) : void {
        CStreetFighterViewUtil._onRenderHeroItem(_playerData, comp, idx, new Handler(_onOpenEmbattleView), _streetData, true);
    }

    private function _onOpenEmbattleView(e:Event = null, idx:int = 0) : void {
        if (e && e.type != MouseEvent.CLICK) {
            return ;
        }
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStreetFighterViewEventType.MAIN_EMBATTLE_CLICK));
    }


    [Inline]
    private function get _ui() : StreetFighterUI {
        return rootUI as StreetFighterUI;
    }
    [Inline]
    private function get _streetData() : CStreetFighterData {
        return super._data[0] as CStreetFighterData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }
}
}
