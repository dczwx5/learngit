package a_core.character.animation
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

/**
	* ...
	* @author
	*/
public class CCharacterFrameAnimation implements ICharacterAnimation {
	
	public function CCharacterFrameAnimation(){
		m_role = new CCharacterDisplay();
		m_animation = new CCharacterDisplay();
		m_role.addChild(m_animation);

		_aniMap = {};
	}

	public function create(propertyData:CCharacterProperty) : void {
		m_skin = propertyData.skin;
		m_defAni = propertyData.defAni;

		_addAni(EAnimation.DIE);
		_addAni(EAnimation.MOVE);
		_addAni(EAnimation.IDLE);
	}

	public function playAnimation(aniName:String) : void {
		var ani:Animation = _aniMap[aniName];
		var lastAni:Animation = m_animation.getChildAt(0) as Animation;
		if (ani == lastAni) {
			ani.play();
			return ;
		}

		if (lastAni) {
			lastAni.stop();
			lastAni.parent.removeChild(lastAni);
		}

		m_animation.addChild(ani);
		ani.play();
	}

	private function _addAni(aniName:String) : void {
		var ani:Animation = new Animation();
		var monsterUrl:String = CPathUtils.getAnimation(m_skin, aniName);
		// 加载动画图集,加载成功后执行回调方法
		ani.loadAtlas(monsterUrl, Handler.create(this, onLoaded, [aniName, ani]));
	}
	private var _loadFinish:Boolean;
	private var _loadCount:int;
	private var _aniMap:Object;
	private function onLoaded(aniName:String, ani:Animation):void {
		_aniMap[aniName] = ani;
		_loadCount++;
		if (_loadCount >= 3) {
			_loadFinish = true;
			m_pEventDispater.event(ECommonEventType.EVENT_RUNNING);
		}
	}

	public function get isRunning() : Boolean {
		return _loadFinish;
	}

	public function get skin() : String {
		return m_skin;
	}
	
	public function get displayObject() : CCharacterDisplay {
		return m_role;
	}

	public function set eventDispatcher(v:EventDispatcher) : void {
		m_pEventDispater = v;
	}

	private var m_role:CCharacterDisplay;
	private var m_animation:CCharacterDisplay;
	private var m_skin:String;
	private var m_defAni:String;

	private var m_pEventDispater:EventDispatcher;

}

}