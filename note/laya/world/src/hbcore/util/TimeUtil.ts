export class TimeUtil {
    // let nowdate:Date = new Date(); 
    // //创建新的日期对象，用来获取现在的时间 
    // let year:Number = nowdate.getFullYear(); 
    // //获取当前的年份 
    
    // let month:Number = nowdate.getMonth()+1; 
    // //获取当前的月份，因为数组从0开始用0-11表示1-12月，所以要加1 
    
    // let date:Number = nowdate.getDate(); 
    // //获取当前日期 
    
    // let day:Number = nowdate.getDay(); 
    // //获取当年的星期 
   
    // let hour:Number = nowdate.getHours(); 
    // //获取当前小时 
    
    // let minute:Number = nowdate.getMinutes(); 
    // //获取当前的分钟 
    // let second:Number = nowdate.getSeconds(); 
    // //获取当前的秒钟 
    static getCurY_M_D_H_M_S() : string {
        let ret:string = TimeUtil.getY_M_D_H_M_S(TimeUtil.curTimer);
        return ret;
    }
    static getY_M_D_H_M_S(time:number) : string {
        let ymd:string = TimeUtil.getY_M_D(time);
        let hms:string = TimeUtil.getH_M_S(time);
        
        return ymd + " " + hms;
    }
    static getCurY_M_D() : string {
        let ret:string = TimeUtil.getY_M_D(TimeUtil.curTimer);
        return ret;
    }
    static getY_M_D(timer:number) : string {
        let pDate = TimeUtil.date;
        pDate.setTime(timer);
        let ret:string = pDate.getFullYear() + '-' + (pDate.getMonth()+1) + '-' + pDate.getDate();

        return ret;
    }
    static getCurH_M_S() : string {
        let ret:string = TimeUtil.getH_M_S(TimeUtil.curTimer);
        return ret;
    }
    static getH_M_S(timer:number) : string {
        let pDate = TimeUtil.date;
        pDate.setTime(timer);
        let ret:string = pDate.getHours() + ':' + (pDate.getMinutes()) + ':' + pDate.getSeconds();
        return ret;
    }

    // 判断
    // d1 : 时间cuo.  如果laya.timer.curtime;
    // 比较d1与d2的年月日, 如果d1>=d2, return true;
    static date1BigEqualDate2ByYmd(d1:number, d2:number) : boolean {
        let date:Date = TimeUtil.date;
        date.setTime(d1);
        date.setHours(0);
        date.setMinutes(0);
        date.setSeconds(0);
        date.setMilliseconds(0);
        let d1Timer:number = date.getTime();

        date.setTime(d2);
        date.setHours(0);
        date.setMinutes(0);
        date.setSeconds(0);
        date.setMilliseconds(0);
        let d2Timer:number = date.getTime();
        let isOk:boolean = d1Timer >= d2Timer;
        return isOk;
    }

    static get curTimer():number{
        return Laya.timer.currTimer;
    }

    static get date() : Date {
        if (TimeUtil.s_date == null) {
            TimeUtil.s_date = new Date();
        }
        return TimeUtil.s_date;
    }
    
    static getCurDate() : Date {
        let d = TimeUtil.date;
        d.setTime(TimeUtil.curTimer);
        return d;
    }
    static getDate(year:number, month:number, date:number) : Date {
        let d = TimeUtil.date;
        d.setFullYear(year);
        d.setMonth(month);
        d.setDate(date);
        return d;
    }
    private static s_date:Date;
}
