//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/10.
//----------------------------------------------------------------------
package kof.game.character.fight.targetfilter.groupcriterias.groupcriteria {

import QFLib.Math.CMath;

import kof.game.character.CKOFTransform;
import kof.game.character.fight.targetfilter.groupcriterias.CAbstractGroupCriteria;
import kof.game.core.CGameObject;

public class CGroupXNearCriteria extends CAbstractGroupCriteria {
    public function CGroupXNearCriteria() {
        super("X Nearest Group");
    }

    override public function meetCriteria(  targetList : Array ) : Array
    {
        var lessXDis : Number;
        var target : CGameObject;
        var ret : Array ;

        for( var i :int = 0; i<targetList.length ;i++ ){
            if( targetList[ i ] === owner ) continue;
            var pTransform : CKOFTransform = targetList[ i ].getComponentByClass( CKOFTransform , true ) as CKOFTransform;
            var temXDis : Number = CMath.abs( pTransform.x - pOwnerTransform.x );
            if( isNaN( lessXDis )) lessXDis = temXDis;

            if( lessXDis >= temXDis )
            {
                target = targetList[ i ];
            }
        }
        if( target )
        {
            ret = [];
            ret.push( target );
        }
        return ret;
    }

    final private function get pOwnerTransform() : CKOFTransform
    {
        return owner.getComponentByClass( CKOFTransform , true ) as CKOFTransform;
    }
}
}
