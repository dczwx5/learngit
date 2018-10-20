//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/12/1.
 */
package kof.game.instance.mainInstance.view.extraDetail {


import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.instance.config.CInstancePath;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.ui.instance.InstanceExtraDetailUI;



public class CInstanceScenarioExtraDetailView extends CRootView {

    public function CInstanceScenarioExtraDetailView() {
        super(InstanceExtraDetailUI, [CInstanceScenarioExtraDetailIntroView, CInstanceScenarioExtraDetailRewardView, CInstanceScenarioExtraDetailFight], null, false)
    }

    protected override function _onCreate() : void {
        _ui.gold_img.toolTip = CLang.Get("common_gold");
        _ui.exp_img.toolTip = CLang.Get("common_exp");
    }
    protected override function _onDispose() : void {
    }
    protected override function _onShow():void {
        popupCenter = false;
        _ui.role_img.url = null;


    }
    protected override function _onHide() : void {
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        (rootUI as InstanceExtraDetailUI).instance_name_txt.text = data.curInstanceData.name;
        (rootUI as InstanceExtraDetailUI).role_img.url = CInstancePath.getInstanceBGIcon(data.curInstanceData.tipsIcon);
        this.addToDialog();

        return true;
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);

        _introView.setData(v, forceInvalid);
        _rewardView.setData(v, forceInvalid);
        _fightView.setData(v, forceInvalid);
    }

    private function get _introView() : CInstanceScenarioExtraDetailIntroView { return getChild(0) as CInstanceScenarioExtraDetailIntroView; }
    private function get _rewardView() : CInstanceScenarioExtraDetailRewardView { return getChild(1) as CInstanceScenarioExtraDetailRewardView; }
    private function get _fightView() : CInstanceScenarioExtraDetailFight { return getChild(2) as CInstanceScenarioExtraDetailFight; }

    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }

    private function get _ui() : InstanceExtraDetailUI {
        return rootUI as InstanceExtraDetailUI;
    }
}
}
