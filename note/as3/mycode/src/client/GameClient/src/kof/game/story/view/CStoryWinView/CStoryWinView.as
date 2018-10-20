//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/14.
 */
package kof.game.story.view.CStoryWinView {

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.CViewExternalUtil;
import kof.game.common.view.component.CCountDownCompoent;
import kof.game.common.view.event.CViewEvent;
import kof.game.item.view.part.CRewardItemListView;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.story.CStorySystem;
import kof.game.story.data.CStoryData;
import kof.game.story.enum.EStoryViewEventType;
import kof.game.story.enum.EStoryWndResType;
import kof.ui.master.HeroStoryView.HeroStoryWinDescUI;
import kof.ui.master.HeroStoryView.HeroStoryWinUI;
import morn.core.components.Image;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

public class CStoryWinView extends CRootView {

    public function CStoryWinView() {
        var childrenList:Array = null;
        super(HeroStoryWinUI, childrenList, EStoryWndResType.WIN, false);
    }

    protected override function _onCreate() : void {
        // 对话层
        _ui.say_mask1_img.cacheAsBitmap = true;
        _ui.say1_txt.cacheAsBitmap = true;
        _ui.say1_txt.mask = _ui.say_mask1_img;

        _ui.say_mask2_img.cacheAsBitmap = true;
        _ui.say2_txt.cacheAsBitmap = true;
        _ui.say2_txt.mask = _ui.say_mask2_img;

        _ui.desc_view.first_pass_mv.stop();
        _ui.desc_view.visible = false;
    }
    protected override function _onDispose() : void {

    }
    protected override function _onShow():void {
        _isRoleWinMovieFinish = false;
        _isFrist = true;
        this.listEnterFrameEvent = true;

        _movieProcess = new CStoryWinMovieProcess(this);
        _movieProcess.initial();


    }
    protected override function _onHide() : void {
        _movieProcess.dispose();
        this.listEnterFrameEvent = false;
        if(_countDownComponent){
            _countDownComponent.dispose();
            _countDownComponent = null;
        }
        _ui.desc_view.ok_btn.clickHandler = null;
        system.stage.flashStage.removeEventListener(KeyboardEvent.KEY_UP, _onKeyboardUp);

        _ui.desc_view.visible = false;
        _ui.desc_view.first_pass_mv.stop();
        _ui.desc_view.first_pass_mv.visible = false;
        _ui.desc_view.first_pass_img.visible = false;
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        if (_isFrist) {
            _isFrist = false;

            _system.addSequential(new Handler(_initialize), _isLoadResFinish);
            _system.addSequential(new Handler(_showRoleWinMovie), isRoleWinMovieFinish);
            _system.addSequential(new Handler(_updateRealView), null);
        }

        this.addToDialog();

        return true;
    }

    // =================================流程========================================
    private var _isRoleWinMovieFinish:Boolean;
    private function _initialize() : void {
        _loadHeroImgTotalCount = 2;
        _ui.hero_icon1_img.removeEventListener(UIEvent.IMAGE_LOADED, _onHeroLoaded);
        _ui.hero_icon1_img.addEventListener(UIEvent.IMAGE_LOADED, _onHeroLoaded);
        _ui.hero_icon11_img.removeEventListener(UIEvent.IMAGE_LOADED, _onHeroLoaded);
        _ui.hero_icon11_img.addEventListener(UIEvent.IMAGE_LOADED, _onHeroLoaded);
        _ui.hero_icon1_img.url = CPlayerPath.getUIHeroFacePath(_storyData.resultData.heroID);
        _ui.hero_icon11_img.url = CPlayerPath.getUIHeroFacePath(_storyData.resultData.heroID);
    }
    // show role movie
    private function _onShowRoleWinMovieFinish() : void {
        _isRoleWinMovieFinish = true;
    }
    private function isRoleWinMovieFinish() : Boolean {
        return _isRoleWinMovieFinish;
    }
    private function _showRoleWinMovie() : void {
        _movieProcess.showRoleWinMovie(_onShowRoleWinMovieFinish);
    }
    //
    private function _updateRealView() : void {
        var pDescView:HeroStoryWinDescUI = _ui.desc_view;
        pDescView.visible = true;

        if (_storyData.lastFightGateIsFirstPass) {
            if (_ui.desc_view.first_pass_mv.mc) {
                _ui.desc_view.first_pass_mv.visible = true;
                _ui.desc_view.first_pass_mv.playFromTo(null, null, new Handler(function () : void {
                    _ui.desc_view.first_pass_mv.stop();
                    _ui.desc_view.first_pass_mv.visible = false;
                    _ui.desc_view.first_pass_img.visible = true;
                }));
            } else {
                _ui.desc_view.first_pass_img.visible = true;
            }

        } else {
            if (_ui.desc_view.first_pass_mv.mc) {
                _ui.desc_view.first_pass_img.visible = false;
                _ui.desc_view.first_pass_mv.stop();
                _ui.desc_view.first_pass_mv.visible = false;
            } else {
                _ui.desc_view.first_pass_img.visible = false;
            }
        }

        var rewardViewExternalHelper:CViewExternalUtil = new CViewExternalUtil(CRewardItemListView, this, null);
        (rewardViewExternalHelper.view as CRewardItemListView).ui = _ui.desc_view.reward_list;
        rewardViewExternalHelper.show();
        rewardViewExternalHelper.setData(_storyData.resultData.rewardList);
        rewardViewExternalHelper.updateWindow();

        _countDownComponent = new CCountDownCompoent(this, _ui.desc_view.count_down_tips, 30000, _onCountDownEnd, "(", CLang.Get("resourceInstance_Result")+")");

        _ui.desc_view.ok_btn.visible = true;
        _ui.desc_view.ok_btn.clickHandler = new Handler(_onCountDownEnd);
        system.stage.flashStage.addEventListener( KeyboardEvent.KEY_UP, _onKeyboardUp, false, 0, true );
    }
    private var _loadHeroImgTotalCount:int = 0;
    private var _loadHeroImgCount:int = 0;
    private function _onHeroLoaded(e:Event) : void {
        var img:Image = e.currentTarget as Image;
        img.removeEventListener(UIEvent.IMAGE_LOADED, _onHeroLoaded);
        _loadHeroImgCount++;
    }
    private function _isLoadResFinish() : Boolean {
        return _loadHeroImgCount > 0 && _loadHeroImgCount >= _loadHeroImgTotalCount;
    }

    // ============================================================================

    protected override function _onEnterFrame(delta:Number) : void {
        if (_countDownComponent) {
            _countDownComponent.tick();
        }
    }
    private function _onCountDownEnd() : void {
        sendEvent(new CViewEvent(CViewEvent.UI_EVENT, EStoryViewEventType.RESULT_EXIT_CLICK));
        close();
    }


    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(v, forceInvalid);
    }

    // ====================================event=============================
    private function _onKeyboardUp( e:KeyboardEvent ) : void  {
        if( e.keyCode == Keyboard.SPACE) {
            _onCountDownEnd();
        }
    }

    //===================================get/set======================================

//    private function get _linksView() : CPeakGameMainLinks { return getChild(0) as CPeakGameMainLinks; }

    [Inline]
    public function get _ui() : HeroStoryWinUI {
        return rootUI as HeroStoryWinUI;
    }
    [Inline]
    private function get _storyData() : CStoryData {
        if (_data && _data.length > 0) {
            return super._data[0] as CStoryData;
        }
        return null;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        if (_data && _data.length > 1) {
            return super._data[1] as CPlayerData;
        }
        return null;
    }
    private function get _system() : CStorySystem {
        return system as CStorySystem;
    }

    private var _isFrist:Boolean = true;
    private var _countDownComponent:CCountDownCompoent;
    private var _movieProcess:CStoryWinMovieProcess;


}
}
