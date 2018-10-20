package game
{
	import laya.events.Event;
	import game.CGameStage;
	import a_core.framework.CAppStage;
	import laya.events.EventDispatcher;
	// import usage.CFsmUsage;
	// import usage.CProcedureUsage;

	/**
	 * ...
	 * @author
	 */
	public class CGameStageStart extends EventDispatcher {

		public function CGameStageStart(){
			m_duringTime = 0;

			CAppStage.DEBUG = true;
			m_gameStage = CGameStage.getInstance();
			m_gameStage.awake();
			
			Laya.timer.frameLoop(1, this, _waitStart);
		}
		private function _waitStart() : void {
			var isStarted:Boolean = m_gameStage.start();
			if (isStarted) {
				Laya.timer.clear(this, _waitStart);
				// Laya.timer.frameLoop(1, this, _onEnterFrame);
				m_isReady = true;
				event(Event.COMPLETE);
			}
		}
		public function update() : void {
			var deltaTime:Number = Laya.timer.delta*0.001;
			m_gameStage.update(deltaTime);

			m_duringTime += deltaTime;
			while(m_duringTime >= FIX_TIME) {
				m_duringTime -= FIX_TIME;
				m_gameStage.fixUpdate(FIX_TIME);
			}
		}

		public function get stage() : CGameStage {
			return m_gameStage;
		}

		private var m_gameStage:CGameStage;
		private var m_duringTime:Number;
		private const FIX_TIME:Number = 1/60;

		public function get isReady() : Boolean {
			return m_isReady;
		}
		private var m_isReady:Boolean;
	}

}