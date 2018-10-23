class LogUtil{
    private static readonly enableLog:boolean = true;

    public static log(message?: any, ...optionalParams: any[]){
        if(this.enableLog){
            console.log("== OpenDataContext log == :" , message, ...optionalParams);
        }
    }

    public static warn(message?: any, ...optionalParams: any[]){
        if(this.enableLog){
            console.warn("== OpenDataContext log == :" , message, ...optionalParams);
        }
    }
}
