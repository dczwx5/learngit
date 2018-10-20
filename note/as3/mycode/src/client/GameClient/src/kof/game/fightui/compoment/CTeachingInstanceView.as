//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/2/2.
 */
package kof.game.fightui.compoment {

import QFLib.Utils.PathUtil;

import kof.framework.CViewHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.table.TeachingGoal;
import kof.ui.demo.FightUI;

import morn.core.handlers.Handler;

public class CTeachingInstanceView extends CViewHandler {
    private var _bViewInitialized : Boolean = false;
    private var _fightUI : FightUI = null;
    private var m_pTeachingData:TeachingGoal;
    private var m_clipName:String = "frameclip_0";
    public function CTeachingInstanceView( fightUI : FightUI) {
        super();
        this._fightUI = fightUI;
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected function onSetup() : Boolean {
        if ( !super.onInitializeView() )
            return false;
        if ( !_bViewInitialized ) {
            (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).addEventListener( CInstanceEvent.ENTER_INSTANCE, _enterInstance );
            _bViewInitialized = true;
        }
        return _bViewInitialized;
    }

    private function _enterInstance( e : CInstanceEvent ) : void {
        _fightUI.box_teaching.visible = false;
        var _instanceDate:CChapterInstanceData = (system.stage.getSystem(CInstanceSystem) as CInstanceSystem).getInstanceByID(int(e.data));
        if ( _instanceDate.instanceType == EInstanceType.TYPE_TEACHING ) {
            _addEvent();
        }
    }

    private function _endInstance( e : CInstanceEvent ) : void {
        _fightUI.box_teaching.visible = false;
        _removeEvent();
    }

    public function showTeachingView(teachingData:TeachingGoal) : void {
        m_pTeachingData = teachingData;
        _fightUI.img_teachingGoalDes.url = getUIPath();
        _fightUI.box_teaching.visible = true;
        _fightUI.text_des.text = m_pTeachingData.GoalTxt;
        _fightUI.clip_teachingNumber.skin = m_clipName+1;
        _fightUI.clip_teachingNumber.index = 0;
        _fightUI.text_goalNumber.text = "/"+m_pTeachingData.Goalnumber.toString();
    }

    public function update(count:int):void{
        _fightUI.text_goalNumber.text = "/"+m_pTeachingData.Goalnumber.toString();
        _fightUI.clip_teachingNumber.skin = m_clipName+count;
        _fightUI.clip_teachingNumber.index = 0;
        _fightUI.clip_teachingNumber.playFromTo(0,_fightUI.clip_teachingNumber.totalFrame - 1, new Handler(onComplete));
    }

    private function onComplete():void{
        _fightUI.clip_teachingNumber.stop();
    }

    private function _addEvent() : void {
        (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).addEventListener( CInstanceEvent.STOP_INSTANCE, _endInstance );
    }

    private function _removeEvent():void{
        (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).removeEventListener( CInstanceEvent.STOP_INSTANCE, _endInstance );
    }

    private function getUIPath() : String {
        var url:String = "icon/teaching/" + m_pTeachingData.Uiname + ".png";
        return PathUtil.getVUrl(url);
    }
}
}
