/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/1/19.
 */
package QFLib.QEngine.Renderer.RenderQueue
{
    import QFLib.Interface.IDisposable;
    import QFLib.QEngine.Renderer.*;

    public class RenderCommandSet implements IDisposable
    {
        private static const ASCEND : int = 0;
        private static const DESCEND : int = 1;

        private static var sSortHelper : Vector.<IRenderCommand> = new Vector.<IRenderCommand>();

        public function RenderCommandSet()
        {
            m_vecRCMDs = new Vector.<IRenderCommand>();
        }
        private var m_vecRCMDs : Vector.<IRenderCommand> = null;
        private var m_CurrentCapcity : int = 0;
        private var m_CurrentUsedCount : int = 0;
        private var m_CompareMode : int = ASCEND;
        private var m_CompareFunc : Function = null;

        [Inline]
        final public function get count() : int
        { return m_CurrentUsedCount; }

        [Inline]
        final public function get capacity() : int
        { return m_CurrentCapcity; }

        public function dispose() : void
        {
            clear();
            m_vecRCMDs.fixed = false;
            m_vecRCMDs.length = 0;
            m_vecRCMDs = null;
        }

        [Inline]
        final public function getElement( index : int ) : IRenderCommand
        { return m_vecRCMDs[ index ]; }

        public function add( pRenderCMD : IRenderCommand ) : void
        {
            if( 0 == m_CurrentCapcity || m_CurrentUsedCount == m_CurrentCapcity )
            {
                m_vecRCMDs.fixed = false;
                m_vecRCMDs.length += 16;
                m_vecRCMDs.fixed = true;

                m_vecRCMDs[ m_CurrentCapcity ] = pRenderCMD;
                m_CurrentCapcity += 16;
            }
            else
            {
                m_vecRCMDs[ m_CurrentUsedCount ] = pRenderCMD;
            }

            m_CurrentUsedCount += 1;
        }

        public function sort( sortMode : int = 1 /*ESortMode.SORT_PASS_GROUP*/ ) : void
        {
            switch( sortMode )
            {
                case ESortMode.SORT_PASS_GROUP:
                    m_CompareFunc = compareByPass;
                    break;
                case ESortMode.SORT_ASCEND_DISTANCE:
                    m_CompareMode = ASCEND;
                    m_CompareFunc = compareByZDistance;
                    break;
                case ESortMode.SORT_DESCEND_DISTANCE:
                    m_CompareMode = DESCEND;
                    m_CompareFunc = compareByZDistance;
                    break;
                default:
                    break;
            }

            if( sSortHelper.length < m_CurrentUsedCount )
                sSortHelper.length = m_CurrentUsedCount;
            mergeSort( 0, m_CurrentUsedCount );
        }

        public function clear() : void { m_CurrentUsedCount = 0; }

        public function tightRCMDsSet() : void
        {

        }

        private function mergeSort( start : int, length : int ) : void
        {
            if( length <= 1 ) return;
            else
            {
                var halfLength : int = length / 2;
                var left : int = start;
                var right : int = start + halfLength;
                var startIndex : int = start;
                var endIndex : int = start + length;

                mergeSort( left, halfLength );
                mergeSort( right, length - halfLength );

                var leftCMD : IRenderCommand = null;
                var rightCMD : IRenderCommand = null;
                for( var i : int = startIndex; i < endIndex; i++ )
                {
                    leftCMD = m_vecRCMDs[ left ];
                    rightCMD = m_vecRCMDs[ right ];

                    if( left < startIndex + halfLength &&
                            ( right == endIndex || m_CompareFunc( leftCMD, rightCMD ) ) )
                    {
                        sSortHelper[ i ] = m_vecRCMDs[ left ];
                        ++left;
                    }
                    else
                    {
                        sSortHelper[ i ] = m_vecRCMDs[ right ];
                        ++right;
                    }
                }

                for( i = startIndex; i < endIndex; i++ )
                {
                    m_vecRCMDs[ i ] = sSortHelper[ i ];
                }
            }
        }

        private function compareByPass( leftCMD : IRenderCommand, rightCMD : IRenderCommand ) : Boolean
        {
            return true;
        }

        private function compareByZDistance( leftCMD : IRenderCommand, rightCMD : IRenderCommand ) : Boolean
        {
            var result : Boolean = ( m_CompareMode == ASCEND );
            return result ? ( leftCMD.zDistance <= rightCMD.zDistance ) : ( leftCMD.zDistance >= rightCMD.zDistance );
        }
    }
}
