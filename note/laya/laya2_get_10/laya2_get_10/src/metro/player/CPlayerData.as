package metro.player {
import a_core.CBaseData;
public class CPlayerData extends CBaseData {
	public static const _CURRENCY:String = "currency";

	public function CPlayerData() {
		addChild(new CPlayerCurrencyData());

		m_flatDatas = new Array(X_SIZE * Y_SIZE);
		
	}
	public override function updateData(dataObj:Object) : void {
		super.updateData(dataObj);
		if (dataObj.hasOwnProperty(_CURRENCY)) {
			currencyData.updateData(dataObj[_CURRENCY]);
		}
	
	}
	public function get ID() : int { return getInt("ID"); }
	public function get name() : String { return getString("name"); }
	public function get currencyData() : CPlayerCurrencyData { return getChild(0) as CPlayerCurrencyData; }

	public function getFlatValue(idx:int) : int {
		return m_flatDatas[idx];
	}
	public function getFlatValue2(x:int, y:int) : int {
		return m_flatDatas[x + y*X_SIZE];
	}
	public function get flatDatas() : Array {
		return m_flatDatas;
	}

	public function reset() : void {
		curScore = 0;
		lastValue = -1;
		openCount = 0;
		m_openLockStep = 0;
		m_lastOpenLockStep = 0;
	}

	// 数值
	public function calcScore(value:int, count:int) : int {
		value = value * count * (count-1);
		if (lastValue + 1 == value) {
			var k:Number = 1.3;
			value *= k;
		}
		value = Math.floor(value);
		return value;
	}
	public function getOpenCost() : int {
		if (openCount > openCost.length) {
			return openCost[openCost.length - 1];
		} else {
			return openCost[openCount];
		}
	}
	public function canOpen() : Boolean {
		var cost:int = getOpenCost();
		if (curScore >= cost) {
			return true;
		}
		return false;
	}
	public function openNewLock() : void {
		openCount++;
		if (openCount >= 24) {
			m_openLockStep = 2;
		} else if (openCount >= 9) {
			m_openLockStep = 1;
		} else {
			m_openLockStep = 0;
		}
	}
	public function updateOpenLockStep() : void {
		m_lastOpenLockStep = m_openLockStep;
	}
	public function get lastOpenLockStep() : int {
		return m_lastOpenLockStep;
	}

	public function createNewValue() : int {
		var ret:int = 0;
		

		// for test
		// ret = 1 + Math.random() * 10;
		// ret = Math.floor(ret);
		// return ret;

		ret = 1 + Math.random() * 100;
		// ret = Math.floor(ret);
		if (ret < 52.5) {
			ret = 1;
		} else if (ret <75.6) {
			ret = 2;
		} else if (ret < 87.9) {
			ret = 3;
		} else if (ret < 95.3) {
			ret = 4;
		} else {
			ret = 5;
		}

		return ret;
	}
	
	public function get openLockStep() : int {
		return m_openLockStep;
	}
	public function updateTopScore() : void {
		if (curScore > m_topScore) {
			m_topScore = curScore;
		}
	}
	public function get topScore() : int {
		return m_topScore;
	}

	private var m_flatDatas:Array;

	public static const X_SIZE:int = 7;
	public static const Y_SIZE:int = 8;

	
	public var topNumber:int;
	private var m_topScore:int;
	public var curScore:int;
	public var lastValue:int;
	public var openCount:int;
	private var m_openLockStep:int; // 0 5x5未解锁完, 1:5x5解锁完, 7x7未解锁完, 2:全部解锁完
	private var m_lastOpenLockStep:int; // 已处理的解锁进度, 将方块可见

	public static const openCost:Array = [
			10, 20, 30, 50, 80, 120, 160, 210, 270, 330, 410, 490, 580, 680, 790, 900, 1030, 1160, 1300, 1450, 1610, 1780, 1960
		];
	public static const OPEN_LOCK_STEP_0:int = 0;
	public static const OPEN_LOCK_STEP_1:int = 1;
	public static const OPEN_LOCK_STEP_2:int = 2;
}}
