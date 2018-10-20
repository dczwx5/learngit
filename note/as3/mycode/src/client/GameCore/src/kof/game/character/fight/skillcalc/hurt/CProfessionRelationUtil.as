//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2018/2/9.
//----------------------------------------------------------------------
package kof.game.character.fight.skillcalc.hurt {

import QFLib.Foundation;
import QFLib.Interface.IDisposable;

import flash.utils.Dictionary;

public class CProfessionRelationUtil implements IDisposable {
    /**
     * 0 攻击
     * 1 防御
     * 2 技巧
     */
    public static const PROFESSION_ATK : int = 0;
    public static const PROFESSION_DEF : int = 1;
    public static const PROFESSION_TECH : int = 2;

    public function CProfessionRelationUtil() : void {
        m_theRelations = {
            0 : {
                "advantage" : [ PROFESSION_DEF ],
                "disadvantage" : [ PROFESSION_TECH ]
            },
            1 : {
                "advantage" : [ PROFESSION_TECH ],
                "disadvantage" : [ PROFESSION_ATK ]
            },
            2 : {
                "advantage" : [ PROFESSION_ATK ],
                "disadvantage" : [ PROFESSION_DEF ]
            }
        }
    }

    public function dispose() : void {
        if ( m_theRelations ) {
            for ( var key : int in m_theRelations ) {
                delete m_theRelations[ key ];
            }
        }
        m_theRelations = null;
    }

    public function getAdvantageRelation( profession1 : int, profession2 : int ) : Boolean {
        var advantages : Array;
        var ret : Boolean;
        var relations : Object = m_theRelations[ profession1 ];
        if ( relations ) {
            advantages = relations[ "advantage" ] as Array;
            ret = advantages.indexOf( profession2 ) > -1;
        } else {
            Foundation.Log.logTraceMsg( "Can not find profession which type = " + profession1 );
            return false;
        }

        return ret;

    }

    public function getDisadvantageRelation( profession1 : int, profession2 : int ) : Boolean {
        var disadvantages : Array;
        var ret : Boolean;
        var relations : Object = m_theRelations[ profession1 ];
        if ( relations ) {
            disadvantages = relations[ "disadvantage" ] as Array;
            ret = disadvantages.indexOf( profession2 ) > -1;
        } else {
            Foundation.Log.logTraceMsg( "Can not find profession which type = " + profession1 );
            return false;
        }

        return ret;
    }

    private var m_theRelations : Object;
}
}
