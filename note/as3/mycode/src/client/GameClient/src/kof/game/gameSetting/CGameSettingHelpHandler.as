//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/1.
 */
package kof.game.gameSetting {

import QFLib.Foundation.CMap;

import flash.ui.Keyboard;

import kof.framework.CAbstractHandler;
import kof.game.gameSetting.CGameSettingData;
import kof.game.gameSetting.util.CGameSettingConst;
import kof.game.gameSetting.view.CFunctionSettiongPanel;
import kof.game.gameSetting.view.CKeyboardSettingPanel;
import kof.game.player.CPlayerSystem;
import kof.game.player.view.playerNew.data.CTabInfoData;

public class CGameSettingHelpHandler extends CAbstractHandler {

    private var _currSelPanelIndex:int;

    public function CGameSettingHelpHandler()
    {
        super();
    }

    public function getTabNameByIndex(tab:int) : String {
        if (0 == tab) {
            return "KeboardSetting";
        } else if (1 == tab) {
            return "FunctionSetting";
        }
        else
        {
            return "";
        }
    }

    public function getTabInfoData() : Vector.<CTabInfoData>
    {
        var tabDataVec : Vector.<CTabInfoData> = new Vector.<CTabInfoData>();
        var pageTabData : Array = [
            {"label" : "按键设置", "name" : "KeboardSetting"},
            {"label" : "功能设置", "name" : "FunctionSetting"}];

        for ( var i : int = 0; i < pageTabData.length; i++ )
        {
            var tabInfoData : CTabInfoData = new CTabInfoData();
            tabInfoData.tabIndex = i;
            tabInfoData.tabNameCN = pageTabData[ i ].label;
            tabInfoData.tabNameEN = pageTabData[ i ].name;
            tabInfoData.panelClass = getPanelClassByTabIndex( i );
//            tabInfoData.openLevel  = GameDefConfig.instance.getSystemOpenLevel(60+i);

            var playerLevel:int = getPlayerLevel();
            if ( playerLevel >= tabInfoData.openLevel || tabInfoData.hasGuideOpen )
            {
                tabDataVec.push( tabInfoData );
            }
        }

        return tabDataVec;
    }

    public function getPlayerLevel() : int
    {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.teamData.level;
    }

    private function getPanelClassByTabIndex(tabIndex:int):Class
    {
        var cls:Class;
        switch(tabIndex)
        {
            case CGameSettingConst.Panel_Index_FunctionSetting:
                cls = CFunctionSettiongPanel;
                break;
            case CGameSettingConst.Panel_Index_KeyboardSetting:
                cls = CKeyboardSettingPanel;
                break;
        }

        return cls;
    }

    public function getDirectionKeyData():Array
    {
        var resultArr:Array = [];
        var settingData:CGameSettingData = _manager.gameSettingData;
        if(settingData)
        {
            resultArr[0] = settingData.keyUpValue;
            resultArr[1] = settingData.keyLeftValue;
            resultArr[2] = settingData.keyDownValue;
            resultArr[3] = settingData.keyRightValue;
            resultArr[4] = settingData.keySwitchValue;
        }

        return resultArr;
    }

    public function getSkillKeyData():Array
    {
        var resultArr:Array = [];
        var settingData:CGameSettingData = _manager.gameSettingData;
        if(settingData)
        {
            resultArr[0] = settingData.attackKeyValue;
            resultArr[1] = settingData.skill1KeyValue;
            resultArr[2] = settingData.skill2KeyValue;
            resultArr[3] = settingData.skill3KeyValue;
            resultArr[4] = settingData.dodgeKeyValue;
            resultArr[5] = settingData.jumpKeyValue;
        }

        return resultArr;
    }

    public function isDirectionKey(keyCode:int):Boolean
    {
        return (keyCode >= Keyboard.A && keyCode <= Keyboard.Z) || (keyCode >= Keyboard.LEFT && keyCode <= Keyboard.DOWN);
    }

    public function isSkillKey(keyCode:int):Boolean
    {
        return (keyCode >= Keyboard.A && keyCode <= Keyboard.Z) || (keyCode >= Keyboard.NUMPAD_0 && keyCode <= Keyboard.NUMPAD_9);
    }

    public function get currSelPanel():int
    {
        return _currSelPanelIndex;
    }

    public function set currSelPanelIndex(value:int):void
    {
        _currSelPanelIndex = value;
    }

    private function get _manager():CGameSettingManager
    {
        return system.getHandler(CGameSettingManager) as CGameSettingManager;
    }
}
}
