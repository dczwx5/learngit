class ContextEventDispatcher implements IEventDispatcher{
    private static readonly eventDispatcher:egret.EventDispatcher = new egret.EventDispatcher();

    addEventListener(type: string, listener: Function, thisObject: any, useCapture?: boolean, priority?: number): void {
        ContextEventDispatcher.eventDispatcher.addEventListener(type, listener, thisObject, useCapture, priority);
    }

    once(type: string, listener: Function, thisObject: any, useCapture?: boolean, priority?: number): void {
        ContextEventDispatcher.eventDispatcher.once(type, listener, thisObject, useCapture, priority);
    }

    removeEventListener(type: string, listener: Function, thisObject: any, useCapture?: boolean): void {
        ContextEventDispatcher.eventDispatcher.removeEventListener(type, listener, thisObject, useCapture);
    }

    hasEventListener(type: string): boolean {
        return ContextEventDispatcher.eventDispatcher.hasEventListener(type);
    }

    dispatchEvent(event: egret.Event): boolean {
        return ContextEventDispatcher.eventDispatcher.dispatchEvent(event);
    }

    willTrigger(type: string): boolean {
        return ContextEventDispatcher.eventDispatcher.willTrigger(type);
    }
}