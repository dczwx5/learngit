//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/2.
 */
package kof.game.gameSetting {

import flash.ui.Keyboard;

import kof.framework.CAbstractHandler;
import kof.framework.IDatabase;

public class CGameSettingManager extends CAbstractHandler {

    private var m_pGameSettingData:CGameSettingData;

    public function CGameSettingManager()
    {
        super();
    }

    public function get gameSettingData():CGameSettingData
    {
        if(m_pGameSettingData == null)
        {
            m_pGameSettingData = new CGameSettingData();
            m_pGameSettingData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;

            m_pGameSettingData.keyUpValue = Keyboard.W;
            m_pGameSettingData.keyLeftValue = Keyboard.A;
            m_pGameSettingData.keyDownValue = Keyboard.S;
            m_pGameSettingData.keyRightValue = Keyboard.D;
            m_pGameSettingData.keySwitchValue = Keyboard.Q;

            m_pGameSettingData.attackKeyValue = Keyboard.J;
            m_pGameSettingData.skill1KeyValue = Keyboard.U;
            m_pGameSettingData.skill2KeyValue = Keyboard.I;
            m_pGameSettingData.skill3KeyValue = Keyboard.O;
            m_pGameSettingData.dodgeKeyValue = Keyboard.L;
            m_pGameSettingData.jumpKeyValue = Keyboard.K;

            m_pGameSettingData.musicValue = 1;
            m_pGameSettingData.soundEffectValue = 1;
        }

        return m_pGameSettingData;
    }

    public function get objData():Object
    {
        var obj:Object = {};
        obj[CGameSettingData.KeyUp] = gameSettingData.keyUpValue;
        obj[CGameSettingData.KeyDown] = gameSettingData.keyDownValue;
        obj[CGameSettingData.KeyLeft] = gameSettingData.keyLeftValue;
        obj[CGameSettingData.KeyRight] = gameSettingData.keyRightValue;
        obj[CGameSettingData.KeySwitch] = gameSettingData.keySwitchValue;
        obj[CGameSettingData.Attack] = gameSettingData.attackKeyValue;
        obj[CGameSettingData.Skill1] = gameSettingData.skill1KeyValue;
        obj[CGameSettingData.Skill2] = gameSettingData.skill2KeyValue;
        obj[CGameSettingData.Skill3] = gameSettingData.skill3KeyValue;
        obj[CGameSettingData.Dodge] = gameSettingData.dodgeKeyValue;
        obj[CGameSettingData.Jump] = gameSettingData.jumpKeyValue;
        obj[CGameSettingData.IsBanOtherAddFriend] = gameSettingData.isBanOtherAddFriend;
        obj[CGameSettingData.IsCloseSound] = gameSettingData.isCloseSound;
        obj[CGameSettingData.IsShieldAll] = gameSettingData.isShieldAll;
//        obj[CGameSettingData.IsShieldOtherEffect] = gameSettingData.isShieldOtherEffect;
        obj[CGameSettingData.IsShieldOtherPlayers] = gameSettingData.isShieldOtherPlayers;
        obj[CGameSettingData.IsRefusePeakPk] = gameSettingData.isRefusePeakPk;
        obj[CGameSettingData.SoundEffectValue] = gameSettingData.soundEffectValue;
        obj[CGameSettingData.MusicValue] = gameSettingData.musicValue;
        obj[CGameSettingData.IsShieldTitle] = gameSettingData.isShieldTitle;

        return obj;
    }

    public function updateGameSettingData(data:Object):void
    {
        if(data)
        {
            gameSettingData.updateDataByData(data);
        }
    }
}
}
