package a_core.character.animation
{
import a_core.character.animation.ICharacterAnimation;
import a_core.game.ecsLoop.CGameComponent;
import a_core.character.property.CCharacterProperty;
import a_core.character.display.CCharacterDisplay;
import a_core.character.display.IDisplay;

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

		owner.transform.x = propertyData.x;
		owner.transform.y = propertyData.y;
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