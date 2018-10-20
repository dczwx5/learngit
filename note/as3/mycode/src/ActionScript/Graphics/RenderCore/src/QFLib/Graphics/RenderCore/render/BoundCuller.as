package QFLib.Graphics.RenderCore.render
{

    import QFLib.Interface.IDisposable;

    import flash.geom.Rectangle;
	import QFLib.Graphics.RenderCore.starling.display.ISceneNode;
	
	public class BoundCuller implements ICuller, IDisposable
	{
		protected static var sHelperRect:Rectangle = new Rectangle();
		
		private var _outBound:Rectangle;
		private var _camera:ICamera;

		public function BoundCuller()
		{
		}

		public function dispose () : void
		{
            _outBound = null;
            _camera = null;
		}
		
		public function set outBound(value:Rectangle):void
		{
			_outBound = value;
		}
		
		public function get outBound():Rectangle
		{
			return _outBound;
		}

		public function get camera():ICamera
		{
			return _camera;
		}

		public function set camera(value:ICamera):void
		{
			_camera = value;
		}

		public function isVisibleNode(node:ISceneNode):Boolean
		{
			node.getWorldBound(sHelperRect);
			return _outBound.intersects(sHelperRect);
		}

		public function checkCullingMask(node:ISceneNode):Boolean
		{
			if (node.layer == 0)
			{
				return true;
			}

			if ((camera.cullingMask & (1<<(node.layer - 1))) != 0)
			{
				return true;
			}
			return false;
		}
	}
}