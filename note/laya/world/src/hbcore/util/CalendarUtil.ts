import Lang from "../framework/Lang";

export class CalendarUtil { 
    // month以1开始
    static reduceDateFun(year:number, month:number) : any {
        ++month;

        let isOk:boolean = true;
        if (month - 1 > 0) {
            month -= 1;
        } else {
            if (year - 1 > 1980) {
                year -= 1;
                month = 12;
            } else {
                isOk = false;
            }
        }

        --month;
        return new CalendarData(year, month, 0, 0, isOk);
        
    }

    static addDateFun(year:number, month:number) : any {
        ++month;

        if (month + 1 < 13) {
            month += 1
        } else {
            year += 1;
            month = 1
        }
        
        --month;

        return new CalendarData(year, month, 0, 0);
    }
    static getTimeDataFun(year:number, month:number) : CalendarData {
        ++month;

        let temp: Date = CalendarUtil.date;
        temp.setFullYear(year); // new Date(year, month, 0);
        temp.setMonth(month);
        temp.setDate(0);

        let date: number = temp.getDate()
        temp.setDate(1)
        let day: number = temp.getDay()
        let bol: boolean = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
        if (bol) {
            if (month == 2) {
                date = 29;
            }
        } else {
            if (month == 2) {
                date = 28;
            }
        }

        --month;
        return new CalendarData(year, month, date, day);
    }

    static getUpYearMonth(year:number, month:number): CalendarData {
        ++month;

        let upYear: number = 0;
        let upMonth: number = 0
        if (month == 1) {
            upYear = year - 1
            upMonth = 12;
        } else {
            upYear = year;
            upMonth = month - 1;
        }

        --upMonth;
        return new CalendarData(upYear, upMonth, 0, 0);
        
    }
    static getNextYearMonth(year:number, month:number): CalendarData {
        ++month;

        let downYear: number = 0;
        let downMonth: number = 0
        if (month == 12) {
            downYear = year + 1
            downMonth = 1;
        } else {
            downYear = year;
            downMonth = month + 1;
        }

        --downMonth;
        return new CalendarData(downYear, downMonth, 0, 0);
    }

    static get date() : Date {
        if (!CalendarUtil.m_date) {
            CalendarUtil.m_date = new Date();
        }
        return CalendarUtil.m_date;
    }

    // year : 1开始
    static getYearName(year:number) : string {
        return Lang.Get('year_name', {v1:year});
    }
    // month : 0开始
    static getMonthName(month:number) : string {
        month++;
        return Lang.Get('month_name', {v1:month});
    }
    // date : 1开始
    static getDateName(date:number) : string {
        return Lang.Get('date_name', {v1:date});
    }
    static m_date:Date;
}

export class CalendarData {
    constructor(y:number, m:number, date:number, day:number, isOk:boolean = true) {
        this.year = y;
        this.month = m;
        this.date = date;
        this.day = day;
        this.isOk = isOk;
    }
    year:number = 0;
    month:number = 0; // start 0
    date:number = 0; // 1-31
    day:number = 0; // 星期几
    isOk:boolean = true;
}