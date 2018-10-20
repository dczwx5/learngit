package a_core.character.builder
{
	import a_core.game.ecsLoop.CGameObject;

	/**
	 * ...
	 * @author
	 */
	public interface ICharacterBuilder{
		function build(obj:CGameObject, data:Object) : Boolean ;
	}

}