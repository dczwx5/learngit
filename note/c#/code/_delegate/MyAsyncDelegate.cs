using code._event;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace code._delegate {
    // ================================使用实例===============================================

    public class MyAsyncDelegateUsage {
        public static void Usage() {
            // listener 
            ArrayList args = new ArrayList();
            args.Add(5);
            // lisen event
            MyAsyncDelegate asyncDelegate = new MyAsyncDelegate(OnCallback, args, OnFinish);

            // dispatch dispatch event
            asyncDelegate.Invoke(new MyEventArgs());

        }
        // SyncDelegateHandlerFinish
        private static void OnFinish() {
            my.Trace("OnFinish");
        }
        // SyncDelegateHandler
        private static void OnCallback(MyEventArgs e, ArrayList args = null) {
            my.Trace("OnCallback");
        }
    }

    // ===================================异步delegate类============================================

    public delegate void SyncDelegateHandlerFinish();
    // e : 触发事件时, 发起来事件数据 - 派发事件方发起 - dispatcher 创建传入
    // args : 由监听方传入, 最后传回callback - 目的是可以从监听事件时传入一些参数, 回调时可以用到 - listener 创建传入
    public delegate void SyncDelegateHandler(MyEventArgs e, ArrayList args = null);
    class MyAsyncDelegate {
        public MyAsyncDelegate(SyncDelegateHandler handler, ArrayList args = null, SyncDelegateHandlerFinish onFinish = null) {
            m_handler = handler;
            m_args = args;
            m_onFinish = onFinish;
        }
        public void Invoke(MyEventArgs e) {
            IAsyncResult ret = m_handler.BeginInvoke(e, m_args, AsyncCallback, null);
            m_handler.EndInvoke(ret);
        }

        private void AsyncCallback(IAsyncResult ar) {
            if (m_onFinish != null) {
                m_onFinish.Invoke();
            }
        }

        private SyncDelegateHandler m_handler;
        private ArrayList m_args;
        private SyncDelegateHandlerFinish m_onFinish;
    }
}
