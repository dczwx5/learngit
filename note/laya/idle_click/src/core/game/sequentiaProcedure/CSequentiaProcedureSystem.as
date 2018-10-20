package core.game.sequentiaProcedure
{
	import core.framework.CAppSystem;
	import core.sequentiaProcedure.CSequentialProcedureManager;
	import laya.utils.Handler;

	/**
	 * ...
	 * @author
	 */
	public class CSequentiaProcedureSystem extends CAppSystem {
		public function CSequentiaProcedureSystem(){
			
		}

		protected override function onAwake() : void {
			super.onAwake();

			m_list = new ProcedureInfoList();
		}
		protected override function onStart() : Boolean {
			return super.onStart();
		}
	
		protected override function onDestroy() : void {
			super.onDestroy();

			m_list.destroy();
			m_list = null;
		}

		// checkFinishHandler 的once要为false
		public function addSequential(caller:*, handler:Handler, checkFinishHandler:Handler) : void {
			var info:ProcedureInfo = m_list.find(caller);
			if (!info) {
				info = m_list.create();
				info.isIdle = false;
				info.procedureManager.finishCallback = Handler.create(this, _onSequnentialFinish, [caller]);
			}
			info.procedureManager.addSequential(handler, checkFinishHandler);
		}

		private function _onSequnentialFinish(caller:*) : void {
			m_list.recycle(caller);
		} 

		private var m_list:ProcedureInfoList;
	}

}

class ProcedureInfoList {
	public function ProcedureInfoList() {
		m_list = new Array();
	}

	public function destroy() : void {
		var i:int = 0;
		var len:int = m_list.length;
		var info:ProcedureInfo;
		for (; i < len; i++) {
			info = m_list[i];
			info.procedureManager.destroy();
			info.reset();
			info.procedureManager = null;
		}
		m_list.length = 0;
		m_list = null;
	}

	public function remove(caller:*) : void {
		var i:int = 0;
		var len:int = m_list.length;
		var info:ProcedureInfo;
		for (; i < len; i++) {
			info = m_list[i];
			if (info.caller == caller) {
				m_list.splice(i, 1);
				break;
			}
		}
	}
	public function find(caller:*) : ProcedureInfo {
		var i:int = 0;
		var len:int = m_list.length;
		var info:ProcedureInfo;
		for (; i < len; i++) {
			info = m_list[i];
			if (info.caller == caller) {
				return info;
			}
		}
		return null;
	}
	public function getIdle() : ProcedureInfo {
		var i:int = 0;
		var len:int = m_list.length;
		var info:ProcedureInfo;
		for (; i < len; i++) {
			info = m_list[i];
			if (info.isIdle) {
				return info;
			}
		}
		return null;
	}
	public function  create() : ProcedureInfo {
		var info:ProcedureInfo = getIdle();
		if (!info) {
			info = new ProcedureInfo();
			var procedureManager:CSequentialProcedureManager = new CSequentialProcedureManager();
			info.procedureManager = procedureManager;
			m_list[m_list.length] = info;
		}
		
		return info;
	}

	public function recycle(caller:*) : void {
		if (m_list.length > 10) {
			remove(caller);
		} else {
			var info:ProcedureInfo = find(caller);
			info.reset();
		}
	}

	private var m_list:Array;
}

import laya.utils.Handler;
import core.sequentiaProcedure.CSequentialProcedureManager;

class ProcedureInfo {
	public var caller:*;
	public var handler:Handler;
	public var checkFinishHandler:Handler;
	public var procedureManager:CSequentialProcedureManager;

	public function reset() : void {
		caller = null;
		handler = null;
		checkFinishHandler = null;
		isIdle = true;
	}

	public var isIdle:Boolean = true;
}