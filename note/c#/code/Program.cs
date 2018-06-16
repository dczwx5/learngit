using code._delegate;
using generics.generics;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace code {
    class Program {
        static void Main(string[] args) {
            //  new GenericsCommon();
            DelegateCommon d = new DelegateCommon();
            d.AddDataEventListener(OnDelegateDataChangeTestA);
            d.AddDataEventListener(OnDelegateDataChangeTestB);
            d.AddDataEventListener(OnDelegateDataChangeTestC);
            d.AddDataEventListener(OnDelegateDataChangeTestC);

            d.TestChangeData();
            d.TestChangeData();
            d.TestChangeData();

            my.ReadLine();

        }

        public static void OnDelegateDataChangeTestA(DelegateEventData e) {
            my.Trace("OnDelegateDataChangeTestA");
            my.Trace(e.data);
        }
        public static void OnDelegateDataChangeTestB(DelegateEventData e) {
            my.Trace("OnDelegateDataChangeTestB");
            my.Trace(e.data);
        }
        public static void OnDelegateDataChangeTestC(DelegateEventData e) {
            my.Trace("OnDelegateDataChangeTestC");
            my.Trace(e.data);
        }

        public static void OnDelegateDataChangeTestD(DelegateEventData e) {
            my.Trace("OnDelegateDataChangeTestD");
            my.Trace(e.data);
        }
    }
}
