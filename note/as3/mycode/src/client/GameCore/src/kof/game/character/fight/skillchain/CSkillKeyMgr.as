//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/7/19.
//----------------------------------------------------------------------
package kof.game.character.fight.skillchain {

import QFLib.Foundation.CMap;

import flash.utils.Dictionary;

import kof.table.Skill;

/**
 * 存储玩家角色对应的技能操作键
 */
public class CSkillKeyMgr {

    public function CSkillKeyMgr( cClass : _interClass) {
        m_professionSkillDic = new Dictionary();
    }

    public function dispose() : void
    {
        for( var key : int in m_professionSkillDic )
            delete m_professionSkillDic[ key ];

        m_professionSkillDic = null;
    }

    public static function get instance() : CSkillKeyMgr
    {
        if( null == _instance )
                _instance = new CSkillKeyMgr( new _interClass() )

        return _instance;
    }

    public  function registSkillKey( profession : int , skillID : int , keyCode : uint) : void
    {
        if(!(profession in m_professionSkillDic)) //null == m_professionSkillDic[ profession ] )
        {
            var skillKeyEntitys : Array = [];
            var skillKeyEntity : Object= {} ;
            skillKeyEntity.skillID = skillID;
            skillKeyEntity.keyCode = keyCode;
            skillKeyEntitys.push( skillKeyEntity );
            m_professionSkillDic[ profession ] = skillKeyEntitys;
        }
        else
        {
            var keyArrs : Array = m_professionSkillDic[  profession ];
            var hasInDic : Boolean = false;
            for each ( var keyEntity : Object in keyArrs )
            {
                if( int(keyEntity.skillID) == skillID ) {
                    keyEntity.keyCode = keyCode;
                    hasInDic = true;
                    break;
                }
            }

            if( !hasInDic )
            {
                keyArrs.push( { "skillID" : skillID,"keyCode" : keyCode } );
                m_professionSkillDic[ profession ] = keyArrs;
            }
        }
    }

    public  function getSkillKeyCode( profession : int , skillID : int ) : uint
    {
        var keyArrs : Array = m_professionSkillDic[  profession ];
        for each ( var keyEntity : Object in keyArrs )
        {
            if( keyEntity.skillID == skillID ) {
                return keyEntity.keyCode;
            }
        }

        return -1;
    }

    public function loadKeyCofig() : void
    {

    }

    private static var _instance : CSkillKeyMgr;
    private static var m_professionSkillDic : Dictionary;
}
}

class _interClass{
    public function _interClass() : void{

    }
}