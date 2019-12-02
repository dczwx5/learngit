import { gameframework } from "../../gameframework";
import { IUpdate } from "../interface/IUpdate";

export module ecs {
    export class CGameObject {
        get isRunning() : boolean { return true; }
        getComponentByClass(clz:any, isCache:boolean) {
            return null;
        }
    }
    export interface IGameSystemHandler {
        isComponentSupported(obj:CGameObject) : boolean;
        beforeTick(delta:number) : void;
        tickValidate(delta:number, obj:CGameObject) : boolean;
        tickUpdate(delta:number, obj:CGameObject);
        afterTick(delta:number);
    }
    export interface IGameComponent {

    }
    export class CGameComponent {
        
    }
    export class CGameSystemHandler extends gameframework.framework.CBean implements IGameSystemHandler {
        private m_listSupportedComponentClass : Array<any>; // class
        private m_bEnabled : boolean;
    
        constructor(... comps) {
            super();
            this.m_listSupportedComponentClass = [];
    
            for (let cls of comps) {
                if (cls)
                    this.m_listSupportedComponentClass.push( cls );
            }
    
            this.m_bEnabled = true;
        }
    
        isComponentClassSupported(clz:any) : Boolean {
            if (!(clz instanceof CGameComponent))
                return false;
            let iIndex : number = this.m_listSupportedComponentClass.indexOf( clz );
            return iIndex != -1;
        }
    
        isComponentSupported(obj:CGameObject) : boolean {
            if ( !this.m_listSupportedComponentClass || this.m_listSupportedComponentClass.length == 0 )
                return true;
            else {
                let supported : boolean = true;
                for (let clz of this.m_listSupportedComponentClass ) {
                    let comp : IGameComponent = obj.getComponentByClass( clz, true );
                    if ( !comp ) {
                        supported = false;
                        break;
                    }
                }
    
                return supported;
            }
        }
    
        get enabled() : boolean {
            return this.m_bEnabled;
        }
    
        set enabled( value : boolean ) {
            this.m_bEnabled = value;
            this.onEnabled( value );
        }
    
        protected onEnabled( value : Boolean ) : void {
            
        }
    
        beforeTick( delta : number ) : void {
        }
    
        tickValidate( delta : number, obj : CGameObject ) : boolean {
            return this.enabled;
        }
    
        tickUpdate( delta : number, obj : CGameObject ) : void {
        }
    
        afterTick( delta : number ) : void {
        }
    
    }
    export class CECS extends gameframework.framework.CAppSystem {
        private m_listHandler:Array<IGameSystemHandler>;
        private m_listUpdatedHandler:Array<IGameSystemHandler>;

        constructor() {
            super();

            this.m_listHandler = [];
            this.m_listUpdatedHandler = [];
        }

        onDestroy() {
            super.onDestroy();
        }

        tickUpdate(delta:number, obj:CGameObject) : void {
            if ( !obj )
                return;
    
            const listUpdated:Array<IGameSystemHandler> = this.m_listUpdatedHandler;
    
            if (this.m_listHandler.length > this.m_listUpdatedHandler.length)
            this.m_listUpdatedHandler.length = this.m_listHandler.length;
    
            let handler:IGameSystemHandler;
            let idxPush:number = 0;
    
            for (handler of this.m_listHandler) {
                if (handler && handler.isComponentSupported(obj)) {
                    if (handler.tickValidate(delta, obj)) {
                        listUpdated[idxPush++] = handler;
                    }
                }
            }
    
            if (obj.isRunning) {
                for (let i:number = 0; i < idxPush; ++i) {
                    listUpdated[i].tickUpdate(delta, obj);
                }
            }
        }    

        beforeTick(delta:number) : void {
            let handler:IGameSystemHandler;
            for (handler of this.m_listHandler) {
                handler.beforeTick(delta);
            }
        }
    
        afterTick(delta:number) : void {
            let handler:IGameSystemHandler;
            for (handler of this.m_listHandler) {
                handler.afterTick(delta);
            }
        }

        get handlers() : Array<IGameSystemHandler> {
            return this.m_listHandler.slice();
        }

        add(handler:IGameSystemHandler) : void {
            this.m_listHandler.push(handler);
        }

        remove(handler:IGameSystemHandler) : void {
            const index:number = this.m_listHandler.indexOf(handler);
            if (index != -1) {
                this.m_listHandler.splice(index, 1);
            }
        }
    }
}