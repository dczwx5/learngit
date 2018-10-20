package a_core.framework
{
	/**
	 * ...
	 * @author
	 */
	public interface IDatabase{
		function getTable(sTableName:String) : IDataTable;
		function get isReady() : Boolean;
	}

}