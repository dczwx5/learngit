using GameFramework.Procedure;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace Core {
    public class CProcedure : ProcedureBase {

        public CAppStage stage {
            get {
                if (null == m_stage) {
                    m_stage = GameObject.FindObjectOfType<CAppStage>();
                }
                return m_stage;
            }
        }
        private CAppStage m_stage;
    }
}
