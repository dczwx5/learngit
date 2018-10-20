package QFLib.Graphics.RenderCore.starling.textures
{
	import flash.geom.Rectangle;

	
	public class TextureInfo
	{
		public var region:Rectangle;
		public var frame:Rectangle;
		public var rotated:Boolean;
		public function TextureInfo(region:Rectangle, frame:Rectangle, rotated:Boolean)
		{
			this.region = region;
			this.frame = frame;
			this.rotated = rotated;
		}
	}
}