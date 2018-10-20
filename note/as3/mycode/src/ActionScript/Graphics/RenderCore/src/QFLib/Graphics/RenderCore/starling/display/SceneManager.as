package QFLib.Graphics.RenderCore.starling.display
{
	import QFLib.Graphics.RenderCore.render.ICamera;

	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import QFLib.Graphics.RenderCore.render.BoundCuller;
	
	import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
	import QFLib.Graphics.RenderCore.starling.core.Starling;

	public class SceneManager
	{
		private static var _viewPortBounds:Rectangle = new Rectangle();
		private static var sRenderSize:Point = new Point();
		private static var sRenderTime:Number = 0;
		
		private var _frameCount:int = 0;
		private var _totalTime:Number = 0;

		private var _culler:BoundCuller = new BoundCuller();
		private var _renderQueueGroup:RenderQueueGroup = new RenderQueueGroup();
		
		public function SceneManager()
		{
		}
		
		public static function set depthSortFunction(value:Function):void
		{
			RenderQueueGroup.depthSortFunction = value;
		}

		public static function getRenderSize():Point
		{
			var starling:Starling = Starling.current;
			var width:Number = starling.stage.stageWidth / starling.currentScale;
			var height:Number = starling.stage.stageHeight / starling.currentScale;

			sRenderSize.setTo(width, height);
			return sRenderSize;
		}

		public function updateScene(dt:Number, sceneNodeRoot:ISceneNode):void
		{
			sceneNodeRoot.updateUnify(dt);
		}
		
		public function renderScene(camera:ICamera, sceneNodeRoot:ISceneNode, support:RenderSupport):void
		{
			expandSceneNode(camera, sceneNodeRoot);

			sortSceneNodeList();

			renderSceneNodeList(support);

			clearSceneNodeList();
		}

		private function expandSceneNode(camera:ICamera, sceneNodeRoot:ISceneNode):void
		{
			_viewPortBounds.x = camera.viewportX;
			_viewPortBounds.y = camera.viewportY;
			_viewPortBounds.width = camera.viewportWidth;
			_viewPortBounds.height = camera.viewportHeight;

			_culler.outBound = _viewPortBounds;
			_culler.camera = camera;
			sceneNodeRoot.addToRenderQueue(_culler, _renderQueueGroup);
		}

		private function sortSceneNodeList():void
		{
			_renderQueueGroup.sort();
		}

		private function renderSceneNodeList(support:RenderSupport):void
		{
			// time statistics
			var preTime:Number = getTimer();
			
			//render
			_renderQueueGroup.render(support);

			// time statistics
			var deltaTime:Number = getTimer() - preTime;
			_totalTime += deltaTime;
			_frameCount++;
			if (_totalTime > 1000.0)
			{
				sRenderTime = _totalTime / _frameCount;
				_frameCount = 0;
				_totalTime = 0;
			}
		}

		private function clearSceneNodeList():void
		{
			_renderQueueGroup.clear();
		}

		public function dispose():void
		{
			_renderQueueGroup.dispose();
		}

		public static function get renderTime():Number
		{
			return sRenderTime;
		}
	}
}