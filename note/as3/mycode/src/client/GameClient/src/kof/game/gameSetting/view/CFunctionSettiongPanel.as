//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/1.
 */
package kof.game.gameSetting.view {

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;

import kof.game.audio.CAudioSystem;
import kof.game.character.ICharacterProfile;
import kof.game.core.CECSLoop;

import kof.game.gameSetting.CGameSettingData;
import kof.game.gameSetting.CGameSettingManager;
import kof.game.gameSetting.CGameSettingNetHandler;
import kof.game.gameSetting.CGameSettingSystem;
import kof.game.gameSetting.event.CGameSettingEvent;
import kof.ui.master.gameSetting.GameSettingMiscUI;

import morn.core.handlers.Handler;

public class CFunctionSettiongPanel extends CGameSettingPanelBase {
    public function CFunctionSettiongPanel( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        ret = ret && onInitialize();
        if ( loadViewByDefault ) {
            ret = ret && loadAssetsByView( viewClass );
            ret = ret && onInitializeView();
        }

        return ret;
    }

    override public function initializeView():void
    {
        super.initializeView();

        m_pViewUI = new GameSettingMiscUI();

        _viewUI.checkBox_banAddFriend.clickHandler = new Handler(_onClickCheckBox, ["banAddFriend"]);
        _viewUI.checkBox_shieldAll.clickHandler = new Handler(_onClickCheckBox, ["shieldAll"]);
//        _viewUI.checkBox_shieldEffect.clickHandler = new Handler(_onClickCheckBox, ["shieldEffect"]);
        _viewUI.checkBox_shieldOther.clickHandler = new Handler(_onClickCheckBox, ["shieldOther"]);
        _viewUI.checkBox_refusePeakPk.clickHandler = new Handler(_onClickCheckBox, ["refusePeakPk"]);
        _viewUI.checkBox_closeSound.clickHandler = new Handler(_onClickCheckBox, ["closeSound"]);
        _viewUI.checkBox_shieldTitle.clickHandler = new Handler(_onClickCheckBox, ["shieldTitle"]);

        _viewUI.slider_sound.changeHandler = new Handler(_onSoundChangeHandler);
        _viewUI.slider_music.changeHandler = new Handler(_onMusicChangeHandler);
    }

    override protected function _addListeners():void
    {
        super._addListeners();

        _viewUI.slider_music.addEventListener(MouseEvent.MOUSE_UP, _onMouseUpHandler);
        _viewUI.slider_sound.addEventListener(MouseEvent.MOUSE_UP, _onMouseUpHandler);
        _viewUI.slider_music.addEventListener(MouseEvent.MOUSE_DOWN, _onMusicDownHandler);
        _viewUI.slider_sound.addEventListener(MouseEvent.MOUSE_DOWN, _onSoundDownHandler);
        system.addEventListener(CGameSettingEvent.OpenOrCloseSound, _onOpenOrCloseSound);
        system.addEventListener(CGameSettingEvent.PeakPkSynchUpdate, _onPeakPkSynchUpdate);
    }

    override protected function _removeListeners():void
    {
        super._removeListeners();

        _viewUI.slider_music.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUpHandler);
        _viewUI.slider_sound.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUpHandler);
        _viewUI.slider_music.removeEventListener(MouseEvent.MOUSE_DOWN, _onMusicDownHandler);
        _viewUI.slider_sound.removeEventListener(MouseEvent.MOUSE_DOWN, _onSoundDownHandler);
        system.removeEventListener(CGameSettingEvent.OpenOrCloseSound, _onOpenOrCloseSound);
        system.removeEventListener(CGameSettingEvent.PeakPkSynchUpdate, _onPeakPkSynchUpdate);
    }

    override protected function _initView():void
    {
        updateDisplay();
    }

    override public function set data( value : * ) : void
    {
    }

    override protected function updateDisplay() : void
    {
        _updateShowInfo();
        _updateSoundInfo();
    }

    /**
     * 显示设置
     */
    private function _updateShowInfo():void
    {
        var gameSettingData:CGameSettingData = (system.getHandler(CGameSettingManager) as CGameSettingManager).gameSettingData;
        if(gameSettingData)
        {
            _viewUI.checkBox_shieldOther.selected = gameSettingData.isShieldOtherPlayers;
            _viewUI.checkBox_closeSound.selected = gameSettingData.isCloseSound;
//            _viewUI.checkBox_shieldEffect.selected = gameSettingData.isShieldOtherEffect;
            _viewUI.checkBox_banAddFriend.selected = gameSettingData.isBanOtherAddFriend;
            _viewUI.checkBox_refusePeakPk.selected = gameSettingData.isRefusePeakPk;
            _viewUI.checkBox_shieldAll.selected = gameSettingData.isShieldAll;
        }
    }

    /**
     * 声音设置
     */
    private function _updateSoundInfo():void
    {
        var gameSettingData:CGameSettingData = (system.getHandler(CGameSettingManager) as CGameSettingManager).gameSettingData;
        if(gameSettingData)
        {
            _viewUI.txt_soundValue.text = (gameSettingData.soundEffectValue * 100) + "%";
            _viewUI.txt_musicValue.text = (gameSettingData.musicValue * 100) + "%";
            _viewUI.slider_music.value = gameSettingData.musicValue * 100;
            _viewUI.slider_sound.value = gameSettingData.soundEffectValue * 100;

            (system.stage.getSystem(CAudioSystem) as CAudioSystem).audioVolume = gameSettingData.soundEffectValue;
            (system.stage.getSystem(CAudioSystem) as CAudioSystem).musicVolume = gameSettingData.musicValue;
        }
    }

    private function _onClickCheckBox(type:String):void
    {
        var obj:Object = {};
        switch (type)
        {
            case "banAddFriend":

                if(_viewUI.checkBox_shieldAll.selected)
                {
                    return;
                }

                obj[CGameSettingData.IsBanOtherAddFriend] = _viewUI.checkBox_banAddFriend.selected;
                break;
            case "shieldAll":
                obj[CGameSettingData.IsShieldAll] = _viewUI.checkBox_shieldAll.selected;

                _viewUI.checkBox_banAddFriend.selected = _viewUI.checkBox_shieldAll.selected;
                _viewUI.checkBox_shieldOther.selected = _viewUI.checkBox_shieldAll.selected;
                _viewUI.checkBox_shieldTitle.selected = _viewUI.checkBox_shieldAll.selected;
                _viewUI.checkBox_refusePeakPk.selected = _viewUI.checkBox_shieldAll.selected;
                obj[CGameSettingData.IsShieldOtherPlayers] = _viewUI.checkBox_shieldOther.selected;
                obj[CGameSettingData.IsShieldTitle] = _viewUI.checkBox_shieldTitle.selected;
                obj[CGameSettingData.IsBanOtherAddFriend] = _viewUI.checkBox_banAddFriend.selected;
                obj[CGameSettingData.IsRefusePeakPk] = _viewUI.checkBox_refusePeakPk.selected;
                isShieldPlayer = _viewUI.checkBox_shieldOther.selected;
                isShieldTitle = _viewUI.checkBox_shieldTitle.selected;
                break;
            case "shieldOther":
                if(_viewUI.checkBox_shieldAll.selected)
                {
                    return;
                }

                obj[CGameSettingData.IsShieldOtherPlayers] = _viewUI.checkBox_shieldOther.selected;
                isShieldPlayer = _viewUI.checkBox_shieldOther.selected;

                // 屏蔽玩家的同时屏蔽称号
                _viewUI.checkBox_shieldTitle.selected = _viewUI.checkBox_shieldOther.selected;
                obj[CGameSettingData.IsShieldTitle] = _viewUI.checkBox_shieldTitle.selected;
                isShieldTitle = _viewUI.checkBox_shieldTitle.selected;

                break;
            case "shieldTitle":
                if(_viewUI.checkBox_shieldAll.selected)
                {
                    return;
                }

                obj[CGameSettingData.IsShieldTitle] = _viewUI.checkBox_shieldTitle.selected;
                isShieldTitle = _viewUI.checkBox_shieldTitle.selected;
                break;
            case "refusePeakPk":
                if(_viewUI.checkBox_shieldAll.selected)
                {
                    return;
                }

                obj[CGameSettingData.IsRefusePeakPk] = _viewUI.checkBox_refusePeakPk.selected;
                break;
            case "closeSound":
                obj[CGameSettingData.IsCloseSound] = _viewUI.checkBox_closeSound.selected;
                _openOrCloseSound();
                break;
        }

        var gameSettingData:CGameSettingData = (system as CGameSettingSystem).gameSettingData;
        gameSettingData.updateDataByData(obj);

        if(type == "closeSound")
        {
            system.dispatchEvent(new CGameSettingEvent(CGameSettingEvent.SoundSynchUpdate,null));
        }

        _saveChange(obj);
    }

    private function _openOrCloseSound():void
    {
        if(_viewUI.checkBox_closeSound.selected)
        {
            (system.stage.getSystem(CAudioSystem) as CAudioSystem).audioVolume = 0;
            (system.stage.getSystem(CAudioSystem) as CAudioSystem).musicVolume = 0;
        }
        else
        {
            var gameSettingData:CGameSettingData = (system as CGameSettingSystem).gameSettingData;
            (system.stage.getSystem(CAudioSystem) as CAudioSystem).audioVolume = gameSettingData.soundEffectValue;
            (system.stage.getSystem(CAudioSystem) as CAudioSystem).musicVolume = gameSettingData.musicValue;
        }
    }

    private function _onSoundChangeHandler(value:Number):void
    {
        (system.stage.getSystem(CAudioSystem) as CAudioSystem).audioVolume = value * 0.01;
        _viewUI.txt_soundValue.text = value + "%";
    }

    private function _onMusicChangeHandler(value:Number):void
    {
        (system.stage.getSystem(CAudioSystem) as CAudioSystem).musicVolume = value * 0.01;
        _viewUI.txt_musicValue.text = value + "%";
    }

    private function _onMouseUpHandler(e:MouseEvent):void
    {
        var obj:Object = {};
        var gameSettingData:CGameSettingData = (system as CGameSettingSystem).gameSettingData;
        if((e.target as DisplayObject).parent == _viewUI.slider_music)
        {
            gameSettingData.musicValue = _viewUI.slider_music.value * 0.01;
            obj[CGameSettingData.MusicValue] = _viewUI.slider_music.value * 0.01;
        }

        if((e.target as DisplayObject).parent == _viewUI.slider_sound)
        {
            gameSettingData.soundEffectValue = _viewUI.slider_sound.value * 0.01;
            obj[CGameSettingData.SoundEffectValue] = _viewUI.slider_sound.value * 0.01;
        }

        _saveChange(obj);
    }

    private function _saveChange(obj:Object):void
    {
        (system.getHandler(CGameSettingNetHandler) as CGameSettingNetHandler).setGameSettingRequest(obj);
    }

    private function _onMusicDownHandler(e:MouseEvent):void
    {
        _viewUI.slider_music.addEventListener(MouseEvent.ROLL_OUT, _onMusicRollOutHandler);
    }

    private function _onMusicRollOutHandler(e:MouseEvent):void
    {
        _viewUI.slider_music.removeEventListener(MouseEvent.ROLL_OUT, _onMusicRollOutHandler);

        var obj:Object = {};
        var gameSettingData:CGameSettingData = (system as CGameSettingSystem).gameSettingData;
        gameSettingData.musicValue = _viewUI.slider_music.value * 0.01;
        obj[CGameSettingData.MusicValue] = _viewUI.slider_music.value * 0.01;

        _saveChange(obj);
    }

    private function _onSoundDownHandler(e:MouseEvent):void
    {
        _viewUI.slider_sound.addEventListener(MouseEvent.ROLL_OUT, _onSoundRollOutHandler);
    }

    private function _onSoundRollOutHandler(e:MouseEvent):void
    {
        _viewUI.slider_sound.removeEventListener(MouseEvent.ROLL_OUT, _onSoundRollOutHandler);

        var obj:Object = {};
        var gameSettingData:CGameSettingData = (system as CGameSettingSystem).gameSettingData;
        gameSettingData.soundEffectValue = _viewUI.slider_sound.value * 0.01;
        obj[CGameSettingData.SoundEffectValue] = _viewUI.slider_sound.value * 0.01;

        _saveChange(obj);
    }

    private function _onOpenOrCloseSound(e:Event):void
    {
        _viewUI.checkBox_closeSound.selected = !_viewUI.checkBox_closeSound.selected;
    }

    private function _onPeakPkSynchUpdate(e:CGameSettingEvent):void
    {
        _viewUI.checkBox_refusePeakPk.selected = e.data as Boolean;
    }

    protected function set isShieldPlayer( value : Boolean ) : void
    {
        (system as CGameSettingSystem).isShieldPlayer = value;
    }

    protected function set isShieldTitle( value : Boolean ) : void
    {
        (system as CGameSettingSystem).isShieldTitle = value;
    }

    override public function removeDisplay():void
    {
        super.removeDisplay();
    }

    private function get _viewUI():GameSettingMiscUI
    {
        return view as GameSettingMiscUI;
    }

    override public function dispose():void
    {
        super.dispose();
    }
}
}
