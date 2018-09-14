package game.procedure
{
	import core.procedure.CProcedureBase;
	import core.fsm.IFsm;
	import core.game.data.CDatabaseSystem;
	import game.CTableConstant;
	import core.game.data.CDataTable;
	import core.framework.IDataTable;
	import table.Chapter;

	/**
	 * ...
	 * @author
	 */
	public class CProceudreLogin extends CProcedureBase {
		public function CProceudreLogin(){
			
		}

		protected override function onInit(fsm:IFsm) : void {
			super.onInit(fsm);
		}
		protected override function onEnter(fsm:IFsm) : void {
			super.onEnter(fsm);

			
		}
		protected override function onUpdate(fsm:IFsm, deltaTime:Number) : void {
			super.onUpdate(fsm);
		}
		protected override function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
		}
		protected override function onDestroy(fsm:IFsm) : void {
			super.onDestroy(fsm);
		}
	}

}