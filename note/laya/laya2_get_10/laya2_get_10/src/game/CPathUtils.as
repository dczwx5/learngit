package game
{
	/**
	 * ...
	 * @author
	 */
	public class CPathUtils{
		// root path : bin\h5
		// // bin\h5\res\atlas
		public static const GAME_PATH:String = "../../";
		public static const ATLAS_PATH:String = "res/atlas/";
		
		public static function getNumber(number:int) : String {
			return "res/" + number + ".png";
		}
		public static function getUIPath(uiName:String) : String {
			return ATLAS_PATH + uiName + ".atlas";
		}

		public static function getTablePath(tableName:String) : String {
			return GAME_PATH + "runtime/table/client/" + tableName + ".json";
		}

		public static function getScenePath(name:String) : String {
			return "res/scene/" + name + ".png";
		}

		public static function getMonsterPath(name:String) : String {
			return "monster/" + name + ".png";
		}

		public static function getAnimation(mID:String, ani:String) : String {
			return ATLAS_PATH + "monster/" + mID + "/" + ani + ".atlas";
		}
		public static function getEffect(skin:String) : String {
			return ATLAS_PATH + skin + ".atlas";
		}
	}

}