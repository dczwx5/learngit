package metro.player {
import a_core.CBaseData;
public class CPlayerCurrencyData extends CBaseData {
	public function CPlayerCurrencyData() {
	}
	public override function updateData(dataObj:Object) : void {
		super.updateData(dataObj);
	}
	public function get gold() : Number { return getNumber("gold"); }

}}