package metro.scene.flat
{

import a_core.fsm.CFsmState;
import a_core.fsm.CFsm;
import metro.scene.flat.CFlatObejct;
import a_core.framework.CBean;
import metro.scene.CMetroSceneHandler;
import a_core.pool.CPoolBean;
import a_core.game.fsm.CFsmSystem;
import metro.player.CPlayerData;

/**
	* ...
	* @author
	*/
public class CFlatBuilder extends CBean {
	public function CFlatBuilder() {
		_flatStatesMapCache = new Object();
	}
	protected override function onDestroy() : void {
		for (var key:* in _flatStatesMapCache) {
			delete _flatStatesMapCache[key];
		}
		_flatStatesMapCache = null;

		m_pSceneHandler = null;
		m_fsmSystem = null;
		m_pPool = null;
	}
	protected override function onStart() : Boolean {
		var ret:Boolean = super.onStart();

		m_pSceneHandler = system.getBean(CMetroSceneHandler) as CMetroSceneHandler;
		m_pPool = m_pSceneHandler.pool;

		m_fsmSystem = system.stage.getSystem(CFsmSystem) as CFsmSystem;
		return ret;
	}

	public function remove(flat:CFlatObejct) : void {
		m_fsmSystem.destroyFsm(flat.fsmID);
		m_pPool.recoverObject(flat);
	}

	// 0 不可见, 锁, 1 : 可见, 锁, 2:正常
	public function build(state:int, value:int, index:int) : CFlatObejct {
		var flat:CFlatObejct = m_pPool.createObject() as CFlatObejct;
		flat.value = value;
		

		if (-1 != index) {
			flat.index = index;
		}

		if (false == flat.isInitialize) {
			_initializeFlatObject(flat, state);
		} else {
			var flatStates:Array = _flatStatesMapCache[flat.fsmID];
			var fsm:CFsm = m_fsmSystem.createFsm(flat.fsmID, flat, flatStates);
			flat.updateFsm(fsm);
			_startFsmByState(fsm, state);
			
		}

		return flat;
	}
	private function _initializeFlatObject(flat:CFlatObejct, state:int) : void {
		var flatStates:Array = [
			new CFlatReady(), new CFlatUnVisible(), new CFlatLock(), 
			new CFlatFalling()
		];
		var fsmID:String = "flat_object_" + _ID;
		_flatStatesMapCache[fsmID] = flatStates;

		var fsm:CFsm = m_fsmSystem.createFsm(fsmID, flat, flatStates);
		flat.initialize(fsm);
		_startFsmByState(fsm, state);

		_ID++;
	}
	private function _startFsmByState(fsm:CFsm, state:int) : void {
		switch (state) {
			case CFlatObejct.STATE_UNVISIBLE:
				fsm.start(CFlatUnVisible);
				break;
			case CFlatObejct.STATE_LOCK:
				fsm.start(CFlatLock);
				break;
			case CFlatObejct.STATE_READY:
				fsm.start(CFlatReady);
				break;
			case CFlatObejct.STATE_FALLING :
				fsm.start(CFlatFalling);
				break;
		}
	}

	private var _flatStatesMapCache:Object; // 缓存statelist

	
	private var _ID:int = 0;
	
	private var m_pSceneHandler:CMetroSceneHandler;
	private var m_pPool:CPoolBean;
	private var m_fsmSystem:CFsmSystem;
}

}

