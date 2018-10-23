package metro.scene.flat
{
	import a_core.CBaseDisplay;
	import metro.player.CPlayerData;
	import laya.display.Text;
	import game.CPathUtils;
	import laya.utils.Ease;
	import a_core.fsm.CFsm;
	import metro.scene.CFrameMovie;

	/**
	 * ...
	 * @author
	 */
	public class CFlatObejct extends CBaseDisplay {
		public function CFlatObejct(){
			m_flatAni = new CFrameMovie();
			m_flatAni.create("number");
			m_flatAni.gotoAndStop(0);
			this.addChild(m_flatAni);

			m_lockAni = new CFrameMovie();
			m_lockAni.create("number");
			m_lockAni.gotoAndStop(LOCK_FRAME_INDEX);
			m_lockAni.visible = false;
			this.addChild(m_lockAni);
			
		}

		public function dispose() : void {
			m_pFsm = null;
		}

		public function reset() : void {
			tempIdxX = 0;	
			tempIdxY = 0;

			m_index = 0;
			m_value = 0;
			m_lockStep = 0;
		}

		public function get isRunning() : Boolean {
			return true;
		}

		public function get value() : int {
			return m_value;
		}
		public function set value(v:int) : void {
			if (m_value == v && v > 0) {
				return ;
			}

			m_value = v;

			if (m_value > 0) {
				m_flatAni.gotoAndStop((m_value - 1));
				// loadImage(CPathUtils.getNumber(m_value));
			}
			m_value > 0 ? alpha = 1 : alpha = 0;
		}

		public function get index() : int {
			return m_index;
		}
		public function set index(v:int) : void {
			m_index = v;
			x = getIndexX() * SIZE;
			y = getIndexY() * SIZE;
		}
		public function getIndexX() : int {
			return m_index % CPlayerData.X_SIZE;
		}
		public function getIndexY() : int {
			return Math.floor(m_index / CPlayerData.X_SIZE);
		}
		public function get fallValue() : int {
			return _fallValue;
		}
		public function set fallValue(v:int) : void {
			_fallValue = v;
		}
		// public function get isLock() : Boolean {
		// 	return _isLock;
		// }
		// public function set isLock(v:Boolean) : void {
		// 	_isLock = v;
		// 	if (_isLock && !m_isFalling) {
		// 		showLock();
		// 	} else {
		// 		graphics.clear();
		// 	}
		// }

		public function hide() : void {
			visible = false;
		}
		public function show() : void {
			visible = true;
		}

		public function showLock() : void {
			m_lockAni.visible = true;
		}
		public function hideLock() : void {
			m_lockAni.visible = false;
		}

		public function initialize(fsm:CFsm) : void {
			if (!m_bInitialize) {
				m_bInitialize = true;
				m_pFsm = fsm;
				m_fsmID = m_pFsm.Name;
			}
		}
		public function updateFsm(v:CFsm) : void {
			m_pFsm = v;
		}
		public function get isInitialize() : Boolean {
			return m_bInitialize;
		}

		public function get fsm() : CFsm {
			return m_pFsm
		}
		public function get fsmID() : String {
			return m_fsmID;
		}
		public function get isReadyState() : Boolean {
			return fsm.currentState is CFlatReady;
		}
		public function get isUnVisibleState() : Boolean {
			return fsm.currentState is CFlatUnVisible;
		}
		public function get isLockState() : Boolean {
			return fsm.currentState is CFlatLock;
		}
		public function get isFallingState() : Boolean {
			return fsm.currentState is CFlatFalling;
		}
		public function get isInvalid() : Boolean {
			return isUnVisibleState || isLockState;
		}

		public function set lockStep(v:int) : void {
			m_lockStep = v;
		}
		public function get lockStep() : int {
			return m_lockStep;
		}

		private var m_lockStep:int; // 方块解锁的顺序, 值越高, 越后解锁, 需要playerData.lastOpenLockStep >= m_lockStep, 才会解锁

		private var m_index:int;
		private var m_value:int;
		
		public static const SIZE:int = 100;

		// private var _isLock:Boolean;
		private var _fallValue:int;

		public var tempIdxX:int;
		public var tempIdxY:int;

		public static const FALL_HANDLER:Function = Ease.linearNone;
		public static const FALL_TIME:Number = 100;

		private var m_bInitialize:Boolean;
		private var m_fsmID:String;
		private var m_pFsm:CFsm;

		public static const STATE_UNVISIBLE:int = 0;
		public static const STATE_LOCK:int = 1;
		public static const STATE_READY:int = 2;
		public static const STATE_FALLING:int = 3;

		private var m_flatAni:CFrameMovie;
		private var m_lockAni:CFrameMovie;

		//
		public static const LOCK_FRAME_INDEX:int = 13;
	}

}