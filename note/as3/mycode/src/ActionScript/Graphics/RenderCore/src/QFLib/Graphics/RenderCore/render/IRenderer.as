package QFLib.Graphics.RenderCore.render
{
	public interface IRenderer
	{
		function getCameraList():Vector.<ICamera>;

		function addCamera(camera:ICamera):void;
		function removeCamera(camera:ICamera):void;

		function setCurrentCamera(camera:ICamera):void;
		function getCurrentCamera():ICamera;

		function render(robj:RenderCommand):void;

		function clearDrawCount():void;
		
		function get drawCount():int;
		
		//以下接口作为暂时接入系统的辅助函数
		function clearCachedProgram():void;
		
		function clearCachedBlendMode():void;
		
		function dispose():void;
	}
}