package game.instance
{
	import core.CBaseData;

	/**
	 * ...
	 * @author
	 */
	public class CInstanceData extends CBaseData {
		public function CInstanceData() {
			
		}

		public override function updateData(dataObj:Object) : void {
			super.updateData(dataObj);
		}

		public function get instanceID() : int {
			return getInt(_INSTANCE_ID);
		}
		
		public static const _INSTANCE_ID:String = "instanceID"

	}

}