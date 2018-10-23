namespace VL {
    export namespace Resource {
        export class EgretResManager {

            private tempGroupBaseName: string;
            private tempGroupIdx: number = 0;

            private currTask: EgretLoadTask;

            private taskCanceled: boolean = false;

            private taskReporter: RES.PromiseTaskReporter;

            private readonly loadTaskQueue: EgretLoadTask[];

            constructor(tempGroupBaseName: string = "tempLoadTask") {
                this.tempGroupBaseName = tempGroupBaseName;
                this.loadTaskQueue = [];

                this.taskReporter = {onProgress: this.onProgress.bind(this), onCancel: this.onCancel.bind(this)};
            }

            public async loadConfig(url: string, resourceRoot: string): Promise<void> {
                return RES.loadConfig(url, resourceRoot);
            }

            public loadResTask(loadTask: EgretLoadTask) {
                let groupName = this.tempGroupBaseName + this.tempGroupIdx;
                loadTask.taskName = loadTask.taskName || groupName;

                this.loadTaskQueue.push(loadTask);
                this.loadNextTask();
            }

            private async loadNextTask() {
                if (this.isRunningTask) {
                    return;
                }
                let task = this.loadTaskQueue.shift();
                if (!task) {
                    return;
                }
                this.currTask = task;
                let keys = task.keys,
                    taskName = task.taskName;

                let groupName = this.tempGroupBaseName + this.tempGroupIdx++;
                taskName = taskName || groupName;

                if (keys && keys.length > 0) {
                    if (RES.createGroup(groupName, keys, true)) {
                        app.log(`加载任务 taskName:${taskName}  keys:${keys}`);
                        await RES.loadGroup(groupName, 0, this.taskReporter);
                        this.onTaskOver();
                    } else {
                        app.warn(`资源组创建失败 taskName:${taskName},  keys:${keys}`);
                        this.onCancel();
                        this.onTaskOver();
                    }
                } else {
                    this.onTaskOver();
                }
            }

            private onTaskOver() {
                let task = this.currTask;
                this.currTask = null;
                if (this.taskCanceled) {
                    this.taskCanceled = false;
                    if (task.onCancel) {
                        app.warn(`加载任务被取消 taskName:${task.taskName}`);
                        task.onCancel(task);
                    }
                } else {
                    if (task.onComplete) {
                        app.log(`加载任务结束 taskName:${task.taskName}`);
                        task.onComplete(task);
                    }
                }

                this.loadNextTask();
            }

            /**
             * 进度回调
             */
            private onProgress(current: number, total: number): void {
                let task = this.currTask;
                app.log(current + ' / ' + total);
                if (task.onProgress) {
                    task.onProgress(task, current, total);
                }

            }

            /**
             * 取消回调
             */
            private onCancel(): void {
                this.taskCanceled = true;
            }


            public getRes(key: string): any {
                return RES.getRes(key);
            }

            public async getResAsync_promise(key: string): Promise<any> {
                return RES.getResAsync(key);
            }

            public getResAsync_callback(key: string, compFunc: (value?: any, key?: string) => void, thisObject: any): void {
                return RES.getResAsync(key, compFunc, thisObject);
            }

            public async destroyRes(name: string, force: boolean = true): Promise<boolean> {
                return !RES.getRes(name) || RES.destroyRes(name, force);
            }

            public destroyReses(names: string[], force: boolean = true) {
                for (let i = 0, l = names.length; i < l; i++) {
                    this.destroyRes(names[i], force);
                }
            }

            /**
             * 根据URL加载资源
             * @param url 资源URL
             * @param dataFormat 可用 egret.URLLoaderDataFormat 里的成员
             *  控制是以文本 (URLLoaderDataFormat.TEXT)、原始二进制数据 (URLLoaderDataFormat.BINARY) 还是 URL 编码变量 (URLLoaderDataFormat.VARIABLES) 接收下载的数据。
             如果 dataFormat 属性的值是 URLLoaderDataFormat.TEXT，则所接收的数据是一个包含已加载文件文本的字符串。
             如果 dataFormat 属性的值是 URLLoaderDataFormat.BINARY，则所接收的数据是一个包含原始二进制数据的 ByteArray 对象。
             如果 dataFormat 属性的值是 URLLoaderDataFormat.TEXTURE，则所接收的数据是一个包含位图数据的Texture对象。
             如果 dataFormat 属性的值是 URLLoaderDataFormat.VARIABLES，则所接收的数据是一个包含 URL 编码变量的 URLVariables 对象。
             */
            public async loadResByURL<RES_TYPE = any>(url: string, dataFormat: string = egret.URLLoaderDataFormat.TEXTURE): Promise<RES_TYPE> {
                return new Promise<RES_TYPE>((resolve, reject) => {
                    let urlReq = new egret.URLRequest(url);
                    let loader = new egret.URLLoader(urlReq);
                    loader.dataFormat = dataFormat;
                    loader.once(egret.Event.COMPLETE, function (e: egret.Event) {
                        resolve(e.data);
                    }, this);
                    loader.once(egret.IOErrorEvent.IO_ERROR, function (e: egret.IOErrorEvent) {
                        reject(e.data);
                    }, this);
                });
            }


            public get isRunningTask(): boolean {
                return !!this.currTask;
            }

        }
    }
}