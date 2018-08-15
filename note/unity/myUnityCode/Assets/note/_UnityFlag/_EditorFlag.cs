using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable] // 使该类可以在inspector中显示
public class _TestStructToDisplay {
    public string structName = "struct";
    public bool isOpen = false;
}
public class _EditorFlag : MonoBehaviour {
    public int m_intValue = 3;

    [SerializeField] // 即使是private也可以在inspector中显示
    private string m_strValue = "abc";

    [HideInInspector] // 即使是public 也不会在inspector中显示
    public int hp = 100;

    public _TestStructToDisplay m_struct;
}
