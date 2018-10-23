namespace VoyaMVC {
    export class Msg<VO = undefined> extends VL.ObjectCache.CacheableClass implements VoyaMVC.IMsg {
        
        private _body: VO;
        
        public init(vo : VO = undefined): Msg<VO> {
            if(vo != null && vo != undefined){
                this._body = vo;
            }
            return this;
        }
        // public restore(maxCacheCount: number = 1) {
        //     super.restore(maxCacheCount);
        // }
        public get body(): VO {
            return this._body;
        }

        public clear() {
            this._body = null;
        }
    }
}
