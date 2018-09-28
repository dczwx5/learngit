package core.character
{
	import core.game.ecsLoop.CGameSystemHandler;
	import core.game.ecsLoop.CGameObject;
	import core.CCommon;
	import laya.events.Event;
	import laya.d3.math.Vector3;
	import core.game.ecsLoop.ITransform;

	/**
	 * ...
	 * @author
	 */
	public class CPlayHandler extends CGameSystemHandler {
		public function CPlayHandler(){
			m_targetPos = new Vector3();
		}
		override protected function onStart() : Boolean {
			var ret:Boolean = super.onStart();

			CCommon.stage.on(Event.CLICK, this, _onMouseClick)

			return ret;
		}
		public override function tickUpdate(delta:Number, obj:CGameObject) : void {
			super.tickUpdate(delta, obj);
			if (m_running) {
				var transform:ITransform = obj.transform;
				var distX:Number = m_targetPos.x - transform.x;
				var absDistX:Number = Math.abs(distX);
				if (distX != 0) {
					var moveStep:Number = m_step;
					if (absDistX < m_step) {
						moveStep = absDistX;
					}
					transform.x += moveStep * (distX/absDistX);
				}

				distX = m_targetPos.x - transform.x;
				if (Math.abs(distX) < 0.000001) {
					m_running = false;
				}
			}

        }

		private function _onMouseClick() : void {
			if (m_pHero && m_pHero.isRunning) {
				m_running = true;
				m_targetPos.x = CCommon.stage.mouseX;
				m_targetPos.y = CCommon.stage.mouseY;
				
			}
		}

		public override function isComponentSupported(obj:CGameObject) : Boolean {
			return m_pHero == obj;
		}
		public function get hero() : CGameObject {
			return m_pHero;
		}
		public function set hero(v:CGameObject) : void {
			m_pHero = v;
		}

		private var m_targetPos:Vector3;
		private var m_running:Boolean;
		private var m_step:Number = 5;

		private var m_pHero:CGameObject; // 玩家控制
	}

}