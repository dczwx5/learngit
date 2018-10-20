//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/2/17
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Memory
{

    import QFLib.Foundation.CMap;
    import QFLib.Interface.IDisposable;
    import QFLib.Interface.IUpdatable;

//
    //
    //
    public class CResourcePools implements IDisposable, IUpdatable
    {
        
        public function CResourcePools( fUpdateTimeInterval : Number = 5.0 )
        {
            m_mapPools = new CMap();
            m_fUpdateTimeInterval = fUpdateTimeInterval;
        }

        // dispose all objects in pool
        public function dispose() : void
        {
            clearAll();
        }

        [Inline]
        final public function set updateTimeInterval ( value : Number ) : void
        {
            if ( value <= 0.0 )
                m_fUpdateTimeInterval = 5.0;
            else
                m_fUpdateTimeInterval = value;
        }

        [Inline]
        final public function set updateSwitchOn ( value : Boolean ) : void
        {
            m_bUpdateSwitchOn = value;
        }

        // clear all objects in pool
        public function clearAll() : void
        {
            for each( var pool : CResourcePool in m_mapPools )
            {
                pool.clearAll();
            }
            m_mapPools.clear();
        }
        // only dispose extra objects in pool( bigger than m_iDefaultPoolSize )
        public function clearExtra() : void
        {
            for each( var pool : CResourcePool in m_mapPools )
            {
                pool.clearExtra();
            }
        }

        final public function get numPools() : uint
        {
            return m_mapPools.length;
        }

        final public function addPool( sPoolName : String, pool : CResourcePool ) : void
        {
            m_mapPools.add( sPoolName, pool );
        }
        final public function removePool( sPoolName : String ) : void
        {
            var pool : CResourcePool = m_mapPools.find( sPoolName );
            if( pool != null ) pool.dispose();

            m_mapPools.remove( sPoolName );
        }

        final public function getPool( sPoolName : String ) : CResourcePool
        {
            var pool : CResourcePool = m_mapPools.find( sPoolName );
            if( pool != null ) return pool;
            else return null;
        }

        final public function getPoolCurrentCapacity( sPoolName : String ) : uint
        {
            var pool : CResourcePool = m_mapPools.find( sPoolName );
            if( pool != null ) return pool.currentCapacity;
            else return 0;
        }
        final public function getPoolCapacity( sPoolName : String ) : uint
        {
            var pool : CResourcePool = m_mapPools.find( sPoolName );
            if( pool != null ) return pool.capacity;
            else return 0;
        }
        final public function getPoolReservedCapacity( sPoolName : String ) : uint
        {
            var pool : CResourcePool = m_mapPools.find( sPoolName );
            if( pool != null ) return pool.preservedCapacity;
            else return 0;
        }

        final public function allocate( sPoolName : String ) : Object
        {
            var pool : CResourcePool = m_mapPools.find( sPoolName );
            if( pool != null ) return pool.allocate();
            else return null;
        }

        final public function recycle( sPoolName : String, obj : Object ) : void
        {
            var pool : CResourcePool = m_mapPools.find( sPoolName );
            if( pool != null ) pool.recycle( obj );
        }

        final public function preallocateInPool( sPoolName : String, iNum : int ) : void
        {
            var pool : CResourcePool = m_mapPools.find( sPoolName );
            if( pool != null ) pool.preallocateInPool( iNum );
        }

        // call update each frame to maintain the quantity of the pool
        public function update( fDeltaTime : Number ) : void
        {
            m_fUpdateTime += fDeltaTime;

            if( m_bUpdateSwitchOn && m_fUpdateTime > m_fUpdateTimeInterval )
            {
                for each( var pool : CResourcePool in m_mapPools )
                {
                    pool.cleanUpRecycledObjects( m_iCleanUpFactor );
                }

                m_fUpdateTime %= m_fUpdateTimeInterval;
            }
        }

        //
        //
        protected var m_mapPools : CMap = null;
        protected var m_fUpdateTime : Number = 0.0;
        protected var m_fUpdateTimeInterval : Number = 10.0;
        protected var m_iCleanUpFactor : int = 3;
        protected var m_bUpdateSwitchOn : Boolean = true;
    }
}
