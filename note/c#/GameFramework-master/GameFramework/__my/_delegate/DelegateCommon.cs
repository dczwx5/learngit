using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace __my._delegate {
    // =====================================================================================

    public class DelegateCommon {

        public DelegateCommon() {
        }

        public void TestChangeData() {
            m_iValue += 25;
            EventProcess();
        }

        private void EventProcess() {
            DelegateEventData e = new DelegateEventData(this, "dataChangeEvent", m_iValue);
            DataEvent(e);
        }

        public void AddDataEventListener(DataEventHandler handler) {
            if (handler != null) {
                DataEvent += handler;
            }
        }
        public void RemoveDataEventListener(DataEventHandler handler) {
            if (handler != null) {
                DataEvent -= handler;
            }
        }

        private int m_iValue;

        public event DataEventHandler DataEvent;
        public delegate void DataEventHandler(DelegateEventData e);
    }

    // ============================测试实例=========================================
    public class DelegateCommonTest {
        public static void Usage() {
            DelegateCommon d = new DelegateCommon();
            d.AddDataEventListener(OnDelegateDataChangeTestA);
            d.AddDataEventListener(OnDelegateDataChangeTestB);

            d.TestChangeData();
            d.TestChangeData();
            d.TestChangeData();
        }
        public static void OnDelegateDataChangeTestA(DelegateEventData e) {
            my.Trace("OnDelegateDataChangeTestA");
            my.Trace(e.data);
        }
        public static void OnDelegateDataChangeTestB(DelegateEventData e) {
            my.Trace("OnDelegateDataChangeTestB");
            my.Trace(e.data);
        }
    }
}
