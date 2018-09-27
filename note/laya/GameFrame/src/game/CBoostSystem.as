package game
{
	import core.game.ecsLoop.CECSLoop;
	import core.game.ecsLoop.IGameSystemHandler;
	import core.framework.ILifeCycle;
	import core.framework.CLifeCycle;

	/**
	 * ...
	 * @author
	 */
	public class CBoostSystem extends CECSLoop {
		public function CBoostSystem(){
			
		}

		override protected function onAwake() : void {
            super.onAwake();

            var handlers:Array = [
				// new CMovementHandler(), 
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
			];

			for each (var handler:IGameSystemHandler in handlers) {
				var bean:CLifeCycle = handler as CLifeCycle;
				if (bean) {
					addBean(handler as CLifeCycle);
				}
			}

			var gamePipelineHandler:IGameSystemHandler = handler as IGameSystemHandler;
			if (gamePipelineHandler) {
				addHandler(gamePipelineHandler);
			}

			// addBean(new CPingPongHandler());
			// addBean(new CServerAskHandler());
			// addBean(new CNetDelayHandler());
        }
	}

}