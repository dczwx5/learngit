using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace __my._delegate.mornuiHandler
{
    // ===============================mornui Handler实现===================================
    /// <summary>
    /// morn ui handler 回调函数
    /// </summary>
    public delegate void MornHandler(ArrayList args);

    /// <summary>
    /// 模仿mornui handler类
    /// </summary>
    public class CMornHandler {
        /// <summary>
        /// callback : MornHandler 回调
        /// ArrayList : 传入的用户参数
        /// </summary>
        public CMornHandler(MornHandler callback, ArrayList args = null) {
            m_handler = callback;
            m_args = args;
        }

        /// <summary>
        /// 函数调用 使用m_args参数
        /// </summary>
        public void execute() {
            Invoke(m_args);
        }
        /// <summary>
        /// 函数调用
        /// data - 额外的参数
        /// </summary>
        public void execute(ArrayList data) {
            if (data == null) {
                execute();
                return;
            }
            if (null != m_handler) {
                ArrayList tempArgs;
                
                if (null != m_args) {
                    tempArgs = (ArrayList)m_args.Clone();
                    for (int i = 0; i < data.Count; i++) {
                        tempArgs.Add(data[i]);
                    }
                } else {
                    tempArgs = m_args;
                }
                Invoke(tempArgs);
            }
        }

        /// <summary>
        /// 函数调用接口, 可以重写为其他调用方式, 比如异步调用
        /// </summary>
        protected virtual void Invoke(ArrayList args) {
            if (null != m_handler) {
                m_handler.Invoke(args);
            }
        }

        protected MornHandler m_handler;
        protected ArrayList m_args;
    }

    // ==================================使用实例==================================================

    public class CMornHandlerUsage {
        public static void Usage() {
            ArrayList args = new ArrayList();
            args.Add(5);
            CMornHandler mornHandler = new CMornHandler(Callback, args);
            mornHandler.execute();

        }
        public static void Callback(ArrayList args) {
            my.Trace("Callback");
        }
         
    }


}
