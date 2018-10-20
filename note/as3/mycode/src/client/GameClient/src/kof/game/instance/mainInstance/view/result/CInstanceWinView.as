//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.instance.mainInstance.view.result {

import QFLib.Foundation.CKeyboard;

import flash.events.KeyboardEvent;

import flash.ui.Keyboard;

import kof.framework.CAppSystem;
import kof.game.audio.IAudio;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.common.CLang;
import kof.game.common.view.CRootView;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.dataLog.CDataLog;
import kof.game.embattle.CEmbattleSystem;
import kof.game.embattle.CEmbattleUtil;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.config.CInstancePath;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.mainInstance.enum.EInstanceWndResType;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.instance.InstanceWinUI;
// pve 总胜利界面
public class CInstanceWinView extends CRootView {

    public function CInstanceWinView() {
        super(InstanceWinUI, [CInstanceWinDescView, CInstanceWinEffectView, CInstanceWinRoleView], EInstanceWndResType.INSTANCE_WIN_RESULT, false)
    }

    protected override function _onCreate() : void {
        // 对话层
        _ui.say_mask1_img.cacheAsBitmap = true;
        _ui.say1_txt.cacheAsBitmap = true;
        _ui.say1_txt.mask = _ui.say_mask1_img;

        _ui.say_mask2_img.cacheAsBitmap = true;
        _ui.say2_txt.cacheAsBitmap = true;
        _ui.say2_txt.mask = _ui.say_mask2_img;

        _descView._ui.ok_btn_tips.text = CLang.Get("common_mouse_or_space");

//        _keyBoard = new CKeyboard(system.stage.flashStage);
    }
    protected override function _onDispose() : void {
    }
    protected override function _onShow():void {
        _descView._ui.ok2_btn.visible = false;
        _descView._ui.tutor_arrow_clip.visible = _descView._ui.tutor_circle_clip.visible = false;
        _descView._ui.ok_btn_tips.visible = false;
        _descView._ui.ok_btn_tips_bg.visible = false;

        _movieProcess = new CInstanceWinMovieProcess(this);
        _movieProcess.initial();
        this.setNoneData();

        var audio:IAudio = (uiCanvas as CAppSystem).stage.getSystem(IAudio) as IAudio;
        audio.playMusicByPath(CInstancePath.getAudioPath(CInstancePath.PVE_RESULT_BG_AUDIO_NAME), 1, 0, 0.1, 0.1);

//        _keyBoard.registerKeyCode(true, Keyboard.SPACE, _onKeyDown);

        CDataLog.logInstanceResultLoadingEnd(system, (system as CInstanceSystem).instanceData, (system as CInstanceSystem).instanceContent);

        system.stage.flashStage.addEventListener( KeyboardEvent.KEY_UP, _onKeyboardUp, false, 0, true );
    }

    private function _onKeyboardDown( e:KeyboardEvent ) : void
    {
    }

    private function _onKeyboardUp( e:KeyboardEvent ) : void
    {
        if( e.keyCode == Keyboard.SPACE)
        {
            if (_descView._ui.ok2_btn.visible)
            {
                close();
            }
        }
    }

    private function _onKeyDown(keyCode:uint):void {
        switch (keyCode) {
            case Keyboard.SPACE:
                if (_descView._ui.ok2_btn.visible) {
                    close();
                }
                break;
        }
    }
    protected override function _onShowing() : void {
        var playerData:CPlayerData = data.instanceDataManager.playerData;
        var instanceType:int = data.curInstanceData.instanceType;
        var embattleListData:CEmbattleListData = playerData.embattleManager.getByType(instanceType);
        if (embattleListData && embattleListData.list && embattleListData.list.length > 0) {
            var emData:CEmbattleData;
            for (var i:int = 0; i < 3; i++) {
                emData = null;
                emData = embattleListData.getByPos(i+1);
                if (emData && emData.prosession > 0) {
                    if (i == 0) {
                        this.loadBmd(CPlayerPath.getUIHeroFacePath(emData.prosession));
                    } else {
                        this.loadBmd(CPlayerPath.getPeakUIHeroFacePath(emData.prosession));
                    }
                }
            }
        }
    }

    protected override function _onHide() : void {
        _movieProcess.dispose();
//        _keyBoard.unregisterKeyCode(false, Keyboard.SPACE, _onKeyDown);
        system.stage.flashStage.removeEventListener(KeyboardEvent.KEY_UP, _onKeyboardUp);
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
        this.setChildrenData(data, forceInvalid);
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;
        _movieProcess.start();
        this.addToDialog();
        return true;
    }

    public function get _ui() : InstanceWinUI {
        return rootUI as InstanceWinUI;
    }
    public function get _descView() : CInstanceWinDescView { return this.getChild(0) as CInstanceWinDescView; }
    public function get _effectView() : CInstanceWinEffectView { return this.getChild(1) as CInstanceWinEffectView; }
    public function get _roleView() : CInstanceWinRoleView { return this.getChild(2) as CInstanceWinRoleView; }

    public function get data() : CInstanceDataCollection {
        return _data as CInstanceDataCollection;
    }
    public function get mainHeroData() : CPlayerHeroData {
        if (!uiCanvas) return null;

        var embattleSystem:CEmbattleSystem = system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
        if (!embattleSystem) { return null; }
        var heroIDlList:Array = (embattleSystem.getBean(CEmbattleUtil) as CEmbattleUtil).getHeroIDListInEmbattleByCurrentInstance();

        if (heroIDlList && heroIDlList.length > 0) {
            var mainHeroID:int;
            for (var i:int = 0; i < heroIDlList.length; i++) {
                if (heroIDlList[i] != null) {
                    mainHeroID = heroIDlList[i] as int;
                    break;
                }
            }

            var playerData:CPlayerData = data.instanceDataManager.playerData;
            var heroData:CPlayerHeroData;
            heroData = playerData.heroList.getHero(mainHeroID);
            return heroData;
        }

        return null;
    }

    private function get instanceData() : CChapterInstanceData {
        return data.curInstanceData;
    }

    private var _movieProcess:CInstanceWinMovieProcess;
    private var _keyBoard:CKeyboard;
}
}
