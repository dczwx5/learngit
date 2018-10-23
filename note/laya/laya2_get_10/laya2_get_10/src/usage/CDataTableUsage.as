package usage
{
	import a_core.framework.CAppStage;
	import a_core.game.data.CDatabaseSystem;
	import a_core.framework.IDataTable;
	import game.CTableConstant;
	import table.Chapter;

	/**
	 * ...
	 * @author
	 */
	public class CDataTableUsage{
		public function CDataTableUsage(stage:CAppStage){
			var database:CDatabaseSystem = stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
			var pTable:IDataTable = database.getTable(CTableConstant.CHAPTER);
			var list:Array = pTable.toArray();
			for each (var chapterRecord:Chapter in list) {
				trace(chapterRecord.Name + chapterRecord.OpenLevel);
			}
		}
	}

}