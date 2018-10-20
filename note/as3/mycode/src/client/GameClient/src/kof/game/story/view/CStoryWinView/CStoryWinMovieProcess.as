//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/21.
 */
package kof.game.story.view.CStoryWinView {

import flash.events.MouseEvent;
import flash.geom.Point;

import kof.ui.instance.InstanceWinEffectUI;
import kof.ui.master.HeroStoryView.HeroStoryWinDescUI;

import morn.core.components.Component;

public class CStoryWinMovieProcess {
    public function CStoryWinMovieProcess(view:CStoryWinView) {
        _win = view;
    }
    public function initial() : void {
        _role1BoxBasePos = new Point(_win._ui.role_1_box.x, _win._ui.role_1_box.y);
        _role11BoxBasePos = new Point(_win._ui.role_11_box.x, _win._ui.role_11_box.y);

        _win._ui.role_box.visible = false;
        _win._ui.role_1_box.scale = 1.05;
        _win._ui.role_11_box.alpha = 1.0;
        _win._ui.role_11_box.scale = 1.05;

        // 对话
        _win._ui.say1_txt.visible = false;
        _win._ui.say2_txt.visible = false;
        _win._ui.say_bg_img.visible = false;
        _win._ui.say_bg_white_img.visible = false;
        _win._ui.say_box.alpha = 1;

        // desc
        var pDescView:HeroStoryWinDescUI = _win._ui.desc_view;
        pDescView.ok_btn.visible = false;

        // effect
        var pEffectView:InstanceWinEffectUI = _win._ui.effectView;
        pEffectView.line1_img.visible = false;
        pEffectView.line2_img.visible = false;
        pEffectView.win_img.visible = false;
        pEffectView.win_effect_clip.visible = false;

        _win.flashStage.addEventListener(MouseEvent.CLICK, _onClick);

    }
    public function dispose() : void {

        _win._ui.role_1_box.setPosition(_role1BoxBasePos.x, _role1BoxBasePos.y);
        _win._ui.role_11_box.setPosition(_role11BoxBasePos.x, _role11BoxBasePos.y);
        _win.flashStage.removeEventListener(MouseEvent.CLICK, _onClick);

    }

    private var _onShowRoleWinMovieFinsihCallback:Function;
    public function showRoleWinMovie(callback:Function) : void {
        _onShowRoleWinMovieFinsihCallback = callback;

        if (isForceStop) {
            _onShowRoleWinMovieFinsi();
            return ;
        }
        var componentList:Vector.<Component> = new Vector.<Component>(16);
        componentList[0] = _win._ui.role_box;
        componentList[1] = _win._ui.role_1_box;
        componentList[2] = _win._ui.role_1_box;
        componentList[3] = _win._ui.role_1_box;
        componentList[4] = _win._ui.effectView.win_box;
        componentList[5] = _win._ui.effectView.line1_img;
        componentList[6] = _win._ui.effectView.line2_img;
        componentList[7] = _win._ui.effectView.win_img;
        componentList[8] = _win._ui.effectView.win_effect_clip;
        componentList[9] = _win._ui.role_11_box;
        componentList[10] = _win._ui.say1_txt;
        componentList[11] = _win._ui.say_bg_img;
        componentList[12] = _win._ui.say_bg_white_img;
        componentList[13] = _win._ui.say_mask1_img;
        componentList[14] = _win._ui.say2_txt;
        componentList[15] = _win._ui.say_mask2_img;
        componentList[16] = _win._ui.say_box;

        _showRoleMovie = new CStoryWinShowRoleMovieCompoent(_win, componentList, _onShowRoleWinMovieFinsi, this);
        _showRoleMovie.start();
    }
    private function _onShowRoleWinMovieFinsi() : void {
        if (_onShowRoleWinMovieFinsihCallback) {
            _onShowRoleWinMovieFinsihCallback();
        }
        _onShowRoleWinMovieFinsihCallback = null;
        _win._ui.say_box.alpha = 0;
        _win._ui.role_1_box.x = _role1BoxBasePos.x - 200;

        _win.flashStage.removeEventListener(MouseEvent.CLICK, _onClick);

    }
    private function _onClick(e:MouseEvent) : void {
        _isForceStop = true;
    }
    public function get isForceStop() : Boolean {
        return _isForceStop;
    }
    private var _isForceStop:Boolean;

    private var _win:CStoryWinView;
    private var _showRoleMovie:CStoryWinShowRoleMovieCompoent;

    private var _role1BoxBasePos:Point;
    private var _role11BoxBasePos:Point;
}
}
