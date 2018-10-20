//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.level.view {

import com.greensock.TweenMax;

import flash.utils.setTimeout;
import kof.game.common.view.CRootView;
import kof.game.level.view.enum.ELevelWndResType;
import kof.ui.component.CCharacterFrameClip;
import kof.ui.components.BossComingView;
import kof.ui.master.level.BossComingUI;

import morn.core.components.Image;

public class CLevelBossComingView extends CRootView {

    private var uiList:Array = [BossComingUI];

    private var m_characterClip:CCharacterFrameClip;

    private var tween:TweenMax;

    private var m_callbackFun:Function;

    private var m_time:int;
    public function CLevelBossComingView() {
        super(uiList, null, ELevelWndResType.BOSS_COMING, false);
    }

    protected override function _onCreate() : void {
    }
    protected override function _onDispose() : void {
        m_characterClip = null;
    }
    protected override function _onShow():void {
        this.listStageClick = true;
        if(m_characterClip){
            m_characterClip.skin = null;
        }
        var img:Image = _ui["img_mask"] as Image;
        img.alpha = 1;
        tween = TweenMax.from(img, 0.5, {alpha:0, yoyo:true, repeat:-1});
    }
    protected override function _onHide() : void {
        tween.kill();
        m_characterClip = null;
    }

    override public function setData( data : Object, forceInvalid:Boolean = true ) : void {
        super.setData( data, forceInvalid );
        m_characterClip = _ui["clipCharacter"] as CCharacterFrameClip;

        m_characterClip.isLoopPlay = true;
        m_characterClip.isStageScale = true;
        m_characterClip.isBust = true;
        if(m_characterClip.framework == null)
        {
            m_characterClip.framework = _initialArgs[0];
        }
        m_characterClip.skin = data.skin;
        m_characterClip.animationName = data.name;
        m_characterClip.isLoopPlay = int(data.loop);
        m_callbackFun = data.callback;
        m_time = data.time;
        m_characterClip.play();

        _onMovieCompletedFun();
    }

    private function _onMovieCompletedFun():void{
        if(m_callbackFun != null){
            setTimeout(m_callbackFun, m_time * 1000);
        }
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        this.addToRoot();

        return true;
    }


//    protected override function _onStageClick(e:MouseEvent) : void {
//        // this._rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.CLICK_STAGE));
//    }

    protected function get _ui() : BossComingView {
        return rootUI as BossComingView;
    }
}
}
