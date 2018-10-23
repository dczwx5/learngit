package a_core.scene
{
	import a_core.game.ecsLoop.CGameObject;

	/**
	 * ...
	 * @author
	 */
	public interface ISceneFacade {
		function get sceneWidth() : Number ;
		function get sceneHeight() : Number;
		function isBlock(x:Number, y:Number) : Boolean ;

		function isInArea(x:Number, y:Number, obj:CGameObject = null) : Boolean ;

	}

}