/**
 * Created by xandy on 2015/9/11.
 */
package QFLib.Graphics.RenderCore.render.compositor
{
	import QFLib.Graphics.RenderCore.render.IMaterial;
	import QFLib.Graphics.RenderCore.render.material.MColorReplace;

	import QFLib.Graphics.RenderCore.starling.textures.Texture;

	public class CompositorColorReplace extends CompositorBase
	{
		public static const Name:String = "ColorReplace";
		protected var mMaterial:MColorReplace = new MColorReplace();

		public function CompositorColorReplace( matrix : Vector.<Number>, offset : Vector.<Number> )
		{
			super();

            mMaterial.colorMatrix = matrix;
            mMaterial.colorOffsets = offset;
		}

		override public function get name():String
		{
			return Name;
		}

		override public function get material():IMaterial
		{
			return mMaterial;
		}

		override public function set preRenderTarget(preTarget:Texture):void
		{
			super.preRenderTarget = preTarget;
			mMaterial.mainTexture = mPreTexture;
			mMaterial.pma = mPreTexture.premultipliedAlpha;
		}

        public override function get textureWidth() : int
        {
            return 2048;
        }

        public override function get textureHeight() : int
        {
            return 1024;
        }

		[Inline] final public function set colorMatrix(value:Vector.<Number>):void
		{
			mMaterial.colorMatrix = value;
		}

        [Inline] final public function set colorOffsets ( value : Vector.<Number> ) : void
        {
            mMaterial.colorOffsets = value;
        }
	}
}
