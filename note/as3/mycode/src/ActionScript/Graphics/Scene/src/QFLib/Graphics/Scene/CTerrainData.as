//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by tDAN 2016/5/20.
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Graphics.Scene
{

import QFLib.Foundation;
import QFLib.Foundation.CMap;
    import QFLib.Foundation.CSet;
    import QFLib.Graphics.RenderCore.CBaseObject;
import QFLib.Math.CAABBox2;
    import QFLib.Math.CAABBox3;
    import QFLib.Math.CMath;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

    import flash.utils.ByteArray;

    //
    //
    public class CTerrainData
	{
		public function CTerrainData()
		{
		}

		public function dispose() : void
		{
        }

        [Inline]
        final public function get numBlocksX() : Number
        {
            return m_iNumGridsX;
        }
        [Inline]
        final public function get numBlocksY() : Number
        {
            return m_iNumGridsY;
        }
        [Inline]
        final public function get gridUnitSize() : Number
        {
            return m_fGridUnitSize;
        }
        [Inline]
        final public function get range() : CAABBox2
        {
            return m_theRange;
        }

        [Inline]
        final public function get numDynamic2DBoxes() : int
        {
            if( m_setDynamic2DBoxes == null ) return 0;
            else return m_setDynamic2DBoxes.length;
        }
        [Inline]
        final public function get numDynamic3DBoxes() : int
        {
            if( m_setDynamic3DBoxes == null ) return 0;
            else return m_setDynamic3DBoxes.length;
        }

        [Inline]
        final public function hasTerrain( f3DPosX : Number, f3DPosZ : Number ) : Boolean
        {
            var f3DPosY : Number = getTerrainHeight( f3DPosX, f3DPosZ );
            return !isBlocked( f3DPosX, f3DPosY, f3DPosZ );
        }

        public function getTerrainHeight( f3DPosX : Number, f3DPosZ : Number, fStepHeight : Number = -1.0 ) : Number
        {
            var f2DPosY : Number = f3DPosZ * CBaseObject.TAN_THETA_OF_CAMERA; // to convert 3D position to 2D screen space cuz terrain data is 2D space

            var iGridX : int = ( f3DPosX - m_theRange.min.x ) / m_fGridUnitSize;
            var iGridY : int = ( f2DPosY - m_theRange.min.y ) / m_fGridUnitSize;
            if( iGridX < 0 || iGridX >= m_iNumGridsX ) return 0.0;
            if( iGridY < 0 || iGridY >= m_iNumGridsY ) return 0.0;

            var fGridHeight : Number = m_vHeightGrids[ iGridY * m_iNumGridsX + iGridX ];
            if( fStepHeight < 0.0 ) return fGridHeight;

            // do height interpolation, start by getting the center of the grid and calculate the weight from positionXZ to grid center
            var fGridCenterX : Number = iGridX * m_fGridUnitSize + m_theRange.min.x + m_fGridUnitSize * 0.5;
            var fGridCenterY : Number = iGridY * m_fGridUnitSize + m_theRange.min.y + m_fGridUnitSize * 0.5;
            var fXWeightToCenter : Number = ( f3DPosX - fGridCenterX ) / m_fGridUnitSize;
            var fYWeightToCenter : Number = ( f2DPosY - fGridCenterY ) / m_fGridUnitSize;

            // prepare to get 4 grids' height value nearby the positionXZ (XZ mirror mapping from the center)
            var iShiftGridX : int;
            if( fXWeightToCenter >= 0.0 ) iShiftGridX = 1;
            else
            {
                iShiftGridX = -1;
                fXWeightToCenter = -fXWeightToCenter;
            }
            var iShiftGridY : int;
            if( fYWeightToCenter >= 0.0 ) iShiftGridY = 1;
            else
            {
                iShiftGridY = -1;
                fYWeightToCenter = -fYWeightToCenter;
            }

            // store 4 grids' height into fGridHeight0 ~ fGridHeight3
            var fGridHeight1 : Number = getGridHeight( iGridX + iShiftGridX, iGridY, fGridHeight );
            var fGridHeight2 : Number = getGridHeight( iGridX, iGridY + iShiftGridY, fGridHeight );
            var fGridHeight3 : Number = getGridHeight( iGridX + iShiftGridX, iGridY + iShiftGridY, ( fGridHeight1 + fGridHeight2 ) * 0.5 );

            // using simplified method to interpolate the X then Z due to each grid is a square
            var fHeight1 : Number = fGridHeight * ( 1.0 - fXWeightToCenter ) + fGridHeight1 * fXWeightToCenter;
            var fHeight2 : Number = fGridHeight2 * ( 1.0 - fXWeightToCenter ) + fGridHeight3 * fXWeightToCenter;
            fGridHeight = fHeight1 * ( 1.0 - fYWeightToCenter ) + fHeight2 * fYWeightToCenter;

            return fGridHeight;
        }

        public function hitTest( f2DPosX : Number, f2DPosY : Number, v3DPos : CVector3 = null ) : CVector3
        {
            var iGridX : int = ( f2DPosX - m_theRange.min.x ) / m_fGridUnitSize;
            if( iGridX < 0 || iGridX >= m_iNumGridsX ) return null;

            var f3DFarestZDis : Number = f2DPosY / CBaseObject.TAN_THETA_OF_CAMERA;
            var f3DZDis : Number;
            var f3DGridPosZ : Number;

            var iGridY : int;
            var f3DHeight : Number;
            var fGridHeight : Number;
            var fLastGridHeight : Number;
            var fLast3DGridPosZ : Number;
            var bBingo : Boolean = false;
            for( iGridY = m_iNumGridsY - 1; iGridY >= 0; iGridY-- )
            {
                f3DZDis = ( m_iNumGridsY - 1 - iGridY ) * m_fGridUnitSize + m_theRange.min.y + m_fGridUnitSize * 0.5;
                f3DZDis /= CBaseObject.TAN_THETA_OF_CAMERA;

                f3DGridPosZ = iGridY * m_fGridUnitSize + m_theRange.min.y + m_fGridUnitSize * 0.5;
                f3DGridPosZ /= CBaseObject.TAN_THETA_OF_CAMERA;
                fGridHeight = this.getTerrainHeight( f2DPosX, f3DGridPosZ );
                if( f3DGridPosZ < f3DFarestZDis )
                {
                    bBingo = true;
                    if( iGridY == m_iNumGridsY - 1 )
                    {
                        fLastGridHeight = fGridHeight;
                        fLast3DGridPosZ = f3DGridPosZ;
                    }
                    break;
                }

                f3DHeight = ( f3DGridPosZ - f3DFarestZDis ) * CBaseObject.TAN_THETA_OF_CAMERA;
                if( fGridHeight >= f3DHeight )
                {
                    bBingo = true;
                    if( iGridY == m_iNumGridsY - 1 )
                    {
                        fLastGridHeight = fGridHeight;
                        fLast3DGridPosZ = f3DGridPosZ;
                    }
                    break;
                }

                fLastGridHeight = fGridHeight;
                fLast3DGridPosZ = f3DGridPosZ;
            }

            if( bBingo )
            {
                if( v3DPos == null ) v3DPos = new CVector3( f2DPosX, fLastGridHeight, fLast3DGridPosZ );
                else v3DPos.setValueXYZ( f2DPosX, fLastGridHeight, fLast3DGridPosZ );
                return v3DPos;
            }
            else return null;
        }

        public function getTerrainLightData( f3DPosX : Number, f3DPosZ : Number ) : CLightData
        {
            var f2DPosY : Number = f3DPosZ * CBaseObject.TAN_THETA_OF_CAMERA; // to convert 3D position to 2D screen space cuz terrain data is 2D space

            var iGridX : int = ( f3DPosX - m_theRange.min.x ) / m_fGridUnitSize;
            var iGridY : int = ( f2DPosY - m_theRange.min.y ) / m_fGridUnitSize;
            if( iGridX < 0 || iGridX >= m_iNumGridsX ) return null;
            if( iGridY < 0 || iGridY >= m_iNumGridsY ) return null;

            if( m_mapLightData.find( iGridY * m_iNumGridsX + iGridX ) != null )
            {
                return m_mapLightData[ iGridY * m_iNumGridsX + iGridX ];
            }

            return null;
        }

        [Inline]
        final public function getGridHeight( iGridX : int, iGridY : int, fOutBoundGridHeight : Number = 0.0 ) : Number
        {
            if( iGridX < 0 || iGridX >= m_iNumGridsX ) return fOutBoundGridHeight;
            if( iGridY < 0 || iGridY >= m_iNumGridsY ) return fOutBoundGridHeight;
            return m_vHeightGrids[ iGridY * m_iNumGridsX + iGridX ];
        }

        public function gridX( f3DPosX : Number, bForceInbound : Boolean = true ) : int
        {
            var iGridX : int = ( f3DPosX - m_theRange.min.x ) / m_fGridUnitSize;
            if( bForceInbound )
            {
                if( iGridX < 0 ) return 0;
                else if( iGridX >= m_iNumGridsX ) return m_iNumGridsX - 1;
            }
            return iGridX;
        }
        public function gridY( f3DPosY : Number, f3DPosZ : Number, bForceInbound : Boolean = true, bConsider3DPosY : Boolean = true ) : int
        {
            var f2DPosY : Number = f3DPosZ * CBaseObject.TAN_THETA_OF_CAMERA; // to convert 3D position to 2D screen space cuz terrain data is 2D space
            if( bConsider3DPosY )
            {
                f2DPosY -= f3DPosY;
            }
            //var f2DPosY : Number = -f3DPosY + ( f3DPosZ * CBaseObject.TAN_THETA_OF_CAMERA ); // to convert 3D position to 2D screen space cuz terrain data is 2D space

            var iGridY : int = ( f2DPosY - m_theRange.min.y ) / m_fGridUnitSize;
            if( bForceInbound )
            {
                if( iGridY < 0 ) return 0;
                else if( iGridY >= m_iNumGridsY ) return m_iNumGridsY - 1;
            }
            return iGridY;
        }

        public function isBlocked( f3DPosX : Number, f3DPosY : Number, f3DPosZ : Number, bConsider3DPosY : Boolean = true, boxRange : CAABBox2 = null ) : Boolean
        {
            var iGridX : int;
            var iGridY : int;

            var f2DPosY : Number = f3DPosZ * CBaseObject.TAN_THETA_OF_CAMERA; // to convert 3D position to 2D screen space cuz terrain data is 2D space
            if( bConsider3DPosY )
            {
                f2DPosY -= f3DPosY;
            }
            //var f2DPosY : Number = f3DPosZ * CBaseObject.TAN_THETA_OF_CAMERA; // to convert 3D position to 2D screen space cuz terrain data is 2D space

            //var iGridX : int = ( f3DPosX - m_theRange.min.x ) / m_fGridUnitSize;
            //var iGridY : int = ( f2DPosY - m_theRange.min.y ) / m_fGridUnitSize;
            //if( iGridX < 0 || iGridX >= m_iNumGridsX ) return true;
            //if( iGridY < 0 || iGridY >= m_iNumGridsY ) return true;

            //var f3DPosY : Number = m_vHeightGrids[ iGridY * m_iNumGridsX + iGridX ];
            //f2DPosY -= f3DPosY; // convert 3D position to 2D screen space cuz terrain data is 2D space

            iGridX = ( f3DPosX - m_theRange.min.x ) / m_fGridUnitSize;
            iGridY = ( f2DPosY - m_theRange.min.y ) / m_fGridUnitSize;
            if( isBlockedGrid( iGridX, iGridY, boxRange ) ) return true;

            if( m_setDynamic2DBoxes != null )
            {
                for each( var box2D : CAABBox2 in m_setDynamic2DBoxes )
                {
                    if( box2D.isCollidedVertexValue( f3DPosX, f2DPosY ) ) return true;
                }
            }
            if( m_setDynamic3DBoxes != null )
            {
                for each( var box3D : CAABBox3 in m_setDynamic3DBoxes )
                {

                    if( box3D.isCollidedVertexValue( f3DPosX,  box3D.center.y, f3DPosZ) ) return true;
                }
            }

            return false;
        }

        public function isLineBlocked( f3DPosX1 : Number, f3DPosY1 : Number, f3DPosZ1 : Number,
                                         f3DPosX2 : Number, f3DPosY2 : Number, f3DPosZ2 : Number,
                                         bConsider3DPosY : Boolean = true, boxRange : CAABBox2 = null,
                                         fBeginT : Number = 0.0 ) : Boolean
        {
            var iGridX : int;
            var iGridY : int;
            //var f3DPosY : Number;

            // convert f3DPosY1 to 2D space -> f2DPosY1
            var f2DPosY1 : Number = f3DPosZ1 * CBaseObject.TAN_THETA_OF_CAMERA; // to convert 3D position to 2D screen space cuz terrain data is 2D space
            if( bConsider3DPosY )
            {
                f2DPosY1 -= f3DPosY1;
            }
            iGridX = ( f3DPosX1 - m_theRange.min.x ) / m_fGridUnitSize;
            iGridY = ( f2DPosY1 - m_theRange.min.y ) / m_fGridUnitSize;
            if( iGridX < 0 || iGridX >= m_iNumGridsX ) return true;
            if( iGridY < 0 || iGridY >= m_iNumGridsY ) return true;
            //f3DPosY = m_vHeightGrids[ iGridY * m_iNumGridsX + iGridX ];
            //f2DPosY1 -= f3DPosY; // convert 3D position to 2D screen space cuz terrain data is 2D space

            // convert f3DPosY2 to 2D space -> f2DPosY2
            var f2DPosY2 : Number = f3DPosZ2 * CBaseObject.TAN_THETA_OF_CAMERA; // to convert 3D position to 2D screen space cuz terrain data is 2D space
            if( bConsider3DPosY )
            {
                f2DPosY2 -= f3DPosY2;
            }
            //iGridX = ( f3DPosX2 - m_theRange.min.x ) / m_fGridUnitSize;
            //iGridY = ( f2DPosY2 - m_theRange.min.y ) / m_fGridUnitSize;
            //if( iGridX < 0 || iGridX >= m_iNumGridsX ) return true;
            //if( iGridY < 0 || iGridY >= m_iNumGridsY ) return true;
            //f3DPosY = m_vHeightGrids[ iGridY * m_iNumGridsX + iGridX ];
            //f2DPosY2 -= f3DPosY; // convert 3D position to 2D screen space cuz terrain data is 2D space

            // check if f3DPos2 is blocked first
            iGridX = ( f3DPosX2 - m_theRange.min.x ) / m_fGridUnitSize;
            iGridY = ( f2DPosY2 - m_theRange.min.y ) / m_fGridUnitSize;
            if( isBlockedGrid( iGridX, iGridY, boxRange ) ) return true;

            var l : Number = f3DPosX2 - f3DPosX1;
            var m : Number = f2DPosY2 - f2DPosY1;
            var fLen : Number = CMath.sqrt( l * l + m * m );
            if( fLen >= m_fGridUnitSize )
            {
                // start checking each step's position from t = fBeginT
                var fStep : Number = m_fGridUnitSize / fLen;
                var t : Number = fBeginT;
                var f3DPosX : Number;
                var f2DPosY : Number;

                while( t < 1.0 )
                {
                    f3DPosX = f3DPosX1 + ( l * t );
                    f2DPosY = f2DPosY1 + ( m * t );

                    iGridX = ( f3DPosX - m_theRange.min.x ) / m_fGridUnitSize;
                    iGridY = ( f2DPosY - m_theRange.min.y ) / m_fGridUnitSize;
                    if( isBlockedGrid( iGridX, iGridY, boxRange ) ) return true;

                    t += fStep;
                }
            }

            if( m_setDynamic2DBoxes != null )
            {
                for each( var box2D : CAABBox2 in m_setDynamic2DBoxes )
                {
                    if( box2D.isCollidedLineValue( f3DPosX1, f2DPosY1, f3DPosX2, f2DPosY2 ) ) return true;
                }
            }
            if( m_setDynamic3DBoxes != null )
            {
                for each( var box3D : CAABBox3 in m_setDynamic3DBoxes )
                {

                    if( box3D.isCollidedLineValue( f3DPosX1, box3D.center.y, f3DPosZ1, f3DPosX2, box3D.center.y, f3DPosZ2)) return true;
                }
            }

            return false;
        }

        [Inline]
        final public function isBlockedGrid( iGridX : Number, iGridY : Number, boxRange : CAABBox2 = null ) : Boolean
        {
            if( iGridX < 0 || iGridX >= m_iNumGridsX ) return true;
            if( iGridY < 0 || iGridY >= m_iNumGridsY ) return true;

            if( boxRange != null )
            {
                var fGridX : Number = m_fGridUnitSize * iGridX + m_theRange.min.x;
                var fGridY : Number = m_fGridUnitSize * iGridY + m_theRange.min.y;
                if( boxRange.isCollidedValue( fGridX, fGridY, fGridX + m_fGridUnitSize, fGridY + m_fGridUnitSize ) == false )
                {
                    return true;
                }
            }

            return m_aBlockGrids[ iGridY * m_iNumGridsX + iGridX ] != 0 ? true : false;
        }

        [Inline]
        final public function isLightedGrid(iGridX : Number, iGridY : Number) : CLightData
        {
            if(iGridX < 0 || iGridX >= m_iNumGridsX) return null;
            if(iGridY < 0 || iGridY >= m_iNumGridsY) return null;

            if( m_mapLightData.find( iGridY * m_iNumGridsX + iGridX) != null)
            {
                return m_mapLightData[ iGridY * m_iNumGridsX + iGridX];
            }

            return null;
        }

        [Inline]
        final public function gridPosition( iGridX : int, iGridY : int, v3DPos : CVector3 = null ) : CVector3
        {
            if( v3DPos == null ) v3DPos = new CVector3();
            if( _retrieveGridPosition( iGridX, iGridY, v3DPos ) == false ) return null;
            else return v3DPos;
        }

        // get nearby grid's 3D position by 3D x/y/z coordinate( PosXYZ -> gridXY -> gridPos )
        public function findNearbyGridPosition3D( f3DPosX : Number, f3DPosY : Number, f3DPosZ : Number, vPos3D : CVector3 = null, boxRange : CAABBox2 = null ) : CVector3
        {
            var iGridX : int = gridX( f3DPosX, true );
            var iGridY : int = gridY( f3DPosY, f3DPosZ, true );
            if( isBlockedGrid( iGridX, iGridY, boxRange ) == false )
            {
                if( vPos3D == null ) vPos3D = new CVector3( f3DPosX, f3DPosY, f3DPosZ );
                else vPos3D.setValueXYZ( f3DPosX, f3DPosY, f3DPosZ );
                return vPos3D;
            }

            //iGridY = gridY( 0.0, f3DPosZ, false );
            return findNearbyGridPosition( iGridX, iGridY, vPos3D, boxRange );
        }

        // get nearby grid's 3D on terrain position by 3D x/z coordinate( PosXZ -> gridXY -> gridTerrainPos )
        public function findNearbyTerrainGridPosition3D( f3DPosX : Number, f3DPosY : Number, f3DPosZ : Number, vPos3D : CVector3 = null, boxRange : CAABBox2 = null ) : CVector3
        {
            var iGridX : int = gridX( f3DPosX, false );
            var iGridY : int = gridY( f3DPosY, f3DPosZ, false );
            if( isBlockedGrid( iGridX, iGridY, boxRange ) == false )
            {
                if( vPos3D == null ) vPos3D = new CVector3( f3DPosX, f3DPosY, f3DPosZ );
                else vPos3D.setValueXYZ( f3DPosX, f3DPosY, f3DPosZ );
                return vPos3D;
            }

            //iGridY = gridY( 0.0, f3DPosZ, false );
            return findNearbyTerrainGridPosition( iGridX, iGridY, vPos3D, boxRange );
        }

        public function findNearbyGridPosition( iGridX : int, iGridY : int, vPos3D : CVector3 = null, boxRange : CAABBox2 = null ) : CVector3
        {
            if( isBlockedGrid( iGridX, iGridY, boxRange ) == false )
            {
                return gridPosition( iGridX, iGridY, vPos3D );
            }

            for( var i : int = 0; i < m_iNumGridsX; i++ )
            {
                var j : int;

                for( j = 1; j < m_iNumGridsY; j++ )
                {
                    if( isBlockedGrid( iGridX + i, iGridY + j, boxRange ) == false )
                    {
                        return gridPosition( iGridX + i, iGridY + j, vPos3D );
                    }
                    if( isBlockedGrid( iGridX + i, iGridY - j, boxRange ) == false )
                    {
                        return gridPosition( iGridX + i, iGridY - j, vPos3D );
                    }
                }
                for( j = 1; j < m_iNumGridsY; j++ )
                {
                    if( isBlockedGrid( iGridX - i, iGridY + j, boxRange ) == false )
                    {
                        return gridPosition( iGridX - i, iGridY + j, vPos3D );
                    }
                    if( isBlockedGrid( iGridX - i, iGridY - j, boxRange ) == false )
                    {
                        return gridPosition( iGridX - i, iGridY - j, vPos3D );
                    }
                }
            }

            return null;
        }

        public function findNearbyTerrainGridPosition( iGridX : int, iGridY : int, vPos3D : CVector3 = null, boxRange : CAABBox2 = null ) : CVector3
        {
            if( isBlockedGrid( iGridX, iGridY, boxRange ) == false )
            {
                return _gridTerrainPosition( iGridX, iGridY, vPos3D );
            }

            for( var i : int = 0; i < m_iNumGridsX; i++ )
            {
                var j : int;

                for( j = 1; j < m_iNumGridsY; j++ )
                {
                    if( isBlockedGrid( iGridX + i, iGridY + j, boxRange ) == false )
                    {
                        return _gridTerrainPosition( iGridX + i, iGridY + j, vPos3D );
                    }
                    if( isBlockedGrid( iGridX + i, iGridY - j, boxRange ) == false )
                    {
                        return _gridTerrainPosition( iGridX + i, iGridY - j, vPos3D );
                    }
                }
                for( j = 1; j < m_iNumGridsY; j++ )
                {
                    if( isBlockedGrid( iGridX - i, iGridY + j, boxRange ) == false )
                    {
                        return _gridTerrainPosition( iGridX - i, iGridY + j, vPos3D );
                    }
                    if( isBlockedGrid( iGridX - i, iGridY - j, boxRange ) == false )
                    {
                        return _gridTerrainPosition( iGridX - i, iGridY - j, vPos3D );
                    }
                }
            }

            return null;
        }

        public function pixelX( iGridX : int, loc : int = 0 ) : Number
        {
            var ret : Number = iGridX * m_fGridUnitSize + m_theRange.min.x;
            if ( loc == 1 )
                ret += m_fGridUnitSize * 0.5;
            else if ( loc == 2 )
                ret += m_fGridUnitSize;
            return ret;
        }

        public function pixelY( iGridY : int, loc : int = 0 ) : Number
        {
            var ret:Number = iGridY * m_fGridUnitSize + m_theRange.min.y;
            if ( loc == 1 )
                ret += m_fGridUnitSize * 0.5;
            else if (loc == 2)
                ret += m_fGridUnitSize;
            return ret;
        }

        public function load( theSceneInfo : Object ) : Boolean
		{
            if( theSceneInfo.hasOwnProperty( "width" ) == false || theSceneInfo.hasOwnProperty( "height" ) == false )
            {
                Foundation.Log.logErrorMsg( "CTerrainData.load(): Can not get 'width' or 'height' params!" );
                return false;
            }
            else
            {
                m_theRange = new CAABBox2( new CVector2( 0, 0 ), new CVector2( theSceneInfo[ "width" ], theSceneInfo[ "height" ] ) );
            }

            if( theSceneInfo.hasOwnProperty( "blockSize" ) )
            {
                m_fGridUnitSize = theSceneInfo[ "blockSize" ];
            }
            else if( theSceneInfo.hasOwnProperty( "hexagonSize" ) ) // for backward compatibility
            {
                m_fGridUnitSize = theSceneInfo[ "hexagonSize" ];
            }

			if( theSceneInfo.hasOwnProperty( "blockInfo" ) )
			{
                if( m_fGridUnitSize != 0.0 )
                {
                    var i : int;

                    m_iNumGridsX = int( m_theRange.width / m_fGridUnitSize );
                    m_iNumGridsY = int( m_theRange.height / m_fGridUnitSize );

                    var iTotalGrids : int = m_iNumGridsX * m_iNumGridsY;
                    m_aBlockGrids = new ByteArray();
                    m_aBlockGrids.length = iTotalGrids;
                    for( i = 0; i < iTotalGrids; i++ ) m_aBlockGrids[ i ] = 0;

                    var aBlockInfos : Object = theSceneInfo[ "blockInfo" ];
                    for each( var iIdx : int in aBlockInfos )
                    {
                        if( iIdx < iTotalGrids ) m_aBlockGrids[ iIdx ] = 0xFF;
                    }

                    m_vHeightGrids = new Vector.<Number>( iTotalGrids );
                    for( i = 0; i < iTotalGrids; i++ )
                    {
                        m_vHeightGrids[ i ] = 0.0;
                    }
                    if( theSceneInfo.hasOwnProperty( "heightInfo" ) )
                    {
                        var aHeightInfos : Object = theSceneInfo[ "heightInfo" ];
                        if( aHeightInfos.length != iTotalGrids )
                        {
                            Foundation.Log.logErrorMsg( "CTerrainData.load(): aHeightInfos.length != iTotalGrids" );
                            return false;
                        }

                        for( i = 0; i < aHeightInfos.length; i++ )
                        {
                            m_vHeightGrids[ i ] = aHeightInfos[ i ];
                        }
                    }

                    m_mapLightData = new CMap();
                    if(theSceneInfo.hasOwnProperty("lightInfo"))
                    {
                        var aLightInfos : Object = theSceneInfo["lightInfo"];
                        for( i = 0; i < aLightInfos.length; i++ )
                        {
                            var lightData : CLightData = new CLightData( aLightInfos[ i ].index, aLightInfos[ i ].light );
                            m_mapLightData.add( aLightInfos[ i ].index, lightData );
                        }
                    }
                }
                else
                {
                    Foundation.Log.logErrorMsg( "CTerrainData.load(): Can not get 'markObjectSize' param when the blockInfo is using...!" );
                    return false;
                }
			}
            else if( theSceneInfo.hasOwnProperty( "blockPoints" ) ) // for backward compatibility
            {
                if( m_fGridUnitSize != 0.0 )
                {
                    m_iNumGridsX = int( m_theRange.width / m_fGridUnitSize );
                    m_iNumGridsY = int( m_theRange.height / m_fGridUnitSize );

                    iTotalGrids = m_iNumGridsX * m_iNumGridsY;
                    m_aBlockGrids = new ByteArray();
                    m_aBlockGrids.length = iTotalGrids;
                    for( i = 0; i < iTotalGrids; i++ ) m_aBlockGrids[ i ] = 0;

                    var aBlockPoints : Object = theSceneInfo[ "blockPoints" ];
                    for each( var point : Object in aBlockPoints )
                    {
                        iIdx = point.y * m_iNumGridsX + point.x;
                        if (iIdx < 0)
                            continue;
                        
                        if( iIdx < iTotalGrids ) m_aBlockGrids[ iIdx ] = 0xFF;
                    }
                }
                else
                {
                    Foundation.Log.logErrorMsg( "CTerrainData.load(): Can not get 'hexagonSize' param when the blockInfo is using...!" );
                    return false;
                }
            }

			return true;
		}

        public function get blockGrids() : ByteArray {
            return m_aBlockGrids;
        }

        //
        // dynamic boxes
        //
        public function addDynamic2DBox( aabb : CAABBox2 ) : void
        {
            if( m_setDynamic2DBoxes == null ) m_setDynamic2DBoxes = new CSet();
            m_setDynamic2DBoxes.add( aabb );
        }
        public function removeDynamic2DBox( aabb : CAABBox2 ) : void
        {
            if( m_setDynamic2DBoxes == null ) return;
            m_setDynamic2DBoxes.remove( aabb );
        }
        public function addDynamic3DBox( aabb : CAABBox3 ) : void
        {
            if( m_setDynamic3DBoxes == null ) m_setDynamic3DBoxes = new CSet();
            m_setDynamic3DBoxes.add( aabb );
        }
        public function removeDynamic3DBox( aabb : CAABBox3 ) : void
        {
            if( m_setDynamic3DBoxes == null ) return;
            m_setDynamic3DBoxes.remove( aabb );
        }

        public function applyAllBoxesToBlockGrids( bRemoveAllBoxes : Boolean ) : void
        {
            // reset all block grids of which are marked by boxes
            for( var i : int = 0; i < m_aBlockGrids.length; i++ )
            {
                if( m_aBlockGrids[ i ] != 255 ) m_aBlockGrids[ i ] = 0;
            }

            if( m_setDynamic2DBoxes != null )
            {
                _apply2DBoxesToBlockGrids();
                if( bRemoveAllBoxes ) m_setDynamic2DBoxes.clear();
            }

            if( m_setDynamic3DBoxes != null )
            {
                _apply3DBoxesToBlockGrids();
                if( bRemoveAllBoxes ) m_setDynamic3DBoxes.clear();
            }
        }

        //
        //
        [Inline]
        final protected function _gridTerrainPosition( iGridX : int, iGridY : int, v3DPos : CVector3 = null ) : CVector3
        {
            if( v3DPos == null ) v3DPos = new CVector3();
            if( _retrieveGridTerrainPosition( iGridX, iGridY, v3DPos ) == false ) return null;
            else return v3DPos;
        }

        // getting grid's 3D position by its x, y, z( PosXYZ -> gridXY -> gridPos )
        protected function _retrieveGridPosition( iGridX : int, iGridY : int, v3DPos : CVector3 ) : Boolean
        {
            if( iGridX < 0 || iGridX >= m_iNumGridsX ) return false;
            if( iGridY < 0 || iGridY >= m_iNumGridsY ) return false;

            v3DPos.x = iGridX * m_fGridUnitSize + m_theRange.min.x + m_fGridUnitSize * 0.5;
            var f2DPosY : Number = iGridY * m_fGridUnitSize + m_theRange.min.y + m_fGridUnitSize * 0.5;
            v3DPos.z = f2DPosY / CBaseObject.TAN_THETA_OF_CAMERA; // to convert 2D position to 3D space cuz terrain data is 2D space
            //var fHeight : Number = m_vHeightGrids[ iGridY * m_iNumGridsX + iGridX ];
            //v3DPos.z = ( f2DPosY + fHeight ) / CBaseObject.TAN_THETA_OF_CAMERA;
            //v3DPos.y = fHeight;
            v3DPos.y = getTerrainHeight( v3DPos.x, v3DPos.z );
            v3DPos.z = ( f2DPosY + v3DPos.y ) / CBaseObject.TAN_THETA_OF_CAMERA;

            return true;
        }

        // getting grid's 3D terrain position by its x, z( PosXZ -> girdXY -> gridTerrainPos )
        protected function _retrieveGridTerrainPosition( iGridX : int, iGridY : int, v3DPos : CVector3 ) : Boolean
        {
            if( iGridX < 0 || iGridX >= m_iNumGridsX ) return false;
            if( iGridY < 0 || iGridY >= m_iNumGridsY ) return false;

            v3DPos.x = iGridX * m_fGridUnitSize + m_theRange.min.x + m_fGridUnitSize * 0.5;
            var f2DPosY : Number = iGridY * m_fGridUnitSize + m_theRange.min.y + m_fGridUnitSize * 0.5;
            v3DPos.z = f2DPosY / CBaseObject.TAN_THETA_OF_CAMERA; // to convert 2D position to 3D space cuz terrain data is 2D space
            //var fHeight : Number = m_vHeightGrids[ iGridY * m_iNumGridsX + iGridX ];
            //v3DPos.z = ( f2DPosY + fHeight ) / CBaseObject.TAN_THETA_OF_CAMERA;
            //v3DPos.y = fHeight;
            v3DPos.y = getTerrainHeight( v3DPos.x, v3DPos.z );
            //v3DPos.z = ( f2DPosY + v3DPos.y ) / CBaseObject.TAN_THETA_OF_CAMERA;

            return true;
        }

        protected function _apply2DBoxesToBlockGrids() : void
        {
            if( m_setDynamic2DBoxes == null ) return ;

            var iGridXMin : int;
            var iGridYMin : int;
            var iGridXMax : int;
            var iGridYMax : int;
            var i : int;
            var j : int;
            var iIndex : int;

            for each( var box2D : CAABBox2 in m_setDynamic2DBoxes )
            {
                // get min X
                iGridXMin = ( box2D.min.x - m_theRange.min.x ) / m_fGridUnitSize;
                if( iGridXMin < 0 ) iGridXMin = 0;
                else if( iGridXMin >= m_iNumGridsX ) iGridXMin = m_iNumGridsX - 1;

                // get min Y
                iGridYMin = ( box2D.min.y - m_theRange.min.y ) / m_fGridUnitSize;
                if( iGridYMin < 0 ) iGridYMin = 0;
                else if( iGridYMin >= m_iNumGridsY ) iGridYMin = m_iNumGridsY - 1;

                // get max X
                iGridXMax = ( box2D.max.x - m_theRange.min.x ) / m_fGridUnitSize;
                if( iGridXMax < 0 ) iGridXMax = 0;
                else if( iGridXMax >= m_iNumGridsX ) iGridXMax = m_iNumGridsX - 1;

                // get max Y
                iGridYMax = ( box2D.max.y - m_theRange.min.y ) / m_fGridUnitSize;
                if( iGridYMax < 0 ) iGridYMax = 0;
                else if( iGridYMax >= m_iNumGridsY ) iGridYMax = m_iNumGridsY - 1;

                for( j = iGridYMin; j <= iGridYMax; j++ )
                {
                    for( i = iGridXMin; i <= iGridXMax; i++ )
                    {
                        iIndex = j * m_iNumGridsX + i;
                        if( m_aBlockGrids[ iIndex ] == 0 ) m_aBlockGrids[ iIndex ] = 1;
                    }
                }
            }
        }

        protected function _apply3DBoxesToBlockGrids() : void
        {
            if( m_setDynamic3DBoxes == null ) return ;

            var iGridXMin : int;
            var iGridYMin : int;
            var iGridXMax : int;
            var iGridYMax : int;
            var iGridY : int;
            var f2DPosY : Number;
            var f3DPosY : Number;
            var i : int;
            var j : int;
            var iIndex : int;

            for each( var box3D : CAABBox3 in m_setDynamic3DBoxes )
            {
                // get min X
                iGridXMin = ( box3D.min.x - m_theRange.min.x ) / m_fGridUnitSize;
                if( iGridXMin < 0 ) iGridXMin = 0;
                else if( iGridXMin >= m_iNumGridsX ) iGridXMin = m_iNumGridsX - 1;

                // get min Y
                f2DPosY = box3D.min.z * CBaseObject.TAN_THETA_OF_CAMERA; // to convert 3D position to 2D screen space cuz terrain data is 2D space
                iGridY = ( f2DPosY - m_theRange.min.y ) / m_fGridUnitSize;
                if( iGridY < 0 ) iGridY = 0;
                else if( iGridY >= m_iNumGridsY ) iGridY = m_iNumGridsY - 1;
                f3DPosY = m_vHeightGrids[ iGridY * m_iNumGridsX + iGridXMin ];
                f2DPosY -= f3DPosY; // convert 3D position to 2D screen space cuz terrain data is 2D space
                iGridYMin = ( f2DPosY - m_theRange.min.y ) / m_fGridUnitSize;
                if( iGridYMin < 0 ) iGridYMin = 0;
                else if( iGridYMin >= m_iNumGridsY ) iGridYMin = m_iNumGridsY - 1;

                // get max X
                iGridXMax = ( box3D.max.x - m_theRange.min.x ) / m_fGridUnitSize;
                if( iGridXMax < 0 ) iGridXMax = 0;
                else if( iGridXMax >= m_iNumGridsX ) iGridXMax = m_iNumGridsX - 1;

                // get max Y
                f2DPosY = box3D.max.z * CBaseObject.TAN_THETA_OF_CAMERA; // to convert 3D position to 2D screen space cuz terrain data is 2D space
                iGridY = ( f2DPosY - m_theRange.min.y ) / m_fGridUnitSize;
                if( iGridY < 0 ) iGridY = 0;
                else if( iGridY >= m_iNumGridsY ) iGridY = m_iNumGridsY - 1;
                f3DPosY = m_vHeightGrids[ iGridY * m_iNumGridsX + iGridXMin ];
                f2DPosY -= f3DPosY; // convert 3D position to 2D screen space cuz terrain data is 2D space
                iGridYMax = ( f2DPosY - m_theRange.min.y ) / m_fGridUnitSize;
                if( iGridYMax < 0 ) iGridYMax = 0;
                else if( iGridYMax >= m_iNumGridsY ) iGridYMax = m_iNumGridsY - 1;

                for( j = iGridYMin; j <= iGridYMax; j++ )
                {
                    for( i = iGridXMin; i <= iGridXMax; i++ )
                    {
                        iIndex = j * m_iNumGridsX + i;
                        if( m_aBlockGrids[ iIndex ] == 0 ) m_aBlockGrids[ iIndex ] = 1;
                    }
                }
            }
        }

        //
		//
        protected var m_theRange : CAABBox2 = null;

        protected var m_fGridUnitSize : Number = 0.0;
        protected var m_iNumGridsX : int = 0;
        protected var m_iNumGridsY : int = 0;
		protected var m_aBlockGrids : ByteArray = null;
        protected var m_vHeightGrids : Vector.<Number> = null;
        protected var m_mapLightData : CMap = null;
        protected var m_setDynamic2DBoxes : CSet = null;
        protected var m_setDynamic3DBoxes : CSet = null;
    }
}
