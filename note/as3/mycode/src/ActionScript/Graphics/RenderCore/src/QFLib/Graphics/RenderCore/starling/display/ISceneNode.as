package QFLib.Graphics.RenderCore.starling.display
{
	import QFLib.Graphics.RenderCore.render.ICamera;
	import QFLib.Graphics.RenderCore.render.ICuller;
	import QFLib.Graphics.RenderCore.starling.core.RenderSupport;

	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public interface ISceneNode
	{
		function isDrawSelf():Boolean;
		
		function getChild(index:int):ISceneNode;
		function getBounds(targetSpace:DisplayObject, resultRect:Rectangle=null):Rectangle;
		
		function get blendMode():String;
		function get childCount():int;
		
		function get localTransform():Matrix;
		function get worldTransform():Matrix;

		function set isInRender(inRender:Boolean):void;
		function get isInRender():Boolean;
		
		function set renderQueueID(groupID:int):void;
		function get renderQueueID():int;
		
		function set inheritRenderQueue(inherit:Boolean):void;
		function get inheritRenderQueue():Boolean;
		
		function get isVisbile():Boolean;
		function set preRender(func:Function):void;

		function renderUnify(support:RenderSupport):void;
		function updateUnify(dt:Number):void;
		
		function getWorldBound(result:Rectangle = null):Rectangle;

		function set layer(value:uint):void;
		function get layer():uint;

		function set usingCamera(value : ICamera) : void;
		function get usingCamera():ICamera;

		/**
		 * @param root 根节点
		 * @param viewPortBounds 视窗包围盒
		 * @param groups 渲染队列
		 * @return 是否继续展开子节点
		 */
		function addToRenderQueue(culler:ICuller, groups:RenderQueueGroup):void;
	}
}