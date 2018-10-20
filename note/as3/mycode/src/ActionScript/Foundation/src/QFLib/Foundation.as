//----------------------------------------------------------------------------------------------------------------------
// (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by tDAN 2016/1/29
//----------------------------------------------------------------------------------------------------------------------

package QFLib
{
    import QFLib.Foundation.CLog;
    import QFLib.Foundation.CPerformanceCounter;

    public class Foundation
    {
        public static var Log : CLog = new CLog(); // global logger for all, however user can still create their personal log by new another CLog
        public static var Perf : CPerformanceCounter = new CPerformanceCounter();

    }

}
