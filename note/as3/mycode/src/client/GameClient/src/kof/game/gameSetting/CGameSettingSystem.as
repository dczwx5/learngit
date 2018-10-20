//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/1.
 */
package kof.game.gameSetting {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.audio.CAudioSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.ICharacterProfile;
import kof.game.character.scripts.CHornorTitleComponent;
import kof.game.common.CLang;
import kof.game.core.CECSLoop;
import kof.game.gameSetting.event.CGameSettingEvent;
import kof.game.gameSetting.util.CKeyMapping;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.event.CInstanceEvent;
import kof.ui.CMsgAlertHandler;
import kof.ui.IUICanvas;

import morn.core.handlers.Handler;

/**
 * 游戏设置
 */
public class CGameSettingSystem extends CBundleSystem implements IGameSetting{

    private var m_bInitialized : Boolean;
    private var m_pMainViewHandler:CGameSettingViewHandler;

    public function CGameSettingSystem() {
        super();
    }

    override public function initialize() : Boolean
    {
        if ( !super.initialize() )
        {
            return false;
        }

        if ( !m_bInitialized )
        {
            m_bInitialized = true;

            m_pMainViewHandler = new CGameSettingViewHandler();
            this.addBean( m_pMainViewHandler );
            m_pMainViewHandler.closeHandler = new Handler( _onViewClosed );

            this.addBean( new CGameSettingHelpHandler() );
            this.addBean( new CGameSettingManager() );
            this.addBean( new CGameSettingNetHandler() );
        }

        return m_bInitialized;
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID(KOFSysTags.GAMESETTING);
    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void
    {
        super.onBundleStart(ctx);

        _initSettingState();
        addEventListeners();
    }

    private function _initSettingState():void
    {
        isShieldPlayer = gameSettingData.isShieldOtherPlayers;
        _initSoundState();
    }

    protected function addEventListeners() : void
    {
        stage.getSystem(ISystemBundleContext).addEventListener(CSystemBundleEvent.USER_DATA,_onUserDataHandler);
        stage.getSystem(CInstanceSystem ).addEventListener(CInstanceEvent.ENTER_INSTANCE, _onEnterInstanceHandler);
        this.addEventListener(CGameSettingEvent.OpenOrCloseSound, _onOpenOrCloseSoundHandler);
        this.addEventListener(CGameSettingEvent.PeakPkSynchUpdate, _onPeakPkSynchUpdate);
    }

    protected function removeEventListeners() : void
    {
        stage.getSystem(ISystemBundleContext).removeEventListener(CSystemBundleEvent.USER_DATA,_onUserDataHandler);
        stage.getSystem(CInstanceSystem ).removeEventListener(CInstanceEvent.ENTER_INSTANCE, _onEnterInstanceHandler);
        this.removeEventListener(CGameSettingEvent.OpenOrCloseSound, _onOpenOrCloseSoundHandler);
        this.removeEventListener(CGameSettingEvent.PeakPkSynchUpdate, _onPeakPkSynchUpdate);
    }

    override protected function onActivated( value : Boolean ) : void
    {
        super.onActivated( value );

        var pView : CGameSettingViewHandler = this.getHandler( CGameSettingViewHandler ) as CGameSettingViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the CEndlessTowerMainViewHandler isn't instance." );
            return;
        }

        if ( value )
        {
            pView.addDisplay();
        }
        else
        {
            if(pView.isKeyNull() && !pView.isSaved())
            {
                (stage.getSystem( IUICanvas ) as IUICanvas).showMsgAlert("有键位尚未设置",CMsgAlertHandler.WARNING);
//                this.setActivated( true );
            }
            else if(pView.isKeyChange() && !pView.isSaved())
            {
                (stage.getSystem( IUICanvas ) as IUICanvas).showMsgAlert("有键位尚未保存",CMsgAlertHandler.WARNING);
//                this.setActivated( true );
            }
            else
            {
//                pView.removeDisplay();
            }

            pView.removeDisplay();
        }
    }

    private function _onViewClosed() : void
    {
        this.setActivated( false );
    }

    private function _onUserDataHandler(e:CSystemBundleEvent):void
    {
    }

    private function _onOpenOrCloseSoundHandler(e:CGameSettingEvent):void
    {
        var obj:Object = {};
        gameSettingData.isCloseSound = !gameSettingData.isCloseSound;
        obj[CGameSettingData.IsCloseSound] = gameSettingData.isCloseSound;

        if(gameSettingData.isCloseSound)
        {
            (stage.getSystem(CAudioSystem) as CAudioSystem).audioVolume = 0;
            (stage.getSystem(CAudioSystem) as CAudioSystem).musicVolume = 0;
        }
        else
        {
            (stage.getSystem(CAudioSystem) as CAudioSystem).audioVolume = gameSettingData.soundEffectValue;
            (stage.getSystem(CAudioSystem) as CAudioSystem).musicVolume = gameSettingData.musicValue;
        }

        this.dispatchEvent(new CGameSettingEvent(CGameSettingEvent.SoundSynchUpdate,null));
        (getHandler(CGameSettingNetHandler) as CGameSettingNetHandler).setGameSettingRequest(obj);
    }

    private function _onEnterInstanceHandler(e:CInstanceEvent):void
    {
        var instanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(instanceSystem)
        {
            if(instanceSystem.isMainCity)
            {
                isShieldPlayer = gameSettingData.isShieldOtherPlayers;
            }
            else
            {
                isShieldPlayer = false;
            }
        }
    }

    private function _onPeakPkSynchUpdate(e:CGameSettingEvent):void
    {
        var state:Boolean = e.data as Boolean;
        gameSettingData.isRefusePeakPk = state;

        var obj:Object = {};
        obj[CGameSettingData.IsRefusePeakPk] = state;
        (getHandler(CGameSettingNetHandler) as CGameSettingNetHandler).setGameSettingRequest(obj);
    }

    public function get gameSettingData():CGameSettingData
    {
        return (getHandler(CGameSettingManager) as CGameSettingManager).gameSettingData;
    }

    public function set isShieldPlayer( value : Boolean ) : void
    {
        var pLoop : CECSLoop = stage.getSystem( CECSLoop ) as CECSLoop;
        if ( pLoop )
        {
            var pCharacterProfile : ICharacterProfile = pLoop.getBean( ICharacterProfile ) as ICharacterProfile;
            if ( pCharacterProfile )
            {
                var instanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
                if(instanceSystem)
                {
                    pCharacterProfile.isNeedChange = instanceSystem.isMainCity;
                }

                pCharacterProfile.playerDisplayed = !value;
            }
        }
    }

    public function set isShieldTitle( value : Boolean ) : void
    {
        var pLoop : CECSLoop = stage.getSystem( CECSLoop ) as CECSLoop;
        if ( pLoop )
        {
            var pCharacterProfile : ICharacterProfile = pLoop.getBean( ICharacterProfile ) as ICharacterProfile;
            if ( pCharacterProfile )
            {
                var instanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
                if(instanceSystem)
                {
                    pCharacterProfile.isNeedChange = instanceSystem.isMainCity;
                }

                pCharacterProfile.playerTitleDisplayed = !value;
            }
        }
    }

    private function _initSoundState():void
    {
        if(gameSettingData.isCloseSound)
        {
            (stage.getSystem(CAudioSystem) as CAudioSystem).audioVolume = 0;
            (stage.getSystem(CAudioSystem) as CAudioSystem).musicVolume = 0;
        }
        else
        {
            (stage.getSystem(CAudioSystem) as CAudioSystem).audioVolume = gameSettingData.soundEffectValue;
            (stage.getSystem(CAudioSystem) as CAudioSystem).musicVolume = gameSettingData.musicValue;
        }
    }

    public function getSkillKeyNameByIndex(index:int):String
    {
        var data:CGameSettingData = (this.getHandler(CGameSettingManager) as CGameSettingManager).gameSettingData;
        var keyName:String = "";
        switch (index)
        {
            case 0:
                keyName = CKeyMapping.getKeyNameByKeyCode(data.attackKeyValue);
                break;
            case 1:
                keyName = CKeyMapping.getKeyNameByKeyCode(data.skill1KeyValue);
                break;
            case 2:
                keyName = CKeyMapping.getKeyNameByKeyCode(data.skill2KeyValue);
                break;
            case 3:
                keyName = CKeyMapping.getKeyNameByKeyCode(data.skill3KeyValue);
                break;
            case 4:
                keyName = CKeyMapping.getKeyNameByKeyCode(data.dodgeKeyValue);
                break;
            case 5:
                keyName = "SPACE";
                break;
        }

        return keyName;
    }

    override public function dispose() : void
    {
        super.dispose();

        removeEventListeners();

        m_pMainViewHandler.dispose();
        m_pMainViewHandler = null;
    }
}
}
