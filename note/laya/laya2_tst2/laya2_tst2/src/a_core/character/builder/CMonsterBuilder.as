package a_core.character.builder
{
	import a_core.character.builder.ICharacterBuilder;
	import a_core.game.ecsLoop.CGameObject;
	import a_core.character.property.CPlayerProperty;
	import a_core.character.animation.CCharacterAnimation;
	import a_core.character.animation.CCharacterFrameAnimation;
	import a_core.character.state.CCharacterStateMachine;

	/**
	 * ...
	 * @author
	 */
	public class CMonsterBuilder implements ICharacterBuilder {
		public function CMonsterBuilder(){
			
		}

		public function build(obj:CGameObject, data:Object) : Boolean {
			var ret:Boolean = true;
			var propertyData:CPlayerProperty = new CPlayerProperty();
			propertyData.updateData(data);
			obj.addComponent(propertyData);
			
			addAnimationCommponent(obj, propertyData);
			addFsmStateComponent(obj);

			return ret;
		}

		protected function addAnimationCommponent(obj:CGameObject, propertyData:CPlayerProperty) : void {
			var animation:CCharacterAnimation = new CCharacterAnimation();
			animation.setAnimation(new CCharacterFrameAnimation());
			obj.addComponent(animation);

			animation.displayObject.pos(propertyData.x, propertyData.y);
		}

		protected function addFsmStateComponent(obj:CGameObject) : void {
			obj.addComponent(new CCharacterStateMachine());
		}
	}

}