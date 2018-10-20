package QFLib.Graphics.RenderCore.render
{
	import QFLib.Graphics.RenderCore.starling.display.ISceneNode;

	public interface ICuller
	{
        function get camera () : ICamera;
        function set camera ( value : ICamera ) : void
        function isVisibleNode(node:ISceneNode):Boolean;
		function checkCullingMask(node:ISceneNode):Boolean;
	}
}