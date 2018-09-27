package core.character.animation
{
import laya.display.Animation;
import game.CPathUtils;
import laya.utils.Handler;
import laya.events.EventDispatcher;
import core.game.ecsLoop.CGameComponent;
import core.character.CCharacter;
import core.character.display.IDisplay;
import core.CBaseObject;

/**
	* ...
	* @author
	*/
public class CCharacterFrameAnimation extends CGameComponent implements IDisplay {
	public static const EVENT_RUNNING:String = "running";
	public function CCharacterFrameAnimation(){
		super("frameAnimation");

		m_role = new CCharacter();
		m_animation = new CCharacter();
		m_role.addChild(m_animation);

		_aniMap = {};
	}

	public function create() : void {
		_addAni(EAnimation.DIE);
		_addAni(EAnimation.MOVE);
		_addAni(EAnimation.IDLE);
	}

	public function playAnimation(aniName:String) : void {
		var ani:Animation = _aniMap[aniName];
		var lastAni:Animation = m_animation.getChildAt(0) as Animation;
		if (lastAni) {
			lastAni.stop();
			lastAni.parent.removeChild(lastAni);
		}

		m_animation.addChild(ani);
		ani.play();
	}

	private function _addAni(aniName:String) : void {
		var ani:Animation = new Animation();
		var monsterUrl:String = CPathUtils.getMonsterAnimation(id, aniName);
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
			event(EVENT_RUNNING);
		}
	}

	public function get isRunning() : Boolean {
		return _loadFinish;
	}

	public function get id() : String {
		return m_id;
	}
	public function set id(v:String) : void {
		m_id = v;
	}
	public function get displayObject() : CCharacter {
		return m_role;
	}

	private var m_role:CCharacter;
	private var m_animation:CCharacter;
	private var m_id:String;


}

}