/**
 * Created by MuZi on 2018/5/11.
 */
class DateUtil {
    public today: Date;
    private year: number;
    private Month_a: number;
    private Month: number;
    private day: number;
    private date: number;
    private Monday: Date;
    private Sunday: Date;
    private day_one: Date;

    constructor() {
        let _today = new Date();
        this.today = _today;
        this.year = _today.getFullYear(); //当前年份
        this.Month_a = _today.getMonth();
        this.Month = this.Month_a + 1; //当前月份
        this.date = _today.getDate();   //当前日期
        this.day = _today.getDay() == 0 ? 7 : _today.getDay(); // 本周第几天 因系统会把周日作为第0天
    }

    public newToday(ms: number) {
        this.today = new Date(ms);
        this.year = this.today.getFullYear();//当前年份
        this.Month_a = this.today.getMonth();
        this.Month = this.Month_a + 1;//当前月份
        this.date = this.today.getDate();//当前日期
        this.day = this.today.getDay() == 0 ? 7 : this.today.getDay();//本周第几天 因系统会把周日作为第0天
        this.Monday;
        this.Sunday;
        this.day_one;
    }

    public getMonday(): Date {
        if (this.Monday) {
            return this.Monday;
        } else {
            var _monday = new Date(this.year, this.Month_a, this.date - this.day + 1);
            this.Monday = _monday;
            return _monday;
        }
    }

    public getSunday(): Date {
        if (this.Sunday) {
            return this.Sunday;
        } else {
            var _Sunday = new Date(this.year, this.Month_a, this.date - this.day + 7);
            this.Sunday = _Sunday;
            return _Sunday;
        }
    }

    public getPreviousMonday(Monday) {
        var _monday = new Date(Monday.getYear(), Monday.getMonth(), Monday.getDate() - 7);
        return _monday;
    }

    public getPreviousSunday(Monday) {
        var _Sunday = new Date(Monday.getYear(), Monday.getMonth(), Monday.getDate() - 1);
        this.Sunday = _Sunday;
        return _Sunday;
    }

    public getNextMonday(Monday) {
        var _monday = new Date(Monday.getYear(), Monday.getMonth(), Monday.getDate() + 7);
        return _monday;
    }

    public getNextSunday(Monday) {
        var _Sunday = new Date(Monday.getYear(), Monday.getMonth(), Monday.getDate() + 13);
        this.Sunday = _Sunday;
        return _Sunday;
    }
}

