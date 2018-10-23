package game.procedure
{
	import a_core.procedure.CProcedureBase;
	import a_core.fsm.CFsm;
	import game.procedure.CProcedureLaunch;
	import a_core.procedure.CProcedureManager;
	import game.procedure.CProcedureSystem;
	import a_core.framework.CAppStage;
	import game.CPathUtils;
	import laya.utils.Handler;

	/**
	 * ...
	 * @author
	 */
	public class CProcedureLoadResource extends CProcedureBase {
		public function CProcedureLoadResource(){
			
		}

		protected override function onInit(fsm:CFsm) : void {
			super.onInit(fsm);

			
		}
		protected override function onEnter(fsm:CFsm) : void {
			super.onEnter(fsm);
			m_bFinish = false;
			
			// 加载资源
			var resList:Array = ['comp', 'gameUI', 'number'];
			for (var i:int = 0; i < resList.length; i++) {
				resList[i] = CPathUtils.getUIPath(resList[i]);
			}
			Laya.loader.load(resList, Handler.create(this, _onLoadResourceFinish));
		}

		private function _onLoadResourceFinish() : void {
			m_bFinish = true;
		}
		protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
			super.onUpdate(fsm, deltaTime);
			if (m_bFinish) {
				changeProcedure(fsm, CProcedureLoadDataTable);
			}
		}
		protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
		}
		protected override function onDestroy(fsm:CFsm) : void {
			super.onDestroy(fsm);
		}
		private var m_bFinish:Boolean;
	}

}