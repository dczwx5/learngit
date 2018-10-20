package core.fsm
{
	/**
	 * ...
	 * @author
	 */
	public interface IFsmManager{
		// function get count() : int;
		function hasFsm(name:String) : Boolean;
		function getFsm(name:String) : IFsm;
		function getAllFsms() : Object ;

		// stateList : CFsmState[]
		function createFsm(name:String, owner:Object, stateList:Array) : IFsm;
		function destroyFsm(name:String) : Boolean ;
	}

}