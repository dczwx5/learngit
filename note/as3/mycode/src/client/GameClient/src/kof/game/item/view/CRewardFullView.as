//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/19.
 */
package kof.game.item.view {


import flash.events.Event;
import flash.events.MouseEvent;

import kof.game.common.CLang;
import kof.game.item.enum.EItemWndResType;
import kof.game.common.view.CRootView;
import kof.game.item.view.part.CRewardItemListViewBig2Row;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;
import kof.ui.imp_common.RewardFullUI;

import morn.core.handlers.Handler;

// 奖励界面
public class CRewardFullView extends CRootView {
    public function CRewardFullView() {
        super(RewardFullUI, null, EItemWndResType.REWARD_FULL, false)
        viewId = EPopWindow.POP_WINDOW_11;
    }

    protected override function _onCreate() : void {
//        this.listStageClick = true;
        _rewardListView = new CRewardItemListViewBig2Row(system, _ui.reward_list, _ui.left_btn, _ui.right_btn);
    }

    protected override function _onDispose() : void {
    }

    protected override function _onShow() : void {
        _ui.ok_btn.btnLabel.text = CLang.Get("common_ok");
        _ui.ok_btn.clickHandler = new Handler(_onOk);
        _ui.effect_bg_img.visible = false;
        _ui.reward_list.visible = false;
        _ui.clip_bgEffect.visible = true;

        _ui.addEventListener(MouseEvent.CLICK, _onClick);
        _isClose = false;
    }

//    protected override function _onStageClick(e:MouseEvent) : void {
//        this.close();
//    }
    protected override function _onHide() : void {
        _ui.ok_btn.clickHandler = null;
        var reciprocalSystem:CReciprocalSystem = system.stage.getSystem(CReciprocalSystem) as CReciprocalSystem;
        reciprocalSystem.removeEventPopWindow( this.viewId );

        _ui.removeEventListener(MouseEvent.CLICK, _onClick);

    }
    public override function setData(data:Object, forceInvalid:Boolean = true) : void {
        super.setData(data, forceInvalid);
    }



    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        _rewardListView.setData(_data);

        _ui.clip_bgEffect.frame = 0;
        _ui.clip_bgEffect.playFromTo(null, null, new Handler(_onShowEffectEnd));


        this.addToPopupDialog();
        return true;
    }
    private function _onShowEffectEnd() : void {
        _ui.clip_bgEffect.visible = false;
        _ui.effect_bg_img.visible = true;
        _rewardListView.updateWindow();

    }

    private function _onOk() : void {
        if (_isClose) return ;
        _isClose = true;
        this.close();
    }

    private function get _ui() : RewardFullUI {
        return rootUI as RewardFullUI;
    }
    private function _onClick(e:Event) : void {
        if ( e.target == _ui.left_btn || e.target == _ui.right_btn) {
            return ;
        }

        if (_isClose) return ;
        _onOk();

    }

    private var _isClose:Boolean;

    private var _rewardListView:CRewardItemListViewBig2Row;
}
}
