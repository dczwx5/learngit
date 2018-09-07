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
		public static function getUIPath(uiName:String) : String {
			return "res/atlas/" + uiName + ".atlas";
		}

		public static function getTablePath(tableName:String) : String {
			return GAME_PATH + "runtime/table/client/" + tableName + ".json";
		}
	}

}