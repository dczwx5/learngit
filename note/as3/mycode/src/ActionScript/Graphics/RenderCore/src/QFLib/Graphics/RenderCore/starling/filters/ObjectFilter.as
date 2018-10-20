//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package QFLib.Graphics.RenderCore.starling.filters
{

    import QFLib.Foundation;
    import QFLib.Graphics.RenderCore.render.ICamera;
    import QFLib.Graphics.RenderCore.render.IGeometry;
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.IRenderer;
    import QFLib.Graphics.RenderCore.render.RenderCommand;
    import QFLib.Graphics.RenderCore.render.material.MSprite;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.core.StaticBuffers;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.starling.events.Event;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.RenderCore.starling.utils.Color;
    import QFLib.Graphics.RenderCore.starling.utils.GetNextPowerOfTwo;
    import QFLib.Graphics.RenderCore.starling.utils.RenderTexturePool;
    import QFLib.Graphics.RenderCore.starling.utils.VertexData;
    import QFLib.Interface.IDisposable;

    import flash.display3D.Context3DBufferUsage;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;

    public class ObjectFilter implements IDisposable, IGeometry
    {
        /*** filter mode: ***/
        public static const BELOW : int = 1;
        public static const ABOVE : int = 2;
        public static const NORMAL : int = 3;

        public static const SolidOutline : String = "SolidOutline";
        public static const RimLightOutline : String = "RimLightOutline";
        public static const GaussianBlur : String = "GaussianBlur";
        public static const Alpha : String = "Alpha";
        public static const Distortion : String = "Distortion";
        public static const ColorMatrix : String = "ColorMatrix";
        public static const RimLight : String = "RimLight";
        public static const Smooth : String = "Smooth";

        private static var sWorldMatrixHelper : Matrix = new Matrix ();

        public function ObjectFilter ( owner : DisplayObject )
        {
            m_vecFilterEffects = new Vector.<FilterEffect> ();
            m_pOwner = owner;

            m_Vertices = new VertexData ( 4, true );
            m_Vertices.setPosition ( 0, -50, -50 );
            m_Vertices.setPosition ( 1, 50, -50 );
            m_Vertices.setPosition ( 2, -50, 50 );
            m_Vertices.setPosition ( 3, 50, 50 );

            m_Vertices.setTexCoords ( 0, 0, 0 );
            m_Vertices.setTexCoords ( 1, 1, 0 );
            m_Vertices.setTexCoords ( 2, 0, 1 );
            m_Vertices.setTexCoords ( 3, 1, 1 );

            m_Vertices.setUniformColor ( Color.WHITE );
            m_Vertices.setUniformAlpha ( 1.0 );

            m_Material = new MSprite ();
            m_WorldMatrix = new Matrix ();
            Starling.current.stage3D.addEventListener ( Event.CONTEXT3D_CREATE,
                    onContextCreated, false, 0, true );
        }

        public function dispose () : void
        {
            Starling.current.stage3D.removeEventListener ( Event.CONTEXT3D_CREATE, onContextCreated );
            destroyBuffers ();
            m_pOwner = null;
            m_OwnerBound = null;
            m_WorldMatrix = null;
            if ( m_InTexture != null )
                RenderTexturePool.instance().recycleTexture(m_InTexture);
            if ( m_OutTexture != null )
                RenderTexturePool.instance().recycleTexture(m_OutTexture);
            clear ();

            if ( m_Material != null )
            {
                m_Material.dispose ();
                m_Material = null;
            }

            if ( m_Vertices != null )
            {
                m_Vertices.dispose ();
                m_Vertices = null;
            }
        }

        [Inline] public function set owner ( value : DisplayObject ) : void
        {
            if ( m_pOwner != value )
            {
                m_pOwner = value;
                m_TextureSizeDirty = true;
            }
        }

        [Inline] public function setFilterMode ( mode : int = 2 /*ABOVE*/ ) : void { m_FilterMode = mode; }

        [Inline] public function set width ( value : Number ) : void
        {
            if ( m_Width != value )
            {
                m_Width = value;

                var xVal : Number = m_Width * 0.5;
                var yVal : Number = m_Height * 0.5;
                m_Vertices.setPosition ( 0, -xVal, -yVal);
                m_Vertices.setPosition ( 1, xVal, -yVal );
                m_Vertices.setPosition ( 2, -xVal, yVal );
                m_Vertices.setPosition ( 3, xVal, yVal );
                m_VerticesDirty = true;
            }
        }

        [Inline] public function set height ( value : Number ) : void
        {
            if ( m_Height != value )
            {
                m_Height = value;

                var xVal : Number = m_Width * 0.5;
                var yVal : Number = m_Height * 0.5;
                m_Vertices.setPosition ( 0, -xVal, -yVal);
                m_Vertices.setPosition ( 1, xVal, -yVal );
                m_Vertices.setPosition ( 2, -xVal, yVal );
                m_Vertices.setPosition ( 3, xVal, yVal );
                m_VerticesDirty = true;
            }
        }

        [Inline] public function get onwerBound () : Rectangle { return m_OwnerBound; }
        [Inline] public function get material () : IMaterial { return m_Material; }
        [Inline] public function get effectCount () : int { return m_vecFilterEffects.length; }

        public function setAllEffectEnable ( value : Boolean ) : void
        {
            for each ( var filterEffect : FilterEffect in m_vecFilterEffects )
            {
                filterEffect.enable = value;
            }
        }

        public function get enable () : Boolean
        {
            var len : int = m_vecFilterEffects.length;
            if ( len <= 0 ) return false;

            var filterEffect : FilterEffect = null;
            for ( var i : int = 0; i < len; i++ )
            {
                filterEffect = m_vecFilterEffects[ i ];
                if ( filterEffect.enable )
                    return true;
            }

            return false;
        }

        public function addEffect ( className : Class, enable : Boolean = true, params : Array = null ) : FilterEffect
        {
            var filterEffect : FilterEffect = null;
            if ( params == null )
                filterEffect = new className ( this );
            else
                filterEffect = new className ( this, params );
            if ( filterEffect == null )
            {
                Foundation.Log.logErrorMsg ( "The FitlerEffect ClassName is invalid:" + className );
                return null;
            }
            var length : int = m_vecFilterEffects.length;
            m_vecFilterEffects.fixed = false;
            m_vecFilterEffects.length += 1;
            m_vecFilterEffects[ length ] = filterEffect;
            m_vecFilterEffects.fixed = true;
            filterEffect.enable = enable;
            return filterEffect;
        }

        public function render ( support : RenderSupport, alpha : Number ) : void
        {
            var pInstance : Starling = Starling.current;
            if ( pInstance == null || !pInstance.contextValid || m_pOwner == null  ) return;

            calcFilterBounds ();
            calcTextureSize ();

            if ( m_InTexture == null || m_OutTexture == null ) return;

            var pCurRenderer : IRenderer = pInstance.renderer;
            var pCamera : ICamera = Starling.current.renderer.getCurrentCamera ();
            var pFilterCamera : ICamera = Starling.current.filterCamera;
            pFilterCamera.setOrthoSize ( m_TextureWidth, m_TextureHeight );
            pFilterCamera.setPosition ( 0.0, 0.0 );
            pCurRenderer.setCurrentCamera ( pFilterCamera );

            var worldScaleX : Number = m_pOwner.worldScaleX;
            var worldMatrix : Matrix = m_pOwner.worldTransform;
            sWorldMatrixHelper.copyFrom ( worldMatrix );
            var wx : Number = worldMatrix.tx;
            var wy : Number = worldMatrix.ty;
            var offsetX : Number = -( m_OwnerBound.left + m_OwnerBound.right ) * 0.5;
            var offsetY : Number = m_OwnerBound.height * 0.5 - m_OwnerBound.bottom;
            worldMatrix.identity ();
            worldMatrix.tx = offsetX;
            worldMatrix.ty = offsetY;
            support.pushRenderTarget ( m_OutTexture );
            support.clear ( 0x00, 0.0 );
            m_pOwner.render ( support, alpha );
            support.popRenderTarget ();
            swapRenderTexture ();
            worldMatrix.copyFrom ( sWorldMatrixHelper );

            var len : int = m_vecFilterEffects.length;
            if ( len <= 0 ) return;
            var pCurFilterEffect : FilterEffect = null;
            for ( var i : int = 0; i < len; i++ )
            {
                pCurFilterEffect = m_vecFilterEffects[ i ];
                if ( !pCurFilterEffect.enable ) continue;

                pCurFilterEffect.preRender ( support, pFilterCamera, m_OutTexture );
                pCurFilterEffect.render ( m_pOwner, support, 1.0, m_InTexture );
                pCurFilterEffect.postRender ( support, pCamera );
                swapRenderTexture ();
            }

            var worldScaleY : Number = m_pOwner.worldScaleY;
            pCurRenderer.setCurrentCamera ( pCamera );
            this.width = m_TextureWidth;
            this.height = m_TextureHeight;
            m_WorldMatrix.copyFrom ( sWorldMatrixHelper );
            m_WorldMatrix.tx = wx - offsetX * worldScaleX;
            m_WorldMatrix.ty = wy - offsetY * worldScaleY;
            syncBuffers ();
            m_Material.mainTexture = m_InTexture;
            m_Material.pma = m_InTexture.premultipliedAlpha;
            m_Material.blendMode = m_pOwner.blendMode;
            var rcmd : RenderCommand = getRenderCommand ();
            pInstance.addToRender ( rcmd );

            if ( m_FilterMode == BELOW )
                m_pOwner.render ( support, 1.0 );
        }

        public function clear () : void
        {
            var filterEffect : FilterEffect = null;
            for ( var i : int = 0, count : int = m_vecFilterEffects.length; i < count; i++ )
            {
                filterEffect = m_vecFilterEffects[ i ];
                filterEffect.dispose ();
            }
            m_vecFilterEffects.fixed = false;
            m_vecFilterEffects.length = 0;
            m_vecFilterEffects.fixed = true;
        }

        public function setVertexBuffers () : void
        {
            var instance : Starling = Starling.current;
            instance.setVertexBuffer ( 0, m_VertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2 );
            instance.setVertexBuffer ( 1, m_VertexBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4 );
            instance.setVertexBuffer ( 2, m_VertexBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2 );
        }

        public function draw () : int
        {
            var instance : Starling = Starling.current;
            instance.drawTriangles ( m_IndexBuffer, 0, 2 );
            instance.clearVertexBuffer ( 0 );
            instance.clearVertexBuffer ( 1 );
            instance.clearVertexBuffer ( 2 );
            return 1;
        }

        private function getRenderCommand () : RenderCommand
        {
            var rcmd : RenderCommand = RenderCommand.assign ( m_WorldMatrix );
            rcmd.geometry = this;
            rcmd.material = m_Material;

            return rcmd;
        }

        private function syncBuffers () : void
        {
            var instance : Starling = Starling.current;
            if ( m_VertexBuffer == null )
            {
                m_VertexBuffer = instance.createVertexBuffer( 4, VertexData.ELEMENTS_PER_VERTEX, Context3DBufferUsage.DYNAMIC_DRAW );
            }
            if ( m_IndexBuffer == null )
            {
                m_IndexBuffer = StaticBuffers.getInstance().imgStaticIndexBuffer;
            }

            if ( m_VerticesDirty )
            {
                instance.uploadVertexBufferData( m_VertexBuffer, m_Vertices.rawData, 0, 4 );
                m_VerticesDirty = false;
            }
        }

        private function onContextCreated ( event : Object ) : void
        {
            destroyBuffers ();
        }

        private function destroyBuffers () : void
        {
            var instance : Starling = Starling.current;
            instance.destroyVertexBuffer ( m_VertexBuffer );
            m_VertexBuffer = null;
            m_IndexBuffer = null;
            m_VerticesDirty = true;
        }

        private function swapRenderTexture () : void
        {
            var tempRenderTexture : Texture = m_InTexture;
            m_InTexture = m_OutTexture;
            m_OutTexture = tempRenderTexture;
        }

        private function calcFilterBounds () : void
        {
            if ( m_pOwner != null )
            {
                if ( m_OwnerBound == null )
                    m_OwnerBound = new Rectangle ();
                m_pOwner.getBounds ( m_pOwner, m_OwnerBound );

                var width : Number = GetNextPowerOfTwo ( m_OwnerBound.width );
                var height : Number = GetNextPowerOfTwo ( m_OwnerBound.height );
                if ( width != m_TextureWidth || height != m_TextureHeight )
                {
                    m_TextureWidth = width;
                    m_TextureHeight = height;
                    m_TextureSizeDirty = true;
                }
            }
        }

        private function calcTextureSize () : void
        {
            if ( m_TextureSizeDirty )
            {
                if ( m_InTexture )
                    RenderTexturePool.instance ().recycleTexture ( m_InTexture );
                if ( m_OutTexture )
                    RenderTexturePool.instance ().recycleTexture ( m_OutTexture );

                m_InTexture = RenderTexturePool.instance ().empty ( m_TextureWidth, m_TextureHeight, true, false, true, 1, "bgra", false );
                m_OutTexture = RenderTexturePool.instance ().empty ( m_TextureWidth, m_TextureHeight, true, false, true, 1, "bgra", false );
                m_TextureSizeDirty = false;
            }
        }

        private var m_VertexBuffer : VertexBuffer3D = null;
        private var m_IndexBuffer : IndexBuffer3D = null;
        private var m_Vertices : VertexData = null;
        private var m_Material : MSprite = null;
        private var m_WorldMatrix : Matrix = null;

        private var m_InTexture : Texture = null;
        private var m_OutTexture : Texture = null;
        private var m_vecFilterEffects : Vector.<FilterEffect> = null;
        private var m_OwnerBound : Rectangle = null;
        private var m_Width : Number = 0.0;
        private var m_Height : Number = 0.0;
        private var m_TextureWidth : Number = -1.0;
        private var m_TextureHeight : Number = -1.0;
        private var m_FilterMode : int = NORMAL;
        private var m_pOwner : DisplayObject = null;
        private var m_TextureSizeDirty : Boolean = true;

        private var m_VerticesDirty : Boolean = true;
    }
}