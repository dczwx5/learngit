package metro.scene
{
	import a_core.CBaseDisplay;
	import metro.player.CPlayerData;
	import laya.display.Text;
	import game.CPathUtils;

	/**
	 * ...
	 * @author
	 */
	public class CFlatObejct extends CBaseDisplay {
		public function CFlatObejct(){
		}

		public function reset() : void {
			tempIdxX = 0;	
			tempIdxY = 0;
			m_value = 0;

			m_index = 0;
			m_value = 0;

			isLock = false;
		}

		public function get isRunning() : Boolean {
			return true;
		}

		public function get value() : int {
			return m_value;
		}
		public function set value(v:int) : void {
			m_value = v;

			if (m_value > 0) {
				loadImage(CPathUtils.getNumber(m_value));
			}

			visible = m_value > 0;

		}

		public function get index() : int {
			return m_index;
		}
		public function set index(v:int) : void {
			m_index = v;
			x = getIndexX() * SIZE;
			y = getIndexY() * SIZE;
		}
		public function getIndexX() : int {
			return m_index % CPlayerData.X_SIZE;
		}
		public function getIndexY() : int {
			return Math.floor(m_index / CPlayerData.X_SIZE);
		}
		public function get fallValue() : int {
			return _fallValue;
		}
		public function set fallValue(v:int) : void {
			_fallValue = v;
		}
		public function get isLock() : Boolean {
			return _isLock;
		}
		public function set isLock(v:Boolean) : void {
			_isLock = v;
			if (_isLock) {
				graphics.clear();
				graphics.drawLine(0, SIZE/3-1, SIZE, SIZE/3-1, '#000000', 3);
				graphics.drawLine(0, 2*SIZE/3-1, SIZE, 2*SIZE/3-1, '#000000', 3);
				graphics.drawLine(SIZE/3-1, 0, SIZE/3-1, SIZE, '#000000', 3);
				graphics.drawLine(2*SIZE/3-1, 0, 2*SIZE/3-1, SIZE, '#000000', 3);
			} else {
				graphics.clear();
			}
		}

		private var m_index:int;
		private var m_value:int;

		private static const COLOR:Array = ['#000000', '#007700', '#000077', '#777700', '#aa0000', '#007777', '#0077ff', '#ffff77', '#77ffff', '#ff77ff']
		
		public static const SIZE:int = 134;

		private var _isLock:Boolean;
		private var _fallValue:int;

		public var tempIdxX:int;
		public var tempIdxY:int;
	}

}