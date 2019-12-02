import CHotUpdate from "./CHotUpdate";

const {ccclass, property} = cc._decorator;

@ccclass
export default class Helloworld extends cc.Component {

    @property(cc.Label)
    version: cc.Label = null;


    start () {
        let hot = this.getComponent(CHotUpdate);
        hot.checkUpdateHandler = this.checkUpdateHandler;
        hot.hotUpdateHandler = this.hotUpdateHandler;
        hot.processHandler = this.processHandler;
        hot.checkUpdate();
    }

    checkUpdateHandler(sucess:boolean, hasNew, msg:string) {
        console.log('检测更新结束 : suess : ' + sucess + ' new ? ' + hasNew);
        if (sucess && hasNew) {
            let hot = this.getComponent(CHotUpdate);
            hot.hotUpdate();
        }
    }
    hotUpdateHandler(sucess:boolean, msg:string){
        console.log('热更新完成， ', sucess);
    }
    processHandler(byteProgress:number, loadedByte:number, totalByte:number, fileProgress:number, downloadedFiles:number, totalFiles:number) {
        console.log('更新进度 ');
    }

}
