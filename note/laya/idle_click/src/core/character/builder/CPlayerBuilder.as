package core.character.builder
{
	import core.character.builder.ICharacterBuilder;
	import core.game.ecsLoop.CGameObject;
	import core.character.property.CPlayerProperty;
	import core.character.animation.CCharacterAnimation;
	import core.character.animation.CCharacterFrameAnimation;
	import core.character.state.CCharacterStateMachine;
	import core.character.move.CMovementComponent;
	import core.game.ecsLoop.CTransform;
	import core.game.ecsLoop.ITransform;

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