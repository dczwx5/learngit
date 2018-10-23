package a_core.fsm
{
	import a_core.fsm.CFsm;
	import a_core.fsm.CFsm;
	import a_core.log.CLog;
	import a_core.CCommon;

	/**
	 * ...
	 * @author
	 */
	public class CFsmState{
		public function CFsmState(){
			
		}

		internal function initialize(fsm:CFsm) : void {
			onInit(fsm);
		}
		protected virtual function onInit(fsm:CFsm) : void {
			var typeName:String = CCommon.getQualifiedClassName(this);
			CLog.log("{0} onInit", typeName)
		}


		internal function enter(fsm:CFsm) : void {
			onEnter(fsm);
		}
		protected virtual function onEnter(fsm:CFsm) : void {
			var typeName:String = CCommon.getQualifiedClassName(this);
			CLog.log("{0} onEnter", typeName)
		}

		internal function update(fsm:CFsm, deltaTime:Number) : void {
			onUpdate(fsm, deltaTime);
		}
		protected virtual function onUpdate(fsm:CFsm, deltaTime:Number) : void {

		}

		internal function leave(fsm:CFsm, isShutDown:Boolean) : void {
			onLeave(fsm, isShutDown);
			
		}
		protected virtual function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
			var typeName:String = CCommon.getQualifiedClassName(this);
			CLog.log("{0} onLeave", typeName)
		}

		internal function destroy(fsm:CFsm) : void {
			onDestroy(fsm);
		}
		protected virtual function onDestroy(fsm:CFsm) : void {
			var typeName:String = CCommon.getQualifiedClassName(this);
			CLog.log("{0} onDestroy", typeName)
		}

		protected function changeState(fsm:CFsm, stateType:Class) : void {
			var fsmImp:CFsm = fsm as CFsm;
			if (null == fsmImp) {
				throw new Error("fsm is invalid");
			}

			if (stateType == null) {
				throw new Error("state type is invalid");
			} 

			fsmImp.changeState(stateType);
		}

		internal function onEvent(fsm:CFsm, sender:Object, eventID:int, userData:Object) : void {

		}
	}

}