package core.game.data
{
	import core.framework.CAppSystem;
	import core.framework.IDatabase;
	import core.sequentiaProcedure.CSequentialProcedureManager;
	import core.game.sequentiaProcedure.CSequentiaProcedureSystem;
	import laya.utils.Handler;
	import core.framework.IDataTable;
	import laya.debug.tools.JsonTool;
	import laya.net.Loader;
	import game.CPathUtils;
	import core.game.data.CDataTable;
	import laya.utils.ClassUtils;
	import laya.debug.tools.ClassTool;

	/**
	 * ...
	 * @author
	 */
	public class CDatabaseSystem extends CAppSystem implements IDatabase {
		private var m_pMainfest:Array; // [tableName, clazz] ; 需要传入clazz是因为ClassTool.getClassByName虽然可以获得类, 但必须先引用类
		public function CDatabaseSystem(mainfest:Array){
			m_pMainfest = mainfest;
			m_isLoadCompleted = false;
			m_pDatabase = new Object();
		}

		public override function destroy() : void {
			super.destroy();

		}

		private var m_bIntialized:Boolean = false;
		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();

			if (!m_bIntialized) {
				loadConfigFile();
				m_bIntialized = true;
			}

			return isReady;
		}

		private function loadConfigFile() : void {
			var tableName:String;
			var tableClazz:Class;

			for (var i:int = 0; i < m_pMainfest.length; i++) {
				tableName = m_pMainfest[i][0];
				tableClazz = m_pMainfest[i][1]
				_loadConfigData(tableName, tableClazz);
			}
		}

		private function _loadConfigData(tableName:String, tableClazz:Class) : void {
			if (!tableName || tableName.length == 0) {
				return ;
			}
		
			var url:String = CPathUtils.getTablePath(tableName);
			Laya.loader.load(url, Handler.create(this, _onFinished, [url, tableName, tableClazz]), null, Loader.JSON);

		}
		private function _onFinished(url:String, tableName:String, clazz:Class) : void {
			var jsonObj:Object = Loader.getRes(url);
			var pTable:CDataTable;
			pTable = new CDataTable(tableName);
			if (m_pDatabase.hasOwnProperty(tableName)) {
				throw new Error("table " + tableName + " is exist");
			}

			m_pDatabase[tableName] = pTable;

			var recordMap:Object = new Object();
			var KEY:String = pTable.primaryKey;
			var keyValue:*;
			var jsonObjList:Array = jsonObj as Array;
			for (var i:int = 0; i < jsonObjList.length; i++) {
				var itemObject:Object = jsonObjList[i];
				keyValue = itemObject[KEY];
				recordMap[keyValue] = new clazz(itemObject);
			}
			pTable.initWithMap(recordMap);

			m_loadedCount++;
			if (m_loadedCount >= m_pMainfest.length) {
				m_isLoadCompleted = true;
				
			}
		}

		public function getTable(sTableName:String) : IDataTable {
			var ret:* = m_pDatabase[sTableName];
			if (ret == undefined) {
				return null;
			}
			return ret;
		}

		public function get isReady() : Boolean {
			return m_isLoadCompleted;
		}

		private var m_isLoadCompleted:Boolean;
		private var m_pDatabase:Object;
		private var m_loadedCount:int;

	}

}