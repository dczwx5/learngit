//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/18.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter {

import QFLib.Interface.IUpdatable;

/**
 * errr... hold the emitters for skill.
 */
public class CEmitterContainer implements IUpdatable{
    public function CEmitterContainer() {

        m_emmiterList = new <CEmmiterController>[];
    }

    public function dispose() : void
    {
        for each( var emmiterController : CEmmiterController in m_emmiterList )
        {
            emmiterController.dispose();
        }

        if( m_emmiterList )
                m_emmiterList.splice(0 , m_emmiterList.length );

        m_emmiterList = null;
    }

    public function update( delta : Number ) : void
    {
        for each( var emmiterController : CEmmiterController in m_emmiterList )
        {
            emmiterController.update( delta );
        }
    }


    public function lastUpdate( delta : Number ) : void
    {
        if( m_emmiterList == null )
                return;
        var emitterCtl : CEmmiterController;
        var list : Vector.<CEmmiterController> = m_emmiterList.slice();

        for ( var i : int = 0 ;i < list.length ; i++ )
        {
            emitterCtl = list[i];
            emitterCtl.lastUpdate( delta );
        }
    }

    public function addEmmitter( eController : CEmmiterController ) : void
    {
        eController.setContainer( this );
        m_emmiterList.push( eController );

    }

    public function removeEmmiter( eController : CEmmiterController ): void
    {
        var index : int = m_emmiterList.indexOf( eController );

        if( index < 0 ) return ;
        eController.dispose();
        m_emmiterList.splice( index  , 1 );
        eController = null;
    }

    private var m_emmiterList : Vector.<CEmmiterController>;
}
}
