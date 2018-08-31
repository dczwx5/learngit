using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DTScene : CDataTableBase {

    public string sceneName {
        get;
        private set;
    }

    public override void ParseDataRow(string dataRowText) {
        string[] text = dataRowText.Split(S_ColumnSplit, StringSplitOptions.None);
        int index = 0;
        Id = int.Parse(text[index++]);
        sceneName = text[index];
    }
}
