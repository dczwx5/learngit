/**
 * Created by xandy on 2015/9/6.
 */
package QFLib.Graphics.RenderCore.render.compositor
{
	import QFLib.Graphics.RenderCore.render.IMaterial;
	import QFLib.Graphics.RenderCore.render.material.MFake;

	import QFLib.Graphics.RenderCore.starling.textures.Texture;

	public class CompositorFake extends CompositorBase
	{
		public static const Name:String = "Fake";
		protected var mMaterial:MFake = new MFake();

		public function CompositorFake()
		{
			super();
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
	}
}
