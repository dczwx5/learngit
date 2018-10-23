namespace App {
    export class Logger {
        constructor() {
            this['$log']
                = this['$warn']
                = this['$error']
                = () => {};
        }

        public init() {
            this['$log'] = egret.log;
            this['$warn'] = egret.warn;
            this['$error'] = egret.error;
        }

        log(message?: any, ...optionalParams: any[]): void {
            this['$log'](message, ...optionalParams);
        }

        warn(message?: any, ...optionalParams: any[]): void {
            this['$warn'](message, ...optionalParams);
        }

        error(message?: any, ...optionalParams: any[]): void {
            this['$error'](message, ...optionalParams);
        }
    }
}