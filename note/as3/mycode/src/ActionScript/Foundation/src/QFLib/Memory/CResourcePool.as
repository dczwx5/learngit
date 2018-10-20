//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/2/17
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Memory
{

import QFLib.Application.Component.IRecycler;
    import QFLib.Foundation.CSet;
    import QFLib.Interface.IDisposable;
    import QFLib.Interface.IFactory;
    import QFLib.Interface.IRecyclable;
    import QFLib.Interface.IResourceFactory;
    import QFLib.Interface.IUpdatable;

    import flash.utils.ByteArray;

//
    //
    //
    public class CResourcePool implements IRecycler, IDisposable
    {
        
        public function CResourcePool( sPoolName : String, classOrFactory : *, iPreservedCapacity : int = 8 )
        {
            m_sPoolName = sPoolName;
            m_setPool = new CSet();
            //m_vPool = new Vector.<Object>( iPreservedCapacity );
            //m_iCurrentIndex = -1;
            m_iPreservedCapacity = iPreservedCapacity;

            if( classOrFactory is Class ) m_theClass = classOrFactory as Class;
            else if( classOrFactory is IResourceFactory ) m_theResFactory = classOrFactory as IResourceFactory;
            else if( classOrFactory is IFactory ) m_theFactory = classOrFactory as IFactory;
            else m_thePrototype = classOrFactory;
        }

        // dispose all objects in pool
        public function dispose() : void
        {
            clearAll();
        }

        // clear all objects in pool
        public function clearAll() : void
        {
            for each( var obj : Object in m_setPool )
            {
                var recyclableObj : IRecyclable = obj as IRecyclable;
                var disposableObj : IDisposable = obj as IDisposable;
                if( recyclableObj != null ) recyclableObj.disposeRecyclable();
                else if( obj != null && obj.hasOwnProperty( "disposeRecyclable" ) && obj.disposeRecyclable is Function ) obj.disposeRecyclable();
                else if( disposableObj != null ) disposableObj.dispose();
                else if( obj != null && obj.hasOwnProperty( "dispose" ) && obj.dispose is Function ) obj.dispose();

            }
            m_setPool.clear();

            /*for( var i : int = 0; i < m_vPool.length; i++ )
            {
                var obj : Object = m_vPool[ i ];
                var disposableObj : IDisposable = obj as IDisposable;
                if( disposableObj != null ) disposableObj.dispose();
                else if( obj != null && obj.hasOwnProperty( "dispose" ) && obj.dispose is Function ) obj.dispose();

                m_vPool[ i ] = null;
            }

            m_vPool.length = m_iPreservedCapacity;
            m_iCurrentIndex = -1;*/
        }

        // only dispose extra objects in pool( bigger than m_iPreservedCapacity )
        public function clearExtra() : void
        {
            var iNumToBeDispose : int = m_setPool.count - m_iPreservedCapacity;
            if( iNumToBeDispose > 0 )
            {
                var obj : Object;
                for( var i : int = 0; i < iNumToBeDispose; i++ )
                {
                    obj = m_setPool.popFirst();

                    var recyclableObj : IRecyclable = obj as IRecyclable;
                    var disposableObj : IDisposable = obj as IDisposable;
                    if( recyclableObj != null ) recyclableObj.disposeRecyclable();
                    else if( obj != null && obj.hasOwnProperty( "disposeRecyclable" ) && obj.disposeRecyclable is Function ) obj.disposeRecyclable();
                    else if( disposableObj != null ) disposableObj.dispose();
                    else if( obj != null && obj.hasOwnProperty( "dispose" ) && obj.dispose is Function ) obj.dispose();
                }
            }

            /*if( m_vPool.length <= m_iPreservedCapacity ) return ;

            for( var i : int = m_iPreservedCapacity; i < m_vPool.length; i++ )
            {
                var obj : Object = m_vPool[ i ];
                var disposableObj : IDisposable = obj as IDisposable;
                if( disposableObj != null ) disposableObj.dispose();
                else if( obj != null && obj.hasOwnProperty( "dispose" ) && obj.dispose is Function ) obj.dispose();

                m_vPool[ i ] = null;
            }

            m_vPool.length = m_iPreservedCapacity;
            m_iCurrentIndex = m_iPreservedCapacity - 1;*/
        }

        // pool attributes
        final public function get poolName() : String
        {
            return m_sPoolName;
        }
        final public function set poolName( sName : String ) : void
        {
            m_sPoolName = sName;
        }

        final public function get currentCapacity() : uint
        {
            return m_setPool.count;
            //return m_iCurrentIndex + 1;
        }
        final public function get capacity() : uint
        {
            return m_setPool.count;
            //return m_vPool.length;
        }

        final public function get preservedCapacity() : uint
        {
            return m_iPreservedCapacity;
        }
        final public function set preservedCapacity( value : uint ) : void
        {
            if ( m_iPreservedCapacity == value ) return;
            m_iPreservedCapacity = value;
            //if( m_iPreservedCapacity > m_vPool.length ) m_vPool.length = value;
        }

        // allocate a object in the pool, if the pool is empty, create one for user
        public function allocate() : Object
        {
            var obj : Object = m_setPool.popFirst();
            if( obj != null )
            {
                var recyclable : IRecyclable = obj as IRecyclable;
                if( recyclable != null ) recyclable.revive();
                else if( obj != null && obj.hasOwnProperty( "revive" ) && obj.revive is Function ) obj.revive();
            }
            else obj = _allocate();
            /*if( m_iCurrentIndex >= 0 )
            {
                obj = m_vPool[ m_iCurrentIndex ];
                m_vPool[ m_iCurrentIndex-- ] = null;

                var recyclable : IRecyclable = obj as IRecyclable;
                if( recyclable != null ) recyclable.revive();
                else if( obj != null && obj.hasOwnProperty( "revive" ) && obj.revive is Function ) obj.revive();
            }
            else obj = _allocate();*/

            return obj;
        }

        // recycle a object into the pool
        public function recycle( obj : Object ) : void
        {
            if( m_setPool.isExisted( obj ) ) return ; // had recycled.

            var recyclable : IRecyclable = obj as IRecyclable;
            if( recyclable != null ) recyclable.recycle();
            else if( obj != null && obj.hasOwnProperty( "recycle" ) && obj.recycle is Function ) obj.recycle();

            m_setPool.add( obj );
            /*if( m_iCurrentIndex >= m_vPool.length - 1 )
            {
                m_vPool.length *= 2;
            }

            m_vPool[ ++m_iCurrentIndex ] = obj;*/
        }

        public function preallocateInPool( iNum : int ) : void
        {
            iNum -= this.currentCapacity;

            for( var i : int = 0; i < iNum; i++ )
            {
                recycle( _allocate() );
            }
        }

        public function cleanUpRecycledObjects( iCleanUpFactor : int = 3 ) : void
        {
            if( iCleanUpFactor <= 0 )
            {
                clearAll();
                return ;
            }
            else if( iCleanUpFactor == 1 )
            {
                clearExtra();
                return ;
            }

            if( m_setPool.count > m_iPreservedCapacity )
            {
                var iCleanUpCounts : int = ( m_setPool.count - m_iPreservedCapacity ) / iCleanUpFactor;
                if( iCleanUpCounts == 0 ) iCleanUpCounts = 1;

                var obj : Object;
                for( var i : int = 0; i < iCleanUpCounts; i++ )
                {
                    obj = m_setPool.popFirst();

                    var recyclableObj : IRecyclable = obj as IRecyclable;
                    var disposableObj : IDisposable = obj as IDisposable;
                    if( recyclableObj != null ) recyclableObj.disposeRecyclable();
                    else if( obj != null && obj.hasOwnProperty( "disposeRecyclable" ) && obj.disposeRecyclable is Function ) obj.disposeRecyclable();
                    else if( disposableObj != null ) disposableObj.dispose();
                    else if( obj != null && obj.hasOwnProperty( "dispose" ) && obj.dispose is Function ) obj.dispose();
                }
            }

            /*if( m_iCurrentIndex >= m_iPreservedCapacity )
            {
                var iLength : int = m_iCurrentIndex + 1;
                var iCleanUpCounts : int = ( iLength - m_iPreservedCapacity ) / iCleanUpFactor;
                if( iCleanUpCounts == 0 ) iCleanUpCounts = 1;

                var iBeginIdx : int = iLength - iCleanUpCounts;
                for( var i : int = iBeginIdx; i < iLength; i++ )
                {
                    var disposableObj : IDisposable = m_vPool[ i ] as IDisposable;
                    if( disposableObj != null ) disposableObj.dispose();
                    m_vPool[ i ] = null;
                }

                m_iCurrentIndex = iBeginIdx - 1;
            }

            var iNewLen : int = m_vPool.length / 2;
            var iGapLen : int = iNewLen / 4;
            if( iNewLen > m_iCurrentIndex + iGapLen && iNewLen >= m_iPreservedCapacity ) m_vPool.length = iNewLen;*/
        }

        //
        //
        protected function _allocate() : Object
        {
            if( m_theResFactory != null ) return m_theResFactory.create( m_sPoolName );
            else if( m_theFactory != null ) return m_theFactory.create();
            else if( m_theClass != null ) return new m_theClass;
            else if( m_thePrototype != null )
            {
                var ba : ByteArray = new ByteArray();
                ba.writeObject( m_thePrototype );
                ba.position = 0;
                return ba.readObject();
            }
            else return null;
        }


        //
        //
        protected var m_sPoolName : String;
        //protected var m_iCurrentIndex : int;
        //protected var m_vPool : Vector.<Object>;
        protected var m_setPool : CSet;
        protected var m_iPreservedCapacity : int;

        protected var m_theClass : Object;
        protected var m_theFactory : IFactory;
        protected var m_theResFactory : IResourceFactory;
        protected var m_thePrototype : Object;
    }
}
