package core.character.builder
{
	import core.character.builder.ICharacterBuilder;
	import core.game.ecsLoop.CGameObject;
	import core.character.property.CPlayerProperty;
	import core.character.animation.CCharacterAnimation;
	import core.character.animation.CCharacterFrameAnimation;

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
			
			addAnimationCommponent(obj, propertyData);

			return ret;
		}

		protected function addAnimationCommponent(obj:CGameObject, propertyData:CPlayerProperty) : void {
			var animation:CCharacterAnimation = new CCharacterAnimation();
			animation.setAnimation(new CCharacterFrameAnimation());
			animation.create(propertyData);
			obj.addComponent(animation);

			animation.displayObject.pos(propertyData.x, propertyData.y);
		}
	}

}