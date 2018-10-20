package core.fsm
{
	import core.fsm.CFsm;
	import core.fsm.IFsm;
	import core.log.CLog;
	import core.CCommon;

	/**
	 * ...
	 * @author
	 */
	public class CFsmState{
		public function CFsmState(){
			
		}

		internal function initialize(fsm:IFsm) : void {
			onInit(fsm);
		}
		protected virtual function onInit(fsm:IFsm) : void {
			var typeName:String = CCommon.getQualifiedClassName(this);
			CLog.log("{0} onInit", typeName)
		}


		internal function enter(fsm:IFsm) : void {
			onEnter(fsm);
		}
		protected virtual function onEnter(fsm:IFsm) : void {
			var typeName:String = CCommon.getQualifiedClassName(this);
			CLog.log("{0} onEnter", typeName)
		}

		internal function update(fsm:IFsm, deltaTime:Number) : void {
			onUpdate(fsm, deltaTime);
		}
		protected virtual function onUpdate(fsm:IFsm, deltaTime:Number) : void {

		}

		internal function leave(fsm:IFsm, isShutDown:Boolean) : void {
			onLeave(fsm, isShutDown);
			
		}
		protected virtual function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
			var typeName:String = CCommon.getQualifiedClassName(this);
			CLog.log("{0} onLeave", typeName)
		}

		internal function destroy(fsm:IFsm) : void {
			onDestroy(fsm);
		}
		protected virtual function onDestroy(fsm:IFsm) : void {
			var typeName:String = CCommon.getQualifiedClassName(this);
			CLog.log("{0} onDestroy", typeName)
		}

		protected function changeState(fsm:IFsm, stateType:Class) : void {
			var fsmImp:CFsm = fsm as CFsm;
			if (null == fsmImp) {
				throw new Error("fsm is invalid");
			}

			if (stateType == null) {
				throw new Error("state type is invalid");
			} 

			fsmImp.changeState(stateType);
		}

		internal function onEvent(fsm:IFsm, sender:Object, eventID:int, userData:Object) : void {

		}
	}

}