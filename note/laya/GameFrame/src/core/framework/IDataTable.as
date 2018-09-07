package core.framework
{
	/**
	 * ...
	 * @author
	 */
	public interface IDataTable{
		function get name() : String;
		function get primaryKey() : String;
		function get tableMap() : Object;
		function findByPrimaryKey(key:*) : *;
		function findByProperty(sPropertyName:String, filterVal:*) : Array;
		function first() : *;
		function last() : *;

		function toArray() : Array;
	}

}