package core.character
{
	/**
	 * ...
	 * @author
	 */
	public class CCharacterDataDescriptor{
		public function CCharacterDataDescriptor(){
			
		}

		public static const TYPE_PLAYER:int = 0;
		public static const TYPE_MONSTER:int = 1;
		public static const TYPE_MAP_OBJECT:int = 2;
		public static const TYPE_NPC:int = 3;

		public static function isPlayer(type:int) : Boolean {
			return type == TYPE_PLAYER;
		}
	}

}