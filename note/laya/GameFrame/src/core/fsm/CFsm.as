package core.fsm
{
	import core.fsm.IFsm;
	import core.fsm.CFsmState;
	import laya.utils.Dictionary;
	import core.framework.CAppSystem;

	/**
	 * ...
	 * @author auto
	 */
	internal final class CFsm extends CFsmBase implements IFsm{
		public function CFsm(name:String, owner:Object, stateList:Array){
			super(name);

			m_owner = owner;
			m_states = new Vector.<CFsmState>(stateList.length);
			m_datas = new Dictionary();

			var i:int = 0;
			for each (var fsmState:CFsmState in stateList) {
				m_states[i++] = fsmState;
				fsmState.initialize(this);
			}

			m_currentStateTime = 0;
			m_currentState = null;
			m_isDestroyed = false;
		}

		public function start(stateType:Class) : void {
			if (isRunning) {
				throw new Error("fsm is running, can nott start again");
			}

			var state:CFsmState = getState(stateType);
			if (state == null) {
				throw new Error("fsm not exist");
			}

			m_currentStateTime = 0;
			m_currentState = state;
			m_currentState.enter(this);
		}


		public function get owner() : Object {
			return m_owner;
		}
		public override function get fsmStateCount() : int {
			return m_states.length;
		}
		public override function get isRunning() : Boolean {
			return m_currentState != null;
		}
		public function get isDestroy() : Boolean {
			return m_isDestroyed;
		}
		public function get currentState() : CFsmState {
			return m_currentState;
		}
		public override function get currentStateTime() : Number {
			return m_currentStateTime;
		}
		
		public function hasState(stateType:Class) : Boolean {
			return getState(stateType) != null;
		}
		public function getState(stateType:Class) : CFsmState {
			for each (var state:CFsmState in m_states) {
				if (state is stateType) {
					return state;
				}
			}
			return null;
		}
		public function getAllState() : Vector.<CFsmState> {
			return m_states;
		}
		public function fireEevnt(sender:Object, eventID:int) : void {
			m_currentState.onEvent(this, sender, eventID, null);
		}

		public function hasData(name:String) : Boolean {
			return getData(name) != null;
		}
		public function getData(name:String) : Object {
			if (name == null || name.length == 0) {
				throw new Error("name is invalid");
			}

			return m_datas.get(name);
		}
		public function setData(name:String, data:Object) : void {
			if (name == null || name.length == 0) {
				throw new Error("name is invalid");
			}

			m_datas.set(name, data);
		}
		public function removeData(name:String) : void {
			if (name == null || name.length == 0) {
				throw new Error("name is invalid");
			}

			m_datas.remove(name);
		}

		internal override function update(deltaTime:Number) : void {
			if (null == m_currentState) {
				return ;
			}

			m_currentStateTime += deltaTime;
			m_currentState.update(this, deltaTime);
		}
		internal override function shutDown() : void {
			if (null != m_currentState) {
				m_currentState.leave(this, true);
				m_currentState = null;
				m_currentStateTime = 0;
			}

			for (var i:int = 0; i < m_states.length; i++) { 
				var state:CFsmState = m_states[i];
				state.destroy(this);
			}
			m_states.length = 0;
			m_datas.clear();

			m_isDestroyed = true;

			m_pSystem = null;
		}

		internal function changeState(stateType:Class) : void {
			if (null == m_currentState) {
				throw new Error("current state is invalid");
			}

			var state:CFsmState = getState(stateType);
			if (null == state) {
				throw new Error("fsm can not change state, state is not exist");
			}

			m_currentState.leave(this, false);
			m_currentStateTime = 0;
			m_currentState = state;
			m_currentState.enter(this);
		}

		public function get system() : CAppSystem {
			return m_pSystem;
		}
		public function set system(v:CAppSystem) : void {
			m_pSystem = null;
		}
		private var m_pSystem:CAppSystem;

		private var m_owner:Object;
		private var m_states:Vector.<CFsmState>;
		private var m_datas:Dictionary;

		private var m_currentState:CFsmState;
		private var m_currentStateTime:Number;
		private var m_isDestroyed:Boolean;
	}

}