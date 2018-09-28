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

	protected override function onEnter() : void {
		super.onEnter();
		var propertyData:CCharacterProperty = owner.getComponentByClass(CCharacterProperty) as CCharacterProperty;
		m_animation.create(propertyData);
	}

	public function get isRunning() : Boolean {
		return m_animation.isRunning;
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
 
	override protected function onExit() : void {
		super.onExit();
	}

	private var m_animation:ICharacterAnimation;
}

}