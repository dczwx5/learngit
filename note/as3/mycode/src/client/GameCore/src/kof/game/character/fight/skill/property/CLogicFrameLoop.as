//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2018/1/1.
//----------------------------------------------------------------------
package kof.game.character.fight.skill.property {

import QFLib.Interface.IUpdatable;

import kof.game.character.fight.skill.CSkillCaster;

import kof.game.character.fight.skill.CSkillDataBase;

public class CLogicFrameLoop implements IUpdatable {

    public function CLogicFrameLoop( callBack : Function ) {
        resetLoop();
        m_timeForLogicFrame = CSkillDataBase.TIME_IN_ONEFRAME;
        m_atomFrameTime = 0.017;
        m_timeForResetLoop = m_timeForLogicFrame * 100;
        m_frameTicCallBack = callBack;
    }

    public function dispose() : void{
        m_frameTicCallBack = null;
        m_timeForLogicFrame = NaN;
        m_atomFrameTime = NaN;
    }

    private function resetLoop() : void {
        m_LogicRuntime = 0.0;
        m_LogicFrame = 0;
    }

    public function update( delta : Number ) : void {
        if ( m_LogicRuntime > m_timeForResetLoop )
            resetLoop();

        var prevRuntime : Number = m_LogicRuntime;
        m_LogicRuntime += delta;

        const ONE_FRAME_TIME : Number = m_atomFrameTime;

        var prevFrameTime : Number = m_LogicFrame * ONE_FRAME_TIME;
        var nextFrameTime : Number = prevFrameTime + ONE_FRAME_TIME;

        var fixedFrameTime : Number;
        var leftDeltaTime : Number = delta;

        if ( m_LogicRuntime > nextFrameTime ) {
            fixedFrameTime = nextFrameTime - prevRuntime;
            if( fixedFrameTime == 0.0 )
                    m_LogicFrame++;

            if( fixedFrameTime > 0.0 ) {
                runFrameCallBack( fixedFrameTime );
                leftDeltaTime -= fixedFrameTime;
                m_LogicFrame++;
            }
        }

        if( leftDeltaTime < MAX_ATOM_DELTA ) {
            while ( leftDeltaTime >= ONE_FRAME_TIME ) {
                leftDeltaTime -= ONE_FRAME_TIME;
                m_LogicFrame++;
                runFrameCallBack( ONE_FRAME_TIME );
            }
        }else{
            resetLoop();
        }

        runFrameCallBack( leftDeltaTime );
    }

    final private function runFrameCallBack( delta : Number ) : void{
        if( m_frameTicCallBack )
                m_frameTicCallBack.apply( null , [delta] );
    }

    private var m_LogicRuntime : Number;
    private var m_LogicFrame : int;
    private var m_timeForResetLoop : Number
    private var m_timeForLogicFrame : Number;
    private var m_frameTicCallBack : Function;
    private var m_atomFrameTime : Number;
    private const MAX_ATOM_DELTA : Number = 0.3;
}
}
