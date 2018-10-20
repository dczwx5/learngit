package metro.player {
import core.CBaseData;
import metro.building.data.CBuildingListData;
public class CPlayerData extends CBaseData {
	public static const _CURRENCY:String = "currency";
	public static const _BUILDINGS:String = "buildings";

	public function CPlayerData() {
		addChild(new CPlayerCurrencyData());
		addChild(new CBuildingListData());
	}
	public override function updateData(dataObj:Object) : void {
		super.updateData(dataObj);
		if (dataObj.hasOwnProperty(_CURRENCY)) {
			currencyData.updateData(dataObj[_CURRENCY]);
		}
		if (dataObj.hasOwnProperty(_BUILDINGS)) {
			buildingListData.updateData(dataObj[_BUILDINGS]);
		}
	}
	public function get ID() : int { return getInt("ID"); }
	public function get name() : String { return getString("name"); }
	public function get currencyData() : CPlayerCurrencyData { return getChild(0) as CPlayerCurrencyData; }
	public function get buildingListData() : CBuildingListData { return getChild(1) as CBuildingListData; }

	
	public function get dps() : Number {
		return m_dps;
	}
	public function set dps(v:Number) : void {
		m_dps = v;
	}
	public function getBuildingDps() : Number {
		return buildingListData.dps;
	}

	private var m_dps:Number;
}}
