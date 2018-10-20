/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/12/6.
 */
package QFLib.Graphics.FX.utils
{
    import QFLib.Interface.IDisposable;

    public class LoopPoolList implements IDisposable
    {
        private var m_List : Vector.<Object>;
        private var m_Capacity : int;
        private var m_Count : int;
        private var m_HeadIndex : int;
        private var m_TailIndex : int;
        private var m_CreateFun : Function;
        private var m_DisposeFun : Function;
        private var m_UnuseFun : Function;
        //@param createFun: ():Object;  create action
        //@param disposeFun: (object:Object):void  dispose action
        //@param unuseFun: (object:Object):void unuse nodify
        public function LoopPoolList ( capacity : int,
                                       createFun : Function,
                                       disposeFun : Function = null,
                                       unuseFun : Function = null )
        {
            m_List = new Vector.<Object> ();
            m_List.length = capacity;
            m_List.fixed = true;
            m_Capacity = capacity;
            m_CreateFun = createFun;
            m_DisposeFun = disposeFun;
            m_UnuseFun = unuseFun;
        }

        public function dispose () : void
        {
            if ( m_List != null )
            {
                for ( var i : int = 0, l : int = m_List.length; i < l; ++i )
                {
                    if ( m_List[ i ] != null )
                    {
                        if ( m_DisposeFun != null )
                        {
                            m_DisposeFun ( m_List[ i ] );
                        }
                        else if ( m_List[ i ] is IDisposable )
                        {
                            (m_List[ i ] as IDisposable).dispose ();
                        }
                        else if ( m_List[ i ].hasOwnProperty ( "dispose" ) && m_List[ i ].dispose is Function )
                        {
                            m_List[ i ].dispose ();
                        }
                    }
                }
                m_List.fixed = false;
                m_List.length = 0;
                m_List = null;
            }
            m_CreateFun = null;
            m_DisposeFun = null;
            m_UnuseFun = null;
        }

        public function get count () : int { return m_Count; }

        public function getObject ( index : int ) : Object
        {
            return m_List[ (index + m_TailIndex) % m_Capacity ];
        }

        public function push () : Object
        {
            if ( m_Capacity > 0 )
            {
                var result : Object = m_List[ m_HeadIndex ];
                if ( result == null )
                {
                    result = m_CreateFun ();
                    m_List[ m_HeadIndex ] = result;
                }
                if ( m_Count < m_Capacity )
                {
                    ++m_Count;
                }
                else if ( m_HeadIndex == m_TailIndex )
                {
                    m_TailIndex = (m_TailIndex + 1) % m_Capacity;
                }
                m_HeadIndex = (m_HeadIndex + 1) % m_Capacity;

                return result;
            }
            return null;
        }

        public function pop ( count : int ) : void
        {
            var i : int;
            if ( m_Count == 0 ) return;
            if ( m_Count < count )
            {
                if ( m_UnuseFun != null )
                {
                    for ( i = 0; i < m_Count; ++i )
                    {
                        m_UnuseFun ( getObject ( i ) );
                    }
                }
                clear ();
            }
            else
            {
                if ( m_UnuseFun != null )
                {
                    for ( i = 0; i < count; ++i )
                    {
                        m_UnuseFun ( getObject ( i ) );
                    }
                }
                m_TailIndex = (m_TailIndex + count) % m_Capacity;
                m_Count -= count;
            }
        }

        public function clear () : void
        {
            m_Count = 0;
            m_HeadIndex = m_TailIndex = 0;
        }
    }
}
