package a_core.framework
{
	/**
	 * ...
	 * @author
	 */
	public interface IDataTable{
		function get Name() : String;
		function get primaryKey() : String;
		function get tableMap() : Object;
		function findByPrimaryKey(value:*) : *;
		function findByProperty(sPropertyName:String, filterVal:*) : Array;
		function get first() : *;
		function get last() : *;

		function toArray() : Array;
	}

}