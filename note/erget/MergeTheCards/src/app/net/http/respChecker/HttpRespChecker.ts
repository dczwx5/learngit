namespace App{
    export abstract class HttpRespChecker {

        public readonly dg_checkHttpResp: VL.Delegate<VL.Net.IHttpRespCheckResult>;

        constructor() {
            this.dg_checkHttpResp = new VL.Delegate<VL.Net.IHttpRespCheckResult>();
        }

        /**
         * 这个是HTTP业务逻辑层的错误，一般由后端返回错误码
         */
        check(packData: any): VL.Net.IHttpRespCheckResult {
            // let checkResult: VL.Net.IHttpRespCheckResult = {pass: true};
            let checkResult: VL.Net.IHttpRespCheckResult = this.onCheck(packData);
            this.dg_checkHttpResp.boardcast(checkResult);
            return checkResult;
        }

        protected abstract onCheck(packData: any):VL.Net.IHttpRespCheckResult;
    }

}
