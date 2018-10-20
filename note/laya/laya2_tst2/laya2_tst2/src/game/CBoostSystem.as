package game
{
	import a_core.game.ecsLoop.CECSLoop;
	import a_core.game.ecsLoop.IGameSystemHandler;
	import a_core.framework.ILifeCycle;
	import a_core.framework.CLifeCycle;
	import a_core.framework.CAppSystem;
	import a_core.character.CPlayHandler;
	import a_core.character.ai.CCharacterAIHandler;
	import a_core.character.move.CMovementHandler;

	/**
	 * ...
	 * @author
	 */
	public class CBoostSystem extends CAppSystem {
		public function CBoostSystem(){
			
		}

		override protected function onAwake() : void {
            super.onAwake();

			var pEcsLoop:CECSLoop = stage.getSystem(CECSLoop) as CECSLoop;
            var handlers:Array = [
				new CMovementHandler(), 
				// new CAnimationHandler(),
				// new CCollisionHandler(),
				// new CPlayHandler(),
				// new CAIHandler(),
				// new CCharacterFSMHandler(),
				// new CEmitterHandler(),
				// new CFightHandler(),
				// new CTickHandler(),
				// new CNPCHandler(),
				// new CMapObjectHandler()
				new CCharacterAIHandler(), 
				new CPlayHandler()
			];

			for each (var handler:IGameSystemHandler in handlers) {
				var bean:CLifeCycle = handler as CLifeCycle;
				if (bean) {
					pEcsLoop.addBean(bean);
					bean.awake();
					
				}

				var gamePipelineHandler:IGameSystemHandler = handler as IGameSystemHandler;
				if (gamePipelineHandler) {
					pEcsLoop.addHandler(gamePipelineHandler);
				}
			}

			

			// addBean(new CPingPongHandler());
			// addBean(new CServerAskHandler());
			// addBean(new CNetDelayHandler());
        }
	}

}