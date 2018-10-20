//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/1.
 */
package kof.game.gameSetting.view {

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.gameSetting.CGameSettingData;
import kof.game.gameSetting.CGameSettingHelpHandler;
import kof.game.gameSetting.CGameSettingManager;
import kof.game.gameSetting.CGameSettingNetHandler;
import kof.game.gameSetting.util.CKeyMapping;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.master.gameSetting.GameSettingKeyRenderUI;
import kof.ui.master.gameSetting.GameSettingKeyUI;

import morn.core.components.Box;

import morn.core.components.Component;

import morn.core.handlers.Handler;

public class CKeyboardSettingPanel extends CGameSettingPanelBase {

    private var m_bIsSaved:Boolean;

    public function CKeyboardSettingPanel( bLoadViewByDefault : Boolean = false )
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

        m_pViewUI = new GameSettingKeyUI();

        _viewUI.btn_revert.clickHandler = new Handler(_onClickRevertHandler);
        _viewUI.btn_saveChange.clickHandler = new Handler(_onClickSaveChangeHandler);
        _viewUI.list_direction.renderHandler = new Handler(_renderDirection);

        _viewUI.list_skill.renderHandler = new Handler(_renderSkill);
//        _viewUI.list_skill.selectHandler = new Handler(_onSkillSelHandler);

        CSystemRuleUtil.setRuleTips(_viewUI.btn_tip1, CLang.Get("keyboardSetting"));
        CSystemRuleUtil.setRuleTips(_viewUI.btn_tip2, CLang.Get("skillSetting"));
    }

    override protected function _addListeners():void
    {
        super._addListeners();

        system.stage.flashStage.addEventListener(KeyboardEvent.KEY_DOWN, _onDirectionKeyDownHandler, false, 0, true);
        system.stage.flashStage.addEventListener(KeyboardEvent.KEY_DOWN, _onSkillKeyDownHandler, false, 0, true);

        _viewUI.list_direction.addEventListener(MouseEvent.CLICK, _onListClickHandler);
        _viewUI.list_skill.addEventListener(MouseEvent.CLICK, _onListClickHandler);
    }

    override protected function _removeListeners():void
    {
        super._removeListeners();

        system.stage.flashStage.removeEventListener(KeyboardEvent.KEY_DOWN, _onDirectionKeyDownHandler);
        system.stage.flashStage.removeEventListener(KeyboardEvent.KEY_DOWN, _onSkillKeyDownHandler);

        _viewUI.list_direction.removeEventListener(MouseEvent.CLICK, _onListClickHandler);
        _viewUI.list_skill.removeEventListener(MouseEvent.CLICK, _onListClickHandler);
    }

    override protected function _initView():void
    {
        _viewUI.list_direction.selectedIndex = -1;
        _viewUI.list_skill.selectedIndex = -1;

        updateDisplay();
    }

    override public function set data( value : * ) : void
    {
    }

    override protected function updateDisplay() : void
    {
        _updateDirectionList();
        _updateSkillList();
    }

    private function _updateDirectionList():void
    {
        _viewUI.list_direction.dataSource = _helper.getDirectionKeyData();
    }

    private function _updateSkillList():void
    {
        _viewUI.list_skill.dataSource = _helper.getSkillKeyData();
    }

    override public function removeDisplay():void
    {
        super.removeDisplay();

        m_bIsSaved = false;
    }

    private function _onClickRevertHandler():void
    {
        _viewUI.list_direction.selectedIndex = -1;
        _viewUI.list_skill.selectedIndex = -1;

        var arr1:Array = [Keyboard.W, Keyboard.A, Keyboard.S, Keyboard.D, Keyboard.Q];
        var arr2:Array = [Keyboard.J, Keyboard.U, Keyboard.I, Keyboard.O, Keyboard.L, Keyboard.K];

        _viewUI.list_direction.dataSource = arr1;
        _viewUI.list_skill.dataSource = arr2;
    }

    private function _onClickSaveChangeHandler():void
    {
        if(isKeyChange())
        {
            saveChange();
        }
    }

    public function isKeyChange():Boolean
    {
        var cells1:Vector.<Box> = _viewUI.list_direction.cells;
        var cells2:Vector.<Box> = _viewUI.list_skill.cells;

        var arr1:Array = _helper.getDirectionKeyData();
        var arr2:Array = _helper.getSkillKeyData();

        for(var i:int = 0; i < arr1.length; i++)
        {
            var keyCode:int = (cells1[i] as Component).dataSource as int;
            if(keyCode != arr1[i])
            {
                return true;
            }
        }

        for(i = 0; i < arr2.length; i++)
        {
            keyCode = (cells2[i] as Component).dataSource as int;
            if(keyCode != arr2[i])
            {
                return true;
            }
        }

        return false;
    }

    public function isKeyNull():Boolean
    {
        var cells1:Vector.<Box> = _viewUI.list_direction.cells;
        var cells2:Vector.<Box> = _viewUI.list_skill.cells;

        for(var i:int = 0; i < cells1.length; i++)
        {
            var keyCode:int = (cells1[i] as Component).dataSource as int;
            if(keyCode == 0)
            {
                return true;
            }
        }

        for(i = 0; i < cells2.length; i++)
        {
            keyCode = (cells2[i] as Component).dataSource as int;
            if(keyCode == 0)
            {
                return true;
            }
        }

        return false;
    }

    public function saveChange():void
    {
        if(isKeyNull())
        {
            (system.stage.getSystem(IUICanvas) as CUISystem).showMsgAlert("有键位尚未设置！", CMsgAlertHandler.WARNING);
            return;
        }

        var cells1:Vector.<Box> = _viewUI.list_direction.cells;
        var cells2:Vector.<Box> = _viewUI.list_skill.cells;

        var settingData:CGameSettingData = _manager.gameSettingData;
        if(settingData)
        {
            settingData.keyUpValue = cells1[0 ].dataSource as int;
            settingData.keyLeftValue = cells1[1 ].dataSource as int;
            settingData.keyDownValue = cells1[2 ].dataSource as int;
            settingData.keyRightValue = cells1[3 ].dataSource as int;
            settingData.keySwitchValue = cells1[4 ].dataSource as int;

            settingData.attackKeyValue = cells2[0 ].dataSource as int;
            settingData.skill1KeyValue = cells2[1 ].dataSource as int;
            settingData.skill2KeyValue = cells2[2 ].dataSource as int;
            settingData.skill3KeyValue = cells2[3 ].dataSource as int;
            settingData.dodgeKeyValue = cells2[4 ].dataSource as int;
            settingData.jumpKeyValue = cells2[5 ].dataSource as int;

            _viewUI.list_direction.selectedIndex = -1;
            _viewUI.list_skill.selectedIndex = -1;

            (system.getHandler(CGameSettingNetHandler) as CGameSettingNetHandler).setGameSettingRequest(_manager.objData);
            (system.stage.getSystem(IUICanvas) as CUISystem).showMsgAlert("保存成功！", CMsgAlertHandler.NORMAL);
            m_bIsSaved = true;
        }
    }

//render==============================================================================================================
    private function _renderDirection(item:Component, index:int):void
    {
        if(!(item is GameSettingKeyRenderUI))
        {
            return;
        }

        item.mouseChildren = false;
        item.mouseEnabled = true;

        var keyCode:int = item.dataSource as int;
        var keyName:String = CKeyMapping.getKeyNameByKeyCode(keyCode);

        (item as GameSettingKeyRenderUI).txt_direction.text = keyName;

        if(index == 4)
        {
            item.y = 133;
        }
    }

    private function _renderSkill(item:Component, index:int):void
    {
        if(!(item is GameSettingKeyRenderUI))
        {
            return;
        }

        item.mouseChildren = false;
        item.mouseEnabled = true;

        var keyCode:int = item.dataSource as int;
        var keyName:String = CKeyMapping.getKeyNameByKeyCode(keyCode);

        (item as GameSettingKeyRenderUI).txt_direction.text = keyName;
    }

//监听==================================================================================================================
    private function _onDirectionKeyDownHandler( e:KeyboardEvent ) : void
    {
        if(_viewUI.list_direction.selectedIndex != -1)
        {
            if(!_helper.isDirectionKey(e.keyCode))
            {
                return;
            }

            var selItem:GameSettingKeyRenderUI = _viewUI.list_direction.selection as GameSettingKeyRenderUI;

//            if(_clearConflictKey(e.keyCode, selItem))
//            {
//                (system.stage.getSystem(IUICanvas) as CUISystem).showMsgAlert("按键设置冲突");
//                return;
//            }

            _clearConflictKey(e.keyCode, selItem);

            if(selItem)
            {
                var keyName:String = CKeyMapping.getKeyNameByKeyCode(e.keyCode);
                if(keyName)
                {
                    selItem.dataSource = e.keyCode;
                    _renderDirection(selItem, _viewUI.list_direction.selectedIndex);
                }
            }
        }
    }

    private function _onSkillKeyDownHandler( e:KeyboardEvent ) : void
    {
        if(_viewUI.list_skill.selectedIndex != -1)
        {
            if(!_helper.isSkillKey(e.keyCode))
            {
                return;
            }

            var selItem:GameSettingKeyRenderUI = _viewUI.list_skill.selection as GameSettingKeyRenderUI;

//            if(_isKeyConflict(e.keyCode, selItem))
//            {
//                (system.stage.getSystem(IUICanvas) as CUISystem).showMsgAlert("按键设置冲突");
//                return;
//            }

            _clearConflictKey(e.keyCode, selItem);

            if(selItem)
            {
                var keyName:String = CKeyMapping.getKeyNameByKeyCode(e.keyCode);
                if(keyName)
                {
                    selItem.dataSource = e.keyCode;
                    _renderSkill(selItem, _viewUI.list_skill.selectedIndex);
                }
            }
        }
    }

    private function _onListClickHandler(e:MouseEvent):void
    {
        if( e.currentTarget == _viewUI.list_direction)
        {
            if(_viewUI.list_skill.selectedIndex != -1)
            {
                _viewUI.list_skill.selectedIndex = -1;
            }
        }

        if( e.currentTarget == _viewUI.list_skill)
        {
            if(_viewUI.list_direction.selectedIndex != -1)
            {
                _viewUI.list_direction.selectedIndex = -1;
            }
        }
    }

    // 清空冲突的键
    private function _clearConflictKey(keyCode:int, selItem:GameSettingKeyRenderUI):Boolean
    {
        var isConflict:Boolean;
        var cells:Vector.<Box> = _viewUI.list_direction.cells;
        for(var i:int = 0; i < cells.length; i++)
        {
            if(cells[i] == selItem)
            {
                continue;
            }

            if(cells[i].dataSource == keyCode)
            {
                cells[i].dataSource = 0;
                _renderDirection(cells[i], i);
                isConflict = true;
            }
        }

        cells = _viewUI.list_skill.cells;
        for(i = 0; i < cells.length; i++)
        {
            if(cells[i] == selItem)
            {
                continue;
            }

            if(cells[i].dataSource == keyCode)
            {
                cells[i].dataSource = 0;
                _renderSkill(cells[i], i);
                isConflict = true;
            }
        }

        return isConflict;
    }

//property==============================================================================================================
    private function get _viewUI():GameSettingKeyUI
    {
        return view as GameSettingKeyUI;
    }

    private function get _helper():CGameSettingHelpHandler
    {
        return system.getHandler(CGameSettingHelpHandler) as CGameSettingHelpHandler;
    }

    private function get _manager():CGameSettingManager
    {
        return system.getHandler(CGameSettingManager) as CGameSettingManager;
    }

    public function get isSaved():Boolean
    {
        return m_bIsSaved;
    }

    override public function dispose():void
    {
        super.dispose();
    }

}
}
