/**
 * Created by xandy on 2015/9/2.
 */
package QFLib.Graphics.RenderCore.render.compositor
{
    import QFLib.Graphics.RenderCore.render.ICompositor;
    import QFLib.Graphics.RenderCore.render.IGeometry;
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.RenderCore.starling.core.Starling;
    import QFLib.Graphics.RenderCore.starling.errors.AbstractMethodError;
    import QFLib.Graphics.RenderCore.starling.events.Event;
    import QFLib.Graphics.RenderCore.starling.textures.Texture;
    import QFLib.Graphics.RenderCore.starling.utils.VertexData;

    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix;

    public class CompositorBase implements ICompositor, IGeometry
	{
        protected static var sWorldMatrix : Matrix = new Matrix ();

		protected var mPreTexture:Texture;

        protected var mGradualChangeTime:Number = 0.0;
        protected var mCurrentTime:Number = 0.0;
        protected var mDelayDisable:Boolean = false;
        protected var mEnable:Boolean = false;

		private var mVertexData:VertexData;
		private var mVertexBuffer:VertexBuffer3D;
		private var mIndexData:Vector.<uint>;
		private var mIndexBuffer:IndexBuffer3D;

		public function CompositorBase()
		{
			mPreTexture = null;

			mVertexData = new VertexData(4);
			mVertexData.setPosition(0, -50, -50);
			mVertexData.setPosition(1, 50, -50);
			mVertexData.setPosition(2, -50, 50);
			mVertexData.setPosition(3, 50, 50);

			mVertexData.setTexCoords(0, 0, 0);
			mVertexData.setTexCoords(1, 1, 0);
			mVertexData.setTexCoords(2, 0, 1);
			mVertexData.setTexCoords(3, 1, 1);

			mIndexData = new <uint>[0, 1, 2, 1, 3, 2];
			mIndexData.fixed = true;

			Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated, false, 0, true);
		}

		private function onContextCreated(event:Object):void
		{
			mVertexBuffer = null;
			mIndexBuffer = null;
		}

		protected function createBuffers():void
		{
			var instance:Starling = Starling.current;
			mVertexBuffer = instance.createVertexBuffer(4, VertexData.ELEMENTS_PER_VERTEX);
			mIndexBuffer = instance.createIndexBuffer(6);
		}

		protected function updateBuffers():void
		{
            var instance:Starling = Starling.current;
			instance.uploadVertexBufferData(mVertexBuffer, mVertexData.rawData, 0, mVertexData.numVertices);
            instance.uploadIndexBufferData(mIndexBuffer, mIndexData, 0, mIndexData.length);
		}

        public function get name():String
		{
			throw new AbstractMethodError("Not implement!");
			//return "";
		}

        public function set preRenderTarget(preTarget:Texture):void
		{
			mPreTexture = preTarget;
		}

		public function get enable():Boolean
		{
			return mEnable;
		}

        public function set enable(value:Boolean):void
		{
            reset ();

            mEnable = value;
            mDelayDisable = mGradualChangeTime > 0 && !mEnable;

            if ( !mEnable && mDelayDisable ) mEnable = true;
        }

        [Inline] public function get geometry():IGeometry
		{
			return this;
		}

        public function get material():IMaterial
		{
			throw new AbstractMethodError("Must supply material in subclass!");
			//return null;
		}

        [Inline] public function get worldMatrix () : Matrix { return sWorldMatrix; }

        public function update ( deltaTime : Number ) : void
        {
            if ( !mEnable ) return;

            if( mEnable && mGradualChangeTime ) mCurrentTime += deltaTime;

            if( mCurrentTime >= mGradualChangeTime )
            {
                mGradualChangeTime = 0.0;
                if ( mDelayDisable ) enable = false;
            }
        }

		public function setVertexBuffers():void
		{
			if (mVertexBuffer == null || mIndexBuffer == null)
			{
				createBuffers();
				updateBuffers();
			}

            var instance:Starling = Starling.current;
            instance.setVertexBuffer(0, mVertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
            instance.setVertexBuffer(2, mVertexBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
		}

		public function draw():int
		{
            var instance : Starling = Starling.current;
			instance.drawTriangles(mIndexBuffer, 0, 2);
            instance.clearVertexBuffer(0);
            instance.clearVertexBuffer(2);
            return 1;
		}

		public function dispose():void
		{
            var instance:Starling = Starling.current;
			instance.stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
            instance.destroyIndexBuffer(mIndexBuffer);
			mIndexBuffer = null;
            instance.destroyVertexBuffer(mVertexBuffer);
			mVertexBuffer = null;
        }

        public function set gradualChangeTime ( value : Number ) : void
        {
            mGradualChangeTime = value;
        }

        protected function reset () : void
        {
            mDelayDisable = false;
            mCurrentTime = 0.0;
        }

        public function get textureWidth() : int
        {
            return 0;
        }

        public function get textureHeight() : int
        {
            return 0;
        }
    }
}
