//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/2/1.
 */
package kof.game.teaching {

import QFLib.Foundation.CKeyboard;

import flash.display.MovieClip;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import kof.framework.CAppSystem;
import kof.game.audio.IAudio;
import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.common.view.component.CCountDownCompoent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.embattle.CEmbattleUtil;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.config.CInstancePath;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.player.config.CPlayerPath;
import kof.game.playerTeam.CPlayerTeamSystem;
import kof.ui.master.Teaching.TeachingAccountUI;

import morn.core.components.FrameClip;
import morn.core.components.Image;
import morn.core.handlers.Handler;

public class CTeachingAccountView extends CRootView {
    private var _countDownComponent:CCountDownCompoent;

    private var m_pRoleImg:Image;

    private var _keyBoard:CKeyboard;
    public function CTeachingAccountView() {
        super(TeachingAccountUI, [], [[TeachingAccountUI]], false)
    }


    override protected function _onCreate() : void {
        super._onCreate();

        _keyBoard = new CKeyboard(system.stage.flashStage);
    }


    private function _onKeyDown(keyCode:uint):void {
        switch (keyCode) {
            case Keyboard.SPACE:
                if  (_ui.box_buttn.visible){
                    close();
                }
                break;
        }
    }

    protected override function _onShow():void {
        this.listEnterFrameEvent = true;

        _countDownComponent = new CCountDownCompoent(this, _ui.txt_count, 30000, _onCountDownEnd, null, CLang.Get("resourceInstance_Result"));

        this.setNoneData();
        invalidate();
        _ui.box_buttn.visible = false;
        _ui.btn_exit.clickHandler = new Handler(_onCountDownEnd);

        if(m_pRoleImg == null){
            m_pRoleImg = new Image();
            m_pRoleImg.smoothing = true;
            (_ui.clip_teaching.mc.mc_role as MovieClip).addChild(m_pRoleImg);
        }

        var audio:IAudio = (uiCanvas as CAppSystem).stage.getSystem(IAudio) as IAudio;
        audio.playMusicByPath(CInstancePath.getAudioPath(CInstancePath.PVE_RESULT_BG_AUDIO_NAME), 1, 0, 0, 0);

        _keyBoard.registerKeyCode(true, Keyboard.SPACE, _onKeyDown);
    }

    private function onComplete():void{
        _ui.box_buttn.visible = true;
    }

    protected override function _onHide() : void {
        _countDownComponent.dispose();
        _countDownComponent = null;
        _keyBoard.unregisterKeyCode(false, Keyboard.SPACE, _onKeyDown);
    }
    private function _onCountDownEnd() : void {
        this.close();
    }
    protected override function _onEnterFrame(delta:Number) : void {
        _countDownComponent.tick();
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        var m_teachingClip:FrameClip = _ui.clip_teaching as FrameClip;
        m_teachingClip.mc.mc_title.text_title.text = getTeachingInstanceDataByID(int(_data)).name;
        m_teachingClip.mc.mc_name.text_name.text = (system.stage.getSystem(CPlayerTeamSystem) as CPlayerTeamSystem).playerData.teamData.name;
        m_teachingClip.mc.mc_des.text_des.text = getTeachingInstanceDataByID(int(_data)).desc;

        var heroImgUrl:String;
        var pEmbattleSystem:CEmbattleSystem = system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
        if (pEmbattleSystem) {
            var pEmbattleUtil:CEmbattleUtil = pEmbattleSystem.getBean(CEmbattleUtil) as CEmbattleUtil;
            if (pEmbattleUtil) {
                var pHeroIDList:Array = pEmbattleUtil.getHeroIDListInEmbattleByCurrentInstance();
                if (pHeroIDList && pHeroIDList.length) {
                    heroImgUrl = CPlayerPath.getUIHeroFacePath(pHeroIDList[0]);
                }
            }
        }

        m_pRoleImg.url = heroImgUrl;
        _ui.clip_teaching.playFromTo(0,75,new Handler(onComplete));
        this.addToDialog();
        return true;
    }

    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);

    }

    private function get _ui() : TeachingAccountUI {
        return rootUI as TeachingAccountUI;
    }

    public function getTeachingInstanceDataByID(instanceID:int) : CChapterInstanceData {
        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        return pInstanceSystem.getInstanceByID(instanceID);
    }
}
}
