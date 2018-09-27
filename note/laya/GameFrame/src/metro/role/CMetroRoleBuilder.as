package metro.role
{
	import core.character.builder.CPlayerBuilder;
	import core.game.ecsLoop.CGameObject;
	import core.character.property.CPlayerProperty;
	import core.character.animation.CCharacterAnimation;
	import core.character.animation.CCharacterFrameAnimation;

	/**
	 * ...
	 * @author
	 */
	public class CMetroRoleBuilder extends CPlayerBuilder {
		public function CMetroRoleBuilder(){
			
		}

		/**public override function build(obj:CGameObject, data:Object) : Boolean {
			var ret:Boolean = true;
			var propertyData:CPlayerProperty = new CPlayerProperty(); // 可将CPlayerProperty替换为自已的PlayerProperty
			propertyData.updateData(data);
			obj.addComponent(propertyData);
			
			addAnimationCommponent(obj, propertyData);

			return ret;
		}

		protected override function addAnimationCommponent(obj:CGameObject, propertyData:CPlayerProperty) : void {
			var animation:CCharacterAnimation = new CCharacterAnimation();
			animation.setAnimation(new CCharacterFrameAnimation()); // 可将CCharacterFrameAnimation替换成自己的
			animation.create(propertyData);
			obj.addComponent(animation);
		}*/
	}

}