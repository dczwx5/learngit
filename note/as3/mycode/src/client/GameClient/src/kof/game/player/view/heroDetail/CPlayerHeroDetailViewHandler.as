//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/26.
 */
package kof.game.player.view.heroDetail {

import flash.events.Event;
import flash.events.MouseEvent;

import kof.game.common.view.CChildView;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EPlayerWndTabType;
import kof.game.player.view.heroDetail.detail.CPlayerHeroDetailView;
import kof.game.player.view.heroDetail.secret.CPlayerHeroSerectView;

import morn.core.components.Box;

public class CPlayerHeroDetailViewHandler extends CChildView {

    public function CPlayerHeroDetailViewHandler() {
        super([CPlayerHeroDetailView, CPlayerHeroSerectView]);
    }
    protected override function _onCreate() : void {
        // do thing by create
        super._onCreate();
        _curTab = _HERO_DETAIL;
        _ui.to_close_btn.visible = false;
        _ui.to_open_btn.visible = true;
    }
    protected override function _onDispose() : void {
        // dispose
        super._onDispose();
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);

        if (_initialArgs && _initialArgs.length > 0) {
            _selectHeroData = this._initialArgs[0] as CPlayerHeroData;
        }

        if (EPlayerWndTabType.STACK_ID_HERO_DETAIL_WND_INFO == _curTab) {
            detailView.setData([_playerData, _selectHeroData], forceInvalid);
        } else {
            secretView.setData([_playerData, _selectHeroData], forceInvalid);
        }
        _initialArgs = null;
        // selectHeroView.setData(_playerData);
    }
    public override function invalidate() : void {
        super.invalidateWithoutChildren();
        if (EPlayerWndTabType.STACK_ID_HERO_DETAIL_WND_INFO == _curTab) {
            detailView.invalidate();
        } else {
            secretView.invalidate();
        }
    }

    protected override function _onShow():void {
        // do thing when show
        super._onShow();

        _ui.to_close_btn.addEventListener(MouseEvent.CLICK, _onChangeTab);
        _ui.to_open_btn.addEventListener(MouseEvent.CLICK, _onChangeTab);
    }
    protected override function _onHide() : void {
        // do thing when hide
        super._onHide();
        _ui.to_close_btn.removeEventListener(MouseEvent.CLICK, _onChangeTab);
        _ui.to_open_btn.removeEventListener(MouseEvent.CLICK, _onChangeTab);

        _selectHeroData = null;
    }

    public override function updateWindow() : Boolean {
        if (super.updateWindow() == false) return false;
        return true;
    }

    private function _onChangeTab(e:Event) : void {
         var box:Box = e.currentTarget as Box;
        if (box == _ui.to_close_btn) {
            _curTab = _HERO_DETAIL;
            _ui.to_open_btn.visible = true;
            _ui.to_close_btn.visible = false;

        } else {
            _curTab = _HERO_SECRET;
            _ui.to_open_btn.visible = false;
            _ui.to_close_btn.visible = true;
        }

        _ui.viewStack.selectedIndex = _curTab;
        if (_curTab == _HERO_DETAIL) {
            detailView.setData([_playerData, _selectHeroData]);
        } else {
            // 简介
            secretView.setData([_playerData, _selectHeroData]);
        }
    }

    public function get detailView() : CPlayerHeroDetailView { return getChild(_HERO_DETAIL) as CPlayerHeroDetailView; }
    public function get secretView() : CPlayerHeroSerectView { return getChild(_HERO_SECRET) as CPlayerHeroSerectView; }

    private function get _playerData() : CPlayerData {
        return _data as CPlayerData;
    }
    private function get _ui() : Object {
        return (rootUI as Object).viewStack.items[EPlayerWndTabType.STACK_ID_HERO_WND_DETAIL] as Object;
    }
    private function get _detailUI() : Object {
        return _ui.viewStack.items[EPlayerWndTabType.STACK_ID_HERO_DETAIL_WND_INFO] as Object;
    }
    private function get _secretUI() : Object {
        return _ui.viewStack.items[EPlayerWndTabType.STACK_ID_HERO_DETAIL_WND_SECRET] as Object;
    }
    // private static const _SELECT_HERO:int = 0;
    private static const _HERO_DETAIL:int = 0;
    private static const _HERO_SECRET:int = 1;
    private var _selectHeroData:CPlayerHeroData;

    private var _curTab:int;

}
}

