package metro.building.data {
import core.CBaseData;
import metro.building.data.CBuildingItemData;
public class CBuildingListData extends CBaseData {
	public function CBuildingListData() {
		super(CBuildingItemData, CBaseData._ID);
	}
	public override function updateData(dataObj:Object) : void {
		super.updateData(dataObj);

		m_dps = 0;
		var tempList:Array = list;
		for each (var bdata:CBuildingItemData in tempList) {
			m_dps += bdata.dps;
		}
	}

	public function getByID(ID:int) : CBuildingItemData {
		return getListChildData("ID", ID) as CBuildingItemData;
	}

	public function get dps() : Number {
		return m_dps;
	}
	private var m_dps:Number;
}}