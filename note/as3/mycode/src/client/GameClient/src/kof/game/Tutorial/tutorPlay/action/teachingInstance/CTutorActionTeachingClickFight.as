//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/10.
 */
package kof.game.Tutorial.tutorPlay.action.teachingInstance {
import QFLib.Foundation;

import flash.events.MouseEvent;

import kof.framework.CAppSystem;
import kof.framework.events.CEventPriority;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.Tutorial.tutorPlay.action.CTutorActionBase;
import kof.game.teaching.CTeachingInstanceManager;
import kof.game.teaching.CTeachingInstanceSystem;
import kof.table.TeachingContent;
import kof.ui.master.Teaching.TeachingItemUI;
import kof.util.CAssertUtils;

import morn.core.components.Component;
import morn.core.components.List;

public class CTutorActionTeachingClickFight extends CTutorActionBase {

    public function CTutorActionTeachingClickFight( actionInfo : CTutorActionInfo, system : CAppSystem ) {
        super( actionInfo, system );
    }

    public override function dispose() : void {
        super.dispose();

    }

    override protected function startByUIComponent( comp : Component ) : void {
        CAssertUtils.assertNotNull( comp );

        startByList( comp as List );
    }

    protected function startByList( pList : List ) : void {
        if ( !pList )
            return;

        var idx : int = _targetIndex;
        var child : Component = pList.getCell( idx ) as Component;
        if ( child ) {
            (child as TeachingItemUI).btn_challenge.addEventListener(MouseEvent.CLICK, _comp_onMouseClickEventHandler, false, CEventPriority.BINDING, true);
            this.holeTarget = (child as TeachingItemUI).btn_challenge;
        } else {
            Foundation.Log.logWarningMsg("默认引导点击配置项" + this._info.ID + "作为List并不能找到下标为" +
                    idx + "的UI对象" );
        }
    }
    private function _comp_onMouseClickEventHandler( event : MouseEvent ) : void {
        event.currentTarget.removeEventListener( event.type, _comp_onMouseClickEventHandler );
        _actionValue = true;
        this.holeTarget = null;
    }

    override public function update(delta:Number) : void {
        super.update(delta);

        var targetTab:int = _targetTab;
        var isTabOk:Boolean = CTutorActionTeachingSelectTab.isSelectTab(_system, targetTab);
        if (!isTabOk) {
            // 强制回滚
            holeTarget = null;
            return ;
        }

        var targetIndex:int = _targetIndex;
        var pSystem:CTeachingInstanceSystem = _system.stage.getSystem(CTeachingInstanceSystem) as CTeachingInstanceSystem;
        var manager:CTeachingInstanceManager = (pSystem.getHandler(CTeachingInstanceManager) as CTeachingInstanceManager);
        var pTeachingList:Array = manager.getTeachingType(targetTab + 1);
        if (!pTeachingList) {
            // 数据异常, 直接完成
            _actionValue = true;
            return ;
        }
        if (targetIndex >= pTeachingList.length) {
            // 数据异常, 直接完成
            _actionValue = true;
            return ;
        }

        var teachingRecord:TeachingContent = pTeachingList[targetIndex];
        if (!teachingRecord) {
            // 没这个教学数据。直接完成
            _actionValue = true;
        } else {
            if( manager.getTeachingDataByID( teachingRecord.ID ) ){
                // 目标已完成
                _actionValue = true;
            } else {
                if(manager.challengeBool(teachingRecord.ID)){
                    // 可挑战
                    // 等玩家点挑战
                } else {
                    // 不可挑战
                    _actionValue = true;
                }
            }
        }
    }
    private function get _targetTab() : int {
        if (_info.actionParams && _info.actionParams.length > 0) {
            return _info.actionParams[0];
        }
        return 0;
    }
    private function get _targetIndex() : int {
        if (_info.actionParams && _info.actionParams.length > 1) {
            return _info.actionParams[1];
        }
        return 0;
    }
}
}

// vim:ft=as3 tw=120 ts=4 sw=4 expandtab
