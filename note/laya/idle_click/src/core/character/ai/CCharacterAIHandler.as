package core.character.ai
{
	import core.game.ecsLoop.CGameSystemHandler;
	import core.character.ai.CCharacterAIComponent;
	import core.game.ecsLoop.CGameObject;

	/**
	 * ...
	 * @author
	 */
	public class CCharacterAIHandler extends CGameSystemHandler {
		public function CCharacterAIHandler(){
			super(CCharacterAIComponent);
		}

		public override function tickUpdate(delta:Number, obj:CGameObject) : void {
			super.tickUpdate(delta, obj);

			var aiCom:CCharacterAIComponent = obj.getComponentByClass(CCharacterAIComponent) as CCharacterAIComponent;
			// 木有行为树
			aiCom.think();
        }
	}

}