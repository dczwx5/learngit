namespace VoyaMVC{
    export abstract class MvcConfigBase implements IMvcConfig{
        private _mediatorList: IMediator[];
        private _handlerList: IController[];

        protected abstract getMediatorList():IMediator[];
        protected abstract getControllerList():IController[];

        public get mediatorList(): VoyaMVC.IMediator[] {
            if(!this._mediatorList){
                this._mediatorList = this.getMediatorList();
            }
            return this._mediatorList;
        }

        public get handlerList(): VoyaMVC.IController[] {
            if(!this._handlerList){
                this._handlerList = this.getControllerList();
            }
            return this._handlerList;
        }
    }
}