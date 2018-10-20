//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/8/2.
 */
package kof.game.instance.view.instanceResult {

import kof.framework.CAppSystem;
import kof.game.audio.IAudio;
import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.component.CCountDownCompoent;
import kof.game.instance.config.CInstancePath;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.mainInstance.enum.EInstanceWndResType;
import kof.ui.master.ResourceInstance.GoldInstanceWinUI;

import morn.core.handlers.Handler;

public class CInstanceGoldWinView extends CRootView {
    public function CInstanceGoldWinView() {
        super(GoldInstanceWinUI, [], EInstanceWndResType.INSTANCE_GOLD_RESULT, false)
    }

    protected override function _onCreate() : void {
    }
    protected override function _onDispose() : void {
    }
    protected override function _onShow():void {
        this.listEnterFrameEvent = true;

        _countDownComponent = new CCountDownCompoent(this, _ui.txt_count, 30000, _onCountDownEnd, null, CLang.Get("resourceInstance_Result"));

        this.setNoneData();
        invalidate();
        _ui.ok_btn.clickHandler = new Handler(_onCountDownEnd);
        var audio:IAudio = (uiCanvas as CAppSystem).stage.getSystem(IAudio) as IAudio;
        audio.playMusicByPath(CInstancePath.getAudioPath(CInstancePath.PVE_RESULT_BG_AUDIO_NAME), 1, 0, 0, 0);
    }

    protected override function _onHide() : void {
        _countDownComponent.dispose();
        _countDownComponent = null;
    }
    private function _onCountDownEnd() : void {
        this.close();
    }
    protected override function _onEnterFrame(delta:Number) : void {
        _countDownComponent.tick();
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;
        var index:int = (_data as CInstanceDataCollection).instanceDataManager.instanceData.lastInstancePassReward.star-1;
        _ui.clip_win.index = index;
        _ui.txt_goldNum.text = (_data as CInstanceDataCollection).instanceDataManager.instanceData.lastInstancePassReward.rewardList.gold.toString();
        this.addToDialog();
        return true;
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);

    }

    private function get _ui() : GoldInstanceWinUI {
        return rootUI as GoldInstanceWinUI;
    }

    private var _countDownComponent:CCountDownCompoent;
}
}
