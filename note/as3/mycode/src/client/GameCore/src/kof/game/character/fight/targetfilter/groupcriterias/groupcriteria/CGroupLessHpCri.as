//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/12/5.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.groupcriterias.groupcriteria {

import kof.game.character.fight.targetfilter.groupcriterias.*;

import kof.game.character.property.CCharacterProperty;
import kof.game.core.CGameObject;

/**
 * 生命百分比最少
 */
public class CGroupLessHpCri extends CAbstractGroupCriteria{
    public function CGroupLessHpCri() {
        super("LessHpGroup");
    }

    override public function meetCriteria(  targetList : Array ) : Array
    {
        var temHP : Number = 2.0;
        var target : CGameObject;
        var pProperty : CCharacterProperty;
        var ret : Array ;

        for( var i :int = 0; i<targetList.length ;i++ ){
            pProperty = targetList[ i ].getComponentByClass( CCharacterProperty , true ) as CCharacterProperty;
            if( pProperty == null || pProperty.MaxHP == 0 ) break;
            if( temHP > pProperty.HP / pProperty.MaxHP )
            {
                target = targetList[ i ];
            }
        }

        if( target ) {
            ret = [];
            ret.push( target );
        }

        return ret;
    }


}
}
