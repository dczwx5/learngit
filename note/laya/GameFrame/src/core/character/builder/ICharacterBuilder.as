package core.character.builder
{
	import core.game.ecsLoop.CGameObject;

	/**
	 * ...
	 * @author
	 */
	public interface ICharacterBuilder{
		function build(obj:CGameObject, data:Object) : Boolean ;
	}

}