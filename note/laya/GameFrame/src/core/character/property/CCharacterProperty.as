package core.character.property
{
	import core.game.ecsLoop.CSubscribeBehaviour;
	import core.CBaseData;

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

		protected var _dataObject:CBaseData;
	}

}