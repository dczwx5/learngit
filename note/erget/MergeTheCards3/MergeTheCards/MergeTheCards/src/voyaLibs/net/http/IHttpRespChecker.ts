namespace VL {
    export namespace Net {
        /**
         * 回传的内容检查器
         * */
        export interface IHttpRespChecker {
            /**
             * 检查数据，并返回检查结果是否通过
             */
            check(pack: HttpRespPack): VL.Net.IHttpRespCheckResult;
        }
    }
}