//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Created by tDAN 2016/1/29
//----------------------------------------------------------------------------------------------------------------------

package QFLib.Foundation
{

import QFLib.Utils.CDateUtil;

import flash.utils.getTimer;

    //
    //
    //
    public class CTime
    {
        // Get time since the epoch and time since the VM was started
        public static var startDate : Date = new Date();
        public static var startTime : Number = startDate.time;
        public static const startTimestamp : uint = getTimer();
        public static const ONE_DAY_MILLISECOND:int = 24*3600*1000;

        public static var loginServerTimestamp:Number;// 登陆时服务器发过来的额时间戳
        public static var timeFromFlashStart:int;// VM启动至登陆所经过的时间

        public static var serverOpenTimestamp:Number;// 开服日期时间戳
        public static var serverOpenDayNum:int;// 开服天数
        public static var timeZone:int;// 时区

        public static function getTimeElapsedSinceStartUp() : Number
        {
            return ( getTimer() - startTimestamp ) / 1000.0;
        }

        public static function getCurrentTimestamp() : Number
        {
            return startTime + (getTimer() - startTimestamp);
        }

        /**
         * 得服务器当前时间戳
         * @return
         */
        public static function getCurrServerTimestamp():Number
        {
            return loginServerTimestamp + (getTimer() - timeFromFlashStart);
        }

        public static function getStartTimeString() : String
        {
            return getTimeString( startTime );
        }
        public static function getCurrentTimeString() : String
        {
            return getTimeString( getCurrentTimestamp() );
        }

        public static function getTimeString( timestamp : Number ) : String
        {
            var i : int;

            m_theDate.setTime( timestamp );

            var sDateTime : String = m_theDate.fullYear.toString();
            sDateTime += "-";

            i = m_theDate.month + 1;
            if( i < 10 ) sDateTime += "0";
            sDateTime += i.toString();
            sDateTime += "-";

            i = m_theDate.date;
            if( i < 10 ) sDateTime += "0";
            sDateTime += i.toString();
            sDateTime += " ";

            i = m_theDate.hours;
            if( i < 10 ) sDateTime += "0";
            sDateTime += i.toString( );
            sDateTime += ":";

            i = m_theDate.minutes;
            if( i < 10 ) sDateTime += "0";
            sDateTime += i.toString();
            sDateTime += ":";

            i = m_theDate.seconds;
            if( i < 10 ) sDateTime += "0";
            sDateTime +=i.toString();
            sDateTime += " ";
            


            
            return sDateTime;
        }

        /**
         * 将时间长度转换为字符串
         * @param date	日期
         * @return 转换完毕的字符串
         */
        public static function toDurTimeString(time:Number) : String {
            time /= 1000;
            var s:int = time % 60;
            time /= 60;
            var m:int = time % 60;
            time /= 60;
            var h:int = time;
            return fillZeros(h.toString(),2) + ":" + fillZeros(m.toString(),2) + ":" + fillZeros(s.toString(),2);
        }
        public static function toDurTimeString2(time:Number) : String {
            time /= 1000;
            var s:int = time % 60;
            time /= 60;
            var m:int = time % 60;
            time /= 60;
            var h:int = time;
            return  fillZeros(m.toString(),2) + ":" + fillZeros(s.toString(),2);
        }
        /**
         * 将数字用0补足长度
         */
        public static function fillZeros(str:String, len:int, flag:String = "0"):String {
            while (str.length < len) {
                str = flag + str;
            }
            return str;
        }

        // time1/time2 : millisecond time
        public static function dateSub(time1:Number, time2:Number) : Number {
            m_theDate.setTime( time1 );
            m_theDataBuf.setTime( time2 );

            var subMillisecond : Number = Math.abs(time2 - time1);
            var subDate : Number;
            if ( subMillisecond > ONE_DAY_MILLISECOND ) {
                subDate = subMillisecond / ONE_DAY_MILLISECOND;
            } else {
                if (m_theDataBuf.date == m_theDate.date) {
                    subDate = 0;
                } else {
                    subDate = 1; // 9.1 - 8.31 会有问题
                }
            }
            return subDate;
        }

        /**
         * 格式（小时：分钟：秒）18:00:00
         */
        public static function formatHMSStr( time:Number ) : String {
            m_theDate.setTime( time );
            return fillZeros(m_theDate.hours.toString(),2) + ":" + fillZeros(m_theDate.minutes.toString(),2) + ":" + fillZeros(m_theDate.seconds.toString(),2);
        }

        /**
         * 格式（年/月/日）2017/5/12
         */
        public static function formatYMDStr( time:Number ):String {
            m_theDate.setTime( time );
            return m_theDate.fullYear + "/" + (m_theDate.month+1) + "/" + m_theDate.date;
        }

        private static var m_theDate : Date = new Date();
        private static var m_theDataBuf : Date = new Date();

        public static function setServerOpenTimeInfo(value:Number):void
        {
            serverOpenTimestamp = value;
            var zeroDate:Date = new Date(value);
            CDateUtil.setZeroDate(zeroDate);
            serverOpenDayNum = Math.ceil((getCurrServerTimestamp() - zeroDate.time) / (1000*3600*24));
        }
    }



}