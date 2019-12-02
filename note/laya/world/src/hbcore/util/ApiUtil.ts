export module ApiUtil {
// 创建非一次回收的handler
export function createHandler(caller: any, method: Function, args?: Array<any>): Laya.Handler {
    return Laya.Handler.create(caller, method, args, false);
}
export function recoverHandler(handler: Laya.Handler) {
    if (handler) {
        handler.recover();
    }
}

// 获得sp的全局坐标
export function getGlobalPos(sp:Laya.Sprite, pos:Laya.Point = null) : Laya.Point {
    if (!pos) {
        pos = new Laya.Point(sp.x, sp.y);
    }    
    let globalPos = (sp.parent as Laya.Sprite).localToGlobal(pos);
    return globalPos;
}
// 全局坐标转为sp的相对坐标
export function globalToLocal(sp:Laya.Sprite, pos:Laya.Point) : Laya.Point {
    let localPos = (sp.parent as Laya.Sprite).globalToLocal(pos);
    return localPos;
}
// obj1的坐标转到obj2的坐标
// pos != null, 使用pos的坐标, pos为obj1同一对等的坐标系,     pos == null, 使用obj1的坐标
export function obj1ToObj2Pos(obj1:Laya.Sprite, obj2:Laya.Sprite, pos:Laya.Point = null) : Laya.Point {
    if (!pos) {
        pos = new Laya.Point(obj1.x, obj1.y);
    }
    let gPos = getGlobalPos(obj1, pos);
    let localPos = globalToLocal(obj2, gPos);
    return localPos;
}
// strnumber(2.12000) => return 2.12
export function formatStrNumber(strNumber:string) : string {
    let dotIndex:number = strNumber.indexOf('.');
    if (dotIndex == -1) {
        return strNumber;
    }

    let strList = strNumber.split('.');
    let str2 = strList[1];
    let notZeroIndex:number = -1;
    for (let i:number = str2.length-1; i >= 0; --i) {
        if (str2.charAt(i) != '0') {
            notZeroIndex = i;
            break;
        }
    }
    if (notZeroIndex != -1) {
        str2 = str2.substring(0, notZeroIndex+1);
    }
    let ret = strList[0] + '.' + str2;

    return ret;
}
// fix : fix后的值不处理. 因为number会有0.000000000000000x的情况
// v(2.120000000006) => return 2.12
export function formatNumber(v:number, fix:number = 5) : number {
    let cell = Math.ceil(v);
    let floor = Math.floor(v);
    if (Math.abs(v - cell) < 0.000000001) {
        v = cell;
    } else if (Math.abs(v - floor) < 0.000000001){
        v = floor;
    }

    let str = v.toFixed(fix);
	str = formatStrNumber(str);
	let ret = Number(str);
    return ret;
}

// 补齐前面的0, 123 => 000123, len 总长度
export function addZeroToFront(str:string, len:number) {
    if (str.length >= len) {
        return str;
    }

    let addCount:number = len - str.length;
    let addStr:string = '';
    for (let i:number = 0; i < addCount; ++i) {
        addStr += '0';
    }

    let ret = addStr + str;
    return ret;
}

// 拆分一个较大值为一个小值列表, 小值为传入的列表里的index,
// 如 : SplitValueToValueList(80, [10, 20, 50]) => return [50, 20, 10] 
//      => 如果returnType == 1 => return [2, 1, 0], 返回的是索引
// v : 要拆分的值
// baseValueList : 拆分的小值, 把v拆分成baseValueList里面的值, 需要保证baseValueList为升序
// returnType : 0 返回的列表里, value是传入的baseValue的值, 1 : 返回的是index
export function SplitValueToValueList(v:number, baseValueList:Array<number>, returnType:number = 0) : Array<number>{
    let ret:Array<number> = new Array<number>();

    for (let i = baseValueList.                                                         length - 1; i >= 0; --i) {
        let baseValue:number = baseValueList[i];
        let tempFloat = v/baseValue;  
        tempFloat = ApiUtil.formatNumber(tempFloat);
        let tempInt = tempFloat>>0;

        // 除baseValue,大于1, 说明可以拆分为该分值
        if (tempFloat >= 1) {
            // 存放分值
             if (returnType == 0) {
                for (let c:number = 0; c < tempInt; ++c) {
                    ret.push(baseValue);
                }
            } else {
                for (let c:number =    0; c < tempInt; ++c) {
                    ret.push(i);
                }
            }
            
            // 更新v
            v = v % baseValue;
            v = ApiUtil.formatNumber(v);
        }

        // 已拆分完
        if (v <= 0) {
            break;
        }
    }

    return ret;
}
}