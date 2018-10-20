package metro.role
{
	import a_core.character.builder.CPlayerBuilder;
	import a_core.game.ecsLoop.CGameObject;
	import a_core.character.property.CPlayerProperty;
	import a_core.character.animation.CCharacterAnimation;
	import a_core.character.animation.CCharacterFrameAnimation;
	import a_core.character.ai.CCharacterAIComponent;

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