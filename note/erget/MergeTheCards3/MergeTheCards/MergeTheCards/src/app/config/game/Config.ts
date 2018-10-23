namespace App {
    export class Config {

        private s_configs: Object;

        /**
         * 初始化
         * @param data  JSONObject
         */
        // public async init() {
        //     let data = await this.loadConfig();
        //     this.s_configs = {};
        //     for (let key in data) {
        //         let clazz = egret.getDefinitionByName(key);
        //         if (!clazz) {
        //             app.warn(`${name}在ConfigBase文件中未定义`);
        //             continue;
        //         }
        //         let values: any[] = data[key].data;
        //         let size: number = values.length;
        //         let dic = {};
        //         this.s_configs[key] = dic;
        //         for (let i: number = 0; i < size; i++) {
        //             let config = new clazz();
        //             let attrs: string[] = config.attrs();
        //             let value: any[] = values[i];
        //             for (let j: number = 0, jLen: number = attrs.length; j < jLen; j++) {
        //                 config[attrs[j]] = value[j];
        //             }
        //             dic[config[attrs[0]]] = config;
        //         }
        //     }
        //
        // }

        /**
         * 初始化
         */
        public async init() {
            let data:Array<{name:string,data:Array<any>}> = await this.loadConfig();
            this.s_configs = {};
            data.map((item:{name:string,data:Array<any>}) => {
                let clazz = egret.getDefinitionByName(item.name);
                if (!clazz) {
                    egret.log(`${name}在ConfigBase文件中未定义`);
                } else {
                    let values:Array<any> = item.data;
                    let size: number = values.length;
                    let dic = {};
                    this.s_configs[item.name] = dic;
                    for (let i: number = 0; i < size; i++) {
                        let config = new clazz();
                        let attrs: string[] = config.attrs();
                        let value: any[] = values[i];
                        for (let j: number = 0, jLen: number = attrs.length; j < jLen; j++) {
                            config[attrs[j]] = value[j];
                        }
                        dic[config[attrs[0]]] =  config;
                    }
                }
            });
        }

        private async loadConfig(){
            return await RES.getResAsync(`config_json`);
        }

        /**
         * 获取配置文件
         * 示例：let configs:Dictionary<HeadConfig> = Config.getConfig(HeadConfig);
         * let configs:Dictionary<HeadConfig> = Config.getConfig(HeadConfig);
         * configs.get('1').emojiID;
         */
        // public static getConfig<T extends {attrs():string[]}>(ref: new ()=>T): Dictionary<T> {
        public getConfig<T extends { attrs(): string[] }>(ref: new () => T): { [id: string]: T } {
            let name: string = egret.getQualifiedClassName(ref);
            return this.s_configs[name];
        }
    }
}