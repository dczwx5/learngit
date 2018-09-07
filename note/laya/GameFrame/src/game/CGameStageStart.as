package game
{
	import laya.events.Event;
	import game.CGameStage;
	import core.framework.CAppStage;
	// import usage.CFsmUsage;
	// import usage.CProcedureUsage;

	/**
	 * ...
	 * @author
	 */
	public class CGameStageStart {

		public function CGameStageStart(){
			m_duringTime = 0;

			CAppStage.DEBUG = true;
			m_gameStage = CGameStage.getInstance();
			m_gameStage.awake();
			m_gameStage.start();


			// fsmUsage = new CFsmUsage();
			// fsmUsage.start();

			// procedureUsage = new CProcedureUsage();

			Laya.timer.frameLoop(1, this, _onEnterFrame);
			
		}

		private function _onEnterFrame() : void {
			var deltaTime:Number = Laya.timer.delta*0.001;
			m_gameStage.update(deltaTime);

			m_duringTime += deltaTime;
			while(m_duringTime >= FIX_TIME) {
				m_duringTime -= FIX_TIME;
				m_gameStage.fixUpdate(FIX_TIME);
			}

			// fsmUsage.update(deltaTime);
			// procedureUsage.update(deltaTime);
		}

		private var m_gameStage:CGameStage;
		private var m_duringTime:Number;
		private const FIX_TIME:Number = 1/60;

		// private var fsmUsage:CFsmUsage;
		// private var procedureUsage:CProcedureUsage;
	}

}