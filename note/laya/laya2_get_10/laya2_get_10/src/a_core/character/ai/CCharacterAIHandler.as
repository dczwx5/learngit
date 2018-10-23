package a_core.character.ai
{
	import a_core.game.ecsLoop.CGameSystemHandler;
	import a_core.character.ai.CCharacterAIComponent;
	import a_core.game.ecsLoop.CGameObject;

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