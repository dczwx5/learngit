package metro.building.data {
import core.CBaseData;
import metro.player.CPlayerPropertyCalc;
public class CBuildingItemData extends CBaseData {
	public function CBuildingItemData() {
	}
	public override function updateData(dataObj:Object) : void {
		super.updateData(dataObj);

		m_dps = CPlayerPropertyCalc.calcDpsByBuilding(this);
		m_nextLvupDpsAdded = CPlayerPropertyCalc.calcDpsAddByBuilding(this);
		m_nextLvupCost = CPlayerPropertyCalc.calcBuildlingLvupCost(this);
	}
	public function get ID() : int { return getInt("ID"); }
	public function get lv() : int { return getInt("lv"); }
	
	public function get dps() : Number {
		return m_dps;
	}
	public function get lvupDpsAdd() : Number {
		return m_nextLvupDpsAdded;
	}
	public function get lvupCost() : Number {
		return m_nextLvupCost;
	}

	private var m_dps:Number = 0;
	private var m_nextLvupDpsAdded:Number = 0;
	private var m_nextLvupCost:Number = 0;
}}