package a_core.character.builder
{
	import a_core.character.builder.ICharacterBuilder;
	import a_core.game.ecsLoop.CGameObject;
	import a_core.character.property.CPlayerProperty;
	import a_core.character.animation.CCharacterAnimation;
	import a_core.character.animation.CCharacterFrameAnimation;
	import a_core.character.state.CCharacterStateMachine;
	import a_core.character.move.CMovementComponent;
	import a_core.game.ecsLoop.CTransform;
	import a_core.game.ecsLoop.ITransform;

	/**
	 * ...
	 * @author
	 */
	public class CPlayerBuilder implements ICharacterBuilder {
		public function CPlayerBuilder(){
			
		}

		public function build(obj:CGameObject, data:Object) : Boolean {
			var ret:Boolean = true;
			var propertyData:CPlayerProperty = new CPlayerProperty();
			propertyData.updateData(data);
			obj.addComponent(propertyData);

			var transform:ITransform = new CTransform();
			obj.addComponent(transform);
			
			addAnimationCommponent(obj, propertyData);
			addFsmStateComponent(obj);

			obj.addComponent(new CMovementComponent());

			return ret;
		}

		protected function addAnimationCommponent(obj:CGameObject, propertyData:CPlayerProperty) : void {
			var animation:CCharacterAnimation = new CCharacterAnimation();
			animation.setAnimation(new CCharacterFrameAnimation());
			obj.addComponent(animation);
		}

		protected function addFsmStateComponent(obj:CGameObject) : void {
			obj.addComponent(new CCharacterStateMachine());
		}
	}

}