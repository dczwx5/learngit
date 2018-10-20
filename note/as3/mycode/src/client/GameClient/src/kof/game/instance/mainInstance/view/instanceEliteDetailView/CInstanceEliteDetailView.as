//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/5.
 */
package kof.game.instance.mainInstance.view.instanceEliteDetailView {

import kof.game.common.view.CRootView;
import kof.game.instance.config.CInstancePath;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.mainInstance.enum.EInstanceWndResType;
import kof.ui.IUICanvas;
import kof.ui.instance.InstanceEliteDetailUI;


public class CInstanceEliteDetailView extends CRootView {

    public function CInstanceEliteDetailView() {
        super(InstanceEliteDetailUI,
                [CInstanceEliteDetailIntroView, CInstanceEliteDetailConditionView, CInstanceEliteDetailRewardView, CInstanceEliteDetailFightView],
                null, false)
    }

    protected override function _onCreate() : void {
    }
    protected override function _onDispose() : void {
    }
    protected override function _onShow():void {
        _ui.role_img.url = null;
    }
    protected override function _onHide() : void {
        // _rootView.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
//        CHeroSpriteUtil.setSkinByID(_uiSystem as CAppSystem, _ui.clipCharacter_1, -1);

    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

          _ui.role_img.url = CInstancePath.getInstanceBGIcon(instanceData.tipsIcon);
//        var strHeroID:String = instanceData.tipsIcon.replace("role_", "");
//        var heroID:int = (int)(strHeroID);
//        CHeroSpriteUtil.setSkinByID(_uiSystem as CAppSystem, _ui.clipCharacter_1, heroID);

        _ui.instance_name_txt.text = instanceData.name;
        _ui.job_clip.index = instanceData.profession;

        // this.addToPopupDialog();
        addToDialog();

        return true;
    }


    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);

        _introView.setData(v, forceInvalid);
        _conditionView.setData(v, forceInvalid);
        _rewardView.setData(v, forceInvalid);
        _fightView.setData(v, forceInvalid);
    }

    private function get _introView() : CInstanceEliteDetailIntroView { return getChild(0) as CInstanceEliteDetailIntroView; }
    private function get _conditionView() : CInstanceEliteDetailConditionView { return getChild(1) as CInstanceEliteDetailConditionView}
    private function get _rewardView() : CInstanceEliteDetailRewardView { return getChild(2) as CInstanceEliteDetailRewardView; }
    private function get _fightView() : CInstanceEliteDetailFightView { return getChild(3) as CInstanceEliteDetailFightView; }

    private function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }

    private function get _ui() : InstanceEliteDetailUI {
        return rootUI as InstanceEliteDetailUI;
    }
    private function get instanceData() : CChapterInstanceData {
        return data.curInstanceData;
    }
}
}
