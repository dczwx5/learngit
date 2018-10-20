//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/1/23.
 */
package kof.game.level.teaching {

import QFLib.Foundation;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.game.fightui.CFightViewHandler;
import kof.game.fightui.compoment.CTeachingInstanceView;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.event.CInstanceEvent;
import kof.game.level.CLevelHandler;
import kof.game.level.teaching.courses.CTeachingAirComboSkill;
import kof.game.level.teaching.courses.CTeachingAirSkill;
import kof.game.level.teaching.courses.CTeachingCancelCD;
import kof.game.level.teaching.courses.CTeachingChangePlayer;
import kof.game.level.teaching.courses.CTeachingCharge;
import kof.game.level.teaching.courses.CTeachingCommonAttack;
import kof.game.level.teaching.courses.CTeachingDodge;
import kof.game.level.teaching.courses.CTeachingFloorComboSkill;
import kof.game.level.teaching.courses.CTeachingFloorSkill;
import kof.game.level.teaching.courses.CTeachingGrabSkill;
import kof.game.level.teaching.courses.CTeachingHighGradeCombo;
import kof.game.level.teaching.courses.CTeachingHighGradeCombo2;
import kof.game.level.teaching.courses.CTeachingPrimaryCombo;
import kof.game.level.teaching.courses.CTeachingSeniorCombo;
import kof.game.level.teaching.courses.CTeachingSeniorStorageSkill;
import kof.game.level.teaching.courses.CTeachingSkillCD;
import kof.game.level.teaching.courses.CTeachingStorageSkill;
import kof.game.level.teaching.courses.CTeachingSuperSkill;
import kof.game.lobby.CLobbySystem;
import kof.table.TeachingGoal;

public class CTeachingHandler extends CAbstractHandler {

    static private var s_pTeachingHandlers : Vector.<Class>;

    private var m_pTeachingCourse:CTeachingCourseBasics;

    private var m_pTeachingData:TeachingGoal;

    private var m_pTeachingInstanceView:CTeachingInstanceView;
    public function CTeachingHandler() {
        super();

        if ( !s_pTeachingHandlers ) {
            s_pTeachingHandlers = new <Class>[];
            s_pTeachingHandlers.push( CTeachingCommonAttack );
            s_pTeachingHandlers.push( CTeachingPrimaryCombo );
            s_pTeachingHandlers.push( CTeachingSuperSkill );
            s_pTeachingHandlers.push( CTeachingChangePlayer );
            s_pTeachingHandlers.push( CTeachingDodge );
            s_pTeachingHandlers.push( CTeachingDodge );
            s_pTeachingHandlers.push( CTeachingSeniorCombo );
            s_pTeachingHandlers.push( CTeachingCharge );
            s_pTeachingHandlers.push( CTeachingCharge );
            s_pTeachingHandlers.push( CTeachingGrabSkill );
            s_pTeachingHandlers.push( CTeachingGrabSkill );
            s_pTeachingHandlers.push( CTeachingFloorSkill );
            s_pTeachingHandlers.push( CTeachingFloorComboSkill );
            s_pTeachingHandlers.push( CTeachingStorageSkill );
            s_pTeachingHandlers.push( CTeachingSeniorStorageSkill );
            s_pTeachingHandlers.push( CTeachingAirSkill );
            s_pTeachingHandlers.push( CTeachingAirComboSkill );
            s_pTeachingHandlers.push( CTeachingHighGradeCombo );
            s_pTeachingHandlers.push( CTeachingHighGradeCombo2 );
            s_pTeachingHandlers.push( CTeachingSkillCD );
            s_pTeachingHandlers.push( CTeachingCancelCD );
        }
    }

    private function _endInstance( e : CInstanceEvent ) : void {
//        (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).removeEventListener( CInstanceEvent.STOP_INSTANCE, _endInstance );
        (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).removeEventListener( CInstanceEvent.NET_EVENT_LEVEL_ENTER, _endInstance );

        if(m_pTeachingCourse){
            m_pTeachingCourse.dispose();
            m_pTeachingCourse = null;
        }
    }

    public function executeTeaching( teachingGoalID : int ) : void {
//        (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).addEventListener( CInstanceEvent.STOP_INSTANCE, _endInstance );
        (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).addEventListener( CInstanceEvent.NET_EVENT_LEVEL_ENTER, _endInstance );

        if(m_pTeachingInstanceView == null){
            var pLobbySystem:CLobbySystem = system.stage.getSystem( CLobbySystem ) as CLobbySystem;
            m_pTeachingInstanceView = pLobbySystem.getHandler(CFightViewHandler ).getBean(CTeachingInstanceView);
        }

        m_pTeachingData = getTeachingGoalTableByID(teachingGoalID);
        m_pTeachingInstanceView.showTeachingView(m_pTeachingData);


        var teachingID: int = m_pTeachingData.ID - 1;
        if ( teachingID < s_pTeachingHandlers.length ) {
            // It have a valid appear action handler.
            var pHandlerClass : Class = s_pTeachingHandlers[ teachingID ];
            if ( !pHandlerClass )
                Foundation.Log.logWarningMsg( "There's no specified teaching action handler for ID: " +
                        teachingID.toString() + ", Fallback to normal action." );
            m_pTeachingCourse = new pHandlerClass( m_pTeachingData,system );
            m_pTeachingCourse.execute( _onCompleted );
        }else{
            _onCompleted();
        }
    }

    private function _onCompleted(count:int = 0) : void {
        m_pTeachingInstanceView.update(count);
        if(count>=m_pTeachingData.Goalnumber){
            if(m_pTeachingCourse){
                m_pTeachingCourse.dispose();
                m_pTeachingCourse = null;
            }

            (system.getBean(CLevelHandler) as CLevelHandler).sendAchieveTeachEventRequest(m_pTeachingData.ID);
        }
    }

    private function getTeachingGoalTableByID(id:int):TeachingGoal{
        var teachingTable : IDataTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.TEACHINGGOAL );
        var teachingGoalObj : TeachingGoal = teachingTable.findByPrimaryKey(id);
        return teachingGoalObj;
    }

}
}
