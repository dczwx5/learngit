using Core;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CLobbySystem : CAppSystem {
    private void Awake() {
        
    }
    // Use this for initialization
    void Start () {
        lobbyView = null;
    }

    public void ShowLobbyView() {
        lobbyView = AddComponent<CLobbyView>();
    }
    public void HideLobbyView() {
        RemoveComponent<CLobbyView>();
        lobbyView = null;
    }

    public CLobbyView lobbyView {
        get;
        private set;
    }
}
