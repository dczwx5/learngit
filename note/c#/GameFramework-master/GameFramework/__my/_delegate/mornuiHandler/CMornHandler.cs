using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace __my._delegate.mornuiHandler
{
    // ===============================mornui Handlerʵ��===================================
    /// <summary>
    /// morn ui handler �ص�����
    /// </summary>
    public delegate void MornHandler(ArrayList args);

    /// <summary>
    /// ģ��mornui handler��
    /// </summary>
    public class CMornHandler {
        /// <summary>
        /// callback : MornHandler �ص�
        /// ArrayList : ������û�����
        /// </summary>
        public CMornHandler(MornHandler callback, ArrayList args = null) {
            m_handler = callback;
            m_args = args;
        }

        /// <summary>
        /// �������� ʹ��m_args����
        /// </summary>
        public void execute() {
            Invoke(m_args);
        }
        /// <summary>
        /// ��������
        /// data - ����Ĳ���
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
        /// �������ýӿ�, ������дΪ�������÷�ʽ, �����첽����
        /// </summary>
        protected virtual void Invoke(ArrayList args) {
            if (null != m_handler) {
                m_handler.Invoke(args);
            }
        }

        protected MornHandler m_handler;
        protected ArrayList m_args;
    }

    // ==================================ʹ��ʵ��==================================================

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
