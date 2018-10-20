////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Graphics.RenderCore.starling.utils
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import QFLib.Graphics.RenderCore.starling.core.RenderSupport;
	import QFLib.Graphics.RenderCore.starling.core.Starling;
	import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
	import QFLib.Graphics.RenderCore.starling.textures.Texture;
	
	/**
	 * [descriptions]
	 * @author Jave.Lin
	 * @date 2015-7-20
	 **/
	public class SnapShotToTextureUtil
	{
		private static var support:RenderSupport;
		private static const pointHelper:Point = new Point();
		
		/**
		 * snapshot for some starling displayObject
		 */
		public static function snapshoot(target:DisplayObject, result:Texture = null, bounds:Rectangle = null, posBound:Rectangle = null, onError:Function = null):Texture
		{
			if (!support)
			{
				support = new RenderSupport();
			}
			
			bounds = target.getBounds(target, bounds);
			
			var useBound:Rectangle = posBound ? posBound : bounds;
				
			if (!result)
			{
				result = Texture.empty(Starling.current.stage.stageWidth, Starling.current.stage.stageHeight, false, false, true, -1, "bgra");
			}
			
			support.nextFrame();
			support.finishQuadBatch();
			support.pushRenderTarget(result);
			support.pushMatrix();
			support.loadIdentity();
			support.setOrthographicProjection(0, 0, Starling.current.stage.stageWidth, Starling.current.stage.stageHeight);
			
			if(Starling.current != null && Starling.current.defaultCamera!= null)
				Starling.current.defaultCamera.matrixProj = support.matrixProject;
						
			support.clear(0x0, 0);
			
			
			//support.scaleMatrix(0.5, 0.5);
			support.translateMatrix(useBound.width, useBound.height);
			target.render(support, 1.0);
			support.finishQuadBatch();

			support.popRenderTarget();
			support.popMatrix();
			
			if(Starling.current != null && Starling.current.defaultCamera!= null)
				Starling.current.defaultCamera.matrixProj = support.matrixProject;
			
			return result;
		}
	}
}