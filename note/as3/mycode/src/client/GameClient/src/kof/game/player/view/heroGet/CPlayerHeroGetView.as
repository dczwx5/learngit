//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/31.
 */
package kof.game.player.view.heroGet {


import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;

import kof.game.common.CFlyPointEffect;

import kof.game.common.CLang;
import kof.game.player.CPlayerSystem;

import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EHeroIntelligence;
import kof.game.player.enum.EPlayerWndResType;
import kof.game.common.view.CRootView;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.playerNew.view.CCombatUpViewHandler;
import kof.game.playerCard.util.CPlayerCardUtil;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;
import kof.table.Skill;
import kof.ui.CUISystem;
import kof.ui.master.jueseNew.RoleGetnewUI;

public class CPlayerHeroGetView extends CRootView {

    private var _baseQualityPos:Point;
    public function CPlayerHeroGetView() {
        super(RoleGetnewUI, null, EPlayerWndResType.HERO_GET, false);
        viewId = EPopWindow.POP_WINDOW_10;
    }
    protected override function _onCreate() : void {
        // do thing by create
        super._onCreate();
        _baseQualityPos = new Point(_ui.quality_clip.x, _ui.quality_clip.y);

    }
    protected override function _onDispose() : void {
        // dispose
        super._onDispose();
    }

    protected override function _onShow():void {
        // do thing when show
        super._onShow();
        _ui.quality_clip.x = _baseQualityPos.x + 400;

        _ui.hero_icon_img.visible = false;
        _ui.btn_close.visible = false;
        _ui.img_confirm.visible = false;
        _ui.desc_box.alpha = 0;
        _ui.desc_box.visible = false;
        _ui.job_clip.visible = false;
        _ui.name_img.visible = false;
//        var clip:CCharacterFrameClip = _ui.clipCharacter as CCharacterFrameClip;
//        clip.addEventListener(Event.COMPLETE, _onMovieCompleted);

        _effectComponent = new CPlayerHeroGetComponent(this);

        system.dispatchEvent(new CPlayerEvent(CPlayerEvent.SHOWHIDE_COMBAT_EFFECT, false));
	}

    protected override function _onShowing() : void {
        this.loadBmd(CPlayerPath.getUIHeroFacePath(_heroData.prototypeID));
    }
    protected override function _onHide() : void {
        // do thing when hide
//        var clip:CCharacterFrameClip = _ui.clipCharacter as CCharacterFrameClip;
//        clip.removeEventListener(Event.COMPLETE, _onMovieCompleted);

        super._onHide();
        _ui.hero_icon_img.url = null;
        _ui.name_img.url = null;

        system.stage.flashStage.removeEventListener(KeyboardEvent.KEY_UP, _onKeyboardUp);
        system.dispatchEvent(new CPlayerEvent(CPlayerEvent.SHOWHIDE_COMBAT_EFFECT, true));

        var reciprocalSystem:CReciprocalSystem = system.stage.getSystem(CReciprocalSystem) as CReciprocalSystem;
        reciprocalSystem.removeEventPopWindow( this.viewId );
    }

    public function playSound() : void {
        // sound
        var sound:String = _heroData.playerDisplayRecord.sound;
        if (sound && sound.length > 0) {
            var musicPath : String = CPlayerPath.getHeroAudioPath(sound);
            _viewManagerHandler.playAudio(musicPath);
        }
    }

    public override function updateWindow() : Boolean {
        if (super.updateWindow() == false) return false;

        // 格斗形象
        _processRoleImage();

        // other
        _ui.job_clip.index =  _heroData.job;
        (system as CPlayerSystem).showCareerTips(_ui.job_clip);
        var qualityType:int = _heroData.qualityBaseType;
        _ui.quality_clip.index = qualityType;
        _ui.bg_clip.index = 4-_heroData.qualityBaseType;

        _ui.name_img.url = CPlayerPath.getUIHeroNamePath(_heroData.prototypeID);
        _ui.point_txt.text = _heroData.lineTable.RoleSet;

        // 技能
        var superSkillData:Skill = _heroData.getSuperSkillRecordInTable();
        if (superSkillData) {
            _ui.skill_desc_txt.text = superSkillData.Description;
            if (superSkillData.IconName && superSkillData.IconName.length > 0) {
                _ui.skill_icon_img.url = CPlayerPath.getSkillBigIcon(superSkillData.IconName);
            } else {
                _ui.skill_icon_img.url = null;
            }
            _ui.skill_name_txt.text = superSkillData.Name;
            _ui.skill_desc_txt.visible = true;
            _ui.skill_icon_img.visible = true;
            _ui.skill_name_txt.visible = true;
        } else {
            _ui.skill_desc_txt.visible = false;
            _ui.skill_icon_img.visible = false;
            _ui.skill_name_txt.visible = false;
        }

        // 抽卡转换碎片提示
        _ui.txt_cardTip.visible = CPlayerCardUtil.HeroChipsNum > 0;
        if(_ui.txt_cardTip.visible)
        {
            _ui.txt_cardTip.text = CLang.Get("playerCard_yzmgdj",{v1:CPlayerCardUtil.HeroChipsNum});
        }

        CPlayerCardUtil.HeroChipsNum = 0;

        _effectComponent.start();
         this.addToPopupDialog();
//        this.addToRoot();

        system.stage.flashStage.addEventListener(KeyboardEvent.KEY_UP, _onKeyboardUp, false, 0, true);

        return true;
    }

    private function _processRoleImage() : void {
        _ui.hero_icon_img.url = CPlayerPath.getUIHeroFacePath(_heroData.prototypeID);
    }
    // =========================event=========================

    private function _onKeyboardUp(e:KeyboardEvent) : void
    {
        e.stopImmediatePropagation();

        if(e.keyCode == Keyboard.SPACE)
        {
            _ui.btn_close.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
        }
    }

    private function get _heroData() : CPlayerHeroData {
        return _data as CPlayerHeroData;
    }

    public function get _ui() : RoleGetnewUI {
        return rootUI as RoleGetnewUI;
    }

    private var _effectComponent:CPlayerHeroGetComponent;

    public function get baseQualityPos() : Point {
        return _baseQualityPos;
    }
}
}

