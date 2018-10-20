//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.state {

import flash.geom.Point;
import flash.utils.getTimer;

import kof.game.character.state.info.CSkillInputRequest;

import kof.game.core.CGameComponent;

/**
 * 角色输入组件，方向，技能按键输入等
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterInput extends CGameComponent {

    private var m_pWheel : Point;
    private var m_bWheelDirty : Boolean;
    private var m_pWheelNormalize : Point;
    private var m_pSkillQueue : Vector.<CSkillInputRequest>;
    private var m_pActionQueue : Vector.<CActionCallRequest>;
    private var m_pSkillUpQueue : Vector.<CSkillInputRequest>;

    public function CCharacterInput() {
        super( "input" );
    }

    override protected virtual function onEnter() : void {
        super.onEnter();

        m_pWheel = new Point();
        m_pWheelNormalize = new Point();
        m_bWheelDirty = false;

        m_pSkillQueue = new <CSkillInputRequest>[];
        m_pActionQueue = new <CActionCallRequest>[];
        m_pSkillUpQueue = new <CSkillInputRequest>[];
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
    }

    override protected virtual function onExit() : void {
        super.onExit();

        m_pWheel = null;
        m_pWheelNormalize = null;

        if ( m_pSkillQueue && m_pSkillQueue.length )
            m_pSkillQueue.splice( 0, m_pSkillQueue.length );
        m_pSkillQueue = null;

        if ( m_pActionQueue && m_pActionQueue.length )
            m_pActionQueue.splice( 0, m_pActionQueue.length );
        m_pActionQueue = null;

        if ( m_pSkillUpQueue && m_pSkillUpQueue.length )
            m_pSkillUpQueue.splice( 0, m_pSkillUpQueue.length );
        m_pSkillUpQueue = null;
    }

    /// Action accessors.
    /// @{

    final public function addActionCall( pFn : Function, pArgs : Array = null ) : void {
        if ( null == pFn )
            return;

        for each ( var pRequestCall : CActionCallRequest in m_pActionQueue ) {
            if ( pRequestCall.callback == pFn ) {
                return;
            }
        }

        m_pActionQueue.push( new CActionCallRequest( pFn, pArgs ) );
    }

    final public function getUniqueActionCalls() : Vector.<Object> {
        var ret : Vector.<Object> = new Vector.<Object>( m_pActionQueue.length, true );
        for ( var i : int = 0; i < ret.length; ++i ) {
            ret[ i ] = m_pActionQueue[ i ];
        }
        return ret;
    }

    final public function truncateActionRequests() : void {
        if ( m_pActionQueue && m_pActionQueue.length ) {
            m_pActionQueue.splice( 0, m_pActionQueue.length );
        }
    }

    /// }@

    /// Wheel accessors.
    /// @{

    final public function get wheel() : Point {
        return m_pWheel;
    }

    final public function set wheel( value : Point ) : void {
        if ( m_pWheel.equals( value ) )
            return;
        m_pWheel.setTo( value.x, value.y );
        m_bWheelDirty = true;

        var fMaxAbs : Number = Math.max( value.x < 0 ? -value.x : value.x, value.y < 0 ? -value.y : value.y );
        if ( isNaN( fMaxAbs ) || 0.0 == fMaxAbs )
            m_pWheelNormalize.setTo( 0, 0 );
        else
            m_pWheelNormalize.setTo( value.x / fMaxAbs, value.y / fMaxAbs );
    }

    final public function get normalizeWheel() : Point {
        return m_pWheelNormalize;
    }


    final public function get isWheelDirty() : Boolean {
        return m_bWheelDirty;
    }

    final public function makeWheelDirty() : void {
        m_bWheelDirty = true;
    }

    final public function clearWheelDirty() : void {
        m_bWheelDirty = false;
    }

    /// @}

    /// Skill accessors.
    /// @{

    final public function getLastRequestTimeBySkillIndex( nSkillIdx : uint ) : Number {
        var revered : Vector.<CSkillInputRequest> = m_pSkillQueue.reverse();
        for each ( var sir : CSkillInputRequest in revered ) {
            if ( sir.skillIndex == nSkillIdx )
                return sir.requestTime;
        }
        return NaN;
    }

    final public function getRequestTimesBySkillIndex( nSkillIdx : uint ) : Vector.<Number> {
        var ret : Vector.<Number> = new <Number>[];
        for each ( var sir : CSkillInputRequest in m_pSkillQueue ) {
            if ( sir.skillIndex == nSkillIdx )
                ret.push( sir.requestTime );
        }
        return ret;
    }

    final public function getUniqueSkillIndexList() : Vector.<CSkillInputRequest> {
        var ret : Vector.<CSkillInputRequest> = new <CSkillInputRequest>[];
        for each ( var sir : CSkillInputRequest in m_pSkillQueue ) {
            if ( -1 == ret.indexOf( sir ) )
                ret.push( sir );
        }

        return ret;
    }

    final public function addSkillRequest( skillIdx : int , args : Array = null ) : void {
        m_pSkillQueue.push( new CSkillInputRequest( skillIdx, getTimer() , args ) );
    }



    final public function truncateSkillRequests() : void {
        if ( m_pSkillQueue && m_pSkillQueue.length )
            m_pSkillQueue.splice( 0, m_pSkillQueue.length );
    }

    final public function getUniqueSkillUpIndexList() : Vector.<CSkillInputRequest> {
        var ret : Vector.<CSkillInputRequest> = new <CSkillInputRequest>[];
        for each ( var sir : CSkillInputRequest in m_pSkillUpQueue ) {
            if ( -1 == ret.indexOf( sir ) )
                ret.push( sir );
        }

        return ret;
    }

    final public function addSkillUpRequest( skillIdx : int , args : Array = null ) : void {
        m_pSkillUpQueue.push( new CSkillInputRequest( skillIdx, getTimer() , args ) );
    }

    final public function truncateSkillUpRequests() : void {
        if ( m_pSkillUpQueue && m_pSkillUpQueue.length )
            m_pSkillUpQueue.splice( 0, m_pSkillUpQueue.length );
    }

    /// @}

}
}

//--------------------------------------
// file scope classes.
//--------------------------------------

//final class CSkillInputRequest {
//
//    public var skillIndex : uint;
//    public var args : Array;
//    public var requestTime : Number;
//
//    public function CSkillInputRequest( nSkillIdx : uint, fRequestTime : Number ,args : Array = null) {
//        this.skillIndex = nSkillIdx;
//        this.requestTime = fRequestTime;
//        this.args = args;
//    }
//
//}

final class CActionCallRequest {

    public var callback : Function;
    public var args : Array;

    public function CActionCallRequest( func : Function, args : Array ) {
        this.callback = func;
        this.args = args;
    }

}

