//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/26.
//----------------------------------------------------------------------
package kof.game.character.fight.chainbase {

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.table.ChainCondition.EPropertyCondition;

/**
 * stats node
 */
public class CChainStatsNode extends CChainBaseNode{

    public function CChainStatsNode( owner : CGameObject  = null ) {
        super();
        m_pOwner = owner;
    }

    public function set skillOwner(value : CGameObject ) : void
    {
        m_pOwner = value;
    }

    override public function dispose() : void
    {
        super.dispose();
        m_pOwner = null;
        m_evaluateValue = null;
    }

    override public function isEvaluate() : Boolean {
        if ( m_pOwner == null ) return false;
        var pt : int = evaluateValue.PropertyConditionType;
        var pv : String = evaluateValue.PropertyConditionValue;
        var pc : int = evaluateValue.PropertyCondition;

        var pvv : int;
        // var pCompareValue : int;
        var stateBoard : CCharacterStateBoard = m_pOwner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;

        pvv = CCharacterStateBoard[pv];

        var ret : Boolean;
        if ( pc == EPropertyCondition.CON_NOT ) {
           ret  = !stateBoard.getValue( pvv );
        }else {
            ret = stateBoard.getValue( pvv );
        }
        if( !ret )
        {
            CSkillDebugLog.logTraceMsg("@CChainStatsNode 目标状态类型不通过 ：没有处在指定的状态 "+ pv  + " 条件 ：" + pc);
        }
        return ret ; //stateBoard.getValue( pvv );
    }

    private var m_pOwner : CGameObject;
}
}
