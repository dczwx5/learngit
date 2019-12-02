/// <reference path="../CGameFrameWork.ts" />
namespace gameframework {
	export namespace log {
/**
 * ...
 * @author
 */
export class CLog{
	public static log(msg:string, ...args) : void {
		if (!framework.CAppStage.DEBUG) return ;
		
		if (args && args.length > 0) {
			for (let i:number = 0; i < args.length; i++) {
				let matchString:string = "{" + i + "}";
				let index:number = msg.indexOf(matchString);
				if (index == -1) {
					msg += args[i];
				} else {
					msg = msg.replace("{" + i + "}", args[i]);
				}
				
			}
		}
		console.log(msg);
	}
}
}
}