
package QFLib.Graphics.RenderCore.render.compositor
{
	import QFLib.Graphics.RenderCore.render.IMaterial;
	import QFLib.Graphics.RenderCore.render.material.MColorGrading;
	
	import QFLib.Graphics.RenderCore.starling.textures.Texture;

	public class CompositorColorGrading extends CompositorBase
	{
		public static const Name:String = "ColorGrading";
		protected var mMaterial:MColorGrading = new MColorGrading();
		
		public function CompositorColorGrading()
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
		
		public function set colorGrading(value:Texture):void
		{
			mMaterial.colorGrading = value;
		}
	}
}
