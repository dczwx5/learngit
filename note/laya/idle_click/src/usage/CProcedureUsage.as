package usage
{
	import core.fsm.CFsmManager;
	import core.fsm.IFsm;
	import core.procedure.CProcedureManager;

	/**
	 * ...
	 * @author
	 */
	public class CProcedureUsage{
		private var procedureManager:CProcedureManager;
		private var fsmManager:CFsmManager;
		public function CProcedureUsage(){
			var owner:OwnerType = new OwnerType();
			var stateList:Array = [new Login(), new Loading(), new Gaming(), new Exit()];
			fsmManager = new CFsmManager();
			procedureManager = new CProcedureManager();
			procedureManager.initialize("gameProcedure", fsmManager, stateList);
			procedureManager.startProcedure(Login);


		}

		public function update(deltaTime:Number) : void {
			fsmManager.update(deltaTime);
			if (procedureManager) {
				if (procedureManager.currentProcedure is Exit) {
					procedureManager.shutDown();
					procedureManager = null;
				}
			}
			
		}
	}

}

import core.procedure.CProcedureBase;
import core.fsm.IFsm;

class OwnerType {

}

class Login extends CProcedureBase {
	protected override function onInit(fsm:IFsm) : void {
		super.onInit(fsm);
		trace("Login.onInit");
	}

	protected override function onEnter(fsm:IFsm) : void {
		super.onEnter(fsm);
		trace("Login.onEnter");
	}

	protected override function onUpdate(fsm:IFsm, deltaTime:Number) : void {
		super.onUpdate(fsm, deltaTime);
		trace("Login.onUpdate");

		changeProcedure(fsm, Loading);
	}

	protected override function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
		super.onLeave(fsm, isShutDown);
		trace("Login.onLeave");
	}

	protected override function onDestroy(fsm:IFsm) : void {
		super.onDestroy(fsm);
		trace("Login.onDestroy");
	}
}
class Loading extends CProcedureBase {
protected override function onInit(fsm:IFsm) : void {
		super.onInit(fsm);
		trace("Loading.onInit");
	}

	protected override function onEnter(fsm:IFsm) : void {
		super.onEnter(fsm);
		trace("Loading.onEnter");
	}

	protected override function onUpdate(fsm:IFsm, deltaTime:Number) : void {
		super.onUpdate(fsm, deltaTime);
		trace("Loading.onUpdate");

		changeProcedure(fsm, Gaming);
	}

	protected override function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
		super.onLeave(fsm, isShutDown);
		trace("Loading.onLeave");
	}

	protected override function onDestroy(fsm:IFsm) : void {
		super.onDestroy(fsm);
		trace("Loading.onDestroy");
	}
}
class Gaming extends CProcedureBase {
protected override function onInit(fsm:IFsm) : void {
		super.onInit(fsm);
		trace("Gaming.onInit");
	}

	protected override function onEnter(fsm:IFsm) : void {
		super.onEnter(fsm);
		trace("Gaming.onEnter");
	}

	protected override function onUpdate(fsm:IFsm, deltaTime:Number) : void {
		super.onUpdate(fsm, deltaTime);
		trace("Gaming.onUpdate");

		changeProcedure(fsm, Exit);
	}

	protected override function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
		super.onLeave(fsm, isShutDown);
		trace("Gaming.onLeave");
	}

	protected override function onDestroy(fsm:IFsm) : void {
		super.onDestroy(fsm);
		trace("Gaming.onDestroy");
	}
}
class Exit extends CProcedureBase {
	  protected override function onInit(fsm:IFsm) : void {
		super.onInit(fsm);
		trace("Exit.onInit");
	}

	protected override function onEnter(fsm:IFsm) : void {
		super.onEnter(fsm);
		trace("Exit.onEnter");
	}

	protected override function onUpdate(fsm:IFsm, deltaTime:Number) : void {
		super.onUpdate(fsm, deltaTime);
		trace("Exit.onUpdate");

		
	}

	protected override function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
		super.onLeave(fsm, isShutDown);
		trace("Exit.onLeave");
	}

	protected override function onDestroy(fsm:IFsm) : void {
		super.onDestroy(fsm);
		trace("Exit.onDestroy");
	}
}