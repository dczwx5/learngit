import SingletonError from "../error/SingletonError";
import Handler = Laya.Handler;

/**
 * @author: henrylee
 * 2018/09/28
 */
export class Emitter {
    private listeners = {}

    on(caller: any, name: number | string, func: Function) {
        let handlers: Handler[] = this.listeners[name];
        //检查是否有同类型的侦听器组
        if (null == handlers) {
            this.listeners[name] = [];
        } else {
            //检查是否同一个caller已经注册过同类型侦听器
            let n: number = handlers.length;
            while (--n > -1) {
                let handler = handlers[n];
                if (handler.caller === caller) {
                    return;
                }
            }
        }
        this.listeners[name].push(Handler.create(caller, func, null, false));
    }

    off(caller: any, name: number | string) {
        let handlers: Handler[] = this.listeners[name];
        if (!handlers) return;

        //遍历过程中如果有插入和删除操作，会造成逻辑混乱，所以复制一份
        let temp: Handler[] = handlers.concat();
        let n: number = temp.length;
        while (--n > -1) {
            let handler = temp[n];
            if (handler.caller === caller) {
                handler = handlers.splice(n, 1)[0];
                handler.recover();
                break;
            }
        }

        if (handlers.length == 0) {
            delete this.listeners[name];
        }
    }

    offAll() {
        for (const key in this.listeners) {
            if (this.listeners.hasOwnProperty(key)) {
                const handlers: Handler[] = this.listeners[key];
                let n: number = handlers.length;
                while (--n > -1) {
                    let handler = handlers[n];
                    handler.recover();
                }
            }
        }

        this.listeners = {};
    }

    event(name: number | string, param?: any) {
        let handlers: Handler[] = this.listeners[name];
        if (!handlers) 
            return ;
            
        //遍历过程中如果有插入和删除操作，会造成逻辑混乱，所以复制一份
        let temp: Handler[] = handlers.concat();
        let n: number = temp.length;
        if (param == undefined) {
            param = null;
        }
        while (--n > -1) {
            let handler: Handler = temp[n];
            handler.runWith(param);
        }
    }
}