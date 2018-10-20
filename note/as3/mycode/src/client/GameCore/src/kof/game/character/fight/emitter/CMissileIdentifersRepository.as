//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/11/15.
//----------------------------------------------------------------------
package kof.game.character.fight.emitter {

import QFLib.Collision.common.IIterator;
import QFLib.Foundation.CMap;

import kof.game.core.CGameComponent;

public class CMissileIdentifersRepository extends CGameComponent {
    public function CMissileIdentifersRepository( name : String = null, branchData : Boolean = false ) {
        super( "missileIds", branchData );
    }

    override public function dispose() : void {
        if( m_theEmittersIDs )
            m_theEmittersIDs.clear();
        m_theEmittersIDs = null;
    }

    override protected function onEnter() : void {
        m_theEmittersIDs = new CMap();
    }

    public function getNextIDByEmitter( emitterID : int ) : int {
        var sEmitterId : String = String( emitterID );
        var idsIterator : IIterator;
        if ( sEmitterId in m_theEmittersIDs ) {
            idsIterator = m_theEmittersIDs[ sEmitterId ];
            if ( idsIterator ) {
                return int( idsIterator.next() );
            }
        }

        return -1;
    }

    public function hasNextIDByEmitter( emitterID : int ) : Boolean {
        var sEmitterId : String = String( emitterID );
        var idsIterator : IIterator;
        if ( sEmitterId in m_theEmittersIDs ) {
            idsIterator = m_theEmittersIDs[ sEmitterId ];
            if ( idsIterator ) {
                return idsIterator.hasNext();
            }
        }
        return false;
    }

    public function hasSpecifyIDByEmitter( emitterID : int , specifyID : int ) : Boolean {
        var sEmitterId : String = String( emitterID );
        var idsIterator : IIterator;
        if ( sEmitterId in m_theEmittersIDs ) {
            idsIterator = m_theEmittersIDs[ sEmitterId ];
            if ( idsIterator ) {
                return (idsIterator as MissileIDsIterator).hasSpecifyID( specifyID );
            }
        }
        return false;
    }

    public function clearIDs() : void {
        for ( var key : String in m_theEmittersIDs ) {
            var idIterator : MissileIDsIterator;
            idIterator = m_theEmittersIDs[ key ];
            idIterator.reset();
        }
    }

    public function setIDs( ids : Object ) : void {
        if ( ids == null )
            return;

        clearIDs();

        var missileIterator : MissileIDsIterator;
        for ( var emitterId : String in ids ) {
            if ( emitterId in m_theEmittersIDs ) {
                missileIterator = m_theEmittersIDs[ emitterId ];
                missileIterator.setIDs( ids[ emitterId ] );
            }
            else {
                missileIterator = new MissileIDsIterator( ids[ emitterId ] );
                m_theEmittersIDs[ emitterId ] = missileIterator;
            }
        }
    }

    private var m_theEmittersIDs : CMap;
}
}

import QFLib.Collision.common.IIterator;

class MissileIDsIterator implements IIterator {
    private var _ids : Array;
    private var _currentIndex : int;

    public function MissileIDsIterator( ids : Array ) : void {
        setIDs( ids );
    }

    public function setIDs( ids : Array ) : void {
        _ids = ids;
        _currentIndex = 0;
    }

    public function reset() : void {
        if ( _ids )
            _ids.splice( 0, _ids.length );
        _currentIndex = 0;
    }

    public function next() : Object {
        if ( _ids == null ) return -1;
        if ( _currentIndex >= _ids.length ) return -1;
        return _ids[ _currentIndex++ ];
    }

    public function hasNext() : Boolean {
        if ( _ids == null || _currentIndex >= _ids.length ) return false;
        return true;
    }

    public function hasSpecifyID( id : int ) : Boolean {
        if ( _ids == null || _currentIndex >= _ids.length ) return false;
        for ( var i : int = 0; i < _ids.length; i++ ) {
            if ( _ids[ i ] == id )
                return true;
        }
        return false;
    }
}
