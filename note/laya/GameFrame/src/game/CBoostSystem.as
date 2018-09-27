package game
{
	import core.game.ecsLoop.CECSLoop;
	import core.game.ecsLoop.IGameSystemHandler;
	import core.framework.ILifeCycle;
	import core.framework.CLifeCycle;
	import core.framework.CAppSystem;

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
					pEcsLoop.addBean(bean);
					bean.awake();
				}
			}

			var gamePipelineHandler:IGameSystemHandler = handler as IGameSystemHandler;
			if (gamePipelineHandler) {
				pEcsLoop.addHandler(gamePipelineHandler);
			}

			// addBean(new CPingPongHandler());
			// addBean(new CServerAskHandler());
			// addBean(new CNetDelayHandler());
        }
	}

}