interface IEventDispatcher{

    addEventListener(type: string, listener: Function, thisObject: any, useCapture?: boolean, priority?: number): void ;

    once(type: string, listener: Function, thisObject: any, useCapture?: boolean, priority?: number): void ;

    removeEventListener(type: string, listener: Function, thisObject: any, useCapture?: boolean): void ;

    hasEventListener(type: string): boolean ;

    dispatchEvent(event: egret.Event): boolean ;

    willTrigger(type: string): boolean ;
}
