//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/12/1.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

import QFLib.Foundation.CMap;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CMath;
import QFLib.Math.CVector2;

import kof.game.character.CFacadeMediator;
import kof.game.character.CKOFTransform;
import kof.game.character.animation.IAnimation;
import kof.game.character.display.IDisplay;

import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.movement.CMovement;
import kof.game.character.state.CCharacterInput;

import kof.game.core.CGameComponent;

/**
 * 给剧情模拟技能释放的
 */
public class CSimulateSkillCaster extends CGameComponent {
    public function CSimulateSkillCaster( name : String = null, branchData : Boolean = false ) {
        super( name, branchData );
    }

    override protected function onEnter() : void
    {
        super.onEnter();
        m_ConditionFlags = new CMap();
        m_ConditionFlags.add( ESkillSkipType.SKIP_AP_EVALUATE,false);
        m_ConditionFlags.add( ESkillSkipType.SKIP_CD_EVALUATE , false);
        m_ConditionFlags.add( ESkillSkipType.SKIP_RP_EVALUATE , false);
    }

    override public function dispose() : void
    {
        this.clearIngnoreConditions();
    }

    override protected function onExit() : void
    {
        super.onExit();
    }

    override public function set enabled( value : Boolean ) : void
    {
        super.enabled = value;
    }

    /**
     * conditionType 传条件 ESkillSkipType里枚举
     * @param conditionType
     * @param flag  true 表示改条件无限
     */
    public function setConditionFlags( conditionType : int , flag : Boolean ) : void
    {
       m_ConditionFlags[conditionType] = flag;
    }

    public function castSkillByID( skillID : int ) : void
    {
        castSkillIngoreAll( skillID );
    }

    /**
     * 跳过所有判断
     * @param skillID
     */
    public function castSkillIngoreAll( skillID : int ) : void
    {
        castSkillByIDWithIngnoreCondition( skillID , [ESkillSkipType.SKIP_AP_EVALUATE,ESkillSkipType.SKIP_CD_EVALUATE,
                                                    ESkillSkipType.SKIP_DP_EVALUATE,ESkillSkipType.SKIP_INTERRUPT_EVALUATE,
                                                    ESkillSkipType.SKIP_RP_EVALUATE,ESkillSkipType.SKIP_STATE_EVALUATE]);
    }

    public function castSkillIgnoreConsume( skillID : int ): void
    {
        castSkillByIDWithIngnoreCondition( skillID , [ESkillSkipType.SKIP_AP_EVALUATE,
            ESkillSkipType.SKIP_DP_EVALUATE, ESkillSkipType.SKIP_RP_EVALUATE]);
    }

    public function castSkillIndexIgnoreConsume( skillIdx : int ) : void{
        castSkillByIndexWithIgnorecondition( skillIdx  , [ESkillSkipType.SKIP_AP_EVALUATE,
            ESkillSkipType.SKIP_DP_EVALUATE, ESkillSkipType.SKIP_RP_EVALUATE]);
    }

    /**
     * 跳过攻击值
     * @param skillID
     */

    public function castSkillIngnoreAP( skillID : int ) : void
    {
        castSkillByIDWithIngnoreCondition( skillID , [ESkillSkipType.SKIP_AP_EVALUATE]);
    }

    /**
     * 无视防御值
     * @param skillID
     */
    public function castSkillIngnoreDP( skillID : int ) : void
    {
        castSkillByIDWithIngnoreCondition( skillID , [ESkillSkipType.SKIP_DP_EVALUATE ]);
    }

    /**
     * 无视怒气值
     * @param skillID
     */
    public function castSkillIngnoreRP( skillID : int ) : void
    {
        castSkillByIDWithIngnoreCondition( skillID , [ ESkillSkipType.SKIP_RP_EVALUATE ]);
    }

    /**
     * 跳过状态判断 主要是技能释放的人物状态条件
     * @param skillID
     */
    public function castSkillIngnoreState( skillID : int ) :void
    {
        castSkillByIDWithIngnoreCondition( skillID , [ESkillSkipType.SKIP_STATE_EVALUATE] );
    }

    /**
     *  skip cd
     * @param skillID
     */
    public function castSkillIngnoreCD( skillID : int ) : void
    {
        castSkillByIDWithIngnoreCondition( skillID , [ESkillSkipType.SKIP_CD_EVALUATE] );
    }

    final public function get boIgnoreAP() : Boolean
    {
        return _getBoIgnoreType( ESkillSkipType.SKIP_AP_EVALUATE );
    }

    final public function get boIgnoreDP() : Boolean
    {
        return _getBoIgnoreType( ESkillSkipType.SKIP_DP_EVALUATE );
    }

    final public function get boIgnoreRP() : Boolean
    {
        return _getBoIgnoreType( ESkillSkipType.SKIP_RP_EVALUATE );
    }

    final public function get boIgnoreCD() : Boolean
    {
        return _getBoIgnoreType( ESkillSkipType.SKIP_CD_EVALUATE );
    }

    final public function get boIgnoreInterrupt() : Boolean
    {
        return _getBoIgnoreType( ESkillSkipType.SKIP_INTERRUPT_EVALUATE );
    }

    final public function get boIgnoreState() : Boolean
    {
        return _getBoIgnoreType( ESkillSkipType.SKIP_STATE_EVALUATE );
    }

    final private function _getBoIgnoreType ( type : int ) : Boolean
    {
        if( type in m_ConditionFlags && m_ConditionFlags[type] ){
            return m_ConditionFlags[type];
        }

        if( ingnoreConditions )
                return ingnoreConditions.indexOf( type ) >= 0;
        return false;
    }

    private function castSkillByIDWithIngnoreCondition( skillID : int , conditions : Array = null): void
    {
        this.m_IngnoreConditions = conditions;
        pFacadeMediator.attackWithSkillID( skillID );
    }

    private function castSkillByIndexWithIgnorecondition( skillIdx :int , conditions : Array = null ) : void{
//        this.m_IngnoreConditions = conditions;
        var input : CCharacterInput = owner.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
        input.addSkillRequest( skillIdx , conditions );
    }

    //闪避无视怒气
    public function dodgeSuddenIgnoreRPAndCD() : void
    {
        var ignoreConditions : Array  = [ ESkillSkipType.SKIP_RP_EVALUATE,ESkillSkipType.SKIP_CD_EVALUATE ];
        pFacadeMediator.dodgeSudden( ignoreConditions );
    }

    public function jumpToXY( x : Number , y : Number ) : void
    {
        var fXVel : Number;
        var fYVel : Number;
        var fZVel : Number;
        var fHeight : Number  ;
        var pTransform : CKOFTransform = owner.getComponentByClass( CKOFTransform , true ) as CKOFTransform;
        var pMovement : CMovement = owner.getComponentByClass( CMovement , true ) as CMovement;
        var fSpeed : Number = pMovement.moveSpeed;

        var pCharacterDisplay : IAnimation = getComponent( IAnimation ) as IAnimation;
        var curPos : CVector2 = pTransform.to2DAxis();
        fXVel =  fSpeed;
        var fReachTime : Number = CMath.abs(curPos.x - x ) / fSpeed;
        fZVel = (y - curPos.y) /fReachTime;

        pCharacterDisplay.emitWithVelocityXYZ( fXVel , fZVel ,  fZVel);
    }

    final private function get pFacadeMediator() : CFacadeMediator
    {
        return owner.getComponentByClass( CFacadeMediator , true ) as CFacadeMediator;
    }

    private function  get ingnoreConditions() : Array
    {
        return m_IngnoreConditions;
    }

    public function set ignoreConditions( conditions : Array ) : void{
        this.m_IngnoreConditions = conditions;
    }

    public function clearIngnoreConditions() : void
    {
        for ( var conditionType : * in m_ConditionFlags )
        {
            if( m_ConditionFlags[conditionType] )
                    continue;
            if( m_IngnoreConditions ) {
                var idx : int = m_IngnoreConditions.indexOf( conditionType );
                if ( idx > -1 ){
                    m_IngnoreConditions.splice( idx , 1 );
                }
            }
        }
        CSkillDebugLog.logTraceMsg( "清空技能判定状态！");
        /**
        if( m_IngnoreConditions )
            m_IngnoreConditions.splice( 0 , m_IngnoreConditions.length );
        m_IngnoreConditions = null;*/
    }

    private function resetConditionFlags() : void
    {
        if( m_ConditionFlags )
        {
            for( var condition : String in m_ConditionFlags )
            {
                m_ConditionFlags[condition] = false;
            }
        }
    }

    private var m_IngnoreConditions : Array;
    private var m_ConditionFlags : CMap;
}
}
