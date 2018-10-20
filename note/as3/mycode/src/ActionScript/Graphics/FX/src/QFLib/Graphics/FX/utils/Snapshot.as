/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/12/8.
 */
package QFLib.Graphics.FX.utils
{

    import QFLib.Graphics.RenderCore.render.ICamera;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObjectContainer;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.RenderCore.starling.utils.GetNextPowerOfTwo;
    import QFLib.Graphics.RenderCore.starling.utils.RenderTexturePool;
    import QFLib.Interface.IDisposable;
    import QFLib.Math.CVector2;

    import flash.geom.Matrix;
    import flash.geom.Rectangle;

    public final class Snapshot implements IDisposable
    {
        private var RTPoolInstance : RenderTexturePool = null;
        private var m_CurrentRT : Texture;
        private var m_CurrentRect : Rectangle = new Rectangle();
        private var m_CurrentScale : CVector2 = CVector2.one ();

        public function Snapshot()
        {
            RTPoolInstance = RenderTexturePool.instance();
        }

        public function dispose() : void
        {
            if ( m_CurrentRT != null )
            {
                RTPoolInstance.recycleTexture( m_CurrentRT );
            }
            m_CurrentRect = null;
        }

        public function snapshotDisplayObject( theTarget : DisplayObject ) : Boolean
        {
            var pStarling : Starling = Starling.current;
            if ( pStarling == null || !pStarling.contextValid || pStarling.defaultCamera == null )
                return false;

            var pSupport : RenderSupport = Starling.current.support;
            var theLocalBounds : Rectangle = theTarget.getLocalBound();
            var theTexture : Texture = RTPoolInstance.empty( GetNextPowerOfTwo( theLocalBounds.width ), GetNextPowerOfTwo( theLocalBounds.height ), true, false, true );
            if ( theTexture == null ) return false;

            //save current camera
            var oldCamera : ICamera = pStarling.renderer.getCurrentCamera();
            var defaultCamera : ICamera = pStarling.defaultCamera;
            defaultCamera.enabled = true;
            defaultCamera.setOrthoSize( theTexture.width, theTexture.height );
            defaultCamera.setPosition( 0.0, 0.0 );
            pStarling.renderer.setCurrentCamera( defaultCamera );

            var worldScaleX : Number = theTarget.worldScaleX;
            var worldScaleY : Number = theTarget.worldScaleY;
            var worldMatrix : Matrix = theTarget.worldTransform;
            m_CurrentScale.x = Math.abs( worldScaleX );
            m_CurrentScale.y = Math.abs( worldScaleY );
            worldMatrix.scale( 1.0 / worldScaleX, 1.0 / m_CurrentScale.y );

            var worldX : Number = worldMatrix.tx;
            var worldY : Number = worldMatrix.ty;

            //worldMatrix.tx = -( theTexture.width * 0.5 - theLocalBounds.width ) + ( worldScaleX < 0 ? theLocalBounds.left : -theLocalBounds.right );
            worldMatrix.tx = -( theTexture.width * 0.5 - theLocalBounds.width ) + -theLocalBounds.right;
            worldMatrix.ty = -theTexture.height * 0.5 - theLocalBounds.top;

            // draw the target object into the texture
            pSupport.pushRenderTarget( theTexture );
            pSupport.clear( 0x0, 0.0 );
            theTarget.render( pSupport, 1.0 );
            pSupport.finishQuadBatch();
            pSupport.popRenderTarget();

            if ( m_CurrentRT != null )_recycleTexture( m_CurrentRT );
            m_CurrentRT = theTexture;
            m_CurrentRect.copyFrom( theLocalBounds );
//            if ( worldScaleX < 0 )
//            {
//                var left : Number = m_CurrentRect.left;
//                var right : Number = m_CurrentRect.right;
//                m_CurrentRect.left = -right;
//                m_CurrentRect.right = -left;
//            }

            worldMatrix.tx = worldX;
            worldMatrix.ty = worldY;
            worldMatrix.scale( worldScaleX, m_CurrentScale.y );
            defaultCamera.enabled = false;
            pStarling.renderer.setCurrentCamera( oldCamera );

            return true;
        }

        [Inline] final public function get currentRT() : Texture
        {
            var theTex : Texture = m_CurrentRT;
            m_CurrentRT = null;
            return theTex;
        }

        [Inline] final public function get currentRect() : Rectangle
        {
            return m_CurrentRect;
        }

        [Inline] final public function get currentScale() : CVector2
        {
            return m_CurrentScale;
        }

        public function recycleTexture( theTexture : Texture ) : void
        {
            _recycleTexture( theTexture );
        }

        private function _recycleTexture( theTexture : Texture ) : void
        {
            RTPoolInstance.recycleTexture( theTexture );
        }
    }
}
