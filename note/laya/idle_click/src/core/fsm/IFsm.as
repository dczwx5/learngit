package core.fsm
{
	import core.fsm.CFsmState;
	import core.framework.CAppSystem;

	/**
	 * ...
	 * @author
	 */
	public interface IFsm {
		function get name() : String;
		function get owner() : Object;
		function get fsmStateCount() : int;
		function get isRunning() : Boolean;
		function get isDestroy() : Boolean;
		function get currentState() : CFsmState;
		function get currentStateTime() : Number;
		function start(stateType:Class) : void;
		function hasState(stateType:Class) : Boolean;
		function getState(stateType:Class) : CFsmState;
		function getAllState() : Vector.<CFsmState>;
		function fireEevnt(sender:Object, eventID:int) : void;

		function hasData(name:String) : Boolean;
		function getData(name:String) : Object;
		function setData(name:String, data:Object) : void;
		function removeData(name:String) : void;

		function get system() : CAppSystem ;
		function set system(v:CAppSystem) : void ;
		
	}

}