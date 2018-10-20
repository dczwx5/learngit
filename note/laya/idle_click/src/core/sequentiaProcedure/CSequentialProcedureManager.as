package core.sequentiaProcedure
{
	import laya.utils.Handler;
	import laya.utils.Timer;
	import avmplus.finish;

	/**
	 * ...
	 * @author auto
	 串行流程
	 */
	public class CSequentialProcedureManager{
		public function CSequentialProcedureManager(){
			reset();
		}

		public function reset() : void {
			m_isRunning = false;
			m_procedureInfoList.length = 0;
			m_currentProcedureInfo = null;
			m_finishCallback = null;
			Laya.timer.clear(this, _onUpdate);
		}

		public function destroy() : void {
			m_isRunning = false;
			m_currentProcedureInfo = null;
			m_procedureInfoList = null;
			Laya.timer.clear(this, _onUpdate);
		}
		// handler == checkFinishHandler == null : 则直接通过 -> 没意义
		// handler == null, checkFinishHandler != null, 则checkFinishHandler返回true, 通过 -> 用于等待某个条件完成
		// handler != null, checkFinishHandler == null, 执行一次handler, 然后通过 -> 用于调用一次handler, 和普通函数调用一置
		// handler != null, checkFinishHandler != null, 执行一次handler, 并等待checkFinishHandler返回true, 通过
		// 注意checkFinishHandler的once要设成false
		public function addSequential(handler:Handler, checkFinishHandler:Handler) : void {
			m_procedureInfoList[m_procedureInfoList.length] = new _CProcedureInfo(handler, checkFinishHandler);
			if (!m_isRunning) {
				m_isRunning = true;
				Laya.timer.frameLoop(1, this, _onUpdate);
			}
		}

		private function _onUpdate() : void {
			if (!m_currentProcedureInfo && m_procedureInfoList.length > 0) {
				m_currentProcedureInfo = m_procedureInfoList.shift();
				if (m_currentProcedureInfo.handler) {
					m_currentProcedureInfo.handler.run();
				}
			}
			if (m_currentProcedureInfo) {
				if (m_currentProcedureInfo.checkFinishHandler) {
					if (m_currentProcedureInfo.checkFinishHandler.run()) {
						// finish返回true, 完成
						m_currentProcedureInfo = null;
					}
				} else {
					// 没有finish直接完成
					m_currentProcedureInfo = null;
				}
			}

			if (!m_currentProcedureInfo && m_procedureInfoList.length == 0) {
				// stop
				m_isRunning = false;
				Laya.timer.clear(this, _onUpdate);
				if (null != m_finishCallback) {
					m_finishCallback.run();
				}
				return ;
			}
		}

		public function set finishCallback(v:Handler) : void {
			m_finishCallback = v;
		}

		private var m_procedureInfoList:Vector.<_CProcedureInfo>;
		private var m_isRunning:Boolean;
		private var m_currentProcedureInfo:_CProcedureInfo;

		private var m_finishCallback:Handler;
	}

}
import laya.utils.Handler;

class _CProcedureInfo {
	public function _CProcedureInfo(handler:Handler, checkFinishHandler:Handler) {
		this.handler = handler;
		this.checkFinishHandler = checkFinishHandler;
	}
	public var handler:Handler;
	public var checkFinishHandler:Handler;
}