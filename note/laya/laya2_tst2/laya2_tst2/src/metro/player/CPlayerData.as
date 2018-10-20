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
	private var m_flatDatas:Array;

	public static const X_SIZE:int = 5;
	public static const Y_SIZE:int = 5;

	public var topNumber:int;
	public var topScore:int;
	public var curScore:int;
}}
