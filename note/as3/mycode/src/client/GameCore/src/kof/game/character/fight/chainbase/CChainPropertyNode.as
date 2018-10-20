//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/7/16.
//----------------------------------------------------------------------
package kof.game.character.fight.chainbase {

import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.core.CGameObject;
import kof.table.ChainCondition.EPropertyCondition;
import kof.table.ChainCondition.EPropertyConditionType;

/**
 * Property node
 */
public class CChainPropertyNode extends CChainBaseNode {

    public function CChainPropertyNode(owner : CGameObject = null) {
        super();
        m_owner = owner;
    }

    public function set skillOwner( value : CGameObject ) : void
    {
        m_owner = value;
    }

    override public function dispose() : void
    {
        super.dispose();
        m_owner = null;
        m_evaluateValue = null;
    }

    override public function isEvaluate() : Boolean
    {
        if( m_owner == null ) return false;
        var pt : int = evaluateValue.PropertyConditionType;
        var pv : int = evaluateValue.PropertyConditionValue;
        var pc : int = evaluateValue.PropertyCondition;
        var pCompareValue : int ;

        var propertyCmp : ICharacterProperty = m_owner.getComponentByClass( ICharacterProperty , true ) as ICharacterProperty;

        if(pt == EPropertyConditionType.P_HP)
        {
            pCompareValue = int( (propertyCmp.HP / propertyCmp.MaxHP) * 100 );
        }
        else if( pt == EPropertyConditionType.P_ATTACK_POWER)
        {
            pCompareValue = int( ( propertyCmp.AttackPower / propertyCmp.MaxAttackPower ) * 100 )
        }
        else if( pt == EPropertyConditionType.P_DEFENCE_PWEER )
        {
            pCompareValue = int( ( propertyCmp.DefensePower / propertyCmp.MaxDefensePower ) * 100 );
        }

        switch (pc){
            case  EPropertyCondition.CON_EQUAL:
                if( pCompareValue == pv )
                    return true;
                break;
            case EPropertyCondition.CON_NOT_EQUAL:
                if (pCompareValue != pv)
                        return true;
                break;
            case EPropertyCondition.CON_GREAOREQUAL:
                if( pCompareValue >= pv )
                        return true;
                break;
            case EPropertyCondition.CON_GREATER :
                if( pCompareValue > pv )
                        return true;
                break;
            case EPropertyCondition.CON_LESS :
                if( pCompareValue < pv )
                    return true;
                break;
            case EPropertyCondition.CON_LESSOREQUAL :
                if( pCompareValue <= pv )
                    return true;
                break;
            case EPropertyCondition.CON_NOT:
                if (!pCompareValue)
                    return true;
                break;
            default:
                return false;

        }

        return false;

    }

    private var m_owner: CGameObject;


}
}
