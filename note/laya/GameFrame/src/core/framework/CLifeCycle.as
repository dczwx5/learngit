package core.framework
{
	import core.log.CLog;
	import laya.events.EventDispatcher;
	import core.CCommon;

	/**
	 * ...
	 * @author auto
	 */
	public class CLifeCycle extends EventDispatcher implements ILifeCycle {
		public function CLifeCycle(){
			m_state = STATE_UNREADY;
		}

		// =================================================

		public function destroy() : void {
			onDestroy();
		}
		public function awake() : void {
			if (isUnReady) {
				onAwake();
			}
		}
		public function start() : Boolean {
			return onStart();
		}

		// =================================================

		protected virtual function onAwake() : void {
			m_state = STATE_AWAKED;
			var typeName:String = CCommon.getQualifiedClassName(this);
			CLog.log("{0} onAwake", typeName);
		}
		protected virtual function onStart() : Boolean {
			m_state = STATE_STARTED;
			
			var typeName:String = CCommon.getQualifiedClassName(this);
			CLog.log("{0} onStart", typeName);

			return true;
		}
		
		protected virtual function onDestroy() : void {
			m_state = STATE_DESTORYED;
			var typeName:String = CCommon.getQualifiedClassName(this);
			CLog.log("{0} onDestroy", typeName);
		}

		// =================================================

		public function get isAwakeState() : Boolean {
			return m_state == STATE_AWAKED;
		}
		public function get isUnReady() : Boolean {
			return m_state == STATE_UNREADY;
		}
		public function get isAwaked() : Boolean {
			return m_state >= STATE_AWAKED;
		}
		public function get isStarted() : Boolean {
			return m_state == STATE_STARTED;
		}
		public function get isDestoryed() : Boolean {
			return m_state == STATE_DESTORYED;
		}

		protected var m_state:int;

		public static const STATE_UNREADY:int = -1;
		public static const STATE_AWAKED:int = 0;
		public static const STATE_STARTED:int = 1;
		public static const STATE_DESTORYED:int = 2;
		
	}

}