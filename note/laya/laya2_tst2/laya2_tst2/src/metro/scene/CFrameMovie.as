package metro.scene
{
import laya.display.Animation;
import game.CPathUtils;
import laya.utils.Handler;
import laya.events.EventDispatcher;
import a_core.game.ecsLoop.CGameComponent;
import a_core.character.display.IDisplay;
import a_core.CBaseDisplay;
import a_core.character.display.CCharacterDisplay;
import a_core.character.animation.ICharacterAnimation;
import a_core.character.property.CCharacterProperty;
import a_core.ECommonEventType;
import laya.display.Sprite;
import laya.events.Event;

/**
	* ...
	* @author
	*/
public class CFrameMovie extends CBaseDisplay {
	
	public function CFrameMovie(){

	}

	public function create(skin:String) : void {
		m_skin = skin;

		_addAni("ani1");
	}

	public function play(loop:Boolean) : void {
		if (!loop) {
			(getChildAt(0) as Animation).on(Event.COMPLETE, this, _playFinished);
		}
		
		(getChildAt(0) as Animation).play(loop);
	}
	private function _playFinished() : void {
		(getChildAt(0) as Animation).off(Event.COMPLETE, this, _playFinished);
		event(Event.COMPLETE);
	}
	private function _addAni(aniName:String) : void {
		var ani:Animation = new Animation();
		var monsterUrl:String = CPathUtils.getEffect(m_skin);
		// 加载动画图集,加载成功后执行回调方法
		ani.loadAtlas(monsterUrl, Handler.create(this, onLoaded, [aniName, ani]));
	}
	private var _loadFinish:Boolean;
	private function onLoaded(aniName:String, ani:Animation):void {
		addChild(ani);
		_loadFinish = true;
	}

	public function get isRunning() : Boolean {
		return _loadFinish;
	}

	public function get skin() : String {
		return m_skin;
	}
	

	private var m_skin:String;

}

}