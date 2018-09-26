package core.character
{
import core.game.ecsLoop.CGameSystemHandler;
import core.game.ecsLoop.CSubscribeBehaviour;
import laya.events.Event;

/**
	* ...
	* @author
	*/
public class CMapObjectHandler extends CGameSystemHandler {
	public function CMapObjectHandler(){
		super(CSubscribeBehaviour);
	}
 
	protected override function onAwake() : void {
		super.onAwake();
		
	}
	protected override virtual function onStart() : Boolean {
		var ret:Boolean = super.onStart();

		Laya.stage.on(Event.CLICK, this, _onMouseClick);

		return ret;
	}

	private function _onMouseClick() : void {
		// 
	}
}

} 