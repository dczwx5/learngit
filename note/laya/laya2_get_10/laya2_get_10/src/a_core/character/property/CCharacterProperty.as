package a_core.character.property
{
	import a_core.game.ecsLoop.CSubscribeBehaviour;
	import a_core.CBaseData;
	import a_core.character.animation.EAnimation;

	/**
	 * ...
	 * @author
	 */
	public class CCharacterProperty extends CSubscribeBehaviour {
		public function CCharacterProperty(){
			super("property", true);

			_dataObject = new CBaseData();
		}

		public function updateData(data:Object) : void {
			_dataObject.updateData(data);
		}

		public function get ID() : Number { return _dataObject.getNumber(CBaseData._ID); }
		public function get type() : Number { return _dataObject.getInt(CBaseData._TYPE); }
		public function get skin() : String { return _dataObject.getString(CBaseData._SKIN); }
		public function get defAni() : String { 
			var defAnimation:String = _dataObject.getString(CBaseData._DEF_ANIMATION);
			if (defAnimation == null || defAnimation.length == 0) {
				defAnimation = EAnimation.IDLE;
			}
			return defAnimation;
		}

		public function get x() : Number { return _dataObject.getNumber(CBaseData._X); }
		public function get y() : Number { return _dataObject.getNumber(CBaseData._Y); }


		protected var _dataObject:CBaseData;
	}

}