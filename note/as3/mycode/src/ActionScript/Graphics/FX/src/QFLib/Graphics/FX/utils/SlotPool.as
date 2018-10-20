/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/11/24.
 */
package QFLib.Graphics.FX.utils
{
    import QFLib.Interface.IDisposable;

    public class SlotPool implements IDisposable
    {
        private var m_counts : Vector.<uint>;
        private var m_pools : Vector.<Vector.<Object>>;
        private var m_createObjectFun : Function;
        //@param createObjectFun: (slot:uint):Object
        public function SlotPool ( count : uint, createObjectFun : Function )
        {
            m_counts = new <uint>[] ();
            m_counts.length = count;
            m_pools = new <Vector.<Object>>[] ();
            m_pools.length = count;
            m_createObjectFun = createObjectFun;
        }

        public function dispose () : void
        {
            if ( m_pools )
            {
                var count : uint = m_pools.length;
                for ( var i : int = 0; i < count; ++i )
                {
                    var pool : Vector.<Object> = m_pools[ i ];
                    for each( var obj : Object in pool )
                    {
                        var disposableObj : IDisposable = obj as IDisposable;
                        if ( disposableObj != null ) disposableObj.dispose ();
                        else if ( obj != null && obj.hasOwnProperty ( "dispose" ) && obj.dispose is Function ) obj.dispose ();

                    }
                    pool.length = 0;

                }
                m_pools.length = 0;
                m_counts.length = 0;
            }
            m_pools = null;
            m_counts = null;
            m_createObjectFun = null;
        }

        public function allocate ( slot : uint ) : Object
        {
            var pools : Vector.<Vector.<Object>> = m_pools;
            var counts : Vector.<uint> = m_counts;
            var pool : Vector.<Object> = pools[ slot ];
            if ( pool == null )pool = new <Object>[];
            var count : uint = counts[ slot ];
            if ( count > 0 )
            {
                --count;
                count[ slot ] = count;
                return pool[ count ];
            }
            else
            {
                var newObj : Object = m_createObjectFun ( slot );
                return newObj;
            }
        }

        public function deallocate ( slot : uint, obj : Object ) : void
        {
            var pools : Vector.<Vector.<Object>> = m_pools;
            var counts : Vector.<uint> = m_counts;
            var pool : Vector.<Object> = pools[ slot ];
            var count : uint = counts[ slot ];
            pool[ count ] = obj;
            ++count;
            count[ slot ] = count;
        }

    }
}
