/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/11/2.
 */
package QFLib.QEngine.Core
{
    import QFLib.Foundation.CMap;
    import QFLib.Interface.IDisposable;

    use namespace Engine_Internal;

    public class Node implements IDisposable
    {
        public function Node( pParent : Node = null, name : String = null )
        {
            m_Name = name;
            m_Enable = true;

            setParent( pParent );
        }
        protected var m_mapChildren : CMap = new CMap();
        protected var m_Name : String = null;
        protected var m_pParent : Node = null;
        protected var m_IndexInParent : int = -1;
        protected var m_Enable : Boolean = true;

        [Inline]
        final public function get enable() : Boolean
        { return m_Enable; }

        [Inline]
        final public function set enable( value : Boolean ) : void
        { m_Enable = value; }

        [Inline]
        final public function get childrenCount() : int
        { return m_mapChildren.count; }

        [Inline]
        final public function get indexInParent() : int
        { return m_IndexInParent; }

        [Inline]
        final public function get parent() : Node
        { return m_pParent; }

        public function dispose() : void
        {
            //remove from parent
            if( m_pParent != null )
            {
                m_pParent.removeChild( this );
                m_pParent = null;
            }

            //dispose children
            var child : Node;
            for( var i : int = 0, n : int = m_mapChildren.count; i < n; i++ )
            {
                child = m_mapChildren[ i ];
                child.dispose();
                child = null;
            }

            //clear
            m_mapChildren.clear();
            m_mapChildren = null;
        }

        public function setParent( pParentNode : Node ) : void
        {
            if( pParentNode == null ) return;
            if( m_pParent != pParentNode )
            {
                pParentNode.addChild( this );
            }
        }

        public function addChild( pChild : Node ) : Node
        {
            if( pChild.parent != this )
            {
                pChild.removeFromParent();

                _notifyAddChild( pChild );
                return pChild;
            }

            return null;
        }

        /**
         * remove but don't dispose
         * @param pChild
         */
        public function removeChild( pChild : Node ) : Node
        {
            var index : int = pChild.indexInParent;
            if( index != -1 )
            {
                _notifyRemoveChild( pChild );
                return pChild;
            }

            return null;
        }

        /**
         *
         */
        public function removeFromParent() : void
        {
            if( m_pParent == null ) return;
            m_pParent.removeChild( this );
        }

        /**
         * remove all children but don't dispose
         */
        public function removeAllChildren() : void
        {
            var child : Node;
            for( var i : int = 0, n : int = m_mapChildren.count; i < n; i++ )
            {
                child = m_mapChildren[ i ];
                child.removeFromParent();
            }

            m_mapChildren.clear();
        }

        Engine_Internal function _notifyAddChild( pChild : Node ) : void
        {
            var count : int = m_mapChildren.count;
            m_mapChildren.add( m_mapChildren.count, pChild, true );
            pChild._notifyAddToParent( this, count );
        }

        Engine_Internal function _notifyRemoveChild( pChild : Node ) : void
        {
            m_mapChildren.remove( pChild.indexInParent );
            pChild._notifyRemoveFromParent();
        }

        Engine_Internal function _notifyAddToParent( pParent : Node, index : int ) : void
        {
            m_pParent = pParent;
            m_IndexInParent = index;
        }

        Engine_Internal function _notifyRemoveFromParent() : void
        {
            m_pParent = null;
            m_IndexInParent = -1;
        }
    }
}
