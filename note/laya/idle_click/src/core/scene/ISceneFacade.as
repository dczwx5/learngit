package core.scene
{
	import core.game.ecsLoop.CGameObject;

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