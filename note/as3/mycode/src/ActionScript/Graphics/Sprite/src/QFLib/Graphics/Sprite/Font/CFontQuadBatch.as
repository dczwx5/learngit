//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by tDAN 2016/8/17.
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Graphics.Sprite.Font
{
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.starling.display.QuadBatch;
    import QFLib.Graphics.RenderCore.starling.utils.MatrixUtil;

    import flash.geom.Matrix;

    import flash.geom.Rectangle;

    public class CFontQuadBatch extends QuadBatch
	{
		public function CFontQuadBatch( fWidth : Number, fHeight : Number, bCenterAnchor : Boolean = false )
		{
            super();

            m_rectBound = new Rectangle();
            setBound( fWidth, fHeight, bCenterAnchor );
		}

		public override function dispose() : void
		{
            super.dispose();
        }

        public function setBound( fWidth : Number, fHeight : Number, bCenterAnchor : Boolean = false ) : void
        {
            m_rectBound.setTo( 0.0, 0.0, fWidth, fHeight );
            if( bCenterAnchor ) m_rectBound.offset( -fWidth * 0.5, -fHeight * 0.5 );
        }

        public override function getBounds( targetSpace : DisplayObject, resultRect : Rectangle = null ) : Rectangle
        {
            if( resultRect == null ) resultRect = new Rectangle();
            resultRect.copyFrom( m_rectBound );

            var mx : Matrix = ( targetSpace == this ? null : getTransformationMatrix( targetSpace, sHelperMatrix ) );
            if( mx == null ) return resultRect;
            else
            {
                MatrixUtil.transformRectangle( mx, resultRect );
                return resultRect;
            }
        }

        //
        //
        protected var m_rectBound : Rectangle = null;
	}
}
