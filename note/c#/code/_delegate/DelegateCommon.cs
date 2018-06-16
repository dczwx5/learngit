using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace code._delegate {
    class DelegateCommon {

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

    
}
