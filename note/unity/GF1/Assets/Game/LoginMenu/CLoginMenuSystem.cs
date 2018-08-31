using Core;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CLoginMenuSystem : CAppSystem {
    private void Awake() {
    }

    // Use this for initialization
    void Start () {
        loginMenuView = null;

    }

    public void showLoginMenuView() {
        loginMenuView = AddComponent<CLoginMenuView>();
    }
    public void hideLoginMenuView() {
        RemoveComponent<CLoginMenuView>();
        loginMenuView = null;
    }

    public CLoginMenuView loginMenuView {
        get;
        private set;
    }
}
