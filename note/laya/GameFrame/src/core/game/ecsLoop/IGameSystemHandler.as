package core.game.ecsLoop
{
	import core.game.ecsLoop.CGameObject;

	/**
	 * ...
	 * @author
	 */
	public interface IGameSystemHandler{
		function get enable() : Boolean;
		function set enable(v:Boolean) : void;
		function isComponentSupported(obj:CGameObject) : Boolean;
		function beforeTick(delta:Number) : void;
		function tickValidate(delta:Number, obj:CGameObject) : Boolean;
		function tickUpdate(delta:Number, obj:CGameObject) : void;
		function afterTick(delta:Number) : void;
	}

}