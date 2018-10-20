//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/10.
//----------------------------------------------------------------------
package QFLib.Collision {

import QFLib.Collision.common.ICollision;
import QFLib.Collision.common.IIterator;
import QFLib.Graphics.RenderCore.CBaseObject;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CAABBox3;

public class CCollisionManager implements IUpdatable {
    public function CCollisionManager( theDisplaySys : CCollisionDisplaySystem ) {
        m_theAtkCollisionList  = new CColArrayCollection();
        m_theDefCollisonList = new CColArrayCollection();
        m_theBlockCollisionList = new CColArrayCollection();
        m_theAtkIterator = m_theAtkCollisionList.getIterator();
        m_theDefIterator = m_theDefCollisonList.getIterator();
        m_theBlockIterator = m_theBlockCollisionList.getIterator();
        m_pDisplsySys = theDisplaySys;
    }

    public function update( delta : Number ) : void
    {
        var atk : CCollisionBound;
        var def : CCollisionBound;
        for( m_theAtkCollisionList.resetIterator( m_theAtkIterator ) ; m_theAtkIterator.hasNext() ;){
            atk = m_theAtkIterator.next() as CCollisionBound;
            atk.resetPairs();
            for( m_theDefCollisonList.resetIterator( m_theDefIterator ) ; m_theDefIterator.hasNext();){
                 def = m_theDefIterator.next() as CCollisionBound;
                if( CCollisionOverlap.testAABB( atk.testAABBBox , def.testAABBBox ) ) {
                    atk.addPair( def );
                }
//                else{
//                    atk.removePair( def );
//                }
            }
        }

        for( m_theBlockCollisionList.resetIterator(m_theBlockIterator) ; m_theBlockIterator.hasNext();){

        }

        if( m_pDisplsySys.enable ) {
            var displsyBound : CCollisionBound;
            for ( m_theAtkCollisionList.resetIterator( m_theAtkIterator ); m_theAtkIterator.hasNext(); ) {
                displsyBound = m_theAtkIterator.next() as CCollisionBound;
                _displayBound( displsyBound );
            }
            for( m_theDefCollisonList.resetIterator( m_theDefIterator ) ; m_theDefIterator.hasNext();) {
                displsyBound = m_theDefIterator.next() as CCollisionBound;
                _displayBound( displsyBound );
            }

        }

    }

    public function registerCollisionBound( type : int , bound : CAABBox3 , ownerData : Object = null ) : Object
    {
        var pColList : CColArrayCollection = _getCollisionTypeList( type );
        var theBound : CCollisionBound;
        theBound = pColList.createBound( bound , ownerData ) as CCollisionBound;
        theBound.Type = type;
        return theBound;
    }

    private function _displayBound( bound : CCollisionBound ) : void
    {
        if( !m_pDisplsySys.enable ) return;
        m_pDisplsySys.displayCollisionBond( bound );
    }

    private function _removeDisplayBound( bound : CCollisionBound ) : void
    {
        m_pDisplsySys.hideCollisionBound( bound );
    }

    public function unRegisterCollisionBound( bound : ICollision ) : void
    {
        var type : int = _getBoundType( bound );
        var pColList : CColArrayCollection = _getCollisionTypeList( type );
        _removeDisplayBound( bound as CCollisionBound );
        pColList.destroyBound( bound );
    }

    public function getOwnerData(bound : ICollision) : Object
    {
        var type : int = _getBoundType( bound );
        var pColList : CColArrayCollection = _getCollisionTypeList( type );
        return pColList.getUserData( bound );
    }

    public function getAABBBound( bound : ICollision ) : CAABBox3
    {
        var type : int = _getBoundType( bound );
        var pColList : CColArrayCollection = _getCollisionTypeList( type );
        return pColList.getAABBBox( bound );
    }

    private function _getBoundType( bound : ICollision ) : int
    {
        return (bound as CCollisionBound).Type;
    }
    public function set boDisplayBox( value : Boolean ) : void
    {
        m_boDisplayBox = value;
    }

    private function _getCollisionTypeList( type : int ) : CColArrayCollection
    {
        if( type == CCollisionBound.TYPE_ATTACK )
                return m_theAtkCollisionList;
        else if( type == CCollisionBound.TYPE_DEFENSE )
                return m_theDefCollisonList;
        else if( type == CCollisionBound.TYPE_BLOCK )
                return m_theBlockCollisionList;
        return null;
    }

    private var m_theAtkCollisionList : CColArrayCollection;
    private var m_theDefCollisonList : CColArrayCollection ;
    private var m_theBlockCollisionList : CColArrayCollection;
    private var m_theAtkIterator : IIterator;
    private var m_theDefIterator : IIterator;
    private var m_theBlockIterator : IIterator;
    private var m_boDisplayBox : Boolean;
    private var m_pDisplsySys : CCollisionDisplaySystem;
}
}
