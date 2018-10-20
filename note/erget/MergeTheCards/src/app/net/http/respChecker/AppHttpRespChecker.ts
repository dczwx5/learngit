namespace App {
    export class AppHttpRespChecker extends HttpRespChecker {

        protected onCheck(packData: {code:number, msg?:string}): VL.Net.IHttpRespCheckResult {
            if(packData.code != 1){
                app.warn(`====== http resp exception =======  code:${packData.code}  msg:${packData.msg}` );
            }
            return {pass: true};
        }

    }
}