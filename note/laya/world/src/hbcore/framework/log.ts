import { config } from "./config";
import { FuncUtil } from "../util/FuncUtil";

export module log {
/**
 * ...
 * @author
 */
	export function log(msg:string, ...args) : void {
		if (!config.DEBUG) return ;
		
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
	export function logObj(msg:string, obj:any, other:string = null) : void {
		if (!config.DEBUG) return ;
		if (other && other.length > 0) {
			log(msg, JSON.stringify(obj), other);
		} else {
			log(msg, JSON.stringify(obj));
		}
	}
}