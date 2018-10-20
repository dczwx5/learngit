    abstract class ViewMediator extends VoyaMVC.Mediator {

        protected abstract view: App.IBaseView;

        protected abstract onViewOpen(...params);
        protected abstract onViewClose();

        protected abstract get viewClass(): new () => App.IBaseView;
        protected abstract get openViewMsg(): new () =>VoyaMVC.IMsg;
        protected abstract get closeViewMsg(): new () =>VoyaMVC.IMsg;

        private easyLoadingCaseId: string;


        activate(...params) {
            this.regMsg(SystemMsg.CloseAllViews, this.onCloseAllViews, this);
            this.regMsg(this.openViewMsg, this.onOpenViewHandler, this);
            this.regMsg(this.closeViewMsg, this.onCloseViewHandler, this);
        }

        deactivate() {
            this.unregMsg(SystemMsg.CloseAllViews, this.onCloseAllViews, this);
            this.unregMsg(this.openViewMsg, this.onOpenViewHandler, this);
            this.unregMsg(this.closeViewMsg, this.onCloseViewHandler, this);
        }

        protected onCloseAllViews(msg:SystemMsg.CloseAllViews){
            this.closeView();
        }

        protected onOpenViewHandler(msg:VoyaMVC.IMsg){
            this.openView(msg.body);
        }
        protected onCloseViewHandler(msg:VoyaMVC.IMsg){
            this.closeView(msg.body);
        }

        protected openView(param:any = null) {
            if (!this.view) {
                this.view = new this.viewClass();
            }
            let view = this.view;

            let onViewInited = ()=>{
                this.view.dg_inited.unregister(onViewInited);
                this.onViewOpen(param);
                app.easyLoadingManager.remove(this.easyLoadingCaseId);
            };

            if (!view.isInited) {
                this.easyLoadingCaseId = app.easyLoadingManager.add(getClassName(this.viewClass));
                view.dg_inited.register(onViewInited, this);
                view.open(param);
            } else {
                view.open(param);
                this.onViewOpen(param);
            }
        }
        // private onViewInited() {
        //     this.view.dg_inited.unregister(this.onViewInited);
        //     this.onViewOpen();
        //     app.easyLoadingManager.remove(this.easyLoadingCaseId);
        // }

        protected closeView(param:any = null) {
            if (this.view && this.view.isOpened) {
                this.onViewClose();
                this.view.close(param);
            }
        }

        protected get isViewInited(): boolean {
            return this.view.isInited;
        }

        protected get viewClassName(): string {
            return getClassName(this.viewClass);
        }
    }