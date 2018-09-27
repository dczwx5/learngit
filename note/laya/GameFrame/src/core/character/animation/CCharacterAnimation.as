package core.character.animation
{
import core.character.animation.ICharacterAnimation;
import core.game.ecsLoop.CGameComponent;
import core.character.property.CCharacterProperty;
import core.character.display.CCharacterDisplay;
import core.character.display.IDisplay;

/**
	* ...
	* @author
	*/
public class CCharacterAnimation extends CGameComponent implements IDisplay {
	public function CCharacterAnimation(){
		super("animation");
		
	}

	public function create(propertyData:CCharacterProperty) : void {
		m_animation.create(propertyData);
	}

	public function playAnimation(aniName:String) : void {
		m_animation.playAnimation(aniName);
	}

	public function setAnimation(v:ICharacterAnimation) : void {
		m_animation = v;
		m_animation.eventDispatcher = this;
	}

	public function get displayObject() : CCharacterDisplay {
		return m_animation.displayObject;
	}

	private var m_animation:ICharacterAnimation;
}

}