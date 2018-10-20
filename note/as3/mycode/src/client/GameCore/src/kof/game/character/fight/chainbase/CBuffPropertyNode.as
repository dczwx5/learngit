//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/8/9.
//----------------------------------------------------------------------
package kof.game.character.fight.chainbase {

import kof.game.character.fight.buff.CBuffContainer;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.core.CGameObject;
import kof.table.ChainCondition.EPropertyCondition;

public class CBuffPropertyNode extends CChainBaseNode {
    public function CBuffPropertyNode( owner : CGameObject ) {
        super();
        m_pOwner = owner;
    }

    public function set skillOwner( value : CGameObject ) : void {
        m_pOwner = value;
    }

    override public function dispose() : void {
        super.dispose();
        m_pOwner = null;
        m_evaluateValue = null;
    }

    override public function isEvaluate() : Boolean {
        if ( m_pOwner == null ) return false;
        var pt : int = evaluateValue.PropertyConditionType;
        var pv : String = evaluateValue.PropertyConditionValue;
        var pc : int = evaluateValue.PropertyCondition;

        var buffContainer : CBuffContainer = m_pOwner.getComponentByClass( CBuffContainer, true ) as CBuffContainer;

        var buffId : int = int( pv );
        var ret : Boolean;

        if ( !buffContainer ) {
            _logBlockMsg( pt, pc ,buffId );
            return false;
        }

        if ( pc == EPropertyCondition.CON_NOT ) {
            ret = !buffContainer.hasBuffID( buffId );
        } else if ( pc == EPropertyCondition.CON_EQUAL ) {
            ret = buffContainer.hasBuffID( buffId );
        }

        if ( !ret ) {
            _logBlockMsg( pt, pc , buffId );
        }
        return ret;
    }

    private function _logBlockMsg( pt : int, pc : int ,pv : int ) : void {
        CSkillDebugLog.logTraceMsg( "@CChainBuffNode buff类型不通过 ：没有包含指定的buffID = "+ pv + "  Type：" + pt + "条件是：" + pc );
    }

    private var m_pOwner : CGameObject;
}
}
