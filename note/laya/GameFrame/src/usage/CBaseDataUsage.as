package usage
{
	/**
	 * ...
	 * @author
	 */
	public class CBaseDataUsage {
		public function CBaseDataUsage(){
			var heroData:Object = {
				"ID":1001,
				"lv":13,
				"attack":15,
				"stone":{
					"power":1000,
					"count":20
				}, 
				"skill":[
					{"ID":1, "lv":2}, {"ID":2, "lv":12}, 
				]
			};

			var rootData:RootData = new RootData();
			rootData.updateData(heroData);

			trace("ID : " + rootData.ID);
			trace("level : " + rootData.lv);
			trace("attack : " + rootData.attack);
			trace("________stoneData");
			trace("power : " + rootData.stoneData.power);
			trace("count : " + rootData.stoneData.count);
			trace("________skillData");
			var skillData:SkillData = rootData.skillListData.getByID(2);
			trace("ID : " + skillData.ID);
			trace("level : " + skillData.lv);
		}

		
	}
}


import core.CBaseData;

class RootData extends CBaseData {
	public function RootData() {
		addChild(new StoneData());
		addChild(new SkillListData());
	}

	public override function updateData(dataObj:Object) : void {
		super.updateData(dataObj);

		var obj:Object = getData(_Stone);
		stoneData.updateData(obj);

		skillListData.updateData(dataObj["skill"]);
	}

	public function get ID() : int { return getInt(_ID); }
	public function get lv() : int { return getInt(_Level); }
	public function get attack() : int { return getInt(_Attack); }

	public function get stoneData() : StoneData {
		return getChild(0) as StoneData;
	}
	public function get skillListData() : SkillListData {
		return getChildByType(SkillListData) as SkillListData;
	}
	public static const _Stone:String = "stone";
	public static const _ID:String = "ID";
	public static const _Level:String = "lv";
	public static const _Attack:String = "attack";

	
}

class StoneData extends CBaseData {
	public function get power() : int { return getInt(_Power); }
	public function get count() : int { return getInt(_Count); }

	public static const _Power:String = "power";
	public static const _Count:String = "count";
}

class SkillListData extends CBaseData {
	public function SkillListData() : void {
		super(SkillData);
	}
	public override function updateData(dataObj:Object) : void {
		super.updateData(dataObj);
	}

	public function getByID(id:int) : SkillData {
		return getListChildData("ID", id) as SkillData;
	}
}
class SkillData extends CBaseData {
	public function get ID() : int { return getInt(_ID); }
	public function get lv() : int { return getInt(_Level); }
	
	public static const _ID:String = "ID";
	public static const _Level:String = "lv";

}