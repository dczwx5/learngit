package core.character.animation
{
	import laya.events.EventDispatcher;
	import core.character.display.CCharacterDisplay;
	import core.character.property.CCharacterProperty;

	/**
	 * ...
	 * @author auto
	 */
	public interface ICharacterAnimation{
		function playAnimation(aniName:String) : void ;
		function get isRunning() : Boolean ;
		function get skin() : String ;
		function create(propertyData:CCharacterProperty) : void ;

		function get displayObject() : CCharacterDisplay;
		function set eventDispatcher(v:EventDispatcher) : void ;
	}

}