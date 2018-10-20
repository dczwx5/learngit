//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/26.
 */
package kof.game.player.view.player {

import flash.display.DisplayObject;
import flash.events.Event;

import kof.framework.CAppSystem;
import kof.game.common.hero.CHeroListView;
import kof.game.common.view.CRootView;
import kof.game.common.view.CViewBase;
import kof.game.player.data.CPlayerData;
import kof.game.player.enum.EPlayerWndResType;
import kof.game.player.enum.EPlayerWndTabType;
import kof.game.player.view.equipmentTrain.CEquipmentTrainViewHandler;
import kof.game.player.view.heroDetail.CPlayerHeroDetailViewHandler;
import kof.game.player.view.heroList.CPlayerHeroListViewHandler;
import kof.game.player.view.playerTrain.CPlayerHeroTrainViewHandler;
import kof.game.player.view.skillup.CSkillUpViewHandler;

public class CPlayerHeroView extends CRootView {

    public function CPlayerHeroView() {
        super(Object,[CHeroListView, CPlayerHeroListViewHandler,
            CPlayerHeroDetailViewHandler, CPlayerHeroTrainViewHandler, CEquipmentTrainViewHandler, CSkillUpViewHandler], EPlayerWndResType.HERO_MAIN, false);
    }
    protected override function _onCreate() : void {
        // do thing by create
        super._onCreate();

        _tabViewList = new Array(5);
        _tabViewList[EPlayerWndTabType.STACK_ID_HERO_WND_LIST] = heroListView;
        _tabViewList[EPlayerWndTabType.STACK_ID_HERO_WND_DETAIL] = heroDetail;
        _tabViewList[EPlayerWndTabType.STACK_ID_HERO_WND_TRAIN] = heroTrainsView;
        _tabViewList[EPlayerWndTabType.STACK_ID_HERO_WND_EQUIP_TRAIN] = equipTrainsView;
        _tabViewList[EPlayerWndTabType.STACK_ID_HERO_SKILL_UP] = skillUpView;
    }

    protected override function _onDispose() : void {
        // dispose
        super._onDispose();
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        // 不要所有的都setData
        if (_initialArgs && _initialArgs.length > 1) {
            heroListSelectView.setArgs([super._initialArgs[1]]);
        }
        _playerData.heroList.sort();
        heroListSelectView.setData(_playerData.heroList.list, forceInvalid);
    }

    // 只刷新相应的界面
    public override function invalidate() : void {
        super.invalidateWithoutChildren();
        var tab:int = _ui.viewStack.selectedIndex;
        var view:CViewBase = _tabViewList[tab];
        if (view.getData() == null) {
            _setTabData(tab);
        }
        if (view.getData() != null) {
            view.invalidate();
        }

        if (heroListSelectView.getData() != null) {
            heroListSelectView.invalidate();
        }
    }

    protected override function _onShow():void {
        // do thing when show
        super._onShow();

        _isFirst = true;
        _ui.tab_list.addEventListener(Event.CHANGE, _onChangeTab);
    }
    protected override function _onShowing() : void {

    }
    protected override function _onHide() : void {
        // do thing when hide
        super._onHide();
        _ui.tab_list.removeEventListener(Event.CHANGE, _onChangeTab);
    }

    public override function updateWindow() : Boolean {
        if (super.updateWindow() == false) return false;

        if (_isFirst) {
            _isFirst = false;
            _ui.visible = false;
            this.addTick(_onTick); // 下帧热行， 不然会有问题，heroListView还没创建列表
        }

        this.addToDialog();

        return true;
    }
    private function _onTick(delta:Number) : void {
        removeTick(_onTick);
        _ui.visible = true;
        var tab:int = EPlayerWndTabType.STACK_ID_HERO_WND_LIST;
        var heroID:int = -1;
        if (_initialArgs) {
            if (_initialArgs.length > 0 && _initialArgs[0] != -1) {
                tab = _initialArgs[0];
            }
            if (_initialArgs.length > 1 && _initialArgs[1] != -1) {
                heroID = _initialArgs[1];
            }
        } else {
            if (_ui.tab_list.selectedIndex != -1) {
                tab = _ui.tab_list.selectedIndex;
            }
        }

        changeTab(tab, heroID);
    }

    // 和invalidate 不同, invalidate使用当前data设置
    public function refreshView(tab:int) : void {
        _setTabData(tab);
    }
    // 从其他界面打开子界面
    public function changeTab(tab:int, heroID:int) : void {
        if (heroID > 0) {
            heroListSelectView.selectHero = heroID;
        }

        _ui.tab_list.selectedIndex = tab;
    }

    // =========================event=========================

    private function _onChangeTab(e:Event) : void {
        _onChangeTabB(_ui.tab_list.selectedIndex);
    }
    // 直接调用setTab, 不会改变tabList
    // 调用tab_list.selectedIndex会改变tabList, 同时高用setTab
    private function _onChangeTabB(tab:int) : void {
        _ui.viewStack.selectedIndex = tab;
        if (tab == EPlayerWndTabType.STACK_ID_HERO_WND_LIST) {
            heroListSelectView.visible = false;
            _ui.hero_list_bg_img.visible = false;
        } else {
            heroListSelectView.visible = true;
            _ui.hero_list_bg_img.visible = true;
        }
        _setTabData(tab);
    }
    private function _setTabData(tab:int) : void {
        var curTab:int = _ui.tab_list.selectedIndex;
        if (curTab != tab) return ;

        var heroTrainsData:Array;
        if (tab == EPlayerWndTabType.STACK_ID_HERO_WND_LIST) {
            heroListView.setData(_playerData);
        } else  if (tab == EPlayerWndTabType.STACK_ID_HERO_WND_DETAIL) {
            heroDetail.setArgs([heroListSelectView.selectHeroData]);
            heroDetail.setData(_playerData);
        } else if (tab == EPlayerWndTabType.STACK_ID_HERO_WND_TRAIN) {
            heroTrainsData = CTrainDataUtil.getTrainData(uiCanvas as CAppSystem, _playerData, heroListSelectView.selectHeroData.prototypeID);
            heroTrainsView.setData(heroTrainsData);
        }  else if (tab == EPlayerWndTabType.STACK_ID_HERO_WND_EQUIP_TRAIN) {
            heroTrainsData = CTrainDataUtil.getEquipTrainData(uiCanvas as CAppSystem, _playerData, heroListSelectView.selectHeroData.prototypeID);
            equipTrainsView.setData(heroTrainsData);
        }
        else if (tab == EPlayerWndTabType.STACK_ID_HERO_SKILL_UP) {
            skillUpView.setArgs([heroListSelectView.selectHeroData]);
            skillUpView.setData(_playerData);
        }
    }

    public function get heroListSelectView() : CHeroListView { return this.getChild(0) as CHeroListView; }
    public function get heroListView() : CPlayerHeroListViewHandler { return this.getChild(1) as CPlayerHeroListViewHandler; }
    public function get heroDetail() : CPlayerHeroDetailViewHandler { return this.getChild(2) as CPlayerHeroDetailViewHandler; }
    public function get heroTrainsView() : CPlayerHeroTrainViewHandler { return this.getChild(3) as CPlayerHeroTrainViewHandler; }
    public function get equipTrainsView() : CEquipmentTrainViewHandler { return this.getChild(4) as CEquipmentTrainViewHandler; }
    public function get skillUpView() : CSkillUpViewHandler { return this.getChild(5) as CSkillUpViewHandler; }

    public function get isEquipTrainTab() : Boolean {
        return _ui.tab_list.selectedIndex == EPlayerWndTabType.STACK_ID_HERO_WND_EQUIP_TRAIN;
    }

    private function get _playerData() : CPlayerData {
        return _data as CPlayerData;
    }

    private function get _ui() : Object {
        return rootUI as Object;
    }

    private var _tabViewList:Array;
    private var _isFirst:Boolean;

}
}

