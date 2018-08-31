using UnityEngine;

namespace Core {

public class CBean : MonoBehaviour {

    public CAppSystem system {
        get;
        set;
    }

    private void OnDestroy() {
        system = null;
    }
}
}