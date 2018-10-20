//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/5.
 */
package kof.game.instance.mainInstance.view.instanceScenarioDetail {

import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.instance.config.CInstancePath;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.ui.instance.InstanceNoteDetailUI;


public class CInstanceScenarioDetailView extends CRootView {

    public function CInstanceScenarioDetailView() {
        super(InstanceNoteDetailUI, [CInstanceScenarioDetailIntroView, CInstanceScenarioDetailStarView, CInstanceScenarioDetailRewardView, CInstanceScenarioDetailFight], null, false)
    }

    protected override function _onCreate() : void {
        _ui.gold_img.toolTip = CLang.Get("common_gold");
        _ui.exp_img.toolTip = CLang.Get("common_exp");
        _ui.hero_exp_img.toolTip = CLang.Get("common_hero_exp");

    }
    protected override function _onDispose() : void {
    }
    protected override function _onShow():void {
        popupCenter = false;
        _ui.role_img.url = null;


    }
    protected override function _onHide() : void {
        // _rootView.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        // CHeroSpriteUtil.setSkinByID(_uiSystem as CAppSystem, _ui.clipCharacter_1, -1);

    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        (rootUI as InstanceNoteDetailUI).instance_name_txt.text = data.curInstanceData.name;
        (rootUI as InstanceNoteDetailUI).role_img.url = CInstancePath.getInstanceBGIcon(data.curInstanceData.tipsIcon);
//        var strHeroID:String = data.curInstanceData.tipsIcon.replace("role_", "");
//        var heroID:int = (int)(strHeroID);
//        CHeroSpriteUtil.setSkinByID(_uiSystem as CAppSystem, _ui.clipCharacter_1, heroID);

//        _ui.job_clip.index = data.curInstanceData.profession;
        // this.addToPopupDialog();
        this.addToDialog();

        return true;
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);

        _introView.setData(v, forceInvalid);
        _starView.setData(v, forceInvalid);
        _rewardView.setData(v, forceInvalid);
        _fightView.setData(v, forceInvalid);
    }

    private function get _introView() : CInstanceScenarioDetailIntroView { return getChild(0) as CInstanceScenarioDetailIntroView; }
    private function get _starView() : CInstanceScenarioDetailStarView { return getChild(1) as CInstanceScenarioDetailStarView}
    private function get _rewardView() : CInstanceScenarioDetailRewardView { return getChild(2) as CInstanceScenarioDetailRewardView; }
    private function get _fightView() : CInstanceScenarioDetailFight { return getChild(3) as CInstanceScenarioDetailFight; }

    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }

    private function get _ui() : InstanceNoteDetailUI {
        return rootUI as InstanceNoteDetailUI;
    }
}
}
