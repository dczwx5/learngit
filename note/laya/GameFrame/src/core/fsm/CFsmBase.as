package core.fsm
{
	/**
	 * ...
	 * @author
	 */
	public class CFsmBase {
		public function CFsmBase(name:String){
			m_name = name;
		}


		public function get name() : String {
			return m_name;
		}

		public virtual function get isDestroyed() : Boolean {
			return false;
		}

		public virtual function get fsmStateCount() : int {
			return -1;
		}
		public virtual function get isRunning() : Boolean {
			return false;
		}
		public virtual function get currentStateName() : String {
			return null;
		}
		public virtual function get currentStateTime() : Number {
			return -1;
		}

		// virtual interface
		internal virtual function shutDown() : void {
		}

		internal virtual function update(deltaTime:Number) : void {
			
		}

		private var m_name:String;
		
	}

}