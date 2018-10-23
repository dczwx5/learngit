namespace App{
    export class EasyLoadingManager {

        private loadingPanel:EasyLoadingPanel;
    
        private _caseIDSeed:number = 0;
    
        private getNewCaseID():string{
            if(this._caseIDSeed >= 1000000){
                this._caseIDSeed = 0;
            }
            return "" + this._caseIDSeed++;
        }

        private loadingCaseList:string[];
    
        constructor(){
            this.loadingCaseList = [];
            this.loadingPanel = new EasyLoadingPanel();
        }
    
        /**
         * 增加一个需要显示loading的事务
         * @param [caseId] 
         * @param [text] 
         * @returns {string} 返回事务ID
         */
        public add(caseId:string = null, text:string = null):string{
            let caseID = caseId || this.getNewCaseID();
            this.loadingCaseList.push(caseID);
            if(!this.isShow){
                this.show(text);
            }
            return caseID;
        }
    
        /**
         * 根据事物ID移除一个显示loading的事物，如果没有其他需要显示loading的事物就关闭loading
         * @param caseID
         */
        public remove(caseID:string){
            let idx = this.loadingCaseList.indexOf(caseID);
            if(idx == -1){
                return;
            }
            this.loadingCaseList.splice(idx, 1);
            if(this.loadingCaseList.length <= 0){
                this.hide();
            }
        }
    
        /**
         * 关闭loading并清空所有case
         */
        public clear(){
            this.loadingCaseList.length = 0;
            this.hide();
        }
    
        private show(text:string = null){
            this.loadingPanel.show(GameLayers.UI_Top, text);
        }
        private hide(){
            this.loadingPanel.hide();
        }
    
        /**
         * 是否在展示中
         * @returns {boolean}
         */
        public get isShow(){
            return this.loadingPanel.isShow;
        }
    }
}

// window['EasyLoadingManager']=EasyLoadingManager;
