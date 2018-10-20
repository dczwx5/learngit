package metro.role
{
	import core.character.builder.CPlayerBuilder;
	import core.game.ecsLoop.CGameObject;
	import core.character.property.CPlayerProperty;
	import core.character.animation.CCharacterAnimation;
	import core.character.animation.CCharacterFrameAnimation;
	import core.character.ai.CCharacterAIComponent;

	/**
	 * ...
	 * @author
	 */
	public class CMetroRoleBuilder extends CPlayerBuilder {
		public function CMetroRoleBuilder(){
			
		}

		public override function build(obj:CGameObject, data:Object) : Boolean {
			var ret:Boolean = super.build(obj, data);
			obj.addComponent(new CCharacterAIComponent());
			return ret;
		}

		/** protected override function addAnimationCommponent(obj:CGameObject, propertyData:CPlayerProperty) : void {
			var animation:CCharacterAnimation = new CCharacterAnimation();
			animation.setAnimation(new CCharacterFrameAnimation()); // 可将CCharacterFrameAnimation替换成自己的
			animation.create(propertyData);
			obj.addComponent(animation);
		}*/
	}

}