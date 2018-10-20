//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/28.
 */
package kof.game.player.view.heroDetail.detail {

import kof.game.common.view.CChildView;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EPlayerWndTabType;

public class CPlayerHeroDetailView extends CChildView {
    public function CPlayerHeroDetailView() {
        super([CPlayerHeroDetailInfoView, CPlayerHeroDetailEquipView,
            CPlayerHeroDetailPropertyView, CPlayerHeroDetailSkillView, CPlayerHeroDetailFriendView]);
    }
    protected override function _onCreate() : void {
        // do thing by create
        super._onCreate();
    }
    protected override function _onDispose() : void {
        // dispose
        super._onDispose();
    }
    protected override function _onShow():void {
        // do thing when show
        super._onShow();
    }
    protected override function _onHide() : void {
        // do thing when hide
        super._onHide();
    }

    public override function setData(data:Object, forceInvalid:Boolean = true) : void {
        super.setData(data, forceInvalid);

        this.setChildrenData(data, forceInvalid);
    }

    public override function updateWindow() : Boolean {
        if (super.updateWindow() == false) return false;
        if (_lastHero != _heroData) {
             // _showEffect();
        }

        return true;
    }
    private var _lastHero:CPlayerHeroData;

//    public function _showEffect() : void {
//        if (_isShowingEffect) {
//            return ;
//        }
//
//        _isShowingEffect = true;
//        var ui:Object = _detailUI;
//        ui.info_appear_mv.stop();
//        ui.info_appear_mv.playFromTo(null, null, new Handler(_onPlayFinish));
//        ui.info_appear_mv.visible = true;
//
//        // selectHeroView.showHeroListEffect();
//    }
//    private function _onPlayFinish() : void {
//        var ui:Object = _detailUI;
//        ui.info_appear_mv.stop();
//        ui.info_appear_mv.visible = false;
//        _isShowingEffect = false;
//    }

    private var _isShowingEffect:Boolean = false;

    private function get _heroData() : CPlayerHeroData {
        return _data[1] as CPlayerHeroData;
    }
    public function get infoView() : CPlayerHeroDetailInfoView { return getChild(_INFO) as CPlayerHeroDetailInfoView; }
    public function get equipView() : CPlayerHeroDetailEquipView { return getChild(_EQUIP) as CPlayerHeroDetailEquipView; }
    public function get propertyView() : CPlayerHeroDetailPropertyView { return getChild(_PROPERTY) as CPlayerHeroDetailPropertyView; }
    public function get skillView() : CPlayerHeroDetailSkillView { return getChild(_SKILL) as CPlayerHeroDetailSkillView; }
    public function get friendView() : CPlayerHeroDetailFriendView { return getChild(_FRIEND) as CPlayerHeroDetailFriendView; }

    private function get _ui() : Object {
        return (rootUI as Object).viewStack.items[EPlayerWndTabType.STACK_ID_HERO_WND_DETAIL] as Object;
    }
    private function get _detailUI() : Object {
        return _ui.viewStack.items[EPlayerWndTabType.STACK_ID_HERO_DETAIL_WND_INFO] as Object;
    }

    private static const _INFO:int = 0;
    private static const _EQUIP:int = 1;
    private static const _PROPERTY:int = 2;
    private static const _SKILL:int = 3;
    private static const _FRIEND:int = 4;



}
}
