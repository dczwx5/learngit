export module FuncUtil {
    /**
     * 在给定的最大值和最小值之间随机选出一个数字
     * @param min 
     * @param max 
     */
    export function Rondom(min: number, max: number): number {
        return (((Math.random() * (max - min + 1)) + min) >> 0);
    }

    // object对象浅复制
    export function shallowCopy<T>(obj:any, cls: new()=>T) : T {
        let ret:any = new cls();
        for (let key in obj) {
            ret[key] = obj[key];
        }
        return ret;
    }

    // object转成string, 目前只支持第一层
    export function objToString(obj:any) : string {
        let ret:string = '';
        if (_isArray(obj)) {
            // 数组
            ret = _arrayToString(obj);
        } else {
            ret = _objToString(obj);
        }
        return ret;
    }
    function _objToString(obj:any) : string {
        let ret:string = '{';
        let item;
        let type:string;
        for (let key in obj) {
            item = obj[key];
            type = typeof item;
            if ('string' == type || 'number' == type || 'boolean' == type) {
                ret += key + ":" + obj[key] + ',';
            } else if (_isArray(item)){
                ret += _arrayToString(item);
            } else {
                ret += _objToString(item);
            }
        }
        ret += '},';
        return ret;
    }
    function _arrayToString(obj:any) : string {
        let ret:string = '[';
        let item;
        let type:string;
        for (let key in obj) {
            item = obj[key];
            type = typeof item;
            if ('string' == type || 'number' == type || 'boolean' == type) {
                ret += key + ":" + obj[key] + ',';
            } else if (_isArray(item)){
                ret += _arrayToString(item);
            } else {
                ret += _objToString(item);
            }
        }
        ret += '],';
        return ret;
    } 
    function _isArray(obj:any) : boolean {
        return obj.hasOwnProperty('length');
    }

    // 数字转为千位表示 12345.11 => 12,345.11
    export function numToKStr(value:number, fixed:number) : string {
		let str:string = value.toFixed(fixed);
		let dotIndex:number = str.indexOf('.');
		let dotStr:string; // 小数点部分
		let numStr:string; // 数字部分
		if (-1 != dotIndex) {
			dotStr = str.substr(dotIndex);
			numStr = str.substring(0, dotIndex);
		} else {
			numStr = str;
		}
		// 
		let moveStep:number = 0;
		let arr = [];
		for (let index:number = numStr.length-1; index >= 0; --index) {
			if (moveStep >= 3) {
				moveStep = 1;
				arr.unshift(',');
				
			} else {
				moveStep++;  
			}
			arr.unshift(numStr.charAt(index));
			
		}
		let ret = arr.join(''); // arr.toString();
		if (dotStr) {
			// 加上这部分
			ret += dotStr;
		}

		return ret;
    }
    
    // 省略字符串 xxxxxxxxxxxx => xxxxx...
    export function toOmitString(str:string, showCharCount:number, omitFlag:string = '...') : string {
        if (!str || str.length < showCharCount) {
            return str;
        }
        let ret:string;
        let len = str.length; 
        let showLen = Math.min(len, showCharCount);
        ret = str.substr(0, showLen);
        ret += omitFlag;
        return ret;
    }
    export function toOmitStringFront(str:string, showCharCount:number, omitFlag:string = '...') : string { 
        if (!str || str.length < showCharCount) {
            return str;
        }
        let ret:string;
    
        let len = str.length;
        let showLen = Math.min(len, showCharCount);
        if (showLen < len) {
            let startIndex = len - showLen;
            ret = str.substr(startIndex, showLen);
            ret = omitFlag + ret;
        } else {
            ret = str;
        }
        return ret;
    }
}