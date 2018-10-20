//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------
package QFLib.Graphics.RenderCore.starling.filters
{

    import QFLib.Graphics.RenderCore.render.ICamera;
    import QFLib.Graphics.RenderCore.render.IGeometry;
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.render.RenderCommand;
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.core.StaticBuffers;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.starling.events.Event;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.RenderCore.starling.utils.VertexData;
    import QFLib.Interface.IDisposable;

    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix;

    public class FilterEffect implements IDisposable, IGeometry
    {
        public function FilterEffect ( pFilter : ObjectFilter )
        {
            m_pFilter = pFilter;
            m_bEnable = true;

            m_Vertices = new VertexData ( 4, true );
            m_Vertices.setPosition ( 0, -50, -50 );
            m_Vertices.setPosition ( 1, 50, -50 );
            m_Vertices.setPosition ( 2, -50, 50 );
            m_Vertices.setPosition ( 3, 50, 50 );

            m_Vertices.setTexCoords ( 0, 0, 0 );
            m_Vertices.setTexCoords ( 1, 1, 0 );
            m_Vertices.setTexCoords ( 2, 0, 1 );
            m_Vertices.setTexCoords ( 3, 1, 1 );

//            m_Vertices.setUniformColor ( Color.WHITE );
//            m_Vertices.setUniformAlpha ( 1.0 );

            m_WorldMatrix = new Matrix ();

            Starling.current.stage3D.addEventListener ( Event.CONTEXT3D_CREATE,
                    onContextCreated, false, 0, true );
        }

        public function dispose () : void
        {
            Starling.current.stage3D.removeEventListener ( Event.CONTEXT3D_CREATE, onContextCreated );
            m_pInTexture = null;
            m_pOutTexture = null;
            m_pFilter = null;
            m_pOnwer = null;

            destroyMaterial ();
            destroyBuffers ();
            if ( m_Vertices != null )
            {
                m_Vertices.dispose ();
                m_Vertices = null;
            }

            m_WorldMatrix = null;
        }

        [Inline] public function get name () : String { return ""; }

        [Inline] public function set enable ( value : Boolean ) : void { m_bEnable = value;}
        [Inline] public function get enable () : Boolean { return m_bEnable; }

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

        public function preRender ( support : RenderSupport, pCamera : ICamera, pOutTexture : Texture ) : void
        {
            if ( pOutTexture == null ) return;
            m_pOutTexture = pOutTexture;

            var pInstance : Starling = Starling.current;
            pInstance.renderer.setCurrentCamera ( pCamera );
            support.pushRenderTarget ( pOutTexture );
            support.clear ( 0x00, 0.0 );
        }

        public function render ( pOnwer : DisplayObject, support : RenderSupport, alpha : Number, pInTexture : Texture ) : Boolean
        {
            if ( pOnwer == null || pInTexture == null ) return false;
            if ( m_pInTexture != pInTexture )
                m_pInTexture = pInTexture;
            if ( m_pOnwer != pOnwer )
                m_pOnwer = pOnwer;

            this.width = m_pOutTexture.width;
            this.height = m_pOutTexture.height;
            syncBuffers ();

//            m_WorldMatrix.tx = m_Width * 0.5;
//            m_WorldMatrix.ty = m_Height * 0.5;

            return true;
        }

        public function postRender ( support : RenderSupport, pCamera : ICamera ) : void
        {
            var pInstance : Starling = Starling.current;
            support.popRenderTarget ();
            pInstance.renderer.setCurrentCamera ( pCamera );
        }

        public function setVertexBuffers () : void
        {
            var instance : Starling = Starling.current;
            instance.setVertexBuffer ( 0, m_VertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2 );
            //instance.setVertexBuffer ( 1, m_VertexBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4 );
            instance.setVertexBuffer ( 2, m_VertexBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2 );
        }

        public function draw () : int
        {
            var instance : Starling = Starling.current;
            instance.drawTriangles ( m_IndexBuffer, 0, 2 );
            instance.clearVertexBuffer ( 0 );
            //instance.clearVertexBuffer ( 1 );
            instance.clearVertexBuffer ( 2 );
            return 1;
        }

        protected function destroyMaterial () : void {}

        protected function getRenderCommand () : RenderCommand
        {
            var rcmd : RenderCommand = RenderCommand.assign ( m_WorldMatrix );
            rcmd.geometry = this;
            rcmd.material = m_Material;

            return rcmd;
        }

        protected function swapRenderTexture () : void
        {
            var tempRenderTexture : Texture = m_pInTexture;
            m_pInTexture = m_pOutTexture;
            m_pOutTexture = tempRenderTexture;
        }

        private function syncBuffers() : void
        {
            var instance : Starling = Starling.current;
            if ( m_VertexBuffer == null )
            {
                m_VertexBuffer = instance.createVertexBuffer( 4, VertexData.ELEMENTS_PER_VERTEX );
            }
            if ( m_IndexBuffer == null )
            {
                m_IndexBuffer = StaticBuffers.getInstance().imgStaticIndexBuffer;
            }

            if ( m_VerticesDirty )
            {
                instance.uploadVertexBufferData ( m_VertexBuffer, m_Vertices.rawData, 0, 4 );
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

        protected var m_VertexBuffer : VertexBuffer3D = null;
        protected var m_IndexBuffer : IndexBuffer3D = null;
        protected var m_Material : IMaterial = null;
        protected var m_Vertices : VertexData = null;
        protected var m_WorldMatrix : Matrix = null;

        protected var m_pInTexture : Texture = null;
        protected var m_pOutTexture : Texture = null;
        protected var m_pFilter : ObjectFilter = null;
        protected var m_pOnwer : DisplayObject = null;

        protected var m_Width : Number = 0;
        protected var m_Height : Number = 0;
        protected var m_bEnable : Boolean = true;
        protected var m_VerticesDirty : Boolean = true;
    }
}
