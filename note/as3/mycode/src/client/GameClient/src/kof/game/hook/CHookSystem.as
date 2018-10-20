//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/17.
 * Time: 10:16
 */
package kof.game.hook {

import QFLib.Interface.IUpdatable;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.system.System;
import flash.utils.Timer;
import flash.utils.getTimer;

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.Tutorial.CTutorSystem;
import kof.game.audio.CAudioSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.status.CGameStatus;
import kof.game.common.system.CAppSystemImp;
import kof.game.endlessTower.CEndlessTowerSystem;
import kof.game.gameSetting.CGameSettingData;
import kof.game.gameSetting.CGameSettingSystem;
import kof.game.gameSetting.event.CGameSettingEvent;
import kof.game.gameSetting.event.CGameSettingEvent;
import kof.game.hook.net.CHookNetDataManager;
import kof.game.instance.CInstanceSystem;
import kof.game.peakGame.enum.EPeakGameWndType;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.ui.CUISystem;

import morn.core.handlers.Handler;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/7/17
 */
public class CHookSystem extends CAppSystemImp implements IUpdatable {
    private var _pHookViewHandler : CHookViewHandler = null;
    private var _pHookHandler : CHookHandler = null;

    private var _bIsInitialize : Boolean = false;
    private var _lastPressTime : int = 0;
    private var m_bOriginState:Boolean;
    private var _saveCloseSound : Boolean;
    private var _exceptIDList:Array = [];

    public function CHookSystem() {
        super();
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.HOOK );
    }

    public override function dispose() : void {
        super.dispose();
        _pHookViewHandler = null;
        _pHookHandler = null;
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;
        if ( !_bIsInitialize ) {
            _bIsInitialize = true;
            this.addBean( _pHookHandler = new CHookHandler() );
            this.addBean( _pHookViewHandler = new CHookViewHandler() );
            this._initialize();
        }
        return _bIsInitialize;
    }

    private function _initialize() : void {
        CHookClientFacade.instance.hookSystem = this;
        this._pHookViewHandler = getBean( CHookViewHandler );
        _pHookViewHandler.closeHandler = new Handler( _closeView );
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        if ( value ) {
            if (CGameStatus.isNotStatus(CGameStatus.Status_Hook) && CGameStatus.checkStatus(this) == false) {
                this.setActivated( false );
            } else {
                var settingData:CGameSettingData = (stage.getSystem(CGameSettingSystem) as CGameSettingSystem).gameSettingData;
                _saveCloseSound = settingData.isCloseSound;
                CGameStatus.setStatus(CGameStatus.Status_Hook);
//                    (this.stage.getSystem( CAudioSystem ) as CAudioSystem).audioVolume = 0;
//                    (this.stage.getSystem( CAudioSystem ) as CAudioSystem).musicVolume = 0;
                var gameSettingData:CGameSettingData = (stage.getSystem(CGameSettingSystem) as CGameSettingSystem).gameSettingData;

                if(gameSettingData)
                {
                    m_bOriginState = gameSettingData.isCloseSound;
                    if(!gameSettingData.isCloseSound)
                    {
                        gameSettingData.isCloseSound = false;
                        stage.getSystem(CGameSettingSystem ).dispatchEvent(new CGameSettingEvent(CGameSettingEvent.OpenOrCloseSound, null));
                    }
                }

                _pHookViewHandler.show();
                closeAllSystemBundle(_exceptIDList);

            }
        }
        else {
//            gameSettingData = (stage.getSystem(CGameSettingSystem) as CGameSettingSystem).gameSettingData;
//            if(gameSettingData && gameSettingData.isCloseSound != m_bOriginState)
//            {
//                gameSettingData.isCloseSound = m_bOriginState;
//                stage.getSystem(CGameSettingSystem ).dispatchEvent(new CGameSettingEvent(CGameSettingEvent.OpenOrCloseSound, null));
//            }
//                (this.stage.getSystem( CAudioSystem ) as CAudioSystem).audioVolume = 1;
//                (this.stage.getSystem( CAudioSystem ) as CAudioSystem).musicVolume = 1;


            //挂机前的是否处于静音状态
            var settingDataSound:CGameSettingData = (stage.getSystem(CGameSettingSystem) as CGameSettingSystem).gameSettingData;
            settingDataSound.isCloseSound = _saveCloseSound;
            if(settingDataSound.isCloseSound)
            {
                (stage.getSystem(CAudioSystem) as CAudioSystem).audioVolume = 0;
                (stage.getSystem(CAudioSystem) as CAudioSystem).musicVolume = 0;
            }
            else
            {
                (stage.getSystem(CAudioSystem) as CAudioSystem).audioVolume = settingDataSound.soundEffectValue;
                (stage.getSystem(CAudioSystem) as CAudioSystem).musicVolume = settingDataSound.musicValue;
            }

            CGameStatus.unSetStatus(CGameStatus.Status_Hook);
            _pHookViewHandler.close();
            this.dispatchEvent(new Event("deActivated"));
        }
    }

    protected override function onBundleStart(pCtx : ISystemBundleContext) : void {
        _lastPressTime = getTimer();
        var timer:Timer = new Timer(15000);
        timer.start();
        timer.addEventListener(TimerEvent.TIMER, openHook);

//            stage.addUITick(openHook);
        stage.flashStage.addEventListener(MouseEvent.CLICK, openHookZero);
        stage.flashStage.addEventListener(KeyboardEvent.KEY_DOWN, openHookZero);

        _exceptIDList = [SYSTEM_ID( KOFSysTags.HOOK ),
                         SYSTEM_ID( KOFSysTags.SYSTEM_NOTICE ),
                         SYSTEM_ID(KOFSysTags.GUILDWAR)];
    }

    private function openHook(e:*):void
    {
        var curTime:int = getTimer();
        var deltaTime:int = curTime - _lastPressTime;
        if (deltaTime > 180000) {
            var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
            if(pInstanceSystem.isMainCity)
            {
                var towerSystem:CEndlessTowerSystem = stage.getSystem(CEndlessTowerSystem) as CEndlessTowerSystem;
                if(!towerSystem.isInAutoChallenge)
                {
//                    var pTutorSystem:CTutorSystem = stage.getSystem(CTutorSystem) as CTutorSystem;
//                    if(!pTutorSystem.isPlaying)
//                    {}
//                    var levelPlayerData:CPlayerData = (stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
//                    //判断是否达到14级
//                    if(levelPlayerData.teamData.level >= 14)
                    //打开挂机界面
                    if(CGameStatus.checkStatus(this, false))
                    {
                        var pUISys : CUISystem = stage.getSystem( CUISystem ) as CUISystem;
                        if ( pUISys ) {
                            if ( pUISys.countOfUIPageLoadingRequests > 0 ) {
                                return ;
                            }
                        }
                        setActived(true);
                    }
                }
            }
        }
    }

    private function openHookZero(e:*):void
    {
        _lastPressTime = getTimer();
    }

    private function _closeView() : void {
        this.setActivated( false );
    }

    public function update( delta : Number ) : void {
        if ( _pHookViewHandler ) {
            _pHookViewHandler.update( delta );
        }
    }
}
}
