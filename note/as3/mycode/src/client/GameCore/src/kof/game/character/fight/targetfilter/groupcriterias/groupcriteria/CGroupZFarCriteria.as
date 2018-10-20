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

public class CGroupZFarCriteria extends CAbstractGroupCriteria {
    public function CGroupZFarCriteria( name : String = '' ) {
        super( "Z Far Group" );
    }

    override public function meetCriteria( targetList : Array ) : Array {
        var farZDis : Number;
        var target : CGameObject;
        var ret : Array ;

        for ( var i : int = 0; i < targetList.length; i++ ) {
            if ( targetList[ i ] === owner ) continue;
            var pTransform : CKOFTransform = targetList[ i ].getComponentByClass( CKOFTransform, true ) as CKOFTransform;
            var temXDis : Number = CMath.abs( pTransform.y - pOwnerTransform.y );
            if ( isNaN( farZDis ) ) farZDis = temXDis;

            if ( farZDis <= temXDis ) {
                target = targetList[ i ];
            }
        }

        if ( target ) {
            ret = [];
            ret.push( target );
        }

        return ret;
    }

    final private function get pOwnerTransform() : CKOFTransform {
        return owner.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
    }
}
}
