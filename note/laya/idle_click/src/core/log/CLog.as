package core.log
{
	import core.framework.CAppStage;

	/**
	 * ...
	 * @author
	 */
	public class CLog{
		public static function log(msg:String, ...args) : void {
			if (!CAppStage.DEBUG) return ;
			
			if (args && args.length > 0) {
				for (var i:int = 0; i < args.length; i++) {
					var matchString:String = "{" + i + "}";
					var index:int = msg.indexOf(matchString);
					if (index == -1) {
						msg += args[i];
					} else {
						msg = msg.replace("{" + i + "}", args[i]);
					}
					
				}
			}
			trace(msg);
		}
	}

}