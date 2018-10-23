package a_core.character.move
{
	import a_core.game.ecsLoop.CGameComponent;
	import a_core.scene.ISceneFacade;
	import a_core.game.ecsLoop.ITransform;
	import laya.d3.math.Vector3;

	/**
	 * ...
	 * @author
	 */
	public class CMovementComponent extends CGameComponent{
		public function CMovementComponent(){
			super("movement");

			m_targetPos = new Vector3();
			m_needToMove = false;
		}

		public function moveTo(x:Number, y:Number) : void {
			var pSceneFacade:ISceneFacade = owner.system.stage.getSystem(ISceneFacade) as ISceneFacade;
			if (!pSceneFacade) {
				return ;
			}

			var isBlock:Boolean = pSceneFacade.isBlock(x, y);
			if (isBlock) {
				return ;
			}

			var transform:ITransform = owner.transform;
			if (Math.abs(transform.x - x) < 0.000001 || Math.abs(transform.y -y) < 0.000001) {
				return ;
			}

			m_targetPos.x = x;
			m_targetPos.y = y;
			m_needToMove = true;
		}

		public function arrived() : void {
			m_needToMove = false;
		}
		public function get needToMove() : Boolean {
			return m_needToMove;
		}
		
		public function get targetPos() : Vector3 {
			return m_targetPos;
		}
		
		private var m_targetPos:Vector3;
		private var m_needToMove:Boolean;
	}

}